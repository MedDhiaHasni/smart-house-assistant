"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.processEvent = processEvent;
exports.takePendingCommands = takePendingCommands;
exports.recordCommandResult = recordCommandResult;
const socket_server_1 = require("../socket-server");
const rule_evaluation_1 = require("./rule-evaluation");
const runtime_store_1 = require("./runtime-store");
function processEvent(event) {
    var _a;
    (0, rule_evaluation_1.assertTimestamp)(event.occurredAt);
    runtime_store_1.runtimeStore.simulatedNow = event.occurredAt;
    runtime_store_1.runtimeStore.events.push(event);
    const { matched, actions, trace } = (0, rule_evaluation_1.evaluateEvent)(event);
    const execution = {
        id: (0, runtime_store_1.createId)('execution'),
        status: actions.length ? 'pending' : matched.length ? 'skipped' : 'skipped',
        event,
        simulatedAt: event.occurredAt,
        trace: [
            { at: event.occurredAt, stage: 'trigger', message: `Received ${event.eventType}.` },
            ...trace,
        ],
        commandIds: [],
    };
    for (const { rule, action } of actions) {
        const command = {
            id: (0, runtime_store_1.createId)('command'),
            deviceId: action.deviceId,
            command: action.command,
            parameters: action.parameters,
            status: 'queued',
            attempts: 0,
            maxRetries: (_a = action.maxRetries) !== null && _a !== void 0 ? _a : 1,
            fallback: action.fallback,
            executionId: execution.id,
            ruleId: rule.id,
            priority: rule.priority,
        };
        runtime_store_1.runtimeStore.commands.push(command);
        execution.commandIds.push(command.id);
        execution.trace.push({
            at: event.occurredAt,
            stage: 'command',
            message: `Queued ${command.command} for ${command.deviceId}.`,
            ruleId: rule.id,
            commandId: command.id,
        });
        (0, socket_server_1.emitToChannel)('commands', 'command:new', command);
    }
    runtime_store_1.runtimeStore.executions.push(execution);
    (0, socket_server_1.emitToChannel)('events', 'event:new', event);
    (0, socket_server_1.emitToChannel)('executions', 'execution:new', execution);
    return execution;
}
function takePendingCommands() {
    const commands = runtime_store_1.runtimeStore.commands.filter((command) => command.status === 'queued');
    for (const command of commands) {
        command.status = 'sent';
        command.attempts += 1;
    }
    return commands;
}
function recordCommandResult(result) {
    var _a, _b;
    const command = runtime_store_1.runtimeStore.commands.find((item) => item.id === result.commandId);
    if (!command)
        throw new Error(`Unknown command "${result.commandId}".`);
    const execution = runtime_store_1.runtimeStore.executions.find((item) => item.id === command.executionId);
    if (!execution)
        throw new Error(`Execution "${command.executionId}" is missing.`);
    if (command.status === 'succeeded' || command.status === 'failed') {
        throw new Error(`Command "${command.id}" already has a final result.`);
    }
    if (result.success) {
        command.status = 'succeeded';
        runtime_store_1.runtimeStore.deviceStates[command.deviceId] = {
            ...runtime_store_1.runtimeStore.deviceStates[command.deviceId],
            ...((_a = result.state) !== null && _a !== void 0 ? _a : command.parameters),
        };
        runtime_store_1.runtimeStore.lastChanges[command.deviceId] = {
            deviceId: command.deviceId,
            state: runtime_store_1.runtimeStore.deviceStates[command.deviceId],
            changedAt: runtime_store_1.runtimeStore.simulatedNow,
            commandId: command.id,
            executionId: execution.id,
        };
        execution.trace.push({
            at: runtime_store_1.runtimeStore.simulatedNow,
            stage: 'acknowledgement',
            message: `Command ${command.id} succeeded.`,
            commandId: command.id,
        });
        (0, socket_server_1.emitToChannel)('devices', 'device:state', runtime_store_1.runtimeStore.lastChanges[command.deviceId]);
    }
    else {
        command.error = (_b = result.error) !== null && _b !== void 0 ? _b : 'Simulator rejected command.';
        if (command.attempts <= command.maxRetries) {
            command.status = 'queued';
            execution.trace.push({
                at: runtime_store_1.runtimeStore.simulatedNow,
                stage: 'retry',
                message: `Attempt ${command.attempts} failed; command queued for retry.`,
                commandId: command.id,
            });
            (0, socket_server_1.emitToChannel)('commands', 'command:new', command);
        }
        else {
            command.status = 'failed';
            execution.trace.push({
                at: runtime_store_1.runtimeStore.simulatedNow,
                stage: 'failure',
                message: command.error,
                commandId: command.id,
            });
            applyFallbackOrAlert(command, execution);
        }
    }
    updateExecutionStatus(execution);
    (0, socket_server_1.emitToChannel)('commands', 'command:result', {
        ...result,
        command,
        executionId: execution.id,
    });
    (0, socket_server_1.emitToChannel)('executions', 'execution:updated', execution);
    return { command, execution };
}
function applyFallbackOrAlert(command, execution) {
    if (command.fallback) {
        const fallback = {
            ...command,
            id: (0, runtime_store_1.createId)('fallback'),
            command: command.fallback.command,
            parameters: command.fallback.parameters,
            status: 'queued',
            attempts: 0,
            maxRetries: 0,
            fallback: undefined,
        };
        runtime_store_1.runtimeStore.commands.push(fallback);
        execution.commandIds.push(fallback.id);
        execution.trace.push({
            at: runtime_store_1.runtimeStore.simulatedNow,
            stage: 'fallback',
            message: `Queued fallback ${fallback.command}.`,
            commandId: fallback.id,
            ruleId: command.ruleId,
        });
        (0, socket_server_1.emitToChannel)('commands', 'command:new', fallback);
        return;
    }
    const alert = {
        id: (0, runtime_store_1.createId)('alert'),
        severity: 'critical',
        title: 'Device command failed',
        message: `${command.command} failed for ${command.deviceId}: ${command.error}`,
        createdAt: runtime_store_1.runtimeStore.simulatedNow,
    };
    runtime_store_1.runtimeStore.alerts.push(alert);
    execution.trace.push({
        at: runtime_store_1.runtimeStore.simulatedNow,
        stage: 'alert',
        message: String(alert['message']),
        commandId: command.id,
    });
    (0, socket_server_1.emitToChannel)('alerts', 'alert:new', alert);
}
function updateExecutionStatus(execution) {
    const commands = runtime_store_1.runtimeStore.commands.filter((item) => execution.commandIds.includes(item.id));
    if (commands.some((item) => item.status === 'queued' || item.status === 'sent')) {
        execution.status = 'pending';
    }
    else if (commands.some((item) => item.status === 'failed')) {
        execution.status = 'failed';
    }
    else {
        execution.status = 'succeeded';
    }
}
