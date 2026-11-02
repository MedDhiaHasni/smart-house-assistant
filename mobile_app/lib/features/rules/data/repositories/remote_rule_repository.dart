import 'package:dio/dio.dart';

import '../../domain/entities/rule_entity.dart';
import '../../domain/repositories/rule_repository.dart';

class RemoteRuleRepository implements RuleRepository {
  RemoteRuleRepository(this._dio);

  final Dio _dio;

  @override
  Future<List<RuleEntity>> getRules() async {
    final response = await _dio.get<Object?>('/rules');
    final payload = response.data;
    if (payload is! Map || payload['data'] is! List) {
      throw const FormatException('Rules response must contain a data list.');
    }

    return (payload['data'] as List)
        .map((item) => _parseRule(item))
        .toList(growable: false);
  }

  @override
  Future<void> updateRule(RuleEntity rule) async {
    await _dio.put<void>(
      '/rules/${Uri.encodeComponent(rule.id)}',
      data: {
        'data': {'enabled': rule.enabled},
      },
    );
  }

  RuleEntity _parseRule(Object? item) {
    if (item is! Map) {
      throw const FormatException('Each rule must be a JSON object.');
    }
    final nested = item['attributes'];
    final data = nested is Map ? nested : item;
    String requiredString(String key) {
      final value = data[key];
      if (value is! String || value.isEmpty) {
        throw FormatException('Rule field "$key" must be a non-empty string.');
      }
      return value;
    }

    final priority = data['priority'];
    final enabled = data['enabled'];
    if (priority is! num || enabled is! bool) {
      throw const FormatException(
        'Rule priority and enabled fields have invalid types.',
      );
    }
    final id = data['documentId'] ?? data['id'];
    if (id == null) {
      throw const FormatException('Rule is missing its document identifier.');
    }
    final trigger = data['trigger'];
    final triggerText = trigger is Map
        ? trigger['eventType']?.toString()
        : trigger?.toString();
    final conditions = data['conditions'];
    final conditionText = conditions is List
        ? conditions
              .whereType<Map>()
              .map(
                (condition) =>
                    '${condition['variable'] ?? 'condition'} ${condition['operator'] ?? ''} ${condition['expected'] ?? ''}'
                        .trim(),
              )
              .join(', ')
        : data['condition']?.toString();
    final actions = data['actions'];
    final actionText = actions is List
        ? actions
              .whereType<Map>()
              .map(
                (action) =>
                    '${action['command'] ?? 'command'} ${action['deviceId'] ?? ''}'
                        .trim(),
              )
              .join(', ')
        : data['action']?.toString();

    return RuleEntity(
      id: id.toString(),
      name: requiredString('name'),
      trigger: triggerText?.isNotEmpty == true
          ? triggerText!
          : requiredString('trigger'),
      condition: conditionText?.isNotEmpty == true
          ? conditionText!
          : 'No additional conditions',
      action: actionText?.isNotEmpty == true
          ? actionText!
          : requiredString('action'),
      priority: priority.toInt(),
      enabled: enabled,
    );
  }
}
