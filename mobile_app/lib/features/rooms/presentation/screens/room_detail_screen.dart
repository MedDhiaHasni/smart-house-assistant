import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/room_models.dart';
import '../providers/rooms_provider.dart';

class RoomDetailScreen extends ConsumerWidget {
  final String roomId;

  const RoomDetailScreen({super.key, required this.roomId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rooms = ref.watch(roomsProvider);
    final controller = ref.read(roomsProvider.notifier);
    var title = 'Room';
    for (final room in rooms.valueOrNull ?? const <RoomCard>[]) {
      if (room.id == roomId) title = room.name;
    }
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: rooms.when(
        data: (items) {
          RoomCard? room;
          for (final item in items) {
            if (item.id == roomId) room = item;
          }
          if (room == null) return const Center(child: Text('Room not found.'));
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current temperature',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${room.temperature}°C',
                        style: Theme.of(context).textTheme.displaySmall
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ...room.devicesList.map(
                (device) => Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Icon(device.icon, color: room!.color),
                    title: Text(device.name),
                    subtitle: Text(device.state),
                    trailing: device.isToggle
                        ? Switch(
                            value: device.enabled,
                            onChanged: (enabled) => controller.sendCommand(
                              device.deviceId,
                              enabled ? 'power_on' : 'power_off',
                              {'enabled': enabled},
                            ),
                          )
                        : SizedBox(
                            width: 120,
                            child: Slider(
                              value: device.value.clamp(0, 100),
                              onChanged: (_) {},
                              onChangeEnd: (temperature) =>
                                  controller.sendCommand(
                                    device.deviceId,
                                    'set_temperature',
                                    {'temperature': temperature},
                                  ),
                              min: 0,
                              max: 100,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          );
        },
        error: (error, stackTrace) => Center(child: Text(error.toString())),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
