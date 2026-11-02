import '../entities/mode_state.dart';

abstract interface class ModesRepository {
  Future<ModeState> load();

  Future<ModeState> setMode(String mode);

  Future<ModeState> addOverride(OverrideEntity override);

  Future<ModeState> removeOverride(String id);
}
