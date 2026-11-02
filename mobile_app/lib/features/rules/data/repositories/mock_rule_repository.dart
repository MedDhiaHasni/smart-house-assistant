import '../../domain/entities/rule_entity.dart';
import '../../domain/repositories/rule_repository.dart';
import '../datasources/mock_rules_data_source.dart';

class MockRuleRepository implements RuleRepository {
  MockRuleRepository(MockRulesDataSource source) : _rules = source.loadRules();

  List<RuleEntity> _rules;

  @override
  Future<List<RuleEntity>> getRules() async => List.unmodifiable(_rules);

  @override
  Future<void> updateRule(RuleEntity rule) async {
    _rules = [
      for (final existing in _rules)
        if (existing.id == rule.id) rule else existing,
    ];
  }
}
