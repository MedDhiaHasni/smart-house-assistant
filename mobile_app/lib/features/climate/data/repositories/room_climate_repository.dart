import '../../../rooms/domain/repositories/room_repository.dart';
import '../../domain/entities/climate_snapshot.dart';
import '../../domain/repositories/climate_repository.dart';

class RoomClimateRepository implements ClimateRepository {
  RoomClimateRepository(this._roomRepository);

  final RoomRepository _roomRepository;

  @override
  Future<ClimateSnapshot?> getCurrentClimate() async {
    final rooms = await _roomRepository.getRooms();
    for (final room in rooms) {
      if (!room.name.toLowerCase().contains('living')) continue;
      final heater = room.devicesList.where(
        (device) => device.name.toLowerCase().contains('heater'),
      );
      return ClimateSnapshot(
        roomName: room.name,
        temperature: room.temperature,
        heaterDeviceId: heater.isEmpty ? null : heater.first.deviceId,
      );
    }
    return null;
  }

  @override
  Future<void> setTargetTemperature(double temperature) async {
    final snapshot = await getCurrentClimate();
    final deviceId = snapshot?.heaterDeviceId;
    if (deviceId == null) {
      throw StateError('The climate room has no configured heater.');
    }
    await _roomRepository.sendCommand(deviceId, 'set_temperature', {
      'temperature': temperature,
    });
  }
}
