import '../../domain/entities/mode_state.dart';
import '../../domain/repositories/modes_repository.dart';

class MockModesRepository implements ModesRepository {
  ModeState _state = ModeState(
    activeMode: 'Home',
    availableModes: const ['Home', 'Away', 'Night', 'Vacation'],
    overrides: [
      OverrideEntity(
        id: 'living-room-light',
        deviceName: 'Living room lights',
        value: 'On',
        expiresAt: DateTime(2026, 11, 3, 7),
      ),
      OverrideEntity(
        id: 'bedroom-temperature',
        deviceName: 'Bedroom temperature',
        value: '19°C',
        expiresAt: DateTime(2026, 11, 3, 6),
      ),
    ],
  );

  @override
  Future<ModeState> load() async => _state;

  @override
  Future<ModeState> setMode(String mode) async {
    if (!_state.availableModes.contains(mode)) {
      throw ArgumentError.value(mode, 'mode', 'Unknown mode.');
    }
    _state = _state.copyWith(activeMode: mode);
    return _state;
  }

  @override
  Future<ModeState> addOverride(OverrideEntity override) async {
    _state = _state.copyWith(overrides: [..._state.overrides, override]);
    return _state;
  }

  @override
  Future<ModeState> removeOverride(String id) async {
    _state = _state.copyWith(
      overrides: [
        for (final override in _state.overrides)
          if (override.id != id) override,
      ],
    );
    return _state;
  }
}
