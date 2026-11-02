"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.default = {
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
