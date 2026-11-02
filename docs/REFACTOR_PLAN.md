# Mobile App Refactor Plan

## Audit results

The legacy starting point had a 1,715-line `mobile_app/lib/main.dart` containing app setup, navigation, screens, shared widgets, mock entities/data, and service providers. The current source audit measured:

| Check | Result |
|---|---:|
| Dart files under `mobile_app/lib` | 121 |
| Screen files named `*_screen.dart` | 18 |
| `mobile_app/lib/main.dart` | 17 lines |
| Dart files over 300 lines | 0 |

The original monolith's contents have been moved as follows:

| Old location in `main.dart` | New location |
|---|---|
| `main()` | `mobile_app/lib/main.dart` |
| App widget and GoRouter routes | `mobile_app/lib/app/app.dart`, `mobile_app/lib/app/router/` |
| App-wide providers and Mock/Live selection | `mobile_app/lib/app/di/providers.dart` |
| Theme and design tokens | `mobile_app/lib/core/theme/` |
| Network clients, Socket.IO, secure storage | `mobile_app/lib/core/network/`, `mobile_app/lib/core/storage/` |
| Connection mode | `mobile_app/lib/core/constants/connection_mode.dart` |
| Login and splash | `mobile_app/lib/features/auth/presentation/screens/` |
| Dashboard and bottom navigation | `mobile_app/lib/features/dashboard/presentation/` |
| Rooms and room details | `mobile_app/lib/features/rooms/presentation/` |
| Routines and routine details | `mobile_app/lib/features/routines/presentation/` |
| Timeline, explain, security, climate, energy, settings | `mobile_app/lib/features/<feature>/{data,domain,presentation}/` |
| Rules, modes, context, conflicts | `mobile_app/lib/features/<feature>/{data,domain,presentation}/` |
| Shared UI | `mobile_app/lib/core/widgets/` and feature-specific widgets |
| English and French translations | `mobile_app/lib/l10n/app_en.arb`, `app_fr.arb` |

## Current architecture status

- Screens are separate files and navigation is through named GoRouter routes.
- Repository implementations and the Mock/Live mode selection are centralized in `app/di/providers.dart`.
- Remote repositories use the Strapi integration API; tested response parsing handles current Strapi v5 responses.
- Climate adapts the selected rooms repository through its own domain contract; Settings has domain/data layers for persisted preferences.
- Some older DTOs still carry presentation types.
- Existing feature screens still contain hardcoded text, spacing, and colors that have not all been migrated to localization and design tokens.
- The measured file-size constraints pass, and Flutter analysis/tests pass. See `PROGRESS.md` for command evidence and remaining gaps.

## Required implementation order

The requested feature order remains the intended sequence for any remaining layer/localization work:

1. Auth
2. Dashboard
3. Rooms
4. Routines
5. Rules
6. Timeline
7. Explain
8. Modes
9. Context
10. Conflicts
11. Climate
12. Energy
13. Security
14. Settings

The workspace root is not a Git repository. The backend has nested Git metadata, so root-level commits for Flutter and docs are unavailable until repository ownership/structure is corrected.
