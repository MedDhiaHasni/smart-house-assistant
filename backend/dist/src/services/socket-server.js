"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.attachSocketServer = attachSocketServer;
exports.setCommandResultHandler = setCommandResultHandler;
exports.emitToChannel = emitToChannel;
exports.closeSocketServer = closeSocketServer;
const socket_io_1 = require("socket.io");
const jsonwebtoken_1 = __importDefault(require("jsonwebtoken"));
const channels = [
    'events',
    'devices',
    'executions',
    'alerts',
    'context',
    'commands',
];
let socketServer;
let commandResultHandler;
function attachSocketServer(httpServer) {
    var _a, _b;
    if (socketServer)
        return;
    const secret = process.env.JWT_SECRET;
    if (!secret)
        throw new Error('JWT_SECRET is required for Socket.IO auth.');
    socketServer = new socket_io_1.Server(httpServer, {
        cors: {
            origin: (_b = (_a = process.env.SOCKET_CORS_ORIGIN) === null || _a === void 0 ? void 0 : _a.split(',')) !== null && _b !== void 0 ? _b : '*',
            methods: ['GET', 'POST'],
        },
    });
    socketServer.use((socket, next) => {
        const rawToken = socket.handshake.auth['token'];
        const token = typeof rawToken === 'string'
            ? rawToken.replace(/^Bearer\s+/i, '')
            : '';
        if (!token)
            return next(new Error('Authentication token required.'));
        try {
            socket.data['claims'] = jsonwebtoken_1.default.verify(token, secret);
            next();
        }
        catch (error) {
            next(new Error(`Socket authentication failed: ${String(error)}`));
        }
    });
    socketServer.on('connection', (socket) => {
        for (const channel of channels)
            socket.join(channel);
        socket.emit('connection:ready', { channels });
        socket.on('command:result', async (payload, acknowledge) => {
            if (!commandResultHandler) {
                acknowledge === null || acknowledge === void 0 ? void 0 : acknowledge({ ok: false, error: 'Command result handler is unavailable.' });
                return;
            }
            if (!isCommandResult(payload)) {
                acknowledge === null || acknowledge === void 0 ? void 0 : acknowledge({ ok: false, error: 'Invalid command result payload.' });
                return;
            }
            const result = await commandResultHandler(payload);
            acknowledge === null || acknowledge === void 0 ? void 0 : acknowledge({ ok: true, result });
        });
    });
}
function setCommandResultHandler(handler) {
    commandResultHandler = handler;
}
function emitToChannel(channel, eventName, payload) {
    socketServer === null || socketServer === void 0 ? void 0 : socketServer.to(channel).emit(eventName, payload);
}
function closeSocketServer() {
    return new Promise((resolve, reject) => {
        if (!socketServer) {
            resolve();
            return;
        }
        socketServer.close((error) => {
            socketServer = undefined;
            if (error)
                reject(error);
            else
                resolve();
        });
    });
}
function isCommandResult(value) {
    if (value === null || typeof value !== 'object')
        return false;
    const result = value;
    return (typeof result['commandId'] === 'string' &&
        typeof result['success'] === 'boolean' &&
        (result['state'] === undefined ||
            (result['state'] !== null && typeof result['state'] === 'object')) &&
        (result['error'] === undefined || typeof result['error'] === 'string'));
}
