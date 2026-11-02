import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di/providers.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/constants/connection_mode.dart';
import '../../../../core/network/api_client.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/settings_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final mode = ref.watch(themeModeProvider);
    final controller = ref.read(settingsControllerProvider);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          l10n.settings,
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.dark_mode_outlined),
                title: Text(l10n.theme),
                trailing: DropdownButton<ThemeMode>(
                  value: mode,
                  items: ThemeMode.values
                      .map(
                        (value) => DropdownMenuItem(
                          value: value,
                          child: Text(value.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => value == null
                      ? null
                      : _updateSetting(
                          context,
                          () => controller.setThemeMode(value),
                        ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.language_rounded),
                title: Text(l10n.language),
                trailing: DropdownButton<Locale?>(
                  value:
                      ref.watch(localeProvider) ??
                      Localizations.localeOf(context),
                  items: const [
                    DropdownMenuItem<Locale?>(
                      value: Locale('en'),
                      child: Text('English'),
                    ),
                    DropdownMenuItem<Locale?>(
                      value: Locale('fr'),
                      child: Text('Français'),
                    ),
                  ],
                  onChanged: (locale) => _updateSetting(
                    context,
                    () => controller.setLocale(locale),
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.wifi_rounded),
                title: Text(l10n.connectionMode),
                trailing: DropdownButton<ConnectionMode>(
                  value: ref.watch(connectionModeProvider),
                  items: [
                    DropdownMenuItem(
                      value: ConnectionMode.mock,
                      child: Text(l10n.mockMode),
                    ),
                    DropdownMenuItem(
                      value: ConnectionMode.live,
                      child: Text(l10n.liveMode),
                    ),
                    DropdownMenuItem(
                      value: ConnectionMode.offline,
                      child: Text(l10n.offlineMode),
                    ),
                  ],
                  onChanged: (mode) => mode == null
                      ? null
                      : _updateSetting(
                          context,
                          () => controller.setConnectionMode(mode),
                        ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.api_rounded),
                title: Text(l10n.backendBaseUrl),
                trailing: Text(apiBaseUrl.replaceFirst('/api', '')),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.rule_outlined),
                title: Text(l10n.ruleEditor),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.pushNamed(RouteNames.ruleEditor),
              ),
              ListTile(
                leading: const Icon(Icons.tune_rounded),
                title: Text(l10n.modesAndOverrides),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.pushNamed(RouteNames.modes),
              ),
              ListTile(
                leading: const Icon(Icons.device_hub_outlined),
                title: Text(l10n.contextViewer),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.pushNamed(RouteNames.context),
              ),
              ListTile(
                leading: const Icon(Icons.warning_amber_outlined),
                title: Text(l10n.conflictsAndRobustness),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.pushNamed(RouteNames.conflicts),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

Future<void> _updateSetting(
  BuildContext context,
  Future<void> Function() update,
) async {
  try {
    await update();
  } catch (error) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(error.toString())));
  }
}
