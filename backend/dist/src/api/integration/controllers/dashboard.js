"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const runtime_store_1 = require("../../../services/rule-engine/runtime-store");
const controller_utils_1 = require("./controller-utils");
exports.default = {
    async dashboardSummary(ctx) {
        ctx.body = {
            data: {
                mode: runtime_store_1.runtimeStore.activeMode,
                context: runtime_store_1.runtimeStore.context,
                climate: runtime_store_1.runtimeStore.deviceStates['living-room-heater'],
                energy: (0, controller_utils_1.energyTotals)(),
                devices: Object.entries(runtime_store_1.runtimeStore.deviceStates).map(([id, state]) => ({ id, state })),
                activeRoutines: runtime_store_1.runtimeStore.rules.filter((rule) => rule.enabled).length,
                recentEvents: runtime_store_1.runtimeStore.events.slice(-20).reverse(),
                alerts: runtime_store_1.runtimeStore.alerts.slice(-20).reverse(),
            },
        };
    },
    async energySummary(ctx) {
        ctx.body = { data: (0, controller_utils_1.energyTotals)() };
    },
};
