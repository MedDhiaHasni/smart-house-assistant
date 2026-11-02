class RuleEntity {
  const RuleEntity({
    required this.id,
    required this.name,
    required this.trigger,
    required this.condition,
    required this.action,
    required this.priority,
    required this.enabled,
  });

  final String id;
  final String name;
  final String trigger;
  final String condition;
  final String action;
  final int priority;
  final bool enabled;

  RuleEntity copyWith({bool? enabled}) => RuleEntity(
    id: id,
    name: name,
    trigger: trigger,
    condition: condition,
    action: action,
    priority: priority,
    enabled: enabled ?? this.enabled,
  );
}
