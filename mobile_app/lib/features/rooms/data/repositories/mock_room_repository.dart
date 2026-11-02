import '../datasources/mock_rooms_data_source.dart';
import '../../domain/repositories/room_repository.dart';
import '../models/room_models.dart';

class MockRoomRepository implements RoomRepository {
  final Map<String, bool> _enabledOverrides = {};
  final Map<String, double> _temperatureOverrides = {};

  @override
  Future<List<RoomCard>> getRooms() async => smartHomeRooms()
      .map(
        (room) => RoomCard(
          id: room.id,
          name: room.name,
          icon: room.icon,
          color: room.color,
          status: room.status,
          statusColor: room.statusColor,
          temperature: room.temperature,
          devices: room.devices,
          devicesList: room.devicesList
              .map(
                (device) => RoomDevice(
                  deviceId: device.deviceId,
                  name: device.name,
                  state: device.state,
                  icon: device.icon,
                  isToggle: device.isToggle,
                  enabled: _enabledOverrides[device.deviceId] ?? device.enabled,
                  value: _temperatureOverrides[device.deviceId] ?? device.value,
                ),
              )
              .toList(),
        ),
      )
      .toList();

  @override
  Future<void> sendCommand(
    String deviceId,
    String command,
    Map<String, Object?> parameters,
  ) async {
    if (command == 'power_on') _enabledOverrides[deviceId] = true;
    if (command == 'power_off') _enabledOverrides[deviceId] = false;
    final temperature = parameters['temperature'];
    if (command == 'set_temperature' && temperature is num) {
      _temperatureOverrides[deviceId] = temperature.toDouble();
    }
  }
}
