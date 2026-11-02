import 'package:dio/dio.dart';

import '../../domain/entities/mode_state.dart';
import '../../domain/repositories/modes_repository.dart';

class RemoteModesRepository implements ModesRepository {
  RemoteModesRepository(this._dio);

  final Dio _dio;

  @override
  Future<ModeState> load() async {
    final response = await _dio.get<Object?>('/modes');
    final payload = _record(response.data, 'Modes response');
    final data = _record(payload['data'], 'Modes data');
    final modes = data['modes'];
    final overrides = data['overrides'];
    if (modes is! List || overrides is! List) {
      throw const FormatException('Modes response has invalid lists.');
    }
    return ModeState(
      activeMode: _string(data['activeMode'], 'activeMode'),
      availableModes: modes.map((mode) => _string(mode, 'mode')).toList(),
      overrides: overrides.map(_parseOverride).toList(),
    );
  }

  @override
  Future<ModeState> setMode(String mode) async {
    await _dio.post<Object?>('/modes', data: {'mode': mode});
    return load();
  }

  @override
  Future<ModeState> addOverride(OverrideEntity override) async {
    final deviceId = override.deviceName.toLowerCase().contains('bedroom')
        ? 'bedroom-heater'
        : 'living-room-heater';
    await _dio.post<Object?>(
      '/overrides',
      data: {
        'deviceId': deviceId,
        'value': {'value': override.value},
        'startsAt': DateTime.now().toUtc().toIso8601String(),
        'expiresAt': override.expiresAt.toUtc().toIso8601String(),
      },
    );
    return load();
  }

  @override
  Future<ModeState> removeOverride(String id) async {
    await _dio.delete<Object?>('/overrides/${Uri.encodeComponent(id)}');
    return load();
  }

  OverrideEntity _parseOverride(Object? value) {
    final data = _record(value, 'Override');
    final id = data['id'] ?? data['documentId'];
    final details = data['value'];
    final displayValue = details is Map
        ? details['value']?.toString() ?? details.toString()
        : details?.toString() ?? '';
    return OverrideEntity(
      id: _string(id, 'override id'),
      deviceName: _string(data['deviceId'], 'deviceId'),
      value: displayValue,
      expiresAt: DateTime.parse(_string(data['expiresAt'], 'expiresAt')),
    );
  }

  Map _record(Object? value, String name) {
    if (value is! Map) throw FormatException('$name must be an object.');
    return value;
  }

  String _string(Object? value, String name) {
    if (value is! String || value.isEmpty) {
      throw FormatException('$name must be a non-empty string.');
    }
    return value;
  }
}
