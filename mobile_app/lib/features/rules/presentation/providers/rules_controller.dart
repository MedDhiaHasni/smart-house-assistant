import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/rule_entity.dart';
import '../../domain/repositories/rule_repository.dart';

class RulesController extends StateNotifier<AsyncValue<List<RuleEntity>>> {
  RulesController(this._repository) : super(const AsyncLoading()) {
    load();
  }

  final RuleRepository _repository;

  Future<void> load() async {
    state = const AsyncLoading();
    try {
      state = AsyncData(await _repository.getRules());
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> toggleRule(String id, bool enabled) async {
    final rules = state.valueOrNull;
    if (rules == null) {
      throw StateError('Rules are not loaded.');
    }
    final index = rules.indexWhere((rule) => rule.id == id);
    if (index < 0) {
      throw StateError('Rule "$id" does not exist.');
    }
    try {
      await _repository.updateRule(rules[index].copyWith(enabled: enabled));
      state = AsyncData(await _repository.getRules());
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }
}
