import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/di/providers.dart';
import '../../../../core/constants/connection_mode.dart';
import '../../domain/repositories/room_repository.dart';
import '../../data/models/room_models.dart';

final roomsProvider =
    StateNotifierProvider<RoomsController, AsyncValue<List<RoomCard>>>((ref) {
      final controller = RoomsController(ref.watch(roomRepositoryProvider));
      if (ref.watch(connectionModeProvider) == ConnectionMode.live) {
        final subscription = ref.watch(socketServiceProvider).messages.listen((
          message,
        ) {
          if (message.event == 'device:state') {
            unawaited(controller.load());
          }
        });
        ref.onDispose(() => unawaited(subscription.cancel()));
      }
      return controller;
    });

class RoomsController extends StateNotifier<AsyncValue<List<RoomCard>>> {
  RoomsController(this._repository) : super(const AsyncLoading()) {
    load();
  }

  final RoomRepository _repository;

  Future<void> load() async {
    state = const AsyncLoading();
    try {
      state = AsyncData(await _repository.getRooms());
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> sendCommand(
    String? deviceId,
    String command,
    Map<String, Object?> parameters,
  ) async {
    if (deviceId == null) {
      throw StateError('The selected device has no configured identifier.');
    }
    try {
      await _repository.sendCommand(deviceId, command, parameters);
      state = AsyncData(await _repository.getRooms());
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }
}
