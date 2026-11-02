"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.default = {
    async index() {
        return {
            status: 'ok',
            mode: 'Home',
            summary: {
                climate: 21.4,
                energy: 6.3,
                security: 'Armed',
            },
            alerts: [],
            events: [],
            routines: [],
        };
    },
};
