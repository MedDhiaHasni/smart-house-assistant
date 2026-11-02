import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/di/providers.dart';
import '../../../../core/constants/connection_mode.dart';

final settingsControllerProvider = Provider<SettingsController>(
  (ref) => SettingsController(ref),
);

class SettingsController {
  SettingsController(this._ref);

  final Ref _ref;

  Future<void> setThemeMode(ThemeMode value) async {
    await _ref.read(settingsRepositoryProvider).saveThemeMode(value.name);
    _ref.read(themeModeProvider.notifier).state = value;
  }

  Future<void> setLocale(Locale? value) async {
    await _ref
        .read(settingsRepositoryProvider)
        .saveLanguageCode(value?.languageCode);
    _ref.read(localeProvider.notifier).state = value;
  }

  Future<void> setConnectionMode(ConnectionMode value) async {
    await _ref.read(settingsRepositoryProvider).saveConnectionMode(value.name);
    _ref.read(connectionModeProvider.notifier).state = value;
  }
}
