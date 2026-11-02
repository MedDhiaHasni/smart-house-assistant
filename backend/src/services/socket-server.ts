import { Server, type Socket } from 'socket.io';
import jwt from 'jsonwebtoken';

type CommandResultHandler = (result: {
  commandId: string;
  success: boolean;
  state?: Record<string, unknown>;
  error?: string;
}) => Promise<unknown>;

const channels = [
  'events',
  'devices',
  'executions',
  'alerts',
  'context',
  'commands',
] as const;

let socketServer: Server | undefined;
let commandResultHandler: CommandResultHandler | undefined;

export function attachSocketServer(httpServer: NodeJS.EventEmitter): void {
  if (socketServer) return;
  const secret = process.env.JWT_SECRET;
  if (!secret) throw new Error('JWT_SECRET is required for Socket.IO auth.');

  socketServer = new Server(httpServer as never, {
    cors: {
      origin: process.env.SOCKET_CORS_ORIGIN?.split(',') ?? '*',
      methods: ['GET', 'POST'],
    },
  });
  socketServer.use((socket, next) => {
    const rawToken = socket.handshake.auth['token'];
    const token =
      typeof rawToken === 'string'
        ? rawToken.replace(/^Bearer\s+/i, '')
        : '';
    if (!token) return next(new Error('Authentication token required.'));
    try {
      socket.data['claims'] = jwt.verify(token, secret);
      next();
    } catch (error) {
      next(new Error(`Socket authentication failed: ${String(error)}`));
    }
  });
  socketServer.on('connection', (socket: Socket) => {
    for (const channel of channels) socket.join(channel);
    socket.emit('connection:ready', { channels });
    socket.on('command:result', async (payload: unknown, acknowledge?: (v: unknown) => void) => {
      if (!commandResultHandler) {
        acknowledge?.({ ok: false, error: 'Command result handler is unavailable.' });
        return;
      }
      if (!isCommandResult(payload)) {
        acknowledge?.({ ok: false, error: 'Invalid command result payload.' });
        return;
      }
      const result = await commandResultHandler(payload);
      acknowledge?.({ ok: true, result });
    });
  });
}

export function setCommandResultHandler(handler: CommandResultHandler): void {
  commandResultHandler = handler;
}

export function emitToChannel(
  channel: (typeof channels)[number],
  eventName: string,
  payload: unknown,
): void {
  socketServer?.to(channel).emit(eventName, payload);
}

export function closeSocketServer(): Promise<void> {
  return new Promise((resolve, reject) => {
    if (!socketServer) {
      resolve();
      return;
    }
    socketServer.close((error) => {
      socketServer = undefined;
      if (error) reject(error);
      else resolve();
    });
  });
}

function isCommandResult(value: unknown): value is Parameters<CommandResultHandler>[0] {
  if (value === null || typeof value !== 'object') return false;
  const result = value as Record<string, unknown>;
  return (
    typeof result['commandId'] === 'string' &&
    typeof result['success'] === 'boolean' &&
    (result['state'] === undefined ||
      (result['state'] !== null && typeof result['state'] === 'object')) &&
    (result['error'] === undefined || typeof result['error'] === 'string')
  );
}
