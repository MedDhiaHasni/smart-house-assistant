import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/climate_provider.dart';

const _climateColor = Color(0xFF1B7AE8);

class ClimateScreen extends ConsumerWidget {
  const ClimateScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final climate = ref.watch(climateProvider);
    final controller = ref.read(climateProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Climate'),
        centerTitle: false,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: climate.when(
        data: (snapshot) {
          if (snapshot == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.thermostat_rounded,
                      size: 56,
                      color: scheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No climate room is available.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(climateProvider);
              await Future<void>.delayed(const Duration(milliseconds: 600));
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              children: [
                _SetpointCard(
                  roomName: '${snapshot.roomName}',
                  temperature: snapshot.temperature.clamp(15, 30).toDouble(),
                  currentLabel: snapshot.temperature.toStringAsFixed(1),
                  onChangeEnd: controller.setTargetTemperature,
                )
                    .animate()
                    .fadeIn(duration: 350.ms)
                    .slideY(begin: 0.06, end: 0, curve: Curves.easeOut),
                const SizedBox(height: 20),
                const _HistoryCard()
                    .animate(delay: 100.ms)
                    .fadeIn(duration: 350.ms)
                    .slideY(begin: 0.06, end: 0, curve: Curves.easeOut),
              ],
            ),
          );
        },
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
                  onPressed: () => ref.invalidate(climateProvider),
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

class _SetpointCard extends StatefulWidget {
  const _SetpointCard({
    required this.roomName,
    required this.temperature,
    required this.currentLabel,
    required this.onChangeEnd,
  });

  final String roomName;
  final double temperature;
  final String currentLabel;
  final void Function(double temperature) onChangeEnd;

  @override
  State<_SetpointCard> createState() => _SetpointCardState();
}

class _SetpointCardState extends State<_SetpointCard> {
  double? _dragValue;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final value = _dragValue ?? widget.temperature;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: scheme.outlineVariant),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _climateColor.withValues(alpha: 0.14),
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
                  color: _climateColor.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.thermostat_rounded,
                  color: _climateColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.roomName,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Center(
            child: Text(
              '${value.toStringAsFixed(1)}°C',
              style: textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -1,
                color: _climateColor,
              ),
            ),
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: _climateColor,
              thumbColor: _climateColor,
              inactiveTrackColor: _climateColor.withValues(alpha: 0.2),
              trackHeight: 8,
              overlayColor: _climateColor.withValues(alpha: 0.12),
            ),
            child: Slider(
              value: value,
              min: 15,
              max: 30,
              divisions: 30,
              label: '${value.toStringAsFixed(1)}°C',
              onChanged: (v) => setState(() => _dragValue = v),
              onChangeEnd: (v) {
                widget.onChangeEnd(v);
                setState(() => _dragValue = null);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '15°',
                  style: textTheme.labelMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  '30°',
                  style: textTheme.labelMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              'Current: ${widget.currentLabel}°C',
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

class _HistoryCard extends StatelessWidget {
  const _HistoryCard();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      height: 230,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
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
                Icons.show_chart_rounded,
                color: _climateColor,
                size: 20,
              ),
              const SizedBox(width: 6),
              Text(
                'History',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    isCurved: true,
                    color: _climateColor,
                    barWidth: 4,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          _climateColor.withValues(alpha: 0.28),
                          _climateColor.withValues(alpha: 0),
                        ],
                      ),
                    ),
                    spots: const [
                      FlSpot(0, 20),
                      FlSpot(1, 20.6),
                      FlSpot(2, 21.1),
                      FlSpot(3, 20.9),
                      FlSpot(4, 21.3),
                      FlSpot(5, 21.6),
                      FlSpot(6, 21.4),
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