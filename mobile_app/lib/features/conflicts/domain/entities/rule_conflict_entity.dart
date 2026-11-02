class RuleConflictEntity {
  const RuleConflictEntity({
    required this.id,
    required this.deviceName,
    required this.firstRule,
    required this.secondRule,
    required this.resolution,
    required this.winningPriority,
  });

  final String id;
  final String deviceName;
  final String firstRule;
  final String secondRule;
  final String resolution;
  final int winningPriority;
}
