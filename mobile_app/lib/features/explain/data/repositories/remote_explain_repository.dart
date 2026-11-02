import 'package:dio/dio.dart';

import '../../domain/repositories/explain_repository.dart';

class RemoteExplainRepository implements ExplainRepository {
  RemoteExplainRepository(this._dio);

  final Dio _dio;

  @override
  Future<List<String>> getLatestTrace() async {
    final timelineResponse = await _dio.get<Object?>('/timeline');
    final payload = timelineResponse.data;
    if (payload is! Map || payload['data'] is! List) {
      throw const FormatException(
        'Timeline response must contain a data list.',
      );
    }
    final executions = (payload['data'] as List)
        .where((entry) => entry is Map && entry['type'] == 'execution')
        .toList();
    if (executions.isEmpty) return const [];
    final latest = executions.first;
    final id = latest['id'];
    if (id is! String || id.isEmpty) {
      throw const FormatException(
        'Latest execution is missing its identifier.',
      );
    }
    final response = await _dio.get<Object?>(
      '/explain/${Uri.encodeComponent(id)}',
    );
    final explanation = response.data;
    if (explanation is! Map ||
        explanation['data'] is! Map ||
        (explanation['data'] as Map)['trace'] is! List) {
      throw const FormatException(
        'Execution explanation has an invalid shape.',
      );
    }
    return ((explanation['data'] as Map)['trace'] as List).map((step) {
      if (step is! Map || step['message'] is! String) {
        throw const FormatException(
          'Execution trace steps must contain a message.',
        );
      }
      final stage = step['stage'];
      final actual = step['actual'];
      final expected = step['expected'];
      final details = [
        if (actual != null) 'actual=$actual',
        if (expected != null) 'expected=$expected',
      ];
      return '${stage ?? 'trace'}: ${step['message']}${details.isEmpty ? '' : ' (${details.join(', ')})'}';
    }).toList();
  }
}
