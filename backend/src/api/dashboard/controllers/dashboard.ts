export default {
  async index(ctx: any) {
    ctx.body = {
      status: 'ok',
      mode: 'Home',
      summary: {
        climate: 21.4,
        temperatureLabel: '21.4°C',
        energy: 6.3,
        security: 'Armed',
        activeRoutines: 5,
      },
      alerts: [
        {
          id: 'bedroom-window',
          type: 'warning',
          title: 'Bedroom window open',
          message: 'Heating was blocked to avoid wasted energy and protect comfort rule.',
          timestamp: '2026-11-02T06:12:00Z',
        },
      ],
      events: [
        {
          id: 'evt-1',
          title: 'Heating optimized',
          severity: 'info',
          time: '2 min ago',
          description: 'Comfort rule adjusted to 21°C',
        },
        {
          id: 'evt-2',
          title: 'Bedroom window open',
          severity: 'warning',
          time: '18 min ago',
          description: 'Heating blocked for safety',
        },
      ],
      routines: [
        {
          id: 'good_morning',
          name: 'Good morning',
          trigger: '07:00 weekdays',
          enabled: true,
          health: 'OK',
        },
        {
          id: 'leaving_home',
          name: 'Leaving home',
          trigger: 'Last person leaves',
          enabled: true,
          health: 'Warning',
        },
      ],
    };
  },
};
