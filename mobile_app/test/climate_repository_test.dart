import 'package:flutter_test/flutter_test.dart';
import 'package:smart_house_assistant/features/climate/data/repositories/room_climate_repository.dart';
import 'package:smart_house_assistant/features/rooms/data/repositories/mock_room_repository.dart';

void main() {
  late RoomClimateRepository repository;

  setUp(() {
    repository = RoomClimateRepository(MockRoomRepository());
  });

  test('maps the living room and heater into a climate snapshot', () async {
    final snapshot = await repository.getCurrentClimate();

    expect(snapshot, isNotNull);
    expect(snapshot!.roomName.toLowerCase(), contains('living'));
    expect(snapshot.heaterDeviceId, isNotNull);
    expect(snapshot.temperature, inInclusiveRange(15, 30));
  });

  test('sends a target temperature through the room repository', () async {
    await expectLater(repository.setTargetTemperature(22), completes);
  });
}
