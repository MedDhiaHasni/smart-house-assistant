import '../../domain/entities/rule_conflict_entity.dart';
import '../../domain/repositories/conflict_repository.dart';

class MockConflictRepository implements ConflictRepository {
  final List<RuleConflictEntity> _conflicts = [
    const RuleConflictEntity(
      id: 'living-room-heating',
      deviceName: 'Living room heater',
      firstRule: 'Comfort heating',
      secondRule: 'Energy saver',
      resolution:
          'Comfort heating wins unless the safety window rule blocks it.',
      winningPriority: 40,
    ),
  ];

  @override
  Future<List<RuleConflictEntity>> getConflicts() async =>
      List.unmodifiable(_conflicts);

  @override
  Future<void> resolve(String id) async {
    _conflicts.removeWhere((conflict) => conflict.id == id);
  }
}
