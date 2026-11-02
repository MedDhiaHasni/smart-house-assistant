# Smart House Assistant

Flutter smart-home dashboard backed by Strapi v5. The mobile app supports Mock mode for an offline demo and Live mode for the Strapi REST and Socket.IO contract.

## Repository structure

- `mobile_app/`: Flutter app, Riverpod state, named GoRouter routes, feature screens and data repositories
- [`backend/`](./backend/README.md): Strapi v5, SQLite development database, simulator contract, rule engine and Socket.IO server
- `docs/`: architecture, API contract, simulator instructions and progress audit

## Run the backend

> Detailed Strapi setup (environment variables, roles, API tokens, seed): see [backend/README.md](./backend/README.md).

From the repository root, create a local environment file from the safe template and replace every placeholder with a unique local value:

```powershell
Copy-Item backend\.env.example backend\.env
Set-Location backend
npm install
npm run seed
npm run start
```

Strapi listens on `http://localhost:1337`. `npm run seed` builds the project and idempotently seeds content types and the Admin, Resident, and Simulator roles. `npm run develop` is available for backend development.

To exercise the simulator and Socket.IO contract while Strapi is running, run from the repository root:

```powershell
node backend\scripts\sample-simulator.js
```

The script exercises rule triggers and conditions, exception and override handling, priority selection, command acknowledgements, retry/fallback/alert behavior, authenticated Socket.IO commands, and reconnection. Set `SMART_HOME_API_URL` to use a non-default API URL.

## Run the Flutter app

```powershell
Set-Location mobile_app
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:1337/api
```

Use `http://10.0.2.2:1337/api` for the Android emulator. For a physical device, replace `10.0.2.2` with the development machine's LAN IP and ensure both devices can reach port 1337. Other platforms can use `http://localhost:1337/api`.

The app starts in Mock mode. Switch to Live mode in Settings to use the remote repositories and authenticated Socket.IO stream. Live sign-in requires a Strapi Users & Permissions account; create or assign one the Resident role in the Strapi admin panel. Demo mode does not require the backend.

## Validation

```powershell
Set-Location mobile_app
flutter analyze
flutter test
```

The live repository integration test runs against a started backend when `LIVE_TEST_API_URL` is provided:

```powershell
flutter test --dart-define=LIVE_TEST_API_URL=http://localhost:1337/api
```

## Documentation

- [Backend setup (Strapi)](./backend/README.md)
- [API contract](./docs/API_CONTRACT.md)
- [Simulator integration](./docs/SIMULATOR_INTEGRATION.md)
- [Architecture](./docs/ARCHITECTURE.md)
