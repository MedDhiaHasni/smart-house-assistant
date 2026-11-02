import { runtimeStore } from '../../../services/rule-engine/runtime-store';

export default {
  async explainExecution(ctx: any) {
    const execution = runtimeStore.executions.find(
      (item) => item.id === ctx.params.executionId,
    );
    if (!execution) return ctx.notFound('Execution not found.');
    ctx.body = { data: execution };
  },

  async explainDevice(ctx: any) {
    const change = runtimeStore.lastChanges[ctx.params.deviceId];
    if (!change) return ctx.notFound('No recorded device change.');
    ctx.body = { data: change };
  },
};
