"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const runtime_store_1 = require("../../../services/rule-engine/runtime-store");
const socket_server_1 = require("../../../services/socket-server");
const controller_utils_1 = require("./controller-utils");
const controller = {
    async context(ctx) {
        ctx.body = {
            data: Object.entries(runtime_store_1.runtimeStore.context).map(([key, value]) => ({
                key,
                value,
                source: 'simulator',
                observedAt: runtime_store_1.runtimeStore.simulatedNow,
            })),
        };
    },
    async updateContext(ctx) {
        const body = (0, controller_utils_1.record)(ctx.request.body, 'Context request');
        const values = body['values'];
        if (values !== undefined) {
            Object.assign(runtime_store_1.runtimeStore.context, (0, controller_utils_1.record)(values, 'values'));
        }
        else {
            const key = (0, controller_utils_1.requiredString)(body['key'], 'key');
            runtime_store_1.runtimeStore.context[key] = body['value'];
        }
        const result = {
            context: runtime_store_1.runtimeStore.context,
            observedAt: (0, controller_utils_1.optionalTimestamp)(body['observedAt']),
        };
        (0, socket_server_1.emitToChannel)('context', 'context:updated', result);
        ctx.body = { data: result };
    },
    async simulatorContext(ctx) {
        await controller.updateContext(ctx);
    },
};
exports.default = controller;
