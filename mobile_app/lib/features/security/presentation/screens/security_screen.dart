import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../modes/presentation/providers/modes_provider.dart';
import '../providers/security_provider.dart';

class SecurityScreen extends ConsumerWidget {
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final snapshot = ref.watch(securitySnapshotProvider);
    final modeController = ref.read(modesControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Security'),
        centerTitle: false,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: snapshot.when(
        data: (security) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(securitySnapshotProvider);
            await Future<void>.delayed(const Duration(milliseconds: 600));
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              _AlarmCard(
                isArmed: security.isArmed,
                activeMode: '${security.activeMode}',
                onChanged: (armed) =>
                    modeController.setMode(armed ? 'Away' : 'Home'),
              )
                  .animate()
                  .fadeIn(duration: 350.ms)
                  .slideY(begin: 0.06, end: 0, curve: Curves.easeOut),
              if (security.alerts.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text(
                  'Alerts',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 12),
                for (final alert in security.alerts)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _AlertTile(message: '$alert'),
                  ),
              ],
              const SizedBox(height: 24),
              Text(
                'Devices',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 12),
              for (var i = 0; i < security.devices.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _DeviceTile(
                    icon: _iconFor(security.devices[i].name),
                    name: '${security.devices[i].name}',
                    status: '${security.devices[i].status}',
                  )
                      .animate(delay: (60 * i).ms)
                      .fadeIn(duration: 350.ms)
                      .slideY(begin: 0.06, end: 0, curve: Curves.easeOut),
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
                  onPressed: () => ref.invalidate(securitySnapshotProvider),
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

  IconData _iconFor(String name) => switch (name.toLowerCase()) {
    final value when value.contains('garage') => Icons.garage_rounded,
    final value when value.contains('door') => Icons.door_front_door_rounded,
    _ => Icons.videocam_rounded,
  };
}

class _AlarmCard extends StatelessWidget {
  const _AlarmCard({
    required this.isArmed,
    required this.activeMode,
    required this.onChanged,
  });

  final bool isArmed;
  final String activeMode;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final Color foreground = isArmed ? scheme.onPrimary : scheme.onSurface;
    final Color muted = isArmed
        ? scheme.onPrimary.withValues(alpha: 0.85)
        : scheme.onSurfaceVariant;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: isArmed
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [scheme.primary, scheme.tertiary],
              )
            : null,
        color: isArmed ? null : scheme.surfaceContainerLow,
        border: isArmed ? null : Border.all(color: scheme.outlineVariant),
        boxShadow: isArmed
            ? [
                BoxShadow(
                  color: scheme.primary.withValues(alpha: 0.28),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              color: foreground.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              isArmed ? Icons.shield_rounded : Icons.shield_outlined,
              color: foreground,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Alarm status',
                  style: textTheme.labelLarge?.copyWith(color: muted),
                ),
                const SizedBox(height: 2),
                Text(
                  isArmed ? 'Armed' : 'Disarmed',
                  style: textTheme.headlineSmall?.copyWith(
                    color: foreground,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$activeMode mode',
                  style: textTheme.bodyMedium?.copyWith(color: muted),
                ),
              ],
            ),
          ),
          Switch(value: isArmed, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _AlertTile extends StatelessWidget {
  const _AlertTile({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.errorContainer.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: scheme.onErrorContainer,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: scheme.onErrorContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeviceTile extends StatelessWidget {
  const _DeviceTile({
    required this.icon,
    required this.name,
    required this.status,
  });

  final IconData icon;
  final String name;
  final String status;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(14),
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
              color: scheme.errorContainer.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: scheme.onErrorContainer),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  status,
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: scheme.onSurfaceVariant),
        ],
      ),
    );
  }
}