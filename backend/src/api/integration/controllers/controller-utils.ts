import { createId, runtimeStore } from '../../../services/rule-engine/runtime-store';
import { emitToChannel } from '../../../services/socket-server';
import type { DeviceCommand, Execution, JsonValue, SimulatorEvent } from '../../../services/rule-engine/types';

export function createManualCommand(
  deviceId: string,
  name: string,
  parameters: Record<string, JsonValue>,
): DeviceCommand {
  if (!runtimeStore.deviceStates[deviceId]) {
    throw new Error(`Unknown device "${deviceId}".`);
  }
  const event: SimulatorEvent = {
    id: createId('event'),
    eventType: 'manual.command',
    payload: { deviceId, command: name },
    source: 'api',
    occurredAt: runtimeStore.simulatedNow,
  };
  const execution: Execution = {
    id: createId('execution'),
    status: 'pending',
    event,
    simulatedAt: runtimeStore.simulatedNow,
    trace: [{ at: runtimeStore.simulatedNow, stage: 'manual', message: `Manual ${name} requested.` }],
    commandIds: [],
  };
  const command: DeviceCommand = {
    id: createId('command'),
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
  runtimeStore.executions.push(execution);
  runtimeStore.commands.push(command);
  emitToChannel('commands', 'command:new', command);
  return command;
}

export function parseEvent(value: unknown): SimulatorEvent {
  const body = record(value, 'Event');
  return {
    id: optionalString(body['id']) ?? createId('event'),
    eventType: requiredString(body['eventType'], 'eventType'),
    payload: jsonRecord(body['payload'] ?? {}, 'payload'),
    source: optionalString(body['source']) ?? 'simulator',
    occurredAt: requiredTimestamp(body['occurredAt'], 'occurredAt'),
  } as SimulatorEvent;
}

export function energyTotals(): Record<string, number> {
  const values = runtimeStore.energyReadings.map((item) => Number(item['value']));
  const current = values.at(-1) ?? Number(runtimeStore.context['energyKw'] ?? 3.2);
  return {
    currentKw: current,
    todayKwh: values.reduce((total, value) => total + value, 0) || 6.3,
  };
}

export function record(value: unknown, name: string): Record<string, unknown> {
  if (value === null || typeof value !== 'object' || Array.isArray(value)) {
    throw new Error(`${name} must be a JSON object.`);
  }
  return value as Record<string, unknown>;
}

export function jsonRecord(value: unknown, name: string): Record<string, JsonValue> {
  const source = record(value, name);
  const result: Record<string, JsonValue> = {};
  for (const [key, item] of Object.entries(source)) {
    result[key] = toJsonValue(item, `${name}.${key}`);
  }
  return result;
}

export function toJsonValue(value: unknown, name: string): JsonValue {
  if (
    value === null ||
    typeof value === 'string' ||
    typeof value === 'number' ||
    typeof value === 'boolean'
  ) {
    return value;
  }
  if (Array.isArray(value)) {
    return value.map((item, index) => toJsonValue(item, `${name}[${index}]`));
  }
  if (typeof value === 'object') return jsonRecord(value, name);
  throw new Error(`${name} must be JSON serializable.`);
}

export function requiredString(value: unknown, name: string): string {
  if (typeof value !== 'string' || value.trim().length === 0) {
    throw new Error(`${name} must be a non-empty string.`);
  }
  return value;
}

export function optionalString(value: unknown): string | undefined {
  return typeof value === 'string' && value.length ? value : undefined;
}

export function requiredBoolean(value: unknown, name: string): boolean {
  if (typeof value !== 'boolean') throw new Error(`${name} must be a boolean.`);
  return value;
}

export function requiredTimestamp(value: unknown, name: string): string {
  const timestamp = requiredString(value, name);
  if (!Number.isFinite(Date.parse(timestamp))) {
    throw new Error(`${name} must be a valid ISO timestamp.`);
  }
  return timestamp;
}

export function optionalTimestamp(value: unknown): string | undefined {
  if (value === undefined) return undefined;
  return requiredTimestamp(value, 'timestamp');
}
