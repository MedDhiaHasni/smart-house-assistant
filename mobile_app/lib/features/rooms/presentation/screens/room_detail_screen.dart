import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/room_models.dart';
import '../providers/rooms_provider.dart';

class RoomDetailScreen extends ConsumerWidget {
  final String roomId;

  const RoomDetailScreen({super.key, required this.roomId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final rooms = ref.watch(roomsProvider);
    final controller = ref.read(roomsProvider.notifier);
    var title = 'Room';
    for (final room in rooms.valueOrNull ?? const <RoomCard>[]) {
      if (room.id == roomId) title = room.name;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: false,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: rooms.when(
        data: (items) {
          RoomCard? found;
          for (final item in items) {
            if (item.id == roomId) found = item;
          }
          if (found == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.meeting_room_outlined,
                      size: 56,
                      color: scheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Room not found.',
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            );
          }
          final room = found;
          final Color roomColor = room.color;
          final devices = room.devicesList.toList();

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(roomsProvider);
              await Future<void>.delayed(const Duration(milliseconds: 600));
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              children: [
                _TemperatureCard(
                  temperature: '${room.temperature}',
                  roomColor: roomColor,
                  roomIcon: room.icon,
                  deviceCount: devices.length,
                )
                    .animate()
                    .fadeIn(duration: 350.ms)
                    .slideY(begin: 0.06, end: 0, curve: Curves.easeOut),
                const SizedBox(height: 24),
                Text(
                  'Devices',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                for (var i = 0; i < devices.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _DeviceCard(
                      device: devices[i],
                      roomColor: roomColor,
                      onToggle: (enabled) => controller.sendCommand(
                        devices[i].deviceId,
                        enabled ? 'power_on' : 'power_off',
                        {'enabled': enabled},
                      ),
                      onValueEnd: (temperature) => controller.sendCommand(
                        devices[i].deviceId,
                        'set_temperature',
                        {'temperature': temperature},
                      ),
                    )
                        .animate(delay: (60 * i).ms)
                        .fadeIn(duration: 350.ms)
                        .slideY(begin: 0.06, end: 0, curve: Curves.easeOut),
                  ),
              ],
            ),
          );
        },
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 48,
                  color: scheme.error,
                ),
                const SizedBox(height: 12),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: scheme.onSurfaceVariant),
                ),
                const SizedBox(height: 16),
                FilledButton.tonalIcon(
                  onPressed: () => ref.invalidate(roomsProvider),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _TemperatureCard extends StatelessWidget {
  const _TemperatureCard({
    required this.temperature,
    required this.roomColor,
    required this.roomIcon,
    required this.deviceCount,
  });

  final String temperature;
  final Color roomColor;
  final IconData roomIcon;
  final int deviceCount;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: scheme.outlineVariant),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            roomColor.withValues(alpha: 0.16),
            scheme.surfaceContainerLow,
          ],
          stops: const [0, 0.7],
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current temperature',
                  style: textTheme.labelLarge?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$temperature°C',
                  style: textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '$deviceCount devices',
                    style: textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 64,
            width: 64,
            decoration: BoxDecoration(
              color: roomColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Icon(roomIcon, color: roomColor, size: 32),
          ),
        ],
      ),
    );
  }
}

class _DeviceCard extends StatelessWidget {
  const _DeviceCard({
    required this.device,
    required this.roomColor,
    required this.onToggle,
    required this.onValueEnd,
  });

  final dynamic device;
  final Color roomColor;
  final ValueChanged<bool> onToggle;
  final ValueChanged<double> onValueEnd;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final bool isToggle = device.isToggle;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: roomColor.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(device.icon, color: roomColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${device.name}',
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${device.state}',
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (isToggle)
                Switch(value: device.enabled, onChanged: onToggle),
            ],
          ),
          if (!isToggle)
            _DeviceSlider(
              initialValue: (device.value as num).toDouble(),
              color: roomColor,
              onChangeEnd: onValueEnd,
            ),
        ],
      ),
    );
  }
}

class _DeviceSlider extends StatefulWidget {
  const _DeviceSlider({
    required this.initialValue,
    required this.color,
    required this.onChangeEnd,
  });

  final double initialValue;
  final Color color;
  final ValueChanged<double> onChangeEnd;

  @override
  State<_DeviceSlider> createState() => _DeviceSliderState();
}

class _DeviceSliderState extends State<_DeviceSlider> {
  double? _drag;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final value = (_drag ?? widget.initialValue).clamp(0, 100).toDouble();

    return Row(
      children: [
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: widget.color,
              thumbColor: widget.color,
              inactiveTrackColor: widget.color.withValues(alpha: 0.2),
              trackHeight: 6,
            ),
            child: Slider(
              value: value,
              min: 0,
              max: 100,
              onChanged: (v) => setState(() => _drag = v),
              onChangeEnd: (v) {
                widget.onChangeEnd(v);
                setState(() => _drag = null);
              },
            ),
          ),
        ),
        SizedBox(
          width: 44,
          child: Text(
            value.round().toString(),
            textAlign: TextAlign.end,
            style: textTheme.labelLarge?.copyWith(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}