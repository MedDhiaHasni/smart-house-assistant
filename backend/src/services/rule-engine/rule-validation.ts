

export function validateRule(input: unknown): {
  valid: boolean;
  errors: string[];
} {
  const errors: string[] = [];
  if (input === null || typeof input !== 'object') {
    return { valid: false, errors: ['Rule must be an object.'] };
  }
  const rule = input as Record<string, unknown>;
  if (typeof rule['name'] !== 'string' || !rule['name'].trim()) {
    errors.push('Rule name is required.');
  }
  if (
    rule['trigger'] === null ||
    typeof rule['trigger'] !== 'object' ||
    typeof (rule['trigger'] as Record<string, unknown>)['eventType'] !== 'string'
  ) {
    errors.push('Rule trigger.eventType is required.');
  }
  if (!Array.isArray(rule['actions']) || rule['actions'].length === 0) {
    errors.push('Rule must define at least one action.');
  }
  if (typeof rule['priority'] !== 'number' || rule['priority'] < 0) {
    errors.push('Rule priority must be a non-negative number.');
  }
  return { valid: errors.length === 0, errors };
}
