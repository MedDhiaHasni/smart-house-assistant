# API contract

Base URL: `http://localhost:1337/api` (Android emulator: `http://10.0.2.2:1337/api`).

Custom responses use a `{ "data": ... }` envelope. Content-type records use Strapi v5 `documentId` values; the Flutter parsers accept both `documentId` and the engine's runtime `id`.

## Mobile and rule endpoints

| Method | Path | Purpose |
|---|---|---|
| GET | `/dashboard/summary` | Mode, context, climate/device state, energy totals, event and alert summaries |
| GET | `/rooms` | Persisted rooms with populated device relations |
| GET | `/devices` | Persisted devices and room relation |
| GET / PUT | `/routines`, `/routines/:id` | Read routines and update `enabled` |
| GET | `/timeline` | Recent simulator events and executions |
| GET / POST | `/context` | Read context variables or update `key`/`value` or `values` |
| GET / PUT | `/rules`, `/rules/:id` | Runtime rule list and enable/disable |
| POST | `/rules/validate` | Validate a rule definition |
| POST | `/rules/dry-run` | Evaluate `eventType`, optional `payload`, and optional `simulatedAt` without dispatch |
| GET | `/rules/conflicts` | List actions competing for the same device |
| GET | `/explain/:executionId` | Full execution trace |
| GET | `/explain/device/:deviceId/last-change` | Most recent device state change |
| GET / POST | `/modes` | Read active mode and set `{ "mode": "Away" }` |
| POST / DELETE | `/overrides`, `/overrides/:id` | Create or remove a time-bounded device override |
| POST | `/devices/:id/command` | Queue `{ "command": "...", "parameters": {} }` |
| POST | `/emergency/all-off` | Queue power-off commands for all known devices |
| GET | `/energy/summary` | Current kW and today's kWh totals |

## Simulator endpoints

| Method | Path | Purpose |
|---|---|---|
| POST | `/sim/event` | Process one event; response contains the event and execution |
| POST | `/sim/device-state` | Report a device state and publish a realtime update |
| POST | `/sim/context` | Update one or more context variables |
| POST | `/sim/batch` | Process an `events` array |
| GET | `/sim/commands` | Return queued commands and mark them sent |
| POST | `/sim/commands/:id/result` | Submit `{ "success": true, "state": {} }` or a failed result |

Events require `eventType`, JSON `payload`, and an ISO-8601 `occurredAt` timestamp. The engine uses that timestamp as simulated time for triggers, conditions, overrides, and traces.

## Socket.IO

Socket.IO is mounted at the backend origin. A valid Strapi JWT must be passed in the handshake auth field:

```javascript
io('http://localhost:1337', { auth: { token: jwt } });
```

Authenticated clients join `events`, `devices`, `executions`, `alerts`, `context`, and `commands`. Commands are published as `command:new`; acknowledgements are submitted as `command:result` and are broadcast back on that event.

`node backend/scripts/sample-simulator.js` runs the live HTTP and Socket.IO contract checks. The optional Flutter live integration test parses responses from a running backend with `LIVE_TEST_API_URL`.
