import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/di/providers.dart';
import '../../domain/entities/climate_snapshot.dart';
import '../../domain/repositories/climate_repository.dart';

final climateProvider =
    StateNotifierProvider<ClimateController, AsyncValue<ClimateSnapshot?>>(
      (ref) => ClimateController(ref.watch(climateRepositoryProvider)),
    );

class ClimateController extends StateNotifier<AsyncValue<ClimateSnapshot?>> {
  ClimateController(this._repository) : super(const AsyncLoading()) {
    load();
  }

  final ClimateRepository _repository;

  Future<void> load() async {
    state = const AsyncLoading();
    try {
      state = AsyncData(await _repository.getCurrentClimate());
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> setTargetTemperature(double temperature) async {
    try {
      await _repository.setTargetTemperature(temperature);
      await load();
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }
}
