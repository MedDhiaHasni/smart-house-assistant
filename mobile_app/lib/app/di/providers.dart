import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/connection_mode.dart';
import '../../core/network/api_client.dart';
import '../../core/network/socket_service.dart';
import '../../core/storage/secure_store.dart';
import '../../core/storage/preferences_store.dart';
import '../../features/settings/data/repositories/preferences_settings_repository.dart';
import '../../features/settings/domain/repositories/settings_repository.dart';
import '../../features/rules/data/datasources/mock_rules_data_source.dart';
import '../../features/rules/data/repositories/mock_rule_repository.dart';
import '../../features/rules/data/repositories/remote_rule_repository.dart';
import '../../features/rules/domain/repositories/rule_repository.dart';
import '../../features/modes/data/repositories/mock_modes_repository.dart';
import '../../features/modes/data/repositories/remote_modes_repository.dart';
import '../../features/modes/domain/repositories/modes_repository.dart';
import '../../features/context/data/datasources/mock_context_data_source.dart';
import '../../features/context/data/repositories/mock_context_repository.dart';
import '../../features/context/data/repositories/remote_context_repository.dart';
import '../../features/context/domain/repositories/context_repository.dart';
import '../../features/conflicts/data/repositories/mock_conflict_repository.dart';
import '../../features/conflicts/data/repositories/remote_conflict_repository.dart';
import '../../features/conflicts/domain/repositories/conflict_repository.dart';
import '../../features/auth/data/repositories/remote_auth_repository.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/dashboard/data/repositories/mock_dashboard_repository.dart';
import '../../features/dashboard/data/repositories/remote_dashboard_repository.dart';
import '../../features/dashboard/domain/repositories/dashboard_repository.dart';
import '../../features/rooms/data/repositories/mock_room_repository.dart';
import '../../features/rooms/data/repositories/remote_room_repository.dart';
import '../../features/rooms/domain/repositories/room_repository.dart';
import '../../features/routines/data/repositories/mock_routine_repository.dart';
import '../../features/routines/data/repositories/remote_routine_repository.dart';
import '../../features/routines/domain/repositories/routine_repository.dart';
import '../../features/timeline/data/repositories/mock_timeline_repository.dart';
import '../../features/timeline/data/repositories/remote_timeline_repository.dart';
import '../../features/timeline/domain/repositories/timeline_repository.dart';
import '../../features/energy/data/repositories/mock_energy_repository.dart';
import '../../features/energy/data/repositories/remote_energy_repository.dart';
import '../../features/energy/domain/repositories/energy_repository.dart';
import '../../features/security/data/repositories/mock_security_repository.dart';
import '../../features/security/data/repositories/remote_security_repository.dart';
import '../../features/security/domain/repositories/security_repository.dart';
import '../../features/explain/data/repositories/mock_explain_repository.dart';
import '../../features/explain/data/repositories/remote_explain_repository.dart';
import '../../features/explain/domain/repositories/explain_repository.dart';
import '../../features/climate/data/repositories/room_climate_repository.dart';
import '../../features/climate/domain/repositories/climate_repository.dart';

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);
final localeProvider = StateProvider<Locale?>((ref) => null);
final connectionModeProvider = StateProvider<ConnectionMode>(
  (ref) => ConnectionMode.mock,
);
final isAuthenticatedProvider = StateProvider<bool>((ref) => false);

final secureStoreProvider = Provider<SecureStore>(
  (ref) => SecureStore(ref.watch(secureStorageProvider)),
);
final apiClientProvider = Provider<ApiClient>(
  (ref) => ApiClient(secureStore: ref.watch(secureStoreProvider)),
);
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => RemoteAuthRepository(
    ref.watch(apiClientProvider).dio,
    ref.watch(secureStoreProvider),
  ),
);
final rulesRepositoryProvider = Provider<RuleRepository>((ref) {
  return switch (ref.watch(connectionModeProvider)) {
    ConnectionMode.live => RemoteRuleRepository(
      ref.watch(apiClientProvider).dio,
    ),
    ConnectionMode.mock ||
    ConnectionMode.offline => MockRuleRepository(MockRulesDataSource()),
  };
});
final modesRepositoryProvider = Provider<ModesRepository>((ref) {
  return switch (ref.watch(connectionModeProvider)) {
    ConnectionMode.live => RemoteModesRepository(
      ref.watch(apiClientProvider).dio,
    ),
    ConnectionMode.mock || ConnectionMode.offline => MockModesRepository(),
  };
});
final contextRepositoryProvider = Provider<ContextRepository>((ref) {
  return switch (ref.watch(connectionModeProvider)) {
    ConnectionMode.live => RemoteContextRepository(
      ref.watch(apiClientProvider).dio,
    ),
    ConnectionMode.mock ||
    ConnectionMode.offline => MockContextRepository(MockContextDataSource()),
  };
});
final conflictRepositoryProvider = Provider<ConflictRepository>((ref) {
  return switch (ref.watch(connectionModeProvider)) {
    ConnectionMode.live => RemoteConflictRepository(
      ref.watch(apiClientProvider).dio,
    ),
    ConnectionMode.mock || ConnectionMode.offline => MockConflictRepository(),
  };
});
final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return switch (ref.watch(connectionModeProvider)) {
    ConnectionMode.live => RemoteDashboardRepository(
      ref.watch(apiClientProvider).dio,
      ref.watch(routineRepositoryProvider),
    ),
    ConnectionMode.mock || ConnectionMode.offline => MockDashboardRepository(),
  };
});
final roomRepositoryProvider = Provider<RoomRepository>((ref) {
  return switch (ref.watch(connectionModeProvider)) {
    ConnectionMode.live => RemoteRoomRepository(
      ref.watch(apiClientProvider).dio,
    ),
    ConnectionMode.mock || ConnectionMode.offline => MockRoomRepository(),
  };
});
final climateRepositoryProvider = Provider<ClimateRepository>(
  (ref) => RoomClimateRepository(ref.watch(roomRepositoryProvider)),
);
final routineRepositoryProvider = Provider<RoutineRepository>((ref) {
  return switch (ref.watch(connectionModeProvider)) {
    ConnectionMode.live => RemoteRoutineRepository(
      ref.watch(apiClientProvider).dio,
    ),
    ConnectionMode.mock || ConnectionMode.offline => MockRoutineRepository(),
  };
});
final timelineRepositoryProvider = Provider<TimelineRepository>((ref) {
  return switch (ref.watch(connectionModeProvider)) {
    ConnectionMode.live => RemoteTimelineRepository(
      ref.watch(apiClientProvider).dio,
    ),
    ConnectionMode.mock || ConnectionMode.offline => MockTimelineRepository(),
  };
});
final energyRepositoryProvider = Provider<EnergyRepository>((ref) {
  return switch (ref.watch(connectionModeProvider)) {
    ConnectionMode.live => RemoteEnergyRepository(
      ref.watch(apiClientProvider).dio,
    ),
    ConnectionMode.mock || ConnectionMode.offline => MockEnergyRepository(),
  };
});
final securityRepositoryProvider = Provider<SecurityRepository>((ref) {
  return switch (ref.watch(connectionModeProvider)) {
    ConnectionMode.live => RemoteSecurityRepository(
      ref.watch(apiClientProvider).dio,
    ),
    ConnectionMode.mock || ConnectionMode.offline => MockSecurityRepository(),
  };
});
final explainRepositoryProvider = Provider<ExplainRepository>((ref) {
  return switch (ref.watch(connectionModeProvider)) {
    ConnectionMode.live => RemoteExplainRepository(
      ref.watch(apiClientProvider).dio,
    ),
    ConnectionMode.mock || ConnectionMode.offline => MockExplainRepository(),
  };
});
final secureStorageProvider = Provider<FlutterSecureStorage>(
  (ref) => const FlutterSecureStorage(),
);
final socketServiceProvider = Provider<SocketService>((ref) {
  final service = SocketService();
  final connectionMode = ref.watch(connectionModeProvider);
  final isAuthenticated = ref.watch(isAuthenticatedProvider);
  if (connectionMode == ConnectionMode.live && isAuthenticated) {
    ref
        .watch(secureStoreProvider)
        .read('jwt')
        .then<void>(
          (token) {
            if (token != null) service.connect(token);
          },
          onError: (Object error, StackTrace stackTrace) {
            service.reportError(error);
          },
        );
  }
  ref.onDispose(() => unawaited(service.dispose()));
  return service;
});
final socketStatusProvider = StreamProvider<String>((ref) {
  if (ref.watch(connectionModeProvider) != ConnectionMode.live) {
    return Stream.value('mock');
  }
  return ref.watch(socketServiceProvider).status;
});
final socketMessagesProvider = StreamProvider<SocketMessage>((ref) {
  if (ref.watch(connectionModeProvider) != ConnectionMode.live) {
    return const Stream<SocketMessage>.empty();
  }
  return ref.watch(socketServiceProvider).messages;
});
final prefsProvider = Provider<SharedPreferences>(
  (ref) => throw StateError('Shared preferences were not initialized.'),
);
final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) =>
      PreferencesSettingsRepository(PreferencesStore(ref.watch(prefsProvider))),
);

List<Override> appSettingsOverrides(SharedPreferences preferences) {
  final stored = PreferencesSettingsRepository(
    PreferencesStore(preferences),
  ).load();
  return [
    prefsProvider.overrideWithValue(preferences),
    themeModeProvider.overrideWith(
      (ref) => ThemeMode.values.firstWhere(
        (value) => value.name == stored.themeMode,
        orElse: () => ThemeMode.system,
      ),
    ),
    localeProvider.overrideWith(
      (ref) => const ['en', 'fr'].contains(stored.languageCode)
          ? Locale(stored.languageCode!)
          : null,
    ),
    connectionModeProvider.overrideWith(
      (ref) => ConnectionMode.values.firstWhere(
        (value) => value.name == stored.connectionMode,
        orElse: () => ConnectionMode.mock,
      ),
    ),
  ];
}
