import type { Core } from '@strapi/strapi';
import { runtimeStore } from '../../../services/rule-engine/runtime-store';

export default ({ strapi }: { strapi: Core.Strapi }) => ({
  async rooms(ctx: any) {
    ctx.body = {
      data: await strapi.documents('api::room.room').findMany({
        populate: { devices: true },
      }),
    };
  },

  async devices(ctx: any) {
    ctx.body = {
      data: await strapi.documents('api::device.device').findMany({
        populate: { room: true },
      }),
    };
  },

  async routines(ctx: any) {
    ctx.body = {
      data: await strapi.documents('api::routine.routine').findMany(),
    };
  },

  async updateRoutine(ctx: any) {
    const body = ctx.request.body;
    if (typeof body?.enabled !== 'boolean') {
      return ctx.badRequest('enabled must be a boolean.');
    }
    ctx.body = {
      data: await strapi.documents('api::routine.routine').update({
        documentId: ctx.params.id,
        data: { enabled: body.enabled },
      }),
    };
  },

  async timeline(ctx: any) {
    const events = runtimeStore.events.map((event) => ({
      id: event.id,
      type: 'event',
      title: event.eventType,
      detail: JSON.stringify(event.payload),
      occurredAt: event.occurredAt,
    }));
    const executions = runtimeStore.executions.map((execution) => ({
      id: execution.id,
      type: 'execution',
      title: execution.status,
      detail: execution.trace.map((step) => step.message).join(' '),
      occurredAt: execution.simulatedAt,
    }));
    ctx.body = {
      data: [...events, ...executions].sort(
        (left, right) =>
          Date.parse(right.occurredAt) - Date.parse(left.occurredAt),
      ),
    };
  },
});
