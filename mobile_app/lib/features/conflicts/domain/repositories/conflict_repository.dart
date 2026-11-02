import '../entities/rule_conflict_entity.dart';

abstract interface class ConflictRepository {
  Future<List<RuleConflictEntity>> getConflicts();

  Future<void> resolve(String id);
}
