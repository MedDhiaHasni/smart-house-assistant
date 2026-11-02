import 'package:dio/dio.dart';

import '../../domain/entities/security_snapshot_entity.dart';
import '../../domain/repositories/security_repository.dart';

class RemoteSecurityRepository implements SecurityRepository {
  RemoteSecurityRepository(this._dio);

  final Dio _dio;

  @override
  Future<SecuritySnapshotEntity> getSnapshot() async {
    final response = await _dio.get<Object?>('/dashboard/summary');
    final payload = response.data;
    if (payload is! Map || payload['data'] is! Map) {
      throw const FormatException(
        'Security response must contain dashboard data.',
      );
    }
    final data = payload['data'] as Map;
    final devices = data['devices'];
    final alerts = data['alerts'];
    final mode = data['mode'];
    if (devices is! List || alerts is! List || mode is! String) {
      throw const FormatException('Security response has invalid collections.');
    }
    return SecuritySnapshotEntity(
      activeMode: mode,
      alerts: alerts.map((alert) {
        if (alert is! Map || alert['message'] is! String) {
          throw const FormatException('Security alert must contain a message.');
        }
        return alert['message'] as String;
      }).toList(),
      devices: devices.map((device) {
        if (device is! Map ||
            device['id'] is! String ||
            device['state'] is! Map) {
          throw const FormatException(
            'Security device must contain its id and state.',
          );
        }
        final id = device['id'] as String;
        final state = device['state'] as Map;
        return SecurityDeviceEntity(
          name: id.replaceAll('-', ' '),
          status: state.entries
              .map((entry) => '${entry.key}: ${entry.value}')
              .join(', '),
        );
      }).toList(),
    );
  }
}
