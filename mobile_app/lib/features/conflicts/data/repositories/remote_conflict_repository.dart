import 'package:dio/dio.dart';

import '../../domain/entities/rule_conflict_entity.dart';
import '../../domain/repositories/conflict_repository.dart';

class RemoteConflictRepository implements ConflictRepository {
  RemoteConflictRepository(this._dio);

  final Dio _dio;
  final Set<String> _resolved = {};

  @override
  Future<List<RuleConflictEntity>> getConflicts() async {
    final response = await _dio.get<Object?>('/rules/conflicts');
    final payload = response.data;
    if (payload is! Map || payload['data'] is! List) {
      throw const FormatException(
        'Conflict response must contain a data list.',
      );
    }
    return (payload['data'] as List)
        .where((item) => item is Map && !_resolved.contains(item['id']))
        .map(_parseConflict)
        .toList();
  }

  @override
  Future<void> resolve(String id) async {
    _resolved.add(id);
  }

  RuleConflictEntity _parseConflict(Object? value) {
    if (value is! Map || value['rules'] is! List) {
      throw const FormatException('Conflict data has an invalid shape.');
    }
    final rules = value['rules'] as List;
    if (rules.length < 2) {
      throw const FormatException('Conflict must name two rules.');
    }
    final id = value['id'];
    final deviceId = value['deviceId'];
    final winner = value['winningRule'];
    final priority = value['priority'];
    if (id is! String ||
        deviceId is! String ||
        winner is! String ||
        priority is! num) {
      throw const FormatException('Conflict is missing required fields.');
    }
    return RuleConflictEntity(
      id: id,
      deviceName: deviceId,
      firstRule: rules[0].toString(),
      secondRule: rules[1].toString(),
      resolution: '$winner wins by priority.',
      winningPriority: priority.toInt(),
    );
  }
}
