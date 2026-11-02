import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/di/providers.dart';
import '../../data/models/routine_models.dart';
import '../../domain/repositories/routine_repository.dart';

final routinesControllerProvider =
    StateNotifierProvider<RoutinesController, AsyncValue<List<RoutineRecord>>>(
      (ref) => RoutinesController(ref.watch(routineRepositoryProvider)),
    );

class RoutinesController
    extends StateNotifier<AsyncValue<List<RoutineRecord>>> {
  RoutinesController(this._repository) : super(const AsyncLoading()) {
    load();
  }

  final RoutineRepository _repository;

  Future<void> load() async {
    state = const AsyncLoading();
    try {
      state = AsyncData(await _repository.getRoutines());
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> setEnabled(String id, bool enabled) async {
    try {
      await _repository.setEnabled(id, enabled);
      state = AsyncData(await _repository.getRoutines());
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }
}
