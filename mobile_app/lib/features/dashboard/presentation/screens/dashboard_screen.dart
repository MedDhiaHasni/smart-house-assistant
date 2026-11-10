import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../routines/presentation/providers/routines_provider.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/action_button.dart';
import '../widgets/status_chips_row.dart';
import '../widgets/summary_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final dashboardState = ref.watch(dashboardProvider);
    final topInset = MediaQuery.of(context).padding.top;

    return dashboardState.when(
      data: (dashboard) => RefreshIndicator(
        onRefresh: () async {
          await ref.refresh(dashboardProvider.future).then<void>((_) {});
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(20, topInset + 16, 20, 32),
          children: [
            _Header(
              greeting: l10n.greeting,
              summary: l10n.houseSummary,
              mode: dashboard.mode,
            ),
            const SizedBox(height: 16),
            const StatusChipsRow(),
            const SizedBox(height: 20),
            _AlertBanner(
              message:
                  'Window in bedroom is open → heating blocked for comfort rule.',
              actionLabel: 'Why?',
              onAction: () => context.pushNamed(RouteNames.explain),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SummaryCard(
                  icon: Icons.thermostat_rounded,
                  title: l10n.climate,
                  value: dashboard.climateValue,
                  subtitle: l10n.heatingOn,
                  color: const Color(0xFF1B7AE8),
                  onTap: () => context.pushNamed(RouteNames.climate),
                ),
                SummaryCard(
                  icon: Icons.flash_on_rounded,
                  title: l10n.energy,
                  value: dashboard.energyValue,
                  subtitle: l10n.peakAt,
                  color: const Color(0xFFE5A427),
                  onTap: () => context.pushNamed(RouteNames.energy),
                ),
                SummaryCard(
                  icon: Icons.shield_rounded,
                  title: l10n.security,
                  value: 'Armed',
                  subtitle: dashboard.securityAlerts,
                  color: const Color(0xFFB11A2A),
                  onTap: () => context.pushNamed(RouteNames.security),
                ),
                SummaryCard(
                  icon: Icons.sync_rounded,
                  title: l10n.activeRoutines,
                  value: dashboard.activeRoutineCount.toString(),
                  subtitle: l10n.activeRoutines,
                  color: const Color(0xFF16A34A),
                  onTap: () => context.pushNamed(RouteNames.dashboard),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _ConsumptionCard(title: l10n.consumption, trailing: l10n.today),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ActionButton(
                    label: l10n.awayMode,
                    icon: Icons.directions_walk_rounded,
                    color: Colors.blue,
                    onTap: () => context.pushNamed(RouteNames.dashboard),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ActionButton(
                    label: l10n.emergencyOff,
                    icon: Icons.power_off_rounded,
                    color: Colors.red,
                    onTap: () => context.pushNamed(RouteNames.dashboard),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            SectionHeader(title: l10n.recentEvents, rightText: l10n.seeAll),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: scheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: scheme.outlineVariant),
              ),
              child: Column(
                children: [
                  for (var i = 0; i < dashboard.events.length; i++) ...[
                    if (i > 0)
                      Divider(
                        height: 1,
                        indent: 72,
                        color: scheme.outlineVariant,
                      ),
                    _EventTile(event: dashboard.events[i]),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 28),
            SectionHeader(title: l10n.smartRoutines, rightText: l10n.open),
            const SizedBox(height: 12),
            ...dashboard.routines.take(3).map(
                  (routine) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _RoutineTile(
                      routine: routine,
                      onToggle: (enabled) => ref
                          .read(routinesControllerProvider.notifier)
                          .setEnabled(routine.id, enabled),
                      onTap: () => context.pushNamed(
                        RouteNames.routineDetail,
                        pathParameters: {'id': routine.id},
                      ),
                    ),
                  ),
                ),
          ]
              .animate(interval: 50.ms)
              .fadeIn(duration: 350.ms)
              .slideY(begin: 0.05, end: 0, curve: Curves.easeOut),
        ),
      ),
      error: (error, stackTrace) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline_rounded, size: 48, color: scheme.error),
              const SizedBox(height: 12),
              Text(
                error.toString(),
                textAlign: TextAlign.center,
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              FilledButton.tonalIcon(
                onPressed: () => ref.invalidate(dashboardProvider),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.greeting,
    required this.summary,
    required this.mode,
  });

  final String greeting;
  final String summary;
  final String mode;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                summary,
                style: textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [scheme.primary, scheme.tertiary]),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.home_rounded, size: 16, color: scheme.onPrimary),
              const SizedBox(width: 6),
              Text(
                mode,
                style: textTheme.labelLarge?.copyWith(
                  color: scheme.onPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AlertBanner extends StatelessWidget {
  const _AlertBanner({
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.25),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.warning_amber_rounded, color: Colors.amber),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: scheme.onSurface, height: 1.3),
            ),
          ),
          TextButton(onPressed: onAction, child: Text(actionLabel)),
        ],
      ),
    );
  }
}

class _ConsumptionCard extends StatelessWidget {
  const _ConsumptionCard({required this.title, required this.trailing});

  final String title;
  final String trailing;

  static const _energyColor = Color(0xFFE5A427);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      height: 190,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bolt_rounded, color: _energyColor, size: 20),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(trailing, style: textTheme.labelMedium),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: LineChart(
              LineChartData(
                minY: 0,
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    isCurved: true,
                    color: _energyColor,
                    barWidth: 4,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          _energyColor.withValues(alpha: 0.30),
                          _energyColor.withValues(alpha: 0),
                        ],
                      ),
                    ),
                    spots: const [
                      FlSpot(0, 2),
                      FlSpot(1, 3.5),
                      FlSpot(2, 2.7),
                      FlSpot(3, 4.5),
                      FlSpot(4, 5),
                      FlSpot(5, 4.6),
                      FlSpot(6, 6),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EventTile extends StatelessWidget {
  const _EventTile({required this.event});

  final dynamic event;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: CircleAvatar(
        backgroundColor: event.severityColor.withValues(alpha: 0.14),
        child: Icon(event.icon, color: event.severityColor, size: 20),
      ),
      title: Text(
        event.title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(event.description),
      trailing: Text(
        event.time,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
      ),
    );
  }
}

class _RoutineTile extends StatelessWidget {
  const _RoutineTile({
    required this.routine,
    required this.onToggle,
    required this.onTap,
  });

  final dynamic routine;
  final ValueChanged<bool> onToggle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: scheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: routine.healthColor.withValues(alpha: 0.14),
                child: Icon(Icons.auto_awesome, color: routine.healthColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      routine.name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${routine.trigger} • Last run: ${routine.lastRun}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              Switch(value: routine.enabled, onChanged: onToggle),
            ],
          ),
        ),
      ),
    );
  }
}