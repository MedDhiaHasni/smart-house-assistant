import '../entities/rule_entity.dart';

abstract interface class RuleRepository {
  Future<List<RuleEntity>> getRules();

  Future<void> updateRule(RuleEntity rule);
}
