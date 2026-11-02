import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/mode_state.dart';
import '../../domain/repositories/modes_repository.dart';

class ModesController extends StateNotifier<AsyncValue<ModeState>> {
  ModesController(this._repository) : super(const AsyncLoading()) {
    load();
  }

  final ModesRepository _repository;

  Future<void> load() async {
    state = const AsyncLoading();
    try {
      state = AsyncData(await _repository.load());
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> setMode(String mode) => _update(() => _repository.setMode(mode));

  Future<void> removeOverride(String id) =>
      _update(() => _repository.removeOverride(id));

  Future<void> addTemporaryOverride({
    required String deviceName,
    required String value,
  }) => _update(
    () => _repository.addOverride(
      OverrideEntity(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        deviceName: deviceName,
        value: value,
        expiresAt: DateTime.now().add(const Duration(hours: 2)),
      ),
    ),
  );

  Future<void> _update(Future<ModeState> Function() update) async {
    try {
      state = AsyncData(await update());
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }
}
