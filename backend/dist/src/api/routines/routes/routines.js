"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.default = {
    routes: [
        {
            method: 'GET',
            path: '/routines',
            handler: 'routines.index',
            config: { auth: false },
        },
    ],
};
