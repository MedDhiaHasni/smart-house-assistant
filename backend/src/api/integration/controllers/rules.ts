import { runtimeStore } from '../../../services/rule-engine/runtime-store';
import { dryRun, validateRule } from '../../../services/rule-engine/rule-engine';
import { emitToChannel } from '../../../services/socket-server';
import { optionalTimestamp, record, requiredString } from './controller-utils';

export default {
  async validateRule(ctx: any) {
    ctx.body = validateRule(ctx.request.body?.rule ?? ctx.request.body);
  },

  async rules(ctx: any) {
    ctx.body = { data: runtimeStore.rules };
  },

  async updateRule(ctx: any) {
    const rule = runtimeStore.rules.find((item) => item.id === ctx.params.id);
    if (!rule) return ctx.notFound('Rule not found.');
    const body = record(ctx.request.body?.data ?? ctx.request.body, 'Rule update');
    if (typeof body['enabled'] !== 'boolean') {
      return ctx.badRequest('enabled must be a boolean.');
    }
    rule.enabled = body['enabled'];
    emitToChannel('context', 'rule:updated', rule);
    ctx.body = { data: rule };
  },

  async dryRun(ctx: any) {
    const body = record(ctx.request.body, 'Dry-run request');
    const eventType = requiredString(body['eventType'], 'eventType');
    ctx.body = dryRun({
      eventType,
      payload: body['payload'] as Record<string, unknown> | undefined,
      simulatedAt: optionalTimestamp(body['simulatedAt']),
    });
  },

  async conflicts(ctx: any) {
    const conflicts = [];
    for (let first = 0; first < runtimeStore.rules.length; first += 1) {
      for (let second = first + 1; second < runtimeStore.rules.length; second += 1) {
        const left = runtimeStore.rules[first];
        const right = runtimeStore.rules[second];
        for (const leftAction of left.actions) {
          for (const rightAction of right.actions) {
            if (
              leftAction.deviceId === rightAction.deviceId &&
              (leftAction.command !== rightAction.command ||
                JSON.stringify(leftAction.parameters) !==
                  JSON.stringify(rightAction.parameters))
            ) {
              conflicts.push({
                id: `${left.id}:${right.id}:${leftAction.deviceId}`,
                deviceId: leftAction.deviceId,
                rules: [left.name, right.name],
                winningRule:
                  left.priority >= right.priority ? left.name : right.name,
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
