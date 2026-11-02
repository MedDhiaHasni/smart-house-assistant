import { evaluateCondition } from './condition-evaluator';
import { runtimeStore } from './runtime-store';
import type {
  Condition,
  DeviceCommand,
  JsonValue,
  RuleAction,
  RuleDefinition,
  SimulatorEvent,
  TraceStep,
} from './types';

export interface DryRunInput {
  eventType: string;
  payload?: Record<string, unknown>;
  simulatedAt?: string;
}

export function dryRun(input: DryRunInput): {
  matchedRules: string[];
  trace: TraceStep[];
  commands: Array<Pick<DeviceCommand, 'deviceId' | 'command' | 'parameters'>>;
} {
  const simulatedAt = input.simulatedAt ?? runtimeStore.simulatedNow;
  assertTimestamp(simulatedAt);
  const event: SimulatorEvent = {
    id: 'dry-run',
    eventType: input.eventType,
    payload: (input.payload ?? {}) as SimulatorEvent['payload'],
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

export function evaluateRuleConditions(
  conditions: Condition[],
  context: Record<string, unknown>,
): boolean {
  return conditions.every((condition) => evaluateCondition(condition, context).matches);
}

export function evaluateEvent(event: SimulatorEvent): {
  matched: Array<{ rule: RuleDefinition; action: RuleAction }>;
  actions: Array<{ rule: RuleDefinition; action: RuleAction }>;
  trace: TraceStep[];
} {
  const trace: TraceStep[] = [];
  const matched: Array<{ rule: RuleDefinition; action: RuleAction }> = [];
  for (const rule of runtimeStore.rules.filter(
    (item) => item.enabled && item.trigger.eventType === event.eventType,
  )) {
    trace.push({
      at: event.occurredAt,
      stage: 'rule',
      message: `Evaluating ${rule.name}.`,
      ruleId: rule.id,
    });
    const conditionsPass = rule.conditions.every((condition) => {
      const result = evaluateCondition(condition, runtimeStore.context);
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
    if (!conditionsPass) continue;
    const excepted = rule.exceptions.some((condition) => {
      const result = evaluateCondition(condition, runtimeStore.context);
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
    if (excepted) continue;
    for (const action of rule.actions) {
      const overridden = runtimeStore.overrides.some(
        (override) =>
          override.deviceId === action.deviceId &&
          override.active &&
          new Date(override.startsAt) <= new Date(event.occurredAt) &&
          new Date(override.expiresAt) > new Date(event.occurredAt),
      );
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

  const byDevice = new Map<string, { rule: RuleDefinition; action: RuleAction }>();
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

export function assertTimestamp(value: string): void {
  if (!Number.isFinite(Date.parse(value))) {
    throw new Error(`Invalid simulated timestamp "${value}".`);
  }
}
