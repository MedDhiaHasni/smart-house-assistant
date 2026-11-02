import '../../domain/entities/rule_entity.dart';

class MockRulesDataSource {
  List<RuleEntity> loadRules() => const [
    RuleEntity(
      id: 'comfort',
      name: 'Comfort heating',
      trigger: 'Temperature falls below 19°C',
      condition: 'Someone is home and no window is open',
      action: 'Set living room to 21°C',
      priority: 40,
      enabled: true,
    ),
    RuleEntity(
      id: 'open_window',
      name: 'Open-window safety',
      trigger: 'A window opens',
      condition: 'Heating is active in that room',
      action: 'Pause heating for that room',
      priority: 90,
      enabled: true,
    ),
    RuleEntity(
      id: 'eco',
      name: 'Peak-hour energy saving',
      trigger: 'Peak energy period starts',
      condition: 'Security mode is not armed',
      action: 'Pause non-essential devices',
      priority: 20,
      enabled: false,
    ),
  ];
}
