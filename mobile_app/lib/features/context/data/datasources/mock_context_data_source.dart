import '../../domain/entities/context_variable_entity.dart';

class MockContextDataSource {
  List<ContextVariableEntity> load() {
    final now = DateTime.now();
    return [
      ContextVariableEntity(
        id: 'occupancy',
        label: 'Occupancy',
        value: '2 people at home',
        source: 'Presence sensors',
        updatedAt: now.subtract(const Duration(minutes: 1)),
      ),
      ContextVariableEntity(
        id: 'weather',
        label: 'Weather',
        value: 'Clear, 17°C outside',
        source: 'Weather service',
        updatedAt: now.subtract(const Duration(minutes: 8)),
      ),
      ContextVariableEntity(
        id: 'bedroom-window',
        label: 'Bedroom window',
        value: 'Open',
        source: 'Window sensor',
        updatedAt: now.subtract(const Duration(minutes: 18)),
      ),
      ContextVariableEntity(
        id: 'energy-tariff',
        label: 'Energy tariff',
        value: 'Off-peak',
        source: 'Energy provider',
        updatedAt: now.subtract(const Duration(minutes: 3)),
      ),
    ];
  }
}
