# Simulator Integration

The simulator connects to Strapi through the `/api/sim/*` contract. HTTP responses use a `{ "data": ... }` envelope. Runtime event, execution, command, override, device-state, and alert state is currently held in memory; seed records for Strapi content types and roles are persisted in SQLite.

## Start the backend

From the repository root:

```powershell
Copy-Item backend\.env.example backend\.env
Set-Location backend
npm install
npm run seed
npm run start
```

Keep the `.env` file local and replace the template values with unique development secrets. The sample simulator reads `JWT_SECRET` from `backend/.env`; the Socket.IO server requires a valid JWT handshake token.

## Exercise the simulator

With Strapi running, from the repository root:

```powershell
node backend\scripts\sample-simulator.js
```

The script exercises:

1. A simulated `window.opened` event, priority resolution, queued device command, and acknowledgement.
2. Actual-versus-expected condition values in the execution trace.
3. Exception and active-override handling.
4. Retry, fallback, terminal failure, and alert creation.
5. Authenticated Socket.IO channel subscription, `command:new`, `command:result`, and reconnection.

Set `SMART_HOME_API_URL` to target a different API URL. Its default is `http://localhost:1337/api`.

## Endpoint contract

| Method | Path | Purpose |
|---|---|---|
| POST | `/api/sim/event` | Submit a simulator event and evaluate rules |
| POST | `/api/sim/device-state` | Update device state |
| POST | `/api/sim/context` | Update context variables |
| POST | `/api/sim/batch` | Submit a batch of events |
| GET | `/api/sim/commands` | Read queued commands |
| POST | `/api/sim/commands/:id/result` | Acknowledge or fail a command |

The app-facing API is documented in [API_CONTRACT.md](./API_CONTRACT.md). It includes dashboard/context summaries, rule validation and dry-run/conflicts, explanations, modes/overrides, device commands, emergency all-off, and energy summaries.

## Flutter Live mode

Run the app with an API URL reachable from the target device. Android emulators use `http://10.0.2.2:1337/api`; physical devices need the development machine's LAN IP. In Settings, choose Live mode and sign in with a Strapi Users & Permissions account assigned the Resident role.

The repository integration test checks parsing against a running backend:

```powershell
Set-Location mobile_app
flutter test --dart-define=LIVE_TEST_API_URL=http://localhost:1337/api test\live_repository_integration_test.dart
```

Live repository parsing and server-side Socket.IO reconnect behavior have been verified. A full authenticated Flutter UI/realtime interaction test is still outstanding; see [PROGRESS.md](./PROGRESS.md).
