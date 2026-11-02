import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_house_assistant/app/di/providers.dart';
import 'package:smart_house_assistant/core/constants/connection_mode.dart';
import 'package:smart_house_assistant/core/storage/preferences_store.dart';
import 'package:smart_house_assistant/features/settings/data/repositories/preferences_settings_repository.dart';
import 'package:smart_house_assistant/features/settings/presentation/providers/settings_controller.dart';

void main() {
  test('loads defaults and persists settings selections', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final repository = PreferencesSettingsRepository(
      PreferencesStore(preferences),
    );

    expect(repository.load().themeMode, 'system');
    expect(repository.load().connectionMode, 'mock');

    await repository.saveThemeMode('dark');
    await repository.saveLanguageCode('fr');
    await repository.saveConnectionMode('live');

    final settings = repository.load();
    expect(settings.themeMode, 'dark');
    expect(settings.languageCode, 'fr');
    expect(settings.connectionMode, 'live');

    final container = ProviderContainer(
      overrides: appSettingsOverrides(preferences),
    );
    addTearDown(container.dispose);
    expect(container.read(themeModeProvider), ThemeMode.dark);
    expect(container.read(localeProvider), const Locale('fr'));
    expect(container.read(connectionModeProvider), ConnectionMode.live);

    await container
        .read(settingsControllerProvider)
        .setConnectionMode(ConnectionMode.offline);
    expect(container.read(connectionModeProvider), ConnectionMode.offline);
    expect(repository.load().connectionMode, 'offline');
  });
}
