import 'package:dio/dio.dart';

import '../../domain/entities/context_variable_entity.dart';
import '../../domain/repositories/context_repository.dart';

class RemoteContextRepository implements ContextRepository {
  RemoteContextRepository(this._dio);

  final Dio _dio;

  @override
  Future<List<ContextVariableEntity>> getVariables() async {
    final response = await _dio.get<Object?>('/context');
    final payload = response.data;
    if (payload is! Map || payload['data'] is! List) {
      throw const FormatException('Context response must contain a data list.');
    }
    return (payload['data'] as List).map(_parseVariable).toList();
  }

  ContextVariableEntity _parseVariable(Object? value) {
    if (value is! Map) {
      throw const FormatException('Context variables must be objects.');
    }
    final key = value['key'];
    final source = value['source'];
    final observedAt = value['observedAt'];
    if (key is! String ||
        key.isEmpty ||
        source is! String ||
        observedAt is! String) {
      throw const FormatException(
        'Context variable is missing required fields.',
      );
    }
    final timestamp = DateTime.tryParse(observedAt);
    if (timestamp == null) {
      throw const FormatException(
        'Context observedAt must be an ISO timestamp.',
      );
    }
    final rawValue = value['value'];
    return ContextVariableEntity(
      id: key,
      label: key
          .split(RegExp(r'[-_]'))
          .map(
            (part) => part.isEmpty
                ? part
                : '${part[0].toUpperCase()}${part.substring(1)}',
          )
          .join(' '),
      value: rawValue?.toString() ?? 'null',
      source: source,
      updatedAt: timestamp,
    );
  }
}
