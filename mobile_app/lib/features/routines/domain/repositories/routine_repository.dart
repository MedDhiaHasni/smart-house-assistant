import '../../data/models/routine_models.dart';

abstract interface class RoutineRepository {
  Future<List<RoutineRecord>> getRoutines();

  Future<void> setEnabled(String id, bool enabled);
}
