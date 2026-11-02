# Known Limitations

- The backend rule-engine runtime (including events, executions, commands, overrides, device states, and alerts) is in memory and resets when Strapi restarts. Seeded Strapi content records use SQLite.
- The seed does not provision a demo Users & Permissions login. Live sign-in requires a locally created user assigned the Resident role.
- The backend is a simulator contract and demo rule engine, not a production hardware/device orchestration service.
- The Flutter Mock/Live repository switch is centralized and remote repository parsing is integration-tested, but an authenticated full-screen Live-mode flow and Flutter realtime/reconnect UI test have not been completed.
- Climate adapts the selected rooms repository and Settings persists preferences, but some legacy DTOs remain coupled to presentation code and not every visible string/spacing/color uses localization or design tokens.
- The root workspace has no Git metadata; only `backend/` is a nested Git repository. Root-level commits cannot capture Flutter/docs changes.
- `npm install` reported 42 dependency audit findings (1 low, 16 moderate, 25 high). No automated breaking or forced dependency upgrade was performed.
