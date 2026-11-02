"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const runtime_store_1 = require("../../../services/rule-engine/runtime-store");
exports.default = ({ strapi }) => ({
    async rooms(ctx) {
        ctx.body = {
            data: await strapi.documents('api::room.room').findMany({
                populate: { devices: true },
            }),
        };
    },
    async devices(ctx) {
        ctx.body = {
            data: await strapi.documents('api::device.device').findMany({
                populate: { room: true },
            }),
        };
    },
    async routines(ctx) {
        ctx.body = {
            data: await strapi.documents('api::routine.routine').findMany(),
        };
    },
    async updateRoutine(ctx) {
        const body = ctx.request.body;
        if (typeof (body === null || body === void 0 ? void 0 : body.enabled) !== 'boolean') {
            return ctx.badRequest('enabled must be a boolean.');
        }
        ctx.body = {
            data: await strapi.documents('api::routine.routine').update({
                documentId: ctx.params.id,
                data: { enabled: body.enabled },
            }),
        };
    },
    async timeline(ctx) {
        const events = runtime_store_1.runtimeStore.events.map((event) => ({
            id: event.id,
            type: 'event',
            title: event.eventType,
            detail: JSON.stringify(event.payload),
            occurredAt: event.occurredAt,
        }));
        const executions = runtime_store_1.runtimeStore.executions.map((execution) => ({
            id: execution.id,
            type: 'execution',
            title: execution.status,
            detail: execution.trace.map((step) => step.message).join(' '),
            occurredAt: execution.simulatedAt,
        }));
        ctx.body = {
            data: [...events, ...executions].sort((left, right) => Date.parse(right.occurredAt) - Date.parse(left.occurredAt)),
        };
    },
});
