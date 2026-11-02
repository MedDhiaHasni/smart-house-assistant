"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.validateRule = validateRule;
function validateRule(input) {
    const errors = [];
    if (input === null || typeof input !== 'object') {
        return { valid: false, errors: ['Rule must be an object.'] };
    }
    const rule = input;
    if (typeof rule['name'] !== 'string' || !rule['name'].trim()) {
        errors.push('Rule name is required.');
    }
    if (rule['trigger'] === null ||
        typeof rule['trigger'] !== 'object' ||
        typeof rule['trigger']['eventType'] !== 'string') {
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
