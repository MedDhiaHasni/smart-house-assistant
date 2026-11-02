import type { Condition, JsonValue } from './types';

export interface ConditionResult {
  matches: boolean;
  actual: JsonValue;
}

export function evaluateCondition(
  condition: Condition,
  context: Record<string, unknown>,
): ConditionResult {
  const actual = context[condition.variable];
  const expected = condition.expected;
  const matches = (() => {
    switch (condition.operator) {
      case 'equals':
        return actual === expected;
      case 'notEquals':
        return actual !== expected;
      case 'greaterThan':
        return typeof actual === 'number' &&
          typeof expected === 'number' &&
          actual > expected;
      case 'lessThan':
        return typeof actual === 'number' &&
          typeof expected === 'number' &&
          actual < expected;
      case 'isTrue':
        return actual === true;
      case 'isFalse':
        return actual === false;
    }
  })();
  return { matches, actual: toJsonValue(actual) };
}

function toJsonValue(value: unknown): JsonValue {
  if (
    value === null ||
    typeof value === 'string' ||
    typeof value === 'number' ||
    typeof value === 'boolean'
  ) {
    return value;
  }
  if (Array.isArray(value)) return value.map(toJsonValue);
  if (typeof value === 'object') {
    return Object.fromEntries(
      Object.entries(value).map(([key, item]) => [key, toJsonValue(item)]),
    );
  }
  return String(value);
}
