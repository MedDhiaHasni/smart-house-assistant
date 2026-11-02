import '../../data/models/room_models.dart';

abstract interface class RoomRepository {
  Future<List<RoomCard>> getRooms();

  Future<void> sendCommand(
    String deviceId,
    String command,
    Map<String, Object?> parameters,
  );
}
