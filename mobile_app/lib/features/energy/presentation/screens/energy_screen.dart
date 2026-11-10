import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/energy_provider.dart';

const _energyColor = Color(0xFFE5A427);

class EnergyScreen extends ConsumerWidget {
  const EnergyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final usage = [5.0, 4.6, 4.2, 5.6, 5.9, 6.1, 6.3];
    final summary = ref.watch(energySummaryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Energy'),
        centerTitle: false,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: summary.when(
        data: (energy) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(energySummaryProvider);
            await Future<void>.delayed(const Duration(milliseconds: 600));
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              _LiveCard(
                currentKw: energy.currentKw.toStringAsFixed(1),
                todayKwh: energy.todayKwh.toStringAsFixed(1),
              )
                  .animate()
                  .fadeIn(duration: 350.ms)
                  .slideY(begin: 0.06, end: 0, curve: Curves.easeOut),
              const SizedBox(height: 20),
              _UsageCard(usage: usage)
                  .animate(delay: 100.ms)
                  .fadeIn(duration: 350.ms)
                  .slideY(begin: 0.06, end: 0, curve: Curves.easeOut),
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
                  onPressed: () => ref.invalidate(energySummaryProvider),
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

class _LiveCard extends StatelessWidget {
  const _LiveCard({required this.currentKw, required this.todayKwh});

  final String currentKw;
  final String todayKwh;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: scheme.outlineVariant),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _energyColor.withValues(alpha: 0.16),
            scheme.surfaceContainerLow,
          ],
          stops: const [0, 0.7],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: _energyColor.withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.bolt_rounded, color: _energyColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Live consumption',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                currentKw,
                style: textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'kW',
                style: textTheme.titleLarge?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              'Today: $todayKwh kWh',
              style: textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UsageCard extends StatelessWidget {
  const _UsageCard({required this.usage});

  final List<double> usage;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      height: 250,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.bar_chart_rounded,
                color: _energyColor,
                size: 20,
              ),
              const SizedBox(width: 6),
              Text(
                'Usage',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: BarChart(
              BarChartData(
                minY: 0,
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: const FlTitlesData(show: false),
                barGroups: List.generate(
                  usage.length,
                  (index) => BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: usage[index],
                        color: index == usage.length - 1
                            ? _energyColor
                            : scheme.primary.withValues(alpha: 0.55),
                        width: 20,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}