import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../providers/modes_provider.dart';

class ModesScreen extends ConsumerWidget {
  const ModesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final state = ref.watch(modesControllerProvider);
    final controller = ref.read(modesControllerProvider.notifier);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.modesAndOverrides),
        centerTitle: false,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: state.when(
        data: (modeState) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(modesControllerProvider);
            await Future<void>.delayed(const Duration(milliseconds: 600));
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              Text(
                l10n.modeHome,
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              RadioGroup<String>(
                groupValue: modeState.activeMode,
                onChanged: (mode) {
                  if (mode != null) controller.setMode(mode);
                },
                child: Column(
                  children: [
                    for (var i = 0; i < modeState.availableModes.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _ModeTile(
                          mode: modeState.availableModes[i],
                          selected: modeState.availableModes[i] ==
                              modeState.activeMode,
                        )
                            .animate(delay: (50 * i).ms)
                            .fadeIn(duration: 300.ms)
                            .slideY(
                              begin: 0.05,
                              end: 0,
                              curve: Curves.easeOut,
                            ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.modesAndOverrides,
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton.filledTonal(
                    tooltip: l10n.addOverride,
                    onPressed: () => controller.addTemporaryOverride(
                      deviceName: 'Living room lights',
                      value: 'On',
                    ),
                    icon: const Icon(Icons.add_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              for (final override in modeState.overrides)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _OverrideTile(
                    deviceName: '${override.deviceName}',
                    value: '${override.value}',
                    expires: MaterialLocalizations.of(context).formatTimeOfDay(
                      TimeOfDay.fromDateTime(override.expiresAt),
                    ),
                    cancelTooltip: l10n.cancel,
                    onCancel: () => controller.removeOverride(override.id),
                  ).animate().fadeIn(duration: 300.ms).slideY(
                        begin: 0.05,
                        end: 0,
                        curve: Curves.easeOut,
                      ),
                ),
            ],
          ),
        ),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 48,
                  color: scheme.error,
                ),
                const SizedBox(height: 12),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: scheme.onSurfaceVariant),
                ),
                const SizedBox(height: 16),
                FilledButton.tonalIcon(
                  onPressed: () => ref.invalidate(modesControllerProvider),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _ModeTile extends StatelessWidget {
  const _ModeTile({required this.mode, required this.selected});

  final String mode;
  final bool selected;

  IconData get _icon {
    final value = mode.toLowerCase();
    if (value.contains('away')) return Icons.directions_walk_rounded;
    if (value.contains('night')) return Icons.nightlight_round;
    if (value.contains('holiday')) return Icons.beach_access_rounded;
    if (value.contains('guest')) return Icons.people_alt_rounded;
    return Icons.home_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: selected
            ? scheme.primaryContainer.withValues(alpha: 0.7)
            : scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: selected ? scheme.primary : scheme.outlineVariant,
          width: selected ? 2 : 1,
        ),
      ),
      child: RadioListTile<String>(
        value: mode,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        secondary: Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            color: selected
                ? scheme.primary
                : scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            _icon,
            size: 22,
            color: selected ? scheme.onPrimary : scheme.onSurfaceVariant,
          ),
        ),
        controlAffinity: ListTileControlAffinity.trailing,
        title: Text(
          mode,
          style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

class _OverrideTile extends StatelessWidget {
  const _OverrideTile({
    required this.deviceName,
    required this.value,
    required this.expires,
    required this.cancelTooltip,
    required this.onCancel,
  });

  final String deviceName;
  final String value;
  final String expires;
  final String cancelTooltip;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 6, 14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: scheme.tertiaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.timer_outlined,
              color: scheme.onTertiaryContainer,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  deviceName,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: scheme.primaryContainer,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        value,
                        style: textTheme.labelMedium?.copyWith(
                          color: scheme.onPrimaryContainer,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 14,
                          color: scheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          expires,
                          style: textTheme.labelMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: cancelTooltip,
            onPressed: onCancel,
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
    );
  }
}