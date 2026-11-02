import '../datasources/mock_routines_data_source.dart';
import '../../domain/repositories/routine_repository.dart';
import '../models/routine_models.dart';

class MockRoutineRepository implements RoutineRepository {
  final List<RoutineRecord> _routines = smartHomeRoutines();

  @override
  Future<List<RoutineRecord>> getRoutines() async =>
      List.unmodifiable(_routines);

  @override
  Future<void> setEnabled(String id, bool enabled) async {
    final index = _routines.indexWhere((routine) => routine.id == id);
    if (index < 0) throw StateError('Routine "$id" does not exist.');
    final routine = _routines[index];
    _routines[index] = RoutineRecord(
      id: routine.id,
      name: routine.name,
      trigger: routine.trigger,
      enabled: enabled,
      health: routine.health,
      healthColor: routine.healthColor,
      flow: routine.flow,
      history: routine.history,
      lastRun: routine.lastRun,
    );
  }
}
