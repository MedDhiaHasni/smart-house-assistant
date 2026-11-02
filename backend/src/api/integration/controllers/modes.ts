import { createId, runtimeStore } from '../../../services/rule-engine/runtime-store';
import { emitToChannel } from '../../../services/socket-server';
import { jsonRecord, optionalTimestamp, record, requiredString, requiredTimestamp } from './controller-utils';

export default {
  async modes(ctx: any) {
    ctx.body = {
      data: {
        activeMode: runtimeStore.activeMode,
        modes: runtimeStore.modes,
        overrides: runtimeStore.overrides.filter((override) => override.active),
      },
    };
  },

  async setMode(ctx: any) {
    const mode = requiredString(record(ctx.request.body, 'Mode request')['mode'], 'mode');
    if (!runtimeStore.modes.includes(mode)) return ctx.badRequest('Unknown mode.');
    runtimeStore.activeMode = mode;
    emitToChannel('context', 'mode:updated', { activeMode: mode });
    ctx.body = { data: { activeMode: mode } };
  },

  async createOverride(ctx: any) {
    const body = record(ctx.request.body, 'Override request');
    const override = {
      id: createId('override'),
      deviceId: requiredString(body['deviceId'], 'deviceId'),
      value: jsonRecord(body['value'], 'value'),
      startsAt: optionalTimestamp(body['startsAt']) ?? runtimeStore.simulatedNow,
      expiresAt: requiredTimestamp(body['expiresAt'], 'expiresAt'),
      active: true,
    };
    runtimeStore.overrides.push(override);
    emitToChannel('context', 'override:created', override);
    ctx.body = { data: override };
  },

  async deleteOverride(ctx: any) {
    const index = runtimeStore.overrides.findIndex(
      (item) => item.id === ctx.params.id,
    );
    if (index < 0) return ctx.notFound('Override not found.');
    const [override] = runtimeStore.overrides.splice(index, 1);
    emitToChannel('context', 'override:deleted', { id: override.id });
    ctx.body = { data: { id: override.id, deleted: true } };
  },
};
