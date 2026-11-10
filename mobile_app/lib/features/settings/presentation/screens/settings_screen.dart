import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final mode = ref.watch(themeModeProvider);
    final controller = ref.read(settingsControllerProvider);
    final topInset = MediaQuery.of(context).padding.top;

    return ListView(
      padding: EdgeInsets.fromLTRB(20, topInset + 16, 20, 32),
      children: [
        Text(
          l10n.settings,
          style: textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 24),
        _SettingsGroup(
          children: [
            _SettingRow(
              icon: Icons.dark_mode_outlined,
              iconBackground: scheme.primaryContainer,
              iconColor: scheme.onPrimaryContainer,
              title: l10n.theme,
              trailing: _PillDropdown(
                child: DropdownButton<ThemeMode>(
                  value: mode,
                  isDense: true,
                  borderRadius: BorderRadius.circular(16),
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
            ),
            _SettingRow(
              icon: Icons.language_rounded,
              iconBackground: scheme.secondaryContainer,
              iconColor: scheme.onSecondaryContainer,
              title: l10n.language,
              trailing: _PillDropdown(
                child: DropdownButton<Locale?>(
                  value:
                      ref.watch(localeProvider) ??
                      Localizations.localeOf(context),
                  isDense: true,
                  borderRadius: BorderRadius.circular(16),
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
            ),
            _SettingRow(
              icon: Icons.wifi_rounded,
              iconBackground: scheme.tertiaryContainer,
              iconColor: scheme.onTertiaryContainer,
              title: l10n.connectionMode,
              trailing: _PillDropdown(
                child: DropdownButton<ConnectionMode>(
                  value: ref.watch(connectionModeProvider),
                  isDense: true,
                  borderRadius: BorderRadius.circular(16),
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
            ),
            _SettingRow(
              icon: Icons.api_rounded,
              iconBackground: scheme.surfaceContainerHighest,
              iconColor: scheme.onSurfaceVariant,
              title: l10n.backendBaseUrl,
              trailing: Flexible(
                child: Text(
                  apiBaseUrl.replaceFirst('/api', ''),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ],
        ).animate().fadeIn(duration: 350.ms).slideY(
              begin: 0.05,
              end: 0,
              curve: Curves.easeOut,
            ),
        const SizedBox(height: 20),
        _SettingsGroup(
          children: [
            _NavRow(
              icon: Icons.rule_outlined,
              title: l10n.ruleEditor,
              onTap: () => context.pushNamed(RouteNames.ruleEditor),
            ),
            _NavRow(
              icon: Icons.tune_rounded,
              title: l10n.modesAndOverrides,
              onTap: () => context.pushNamed(RouteNames.modes),
            ),
            _NavRow(
              icon: Icons.device_hub_outlined,
              title: l10n.contextViewer,
              onTap: () => context.pushNamed(RouteNames.context),
            ),
            _NavRow(
              icon: Icons.warning_amber_outlined,
              title: l10n.conflictsAndRobustness,
              onTap: () => context.pushNamed(RouteNames.conflicts),
            ),
          ],
        )
            .animate(delay: 100.ms)
            .fadeIn(duration: 350.ms)
            .slideY(begin: 0.05, end: 0, curve: Curves.easeOut),
      ],
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: scheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0)
              Divider(height: 1, indent: 72, color: scheme.outlineVariant),
            children[i],
          ],
        ],
      ),
    );
  }
}

class _IconTile extends StatelessWidget {
  const _IconTile({
    required this.icon,
    required this.background,
    required this.color,
  });

  final IconData icon;
  final Color background;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      width: 42,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
    required this.title,
    required this.trailing,
  });

  final IconData icon;
  final Color iconBackground;
  final Color iconColor;
  final String title;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _IconTile(
            icon: icon,
            background: iconBackground,
            color: iconColor,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          trailing,
        ],
      ),
    );
  }
}

class _NavRow extends StatelessWidget {
  const _NavRow({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            _IconTile(
              icon: icon,
              background: scheme.primaryContainer.withValues(alpha: 0.6),
              color: scheme.onPrimaryContainer,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: scheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

class _PillDropdown extends StatelessWidget {
  const _PillDropdown({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: DropdownButtonHideUnderline(child: child),
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