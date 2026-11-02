"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.dryRun = dryRun;
exports.evaluateRuleConditions = evaluateRuleConditions;
exports.evaluateEvent = evaluateEvent;
exports.assertTimestamp = assertTimestamp;
const condition_evaluator_1 = require("./condition-evaluator");
const runtime_store_1 = require("./runtime-store");
function dryRun(input) {
    var _a, _b;
    const simulatedAt = (_a = input.simulatedAt) !== null && _a !== void 0 ? _a : runtime_store_1.runtimeStore.simulatedNow;
    assertTimestamp(simulatedAt);
    const event = {
        id: 'dry-run',
        eventType: input.eventType,
        payload: ((_b = input.payload) !== null && _b !== void 0 ? _b : {}),
        source: 'dry-run',
        occurredAt: simulatedAt,
    };
    const evaluation = evaluateEvent(event);
    return {
        matchedRules: evaluation.matched.map(({ rule }) => rule.id),
        trace: evaluation.trace,
        commands: evaluation.actions.map(({ action }) => ({
            deviceId: action.deviceId,
            command: action.command,
            parameters: action.parameters,
        })),
    };
}
function evaluateRuleConditions(conditions, context) {
    return conditions.every((condition) => (0, condition_evaluator_1.evaluateCondition)(condition, context).matches);
}
function evaluateEvent(event) {
    const trace = [];
    const matched = [];
    for (const rule of runtime_store_1.runtimeStore.rules.filter((item) => item.enabled && item.trigger.eventType === event.eventType)) {
        trace.push({
            at: event.occurredAt,
            stage: 'rule',
            message: `Evaluating ${rule.name}.`,
            ruleId: rule.id,
        });
        const conditionsPass = rule.conditions.every((condition) => {
            const result = (0, condition_evaluator_1.evaluateCondition)(condition, runtime_store_1.runtimeStore.context);
            trace.push({
                at: event.occurredAt,
                stage: 'condition',
                message: `${condition.variable} ${condition.operator}: ${result.matches ? 'matched' : 'not matched'}.`,
                actual: result.actual,
                expected: condition.expected,
                ruleId: rule.id,
            });
            return result.matches;
        });
        if (!conditionsPass)
            continue;
        const excepted = rule.exceptions.some((condition) => {
            const result = (0, condition_evaluator_1.evaluateCondition)(condition, runtime_store_1.runtimeStore.context);
            trace.push({
                at: event.occurredAt,
                stage: 'exception',
                message: `${condition.variable} exception ${result.matches ? 'applied' : 'not applied'}.`,
                actual: result.actual,
                expected: condition.expected,
                ruleId: rule.id,
            });
            return result.matches;
        });
        if (excepted)
            continue;
        for (const action of rule.actions) {
            const overridden = runtime_store_1.runtimeStore.overrides.some((override) => override.deviceId === action.deviceId &&
                override.active &&
                new Date(override.startsAt) <= new Date(event.occurredAt) &&
                new Date(override.expiresAt) > new Date(event.occurredAt));
            if (overridden) {
                trace.push({
                    at: event.occurredAt,
                    stage: 'override',
                    message: `An active override prevents actions for ${action.deviceId}.`,
                    ruleId: rule.id,
                });
                continue;
            }
            matched.push({ rule, action });
        }
    }
    const byDevice = new Map();
    for (const candidate of matched.sort((a, b) => b.rule.priority - a.rule.priority)) {
        const winner = byDevice.get(candidate.action.deviceId);
        if (!winner) {
            byDevice.set(candidate.action.deviceId, candidate);
            continue;
        }
        trace.push({
            at: event.occurredAt,
            stage: 'priority',
            message: `${winner.rule.name} (priority ${winner.rule.priority}) wins over ${candidate.rule.name} (priority ${candidate.rule.priority}).`,
            ruleId: winner.rule.id,
        });
    }
    return { matched, actions: [...byDevice.values()], trace };
}
function assertTimestamp(value) {
    if (!Number.isFinite(Date.parse(value))) {
        throw new Error(`Invalid simulated timestamp "${value}".`);
    }
}
