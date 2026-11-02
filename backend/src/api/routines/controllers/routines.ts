export default {
  async index(ctx: any) {
    ctx.body = {
      status: 'ok',
      data: [
        {
          id: 'good_morning',
          name: 'Good morning',
          trigger: '07:00 weekdays',
          enabled: true,
          health: 'OK',
          flow: [
            'Trigger: time = 07:00 on weekdays',
            'Conditions: home occupancy > 0, weather = clear',
            'Actions: open shutters, kitchen lights on, set heating to 21°C',
            'Exception: guest mode disables action',
          ],
        },
        {
          id: 'eco_saver',
          name: 'Eco saver',
          trigger: 'Peak hours',
          enabled: true,
          health: 'OK',
          flow: [
            'Trigger: energy > threshold',
            'Conditions: high consumption',
            'Actions: suspend non-essential devices',
          ],
        },
      ],
    };
  },
};
