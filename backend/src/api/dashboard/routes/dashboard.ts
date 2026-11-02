export default {
  routes: [
    {
      method: 'GET',
      path: '/dashboard',
      handler: 'dashboard.index',
      config: {
        auth: false,
      },
    },
  ],
};
