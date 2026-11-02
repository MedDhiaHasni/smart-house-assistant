import '../entities/energy_summary_entity.dart';

abstract interface class EnergyRepository {
  Future<EnergySummaryEntity> getSummary();
}
