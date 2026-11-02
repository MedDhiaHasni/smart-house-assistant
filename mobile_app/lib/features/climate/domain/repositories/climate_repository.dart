import '../entities/climate_snapshot.dart';

abstract interface class ClimateRepository {
  Future<ClimateSnapshot?> getCurrentClimate();

  Future<void> setTargetTemperature(double temperature);
}
