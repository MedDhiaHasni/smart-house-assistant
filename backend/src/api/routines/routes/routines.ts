export default {
  routes: [
    {
      method: 'GET',
      path: '/routines',
      handler: 'routines.index',
      config: { auth: false },
    },
  ],
};
