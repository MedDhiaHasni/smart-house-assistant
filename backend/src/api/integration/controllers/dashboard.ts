import { runtimeStore } from '../../../services/rule-engine/runtime-store';
import { energyTotals } from './controller-utils';

export default {
  async dashboardSummary(ctx: any) {
    ctx.body = {
      data: {
        mode: runtimeStore.activeMode,
        context: runtimeStore.context,
        climate: runtimeStore.deviceStates['living-room-heater'],
        energy: energyTotals(),
        devices: Object.entries(runtimeStore.deviceStates).map(
          ([id, state]) => ({ id, state }),
        ),
        activeRoutines: runtimeStore.rules.filter((rule) => rule.enabled).length,
        recentEvents: runtimeStore.events.slice(-20).reverse(),
        alerts: runtimeStore.alerts.slice(-20).reverse(),
      },
    };
  },

  async energySummary(ctx: any) {
    ctx.body = { data: energyTotals() };
  },
};
