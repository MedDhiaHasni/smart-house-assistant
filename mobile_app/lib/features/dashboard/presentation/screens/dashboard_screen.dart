import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/section_header.dart';
import '../../../../app/router/route_names.dart';
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
    final dashboardState = ref.watch(dashboardProvider);
    return dashboardState.when(
      data: (dashboard) => RefreshIndicator(
        onRefresh: () async {
          await ref.refresh(dashboardProvider.future).then<void>((_) {});
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.greeting,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l10n.houseSummary,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C7C7B).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    dashboard.mode,
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const StatusChipsRow(),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.amber),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Window in bedroom is open → heating blocked for comfort rule.',
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.pushNamed(RouteNames.explain),
                    child: const Text('Why?'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
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
            const SizedBox(height: 18),
            SizedBox(
              height: 160,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.consumption,
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          Text(
                            l10n.today,
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: LineChart(
                          LineChartData(
                            gridData: const FlGridData(show: false),
                            titlesData: const FlTitlesData(show: false),
                            borderData: FlBorderData(show: false),
                            lineBarsData: [
                              LineChartBarData(
                                isCurved: true,
                                color: const Color(0xFFE5A427),
                                barWidth: 4,
                                dotData: const FlDotData(show: false),
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
                ),
              ),
            ),
            const SizedBox(height: 18),
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
            const SizedBox(height: 18),
            SectionHeader(title: l10n.recentEvents, rightText: l10n.seeAll),
            const SizedBox(height: 10),
            ...dashboard.events.map(
              (event) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: event.severityColor.withValues(alpha: 0.12),
                  child: Icon(event.icon, color: event.severityColor),
                ),
                title: Text(event.title),
                subtitle: Text(event.description),
                trailing: Text(event.time),
              ),
            ),
            const SizedBox(height: 18),
            SectionHeader(title: l10n.smartRoutines, rightText: l10n.open),
            const SizedBox(height: 10),
            ...dashboard.routines
                .take(3)
                .map(
                  (routine) => Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: routine.healthColor.withValues(
                          alpha: 0.12,
                        ),
                        child: Icon(
                          Icons.auto_awesome,
                          color: routine.healthColor,
                        ),
                      ),
                      title: Text(routine.name),
                      subtitle: Text(
                        '${routine.trigger} • Last run: ${routine.lastRun}',
                      ),
                      trailing: Switch(
                        value: routine.enabled,
                        onChanged: (enabled) => ref
                            .read(routinesControllerProvider.notifier)
                            .setEnabled(routine.id, enabled),
                      ),
                      onTap: () => context.pushNamed(
                        RouteNames.routineDetail,
                        pathParameters: {'id': routine.id},
                      ),
                    ),
                  ),
                ),
          ],
        ),
      ),
      error: (error, stackTrace) => Center(child: Text(error.toString())),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }
}
