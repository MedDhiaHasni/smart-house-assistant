// import type { Core } from '@strapi/strapi';
import type { Core } from '@strapi/strapi';

import { seedDatabase } from './services/seed';
import { recordCommandResult } from './services/rule-engine/command-processor';
import { attachSocketServer, closeSocketServer, setCommandResultHandler } from './services/socket-server';

export default {
  /**
   * An asynchronous register function that runs before
   * your application is initialized.
   *
   * This gives you an opportunity to extend code.
   */
  register(/* { strapi }: { strapi: Core.Strapi } */) {},

  /**
   * An asynchronous bootstrap function that runs before
   * your application gets started.
   *
   * This gives you an opportunity to set up your data model,
   * run jobs, or perform some special logic.
   */
  async bootstrap({ strapi }: { strapi: Core.Strapi }) {
    await seedDatabase(strapi);
    if (process.env['SKIP_SOCKET_SERVER'] === 'true') return;
    if (!strapi.server.httpServer) {
      throw new Error('Strapi HTTP server must exist before Socket.IO is attached.');
    }
    attachSocketServer(strapi.server.httpServer);
    setCommandResultHandler(async (result) => recordCommandResult(result));
  },

  async destroy() {
    await closeSocketServer();
  },
};
