"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.createManualCommand = createManualCommand;
exports.parseEvent = parseEvent;
exports.energyTotals = energyTotals;
exports.record = record;
exports.jsonRecord = jsonRecord;
exports.toJsonValue = toJsonValue;
exports.requiredString = requiredString;
exports.optionalString = optionalString;
exports.requiredBoolean = requiredBoolean;
exports.requiredTimestamp = requiredTimestamp;
exports.optionalTimestamp = optionalTimestamp;
const runtime_store_1 = require("../../../services/rule-engine/runtime-store");
const socket_server_1 = require("../../../services/socket-server");
function createManualCommand(deviceId, name, parameters) {
    if (!runtime_store_1.runtimeStore.deviceStates[deviceId]) {
        throw new Error(`Unknown device "${deviceId}".`);
    }
    const event = {
        id: (0, runtime_store_1.createId)('event'),
        eventType: 'manual.command',
        payload: { deviceId, command: name },
        source: 'api',
        occurredAt: runtime_store_1.runtimeStore.simulatedNow,
    };
    const execution = {
        id: (0, runtime_store_1.createId)('execution'),
        status: 'pending',
        event,
        simulatedAt: runtime_store_1.runtimeStore.simulatedNow,
        trace: [{ at: runtime_store_1.runtimeStore.simulatedNow, stage: 'manual', message: `Manual ${name} requested.` }],
        commandIds: [],
    };
    const command = {
        id: (0, runtime_store_1.createId)('command'),
        deviceId,
        command: name,
        parameters,
        status: 'queued',
        attempts: 0,
        maxRetries: 1,
        executionId: execution.id,
        ruleId: 'manual',
        priority: 1000,
    };
    execution.commandIds.push(command.id);
    runtime_store_1.runtimeStore.executions.push(execution);
    runtime_store_1.runtimeStore.commands.push(command);
    (0, socket_server_1.emitToChannel)('commands', 'command:new', command);
    return command;
}
function parseEvent(value) {
    var _a, _b, _c;
    const body = record(value, 'Event');
    return {
        id: (_a = optionalString(body['id'])) !== null && _a !== void 0 ? _a : (0, runtime_store_1.createId)('event'),
        eventType: requiredString(body['eventType'], 'eventType'),
        payload: jsonRecord((_b = body['payload']) !== null && _b !== void 0 ? _b : {}, 'payload'),
        source: (_c = optionalString(body['source'])) !== null && _c !== void 0 ? _c : 'simulator',
        occurredAt: requiredTimestamp(body['occurredAt'], 'occurredAt'),
    };
}
function energyTotals() {
    var _a, _b;
    const values = runtime_store_1.runtimeStore.energyReadings.map((item) => Number(item['value']));
    const current = (_a = values.at(-1)) !== null && _a !== void 0 ? _a : Number((_b = runtime_store_1.runtimeStore.context['energyKw']) !== null && _b !== void 0 ? _b : 3.2);
    return {
        currentKw: current,
        todayKwh: values.reduce((total, value) => total + value, 0) || 6.3,
    };
}
function record(value, name) {
    if (value === null || typeof value !== 'object' || Array.isArray(value)) {
        throw new Error(`${name} must be a JSON object.`);
    }
    return value;
}
function jsonRecord(value, name) {
    const source = record(value, name);
    const result = {};
    for (const [key, item] of Object.entries(source)) {
        result[key] = toJsonValue(item, `${name}.${key}`);
    }
    return result;
}
function toJsonValue(value, name) {
    if (value === null ||
        typeof value === 'string' ||
        typeof value === 'number' ||
        typeof value === 'boolean') {
        return value;
    }
    if (Array.isArray(value)) {
        return value.map((item, index) => toJsonValue(item, `${name}[${index}]`));
    }
    if (typeof value === 'object')
        return jsonRecord(value, name);
    throw new Error(`${name} must be JSON serializable.`);
}
function requiredString(value, name) {
    if (typeof value !== 'string' || value.trim().length === 0) {
        throw new Error(`${name} must be a non-empty string.`);
    }
    return value;
}
function optionalString(value) {
    return typeof value === 'string' && value.length ? value : undefined;
}
function requiredBoolean(value, name) {
    if (typeof value !== 'boolean')
        throw new Error(`${name} must be a boolean.`);
    return value;
}
function requiredTimestamp(value, name) {
    const timestamp = requiredString(value, name);
    if (!Number.isFinite(Date.parse(timestamp))) {
        throw new Error(`${name} must be a valid ISO timestamp.`);
    }
    return timestamp;
}
function optionalTimestamp(value) {
    if (value === undefined)
        return undefined;
    return requiredTimestamp(value, 'timestamp');
}
