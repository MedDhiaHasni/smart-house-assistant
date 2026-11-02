import { emitToChannel } from '../socket-server';
import { evaluateEvent, assertTimestamp } from './rule-evaluation';
import { createId, runtimeStore } from './runtime-store';
import type { DeviceCommand, Execution, SimulatorEvent } from './types';

export function processEvent(event: SimulatorEvent): Execution {
  assertTimestamp(event.occurredAt);
  runtimeStore.simulatedNow = event.occurredAt;
  runtimeStore.events.push(event);
  const { matched, actions, trace } = evaluateEvent(event);
  const execution: Execution = {
    id: createId('execution'),
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
    const command: DeviceCommand = {
      id: createId('command'),
      deviceId: action.deviceId,
      command: action.command,
      parameters: action.parameters,
      status: 'queued',
      attempts: 0,
      maxRetries: action.maxRetries ?? 1,
      fallback: action.fallback,
      executionId: execution.id,
      ruleId: rule.id,
      priority: rule.priority,
    };
    runtimeStore.commands.push(command);
    execution.commandIds.push(command.id);
    execution.trace.push({
      at: event.occurredAt,
      stage: 'command',
      message: `Queued ${command.command} for ${command.deviceId}.`,
      ruleId: rule.id,
      commandId: command.id,
    });
    emitToChannel('commands', 'command:new', command);
  }
  runtimeStore.executions.push(execution);
  emitToChannel('events', 'event:new', event);
  emitToChannel('executions', 'execution:new', execution);
  return execution;
}

export function takePendingCommands(): DeviceCommand[] {
  const commands = runtimeStore.commands.filter(
    (command) => command.status === 'queued',
  );
  for (const command of commands) {
    command.status = 'sent';
    command.attempts += 1;
  }
  return commands;
}

export function recordCommandResult(result: {
  commandId: string;
  success: boolean;
  state?: Record<string, unknown>;
  error?: string;
}): { command: DeviceCommand; execution: Execution } {
  const command = runtimeStore.commands.find(
    (item) => item.id === result.commandId,
  );
  if (!command) throw new Error(`Unknown command "${result.commandId}".`);
  const execution = runtimeStore.executions.find(
    (item) => item.id === command.executionId,
  );
  if (!execution) throw new Error(`Execution "${command.executionId}" is missing.`);
  if (command.status === 'succeeded' || command.status === 'failed') {
    throw new Error(`Command "${command.id}" already has a final result.`);
  }

  if (result.success) {
    command.status = 'succeeded';
    runtimeStore.deviceStates[command.deviceId] = {
      ...runtimeStore.deviceStates[command.deviceId],
      ...(result.state ?? command.parameters),
    };
    runtimeStore.lastChanges[command.deviceId] = {
      deviceId: command.deviceId,
      state: runtimeStore.deviceStates[command.deviceId],
      changedAt: runtimeStore.simulatedNow,
      commandId: command.id,
      executionId: execution.id,
    };
    execution.trace.push({
      at: runtimeStore.simulatedNow,
      stage: 'acknowledgement',
      message: `Command ${command.id} succeeded.`,
      commandId: command.id,
    });
    emitToChannel('devices', 'device:state', runtimeStore.lastChanges[command.deviceId]);
  } else {
    command.error = result.error ?? 'Simulator rejected command.';
    if (command.attempts <= command.maxRetries) {
      command.status = 'queued';
      execution.trace.push({
        at: runtimeStore.simulatedNow,
        stage: 'retry',
        message: `Attempt ${command.attempts} failed; command queued for retry.`,
        commandId: command.id,
      });
      emitToChannel('commands', 'command:new', command);
    } else {
      command.status = 'failed';
      execution.trace.push({
        at: runtimeStore.simulatedNow,
        stage: 'failure',
        message: command.error,
        commandId: command.id,
      });
      applyFallbackOrAlert(command, execution);
    }
  }

  updateExecutionStatus(execution);
  emitToChannel('commands', 'command:result', {
    ...result,
    command,
    executionId: execution.id,
  });
  emitToChannel('executions', 'execution:updated', execution);
  return { command, execution };
}

function applyFallbackOrAlert(command: DeviceCommand, execution: Execution): void {
  if (command.fallback) {
    const fallback: DeviceCommand = {
      ...command,
      id: createId('fallback'),
      command: command.fallback.command,
      parameters: command.fallback.parameters,
      status: 'queued',
      attempts: 0,
      maxRetries: 0,
      fallback: undefined,
    };
    runtimeStore.commands.push(fallback);
    execution.commandIds.push(fallback.id);
    execution.trace.push({
      at: runtimeStore.simulatedNow,
      stage: 'fallback',
      message: `Queued fallback ${fallback.command}.`,
      commandId: fallback.id,
      ruleId: command.ruleId,
    });
    emitToChannel('commands', 'command:new', fallback);
    return;
  }
  const alert = {
    id: createId('alert'),
    severity: 'critical',
    title: 'Device command failed',
    message: `${command.command} failed for ${command.deviceId}: ${command.error}`,
    createdAt: runtimeStore.simulatedNow,
  };
  runtimeStore.alerts.push(alert);
  execution.trace.push({
    at: runtimeStore.simulatedNow,
    stage: 'alert',
    message: String(alert['message']),
    commandId: command.id,
  });
  emitToChannel('alerts', 'alert:new', alert);
}

function updateExecutionStatus(execution: Execution): void {
  const commands = runtimeStore.commands.filter((item) =>
    execution.commandIds.includes(item.id),
  );
  if (commands.some((item) => item.status === 'queued' || item.status === 'sent')) {
    execution.status = 'pending';
  } else if (commands.some((item) => item.status === 'failed')) {
    execution.status = 'failed';
  } else {
    execution.status = 'succeeded';
  }
}
