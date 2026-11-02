class ContextVariableEntity {
  const ContextVariableEntity({
    required this.id,
    required this.label,
    required this.value,
    required this.source,
    required this.updatedAt,
  });

  final String id;
  final String label;
  final String value;
  final String source;
  final DateTime updatedAt;
}
