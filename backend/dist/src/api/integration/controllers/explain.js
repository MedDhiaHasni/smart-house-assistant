"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const runtime_store_1 = require("../../../services/rule-engine/runtime-store");
exports.default = {
    async explainExecution(ctx) {
        const execution = runtime_store_1.runtimeStore.executions.find((item) => item.id === ctx.params.executionId);
        if (!execution)
            return ctx.notFound('Execution not found.');
        ctx.body = { data: execution };
    },
    async explainDevice(ctx) {
        const change = runtime_store_1.runtimeStore.lastChanges[ctx.params.deviceId];
        if (!change)
            return ctx.notFound('No recorded device change.');
        ctx.body = { data: change };
    },
};
