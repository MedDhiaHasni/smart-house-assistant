import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../domain/repositories/routine_repository.dart';
import '../models/routine_models.dart';

class RemoteRoutineRepository implements RoutineRepository {
  RemoteRoutineRepository(this._dio);

  final Dio _dio;

  @override
  Future<List<RoutineRecord>> getRoutines() async {
    final response = await _dio.get<Object?>('/routines');
    final payload = response.data;
    if (payload is! Map || payload['data'] is! List) {
      throw const FormatException(
        'Routines response must contain a data list.',
      );
    }
    return (payload['data'] as List).map(_parseRoutine).toList();
  }

  @override
  Future<void> setEnabled(String id, bool enabled) async {
    await _dio.put<Object?>(
      '/routines/${Uri.encodeComponent(id)}',
      data: {'enabled': enabled},
    );
  }

  RoutineRecord _parseRoutine(Object? value) {
    if (value is! Map) {
      throw const FormatException('Routine entries must be objects.');
    }
    final attributes = value['attributes'];
    final data = attributes is Map ? {...attributes, ...value} : value;
    final id = data['documentId'] ?? data['id'];
    final name = data['name'];
    final enabled = data['enabled'];
    if (id == null || name is! String || enabled is! bool) {
      throw const FormatException(
        'Routine is missing its identifier, name, or enabled state.',
      );
    }
    final trigger = data['trigger'];
    final triggerText = trigger is Map
        ? trigger.entries
              .map((entry) => '${entry.key}: ${entry.value}')
              .join(', ')
        : trigger?.toString() ?? 'No trigger configured';
    final conditions = data['conditions'];
    final exceptions = data['exceptions'];
    final actions = data['actions'];
    final priority = data['priority'];
    return RoutineRecord(
      id: id.toString(),
      name: name,
      trigger: triggerText,
      enabled: enabled,
      health: enabled ? 'OK' : 'Paused',
      healthColor: enabled ? Colors.green : Colors.grey,
      lastRun: 'No runs yet',
      flow: [
        'Trigger: $triggerText',
        'Conditions: ${_formatList(conditions)}',
        'Actions: ${_formatList(actions)}',
        'Exceptions: ${_formatList(exceptions)}',
        if (priority is num) 'Priority: ${priority.toInt()}',
      ],
      history: const [],
    );
  }

  String _formatList(Object? value) {
    if (value is! List || value.isEmpty) return 'None';
    return value
        .map(
          (item) => item is Map
              ? item.entries
                    .map((entry) => '${entry.key}: ${entry.value}')
                    .join(', ')
              : item.toString(),
        )
        .join('; ');
  }
}
