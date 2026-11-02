"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const runtime_store_1 = require("../../../services/rule-engine/runtime-store");
const rule_engine_1 = require("../../../services/rule-engine/rule-engine");
const socket_server_1 = require("../../../services/socket-server");
const controller_utils_1 = require("./controller-utils");
exports.default = {
    async simulatorEvent(ctx) {
        const event = (0, controller_utils_1.parseEvent)(ctx.request.body);
        const execution = (0, rule_engine_1.processEvent)(event);
        ctx.body = { data: { event, execution } };
    },
    async simulatorDeviceState(ctx) {
        var _a;
        const body = (0, controller_utils_1.record)(ctx.request.body, 'Device state request');
        const deviceId = (0, controller_utils_1.requiredString)(body['deviceId'], 'deviceId');
        const state = (0, controller_utils_1.record)(body['state'], 'state');
        runtime_store_1.runtimeStore.deviceStates[deviceId] = {
            ...runtime_store_1.runtimeStore.deviceStates[deviceId],
            ...state,
        };
        runtime_store_1.runtimeStore.simulatedNow = (_a = (0, controller_utils_1.optionalTimestamp)(body['occurredAt'])) !== null && _a !== void 0 ? _a : runtime_store_1.runtimeStore.simulatedNow;
        const result = { deviceId, state: runtime_store_1.runtimeStore.deviceStates[deviceId], changedAt: runtime_store_1.runtimeStore.simulatedNow };
        runtime_store_1.runtimeStore.lastChanges[deviceId] = result;
        (0, socket_server_1.emitToChannel)('devices', 'device:state', result);
        ctx.body = { data: result };
    },
    async simulatorBatch(ctx) {
        const body = (0, controller_utils_1.record)(ctx.request.body, 'Simulator batch');
        if (!Array.isArray(body['events']))
            return ctx.badRequest('events must be an array.');
        const results = body['events'].map((item) => (0, rule_engine_1.processEvent)((0, controller_utils_1.parseEvent)(item)));
        ctx.body = { data: results };
    },
    async simulatorCommands(ctx) {
        ctx.body = { data: (0, rule_engine_1.takePendingCommands)() };
    },
    async simulatorCommandResult(ctx) {
        const body = (0, controller_utils_1.record)(ctx.request.body, 'Command result');
        const result = (0, rule_engine_1.recordCommandResult)({
            commandId: (0, controller_utils_1.requiredString)(ctx.params.id, 'command id'),
            success: (0, controller_utils_1.requiredBoolean)(body['success'], 'success'),
            state: body['state'],
            error: typeof body['error'] === 'string' ? body['error'] : undefined,
        });
        ctx.body = { data: result };
    },
};
