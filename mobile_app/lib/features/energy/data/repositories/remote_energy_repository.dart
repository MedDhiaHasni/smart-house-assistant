import 'package:dio/dio.dart';

import '../../domain/entities/energy_summary_entity.dart';
import '../../domain/repositories/energy_repository.dart';

class RemoteEnergyRepository implements EnergyRepository {
  RemoteEnergyRepository(this._dio);

  final Dio _dio;

  @override
  Future<EnergySummaryEntity> getSummary() async {
    final response = await _dio.get<Object?>('/energy/summary');
    final payload = response.data;
    if (payload is! Map || payload['data'] is! Map) {
      throw const FormatException(
        'Energy response must contain a data object.',
      );
    }
    final data = payload['data'] as Map;
    final currentKw = data['currentKw'];
    final todayKwh = data['todayKwh'];
    if (currentKw is! num || todayKwh is! num) {
      throw const FormatException('Energy totals must be numeric.');
    }
    return EnergySummaryEntity(
      currentKw: currentKw.toDouble(),
      todayKwh: todayKwh.toDouble(),
    );
  }
}
