import '../../domain/entities/energy_summary_entity.dart';
import '../../domain/repositories/energy_repository.dart';

class MockEnergyRepository implements EnergyRepository {
  @override
  Future<EnergySummaryEntity> getSummary() async =>
      const EnergySummaryEntity(currentKw: 3.2, todayKwh: 6.3);
}
