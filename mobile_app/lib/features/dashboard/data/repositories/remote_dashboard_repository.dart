import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../routines/domain/repositories/routine_repository.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../models/dashboard_models.dart';

class RemoteDashboardRepository implements DashboardRepository {
  RemoteDashboardRepository(this._dio, this._routineRepository);

  final Dio _dio;
  final RoutineRepository _routineRepository;

  @override
  Future<DashboardData> getDashboard() async {
    final response = await _dio.get<Object?>('/dashboard/summary');
    final payload = response.data;
    if (payload is! Map || payload['data'] is! Map) {
      throw const FormatException(
        'Dashboard response must contain a data object.',
      );
    }
    final data = payload['data'] as Map;
    final energy = _record(data['energy'], 'energy');
    final climate = _record(data['climate'], 'climate');
    final alertValues = data['alerts'];
    final routineCount = data['activeRoutines'];
    final events = data['recentEvents'];
    if (alertValues is! List || events is! List || routineCount is! num) {
      throw const FormatException('Dashboard summary has invalid collections.');
    }
    final routines = await _routineRepository.getRoutines();
    final currentTemperature = climate['temperature'];
    final currentEnergy = energy['todayKwh'];
    return DashboardData(
      mode: _requiredString(data['mode'], 'mode'),
      climateValue: currentTemperature is num
          ? '${currentTemperature.toStringAsFixed(1)}°C'
          : 'Unavailable',
      energyValue: currentEnergy is num
          ? '${currentEnergy.toStringAsFixed(1)} kWh'
          : 'Unavailable',
      securityAlerts: '${alertValues.length} alerts',
      activeRoutineCount: routineCount.toInt(),
      events: events.map(_parseEvent).toList(),
      routines: routines
          .map(
            (routine) => RoutineCard(
              id: routine.id,
              name: routine.name,
              trigger: routine.trigger,
              lastRun: routine.lastRun,
              enabled: routine.enabled,
              health: routine.health,
              healthColor: routine.healthColor,
            ),
          )
          .toList(),
    );
  }

  EventItem _parseEvent(Object? value) {
    final event = _record(value, 'event');
    final type = _requiredString(event['eventType'], 'eventType');
    final timestamp = DateTime.tryParse(
      _requiredString(event['occurredAt'], 'occurredAt'),
    );
    if (timestamp == null) {
      throw const FormatException('Event occurredAt must be an ISO timestamp.');
    }
    final details = event['payload'];
    final isAlert = type.contains('alert') || type.contains('window');
    return EventItem(
      title: type.replaceAll('.', ' '),
      description: details is Map
          ? details.entries
                .map((entry) => '${entry.key}: ${entry.value}')
                .join(', ')
          : details?.toString() ?? '',
      time: timestamp.toLocal().toString(),
      icon: isAlert ? Icons.warning_amber_rounded : Icons.bolt_rounded,
      severityColor: isAlert ? Colors.amber : Colors.green,
    );
  }

  Map _record(Object? value, String name) {
    if (value is! Map) throw FormatException('$name must be an object.');
    return value;
  }

  String _requiredString(Object? value, String name) {
    if (value is! String || value.isEmpty) {
      throw FormatException('$name must be a non-empty string.');
    }
    return value;
  }
}
