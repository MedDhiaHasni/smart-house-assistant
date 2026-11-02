import { runtimeStore } from '../../../services/rule-engine/runtime-store';
import { processEvent, recordCommandResult, takePendingCommands } from '../../../services/rule-engine/rule-engine';
import { emitToChannel } from '../../../services/socket-server';
import { optionalTimestamp, parseEvent, record, requiredBoolean, requiredString } from './controller-utils';

export default {
  async simulatorEvent(ctx: any) {
    const event = parseEvent(ctx.request.body);
    const execution = processEvent(event);
    ctx.body = { data: { event, execution } };
  },

  async simulatorDeviceState(ctx: any) {
    const body = record(ctx.request.body, 'Device state request');
    const deviceId = requiredString(body['deviceId'], 'deviceId');
    const state = record(body['state'], 'state');
    runtimeStore.deviceStates[deviceId] = {
      ...runtimeStore.deviceStates[deviceId],
      ...state,
    };
    runtimeStore.simulatedNow = optionalTimestamp(body['occurredAt']) ?? runtimeStore.simulatedNow;
    const result = { deviceId, state: runtimeStore.deviceStates[deviceId], changedAt: runtimeStore.simulatedNow };
    runtimeStore.lastChanges[deviceId] = result;
    emitToChannel('devices', 'device:state', result);
    ctx.body = { data: result };
  },

  async simulatorBatch(ctx: any) {
    const body = record(ctx.request.body, 'Simulator batch');
    if (!Array.isArray(body['events'])) return ctx.badRequest('events must be an array.');
    const results = (body['events'] as unknown[]).map((item) =>
      processEvent(parseEvent(item)),
    );
    ctx.body = { data: results };
  },

  async simulatorCommands(ctx: any) {
    ctx.body = { data: takePendingCommands() };
  },

  async simulatorCommandResult(ctx: any) {
    const body = record(ctx.request.body, 'Command result');
    const result = recordCommandResult({
      commandId: requiredString(ctx.params.id, 'command id'),
      success: requiredBoolean(body['success'], 'success'),
      state: body['state'] as Record<string, unknown> | undefined,
      error: typeof body['error'] === 'string' ? body['error'] : undefined,
    });
    ctx.body = { data: result };
  },
};
