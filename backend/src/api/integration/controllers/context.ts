import { runtimeStore } from '../../../services/rule-engine/runtime-store';
import { emitToChannel } from '../../../services/socket-server';
import { optionalTimestamp, record, requiredString } from './controller-utils';

const controller = {
  async context(ctx: any) {
    ctx.body = {
      data: Object.entries(runtimeStore.context).map(([key, value]) => ({
        key,
        value,
        source: 'simulator',
        observedAt: runtimeStore.simulatedNow,
      })),
    };
  },

  async updateContext(ctx: any) {
    const body = record(ctx.request.body, 'Context request');
    const values = body['values'];
    if (values !== undefined) {
      Object.assign(runtimeStore.context, record(values, 'values'));
    } else {
      const key = requiredString(body['key'], 'key');
      runtimeStore.context[key] = body['value'];
    }
    const result = {
      context: runtimeStore.context,
      observedAt: optionalTimestamp(body['observedAt']),
    };
    emitToChannel('context', 'context:updated', result);
    ctx.body = { data: result };
  },

  async simulatorContext(ctx: any) {
    await controller.updateContext(ctx);
  },
};

export default controller;
