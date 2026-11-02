"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const runtime_store_1 = require("../../../services/rule-engine/runtime-store");
const rule_engine_1 = require("../../../services/rule-engine/rule-engine");
const socket_server_1 = require("../../../services/socket-server");
const controller_utils_1 = require("./controller-utils");
exports.default = {
    async validateRule(ctx) {
        var _a, _b;
        ctx.body = (0, rule_engine_1.validateRule)((_b = (_a = ctx.request.body) === null || _a === void 0 ? void 0 : _a.rule) !== null && _b !== void 0 ? _b : ctx.request.body);
    },
    async rules(ctx) {
        ctx.body = { data: runtime_store_1.runtimeStore.rules };
    },
    async updateRule(ctx) {
        var _a, _b;
        const rule = runtime_store_1.runtimeStore.rules.find((item) => item.id === ctx.params.id);
        if (!rule)
            return ctx.notFound('Rule not found.');
        const body = (0, controller_utils_1.record)((_b = (_a = ctx.request.body) === null || _a === void 0 ? void 0 : _a.data) !== null && _b !== void 0 ? _b : ctx.request.body, 'Rule update');
        if (typeof body['enabled'] !== 'boolean') {
            return ctx.badRequest('enabled must be a boolean.');
        }
        rule.enabled = body['enabled'];
        (0, socket_server_1.emitToChannel)('context', 'rule:updated', rule);
        ctx.body = { data: rule };
    },
    async dryRun(ctx) {
        const body = (0, controller_utils_1.record)(ctx.request.body, 'Dry-run request');
        const eventType = (0, controller_utils_1.requiredString)(body['eventType'], 'eventType');
        ctx.body = (0, rule_engine_1.dryRun)({
            eventType,
            payload: body['payload'],
            simulatedAt: (0, controller_utils_1.optionalTimestamp)(body['simulatedAt']),
        });
    },
    async conflicts(ctx) {
        const conflicts = [];
        for (let first = 0; first < runtime_store_1.runtimeStore.rules.length; first += 1) {
            for (let second = first + 1; second < runtime_store_1.runtimeStore.rules.length; second += 1) {
                const left = runtime_store_1.runtimeStore.rules[first];
                const right = runtime_store_1.runtimeStore.rules[second];
                for (const leftAction of left.actions) {
                    for (const rightAction of right.actions) {
                        if (leftAction.deviceId === rightAction.deviceId &&
                            (leftAction.command !== rightAction.command ||
                                JSON.stringify(leftAction.parameters) !==
                                    JSON.stringify(rightAction.parameters))) {
                            conflicts.push({
                                id: `${left.id}:${right.id}:${leftAction.deviceId}`,
                                deviceId: leftAction.deviceId,
                                rules: [left.name, right.name],
                                winningRule: left.priority >= right.priority ? left.name : right.name,
                                priority: Math.max(left.priority, right.priority),
                            });
                        }
                    }
                }
            }
        }
        ctx.body = { data: conflicts };
    },
};
