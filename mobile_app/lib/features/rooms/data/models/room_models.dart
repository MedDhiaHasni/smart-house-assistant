import 'package:flutter/material.dart';

class RoomCard {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final String status;
  final Color statusColor;
  final double temperature;
  final int devices;
  final List<RoomDevice> devicesList;

  RoomCard({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.status,
    required this.statusColor,
    required this.temperature,
    required this.devices,
    required this.devicesList,
  });
}

class RoomDevice {
  final String? deviceId;
  final String name;
  final String state;
  final IconData icon;
  final bool isToggle;
  final bool enabled;
  final double value;

  RoomDevice({
    this.deviceId,
    required this.name,
    required this.state,
    required this.icon,
    required this.isToggle,
    required this.enabled,
    required this.value,
  });
}
