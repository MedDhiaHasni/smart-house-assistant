import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/climate_provider.dart';

class ClimateScreen extends ConsumerWidget {
  const ClimateScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final climate = ref.watch(climateProvider);
    final controller = ref.read(climateProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: const Text('Climate')),
      body: climate.when(
        data: (snapshot) {
          if (snapshot == null) {
            return const Center(child: Text('No climate room is available.'));
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        snapshot.roomName,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 10),
                      Slider(
                        value: snapshot.temperature.clamp(15, 30).toDouble(),
                        min: 15,
                        max: 30,
                        divisions: 30,
                        onChanged: (_) {},
                        onChangeEnd: (temperature) =>
                            controller.setTargetTemperature(temperature),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Current: ${snapshot.temperature.toStringAsFixed(1)}°C',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Card(
                child: SizedBox(
                  height: 190,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: false),
                        titlesData: const FlTitlesData(show: false),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            isCurved: true,
                            color: Theme.of(context).colorScheme.primary,
                            barWidth: 3,
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
                ),
              ),
            ],
          );
        },
        error: (error, stackTrace) => Center(child: Text(error.toString())),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
