import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/rule_conflict_entity.dart';
import '../../domain/repositories/conflict_repository.dart';

class ConflictsController
    extends StateNotifier<AsyncValue<List<RuleConflictEntity>>> {
  ConflictsController(this._repository) : super(const AsyncLoading()) {
    load();
  }

  final ConflictRepository _repository;

  Future<void> load() async {
    state = const AsyncLoading();
    try {
      state = AsyncData(await _repository.getConflicts());
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> resolve(String id) async {
    try {
      await _repository.resolve(id);
      state = AsyncData(await _repository.getConflicts());
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }
}
