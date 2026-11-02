"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const seed_1 = require("./services/seed");
const command_processor_1 = require("./services/rule-engine/command-processor");
const socket_server_1 = require("./services/socket-server");
exports.default = {
    /**
     * An asynchronous register function that runs before
     * your application is initialized.
     *
     * This gives you an opportunity to extend code.
     */
    register( /* { strapi }: { strapi: Core.Strapi } */) { },
    /**
     * An asynchronous bootstrap function that runs before
     * your application gets started.
     *
     * This gives you an opportunity to set up your data model,
     * run jobs, or perform some special logic.
     */
    async bootstrap({ strapi }) {
        await (0, seed_1.seedDatabase)(strapi);
        if (process.env['SKIP_SOCKET_SERVER'] === 'true')
            return;
        if (!strapi.server.httpServer) {
            throw new Error('Strapi HTTP server must exist before Socket.IO is attached.');
        }
        (0, socket_server_1.attachSocketServer)(strapi.server.httpServer);
        (0, socket_server_1.setCommandResultHandler)(async (result) => (0, command_processor_1.recordCommandResult)(result));
    },
    async destroy() {
        await (0, socket_server_1.closeSocketServer)();
    },
};
