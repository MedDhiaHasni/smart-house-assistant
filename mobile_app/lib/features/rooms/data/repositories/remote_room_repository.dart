import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../domain/repositories/room_repository.dart';
import '../models/room_models.dart';

class RemoteRoomRepository implements RoomRepository {
  RemoteRoomRepository(this._dio);

  final Dio _dio;

  @override
  Future<List<RoomCard>> getRooms() async {
    final responses = await Future.wait([
      _dio.get<Object?>('/rooms'),
      _dio.get<Object?>('/devices'),
    ]);
    final rooms = _dataList(responses[0].data, 'rooms');
    final devices = _dataList(responses[1].data, 'devices');
    return rooms.map((room) => _parseRoom(room, devices)).toList();
  }

  @override
  Future<void> sendCommand(
    String deviceId,
    String command,
    Map<String, Object?> parameters,
  ) async {
    await _dio.post<Object?>(
      '/devices/${Uri.encodeComponent(deviceId)}/command',
      data: {'command': command, 'parameters': parameters},
    );
  }

  List<Map> _dataList(Object? value, String name) {
    if (value is! Map || value['data'] is! List) {
      throw FormatException('$name response must contain a data list.');
    }
    return (value['data'] as List).map((item) {
      if (item is! Map) throw FormatException('$name item must be an object.');
      final attributes = item['attributes'];
      return attributes is Map ? {...attributes, ...item} : item;
    }).toList();
  }

  RoomCard _parseRoom(Map room, List<Map> devices) {
    final id = (room['documentId'] ?? room['id'])?.toString();
    final name = room['name'];
    if (id == null || name is! String || name.isEmpty) {
      throw const FormatException('Room is missing its identifier or name.');
    }
    final roomDevices = devices.where((device) {
      final relation = device['room'];
      if (relation is Map) {
        return (relation['documentId'] ?? relation['id'])?.toString() == id;
      }
      final deviceName = device['name'];
      return deviceName is String &&
          deviceName.toLowerCase().startsWith(name.toLowerCase());
    }).toList();
    final roomColor = _roomColor(name);
    final stateByDevice = roomDevices.map(_parseDevice).toList();
    final temperature =
        roomDevices
            .map((device) => device['state'])
            .whereType<Map>()
            .map((state) => state['temperature'])
            .whereType<num>()
            .map((value) => value.toDouble())
            .firstOrNull ??
        20;
    final status = room['status']?.toString() ?? 'unknown';
    return RoomCard(
      id: id,
      name: name,
      icon: _roomIcon(name),
      color: roomColor,
      status: status,
      statusColor: status == 'occupied' ? Colors.green : Colors.grey,
      temperature: temperature,
      devices: stateByDevice.length,
      devicesList: stateByDevice,
    );
  }

  RoomDevice _parseDevice(Map device) {
    final name = device['name'];
    final id = (device['externalId'] ?? device['documentId'] ?? device['id'])
        ?.toString();
    final category = device['category']?.toString() ?? '';
    final state = device['state'];
    if (name is! String || id == null || state is! Map) {
      throw const FormatException('Device is missing required fields.');
    }
    final enabled = state['enabled'] == true;
    final temperature = state['temperature'];
    final toggle = category == 'lighting' || category == 'security';
    return RoomDevice(
      deviceId: id,
      name: name,
      state: state.entries
          .map((entry) => '${entry.key}: ${entry.value}')
          .join(', '),
      icon: category == 'climate'
          ? Icons.thermostat_rounded
          : category == 'lighting'
          ? Icons.lightbulb_rounded
          : Icons.devices_other_rounded,
      isToggle: toggle,
      enabled: enabled,
      value: temperature is num ? temperature.toDouble() : (enabled ? 100 : 0),
    );
  }

  IconData _roomIcon(String name) {
    final normalized = name.toLowerCase();
    if (normalized.contains('bed')) return Icons.bed_rounded;
    if (normalized.contains('kitchen')) return Icons.kitchen_rounded;
    if (normalized.contains('garage')) return Icons.garage_rounded;
    return Icons.chair_alt_rounded;
  }

  Color _roomColor(String name) {
    final normalized = name.toLowerCase();
    if (normalized.contains('bed')) return Colors.purple;
    if (normalized.contains('kitchen')) return Colors.orange;
    if (normalized.contains('garage')) return Colors.indigo;
    return Colors.blue;
  }
}
