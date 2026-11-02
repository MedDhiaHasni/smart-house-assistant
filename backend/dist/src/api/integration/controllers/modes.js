"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const runtime_store_1 = require("../../../services/rule-engine/runtime-store");
const socket_server_1 = require("../../../services/socket-server");
const controller_utils_1 = require("./controller-utils");
exports.default = {
    async modes(ctx) {
        ctx.body = {
            data: {
                activeMode: runtime_store_1.runtimeStore.activeMode,
                modes: runtime_store_1.runtimeStore.modes,
                overrides: runtime_store_1.runtimeStore.overrides.filter((override) => override.active),
            },
        };
    },
    async setMode(ctx) {
        const mode = (0, controller_utils_1.requiredString)((0, controller_utils_1.record)(ctx.request.body, 'Mode request')['mode'], 'mode');
        if (!runtime_store_1.runtimeStore.modes.includes(mode))
            return ctx.badRequest('Unknown mode.');
        runtime_store_1.runtimeStore.activeMode = mode;
        (0, socket_server_1.emitToChannel)('context', 'mode:updated', { activeMode: mode });
        ctx.body = { data: { activeMode: mode } };
    },
    async createOverride(ctx) {
        var _a;
        const body = (0, controller_utils_1.record)(ctx.request.body, 'Override request');
        const override = {
            id: (0, runtime_store_1.createId)('override'),
            deviceId: (0, controller_utils_1.requiredString)(body['deviceId'], 'deviceId'),
            value: (0, controller_utils_1.jsonRecord)(body['value'], 'value'),
            startsAt: (_a = (0, controller_utils_1.optionalTimestamp)(body['startsAt'])) !== null && _a !== void 0 ? _a : runtime_store_1.runtimeStore.simulatedNow,
            expiresAt: (0, controller_utils_1.requiredTimestamp)(body['expiresAt'], 'expiresAt'),
            active: true,
        };
        runtime_store_1.runtimeStore.overrides.push(override);
        (0, socket_server_1.emitToChannel)('context', 'override:created', override);
        ctx.body = { data: override };
    },
    async deleteOverride(ctx) {
        const index = runtime_store_1.runtimeStore.overrides.findIndex((item) => item.id === ctx.params.id);
        if (index < 0)
            return ctx.notFound('Override not found.');
        const [override] = runtime_store_1.runtimeStore.overrides.splice(index, 1);
        (0, socket_server_1.emitToChannel)('context', 'override:deleted', { id: override.id });
        ctx.body = { data: { id: override.id, deleted: true } };
    },
};
