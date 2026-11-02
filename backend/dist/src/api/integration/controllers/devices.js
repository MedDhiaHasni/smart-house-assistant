"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const runtime_store_1 = require("../../../services/rule-engine/runtime-store");
const controller_utils_1 = require("./controller-utils");
exports.default = {
    async deviceCommand(ctx) {
        var _a;
        const body = (0, controller_utils_1.record)(ctx.request.body, 'Device command request');
        const command = (0, controller_utils_1.createManualCommand)((0, controller_utils_1.requiredString)(ctx.params.id, 'device id'), (0, controller_utils_1.requiredString)(body['command'], 'command'), (0, controller_utils_1.jsonRecord)((_a = body['parameters']) !== null && _a !== void 0 ? _a : {}, 'parameters'));
        ctx.body = { data: command };
    },
    async emergencyAllOff(ctx) {
        const commands = Object.keys(runtime_store_1.runtimeStore.deviceStates).map((deviceId) => (0, controller_utils_1.createManualCommand)(deviceId, 'power_off', {}));
        ctx.body = { data: { commands, queued: commands.length } };
    },
};
