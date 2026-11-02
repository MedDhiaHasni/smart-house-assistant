import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../domain/repositories/timeline_repository.dart';
import '../models/timeline_model.dart';

class RemoteTimelineRepository implements TimelineRepository {
  RemoteTimelineRepository(this._dio);

  final Dio _dio;

  @override
  Future<List<TimelineEntry>> getTimeline() async {
    final response = await _dio.get<Object?>('/timeline');
    final payload = response.data;
    if (payload is! Map || payload['data'] is! List) {
      throw const FormatException(
        'Timeline response must contain a data list.',
      );
    }
    return (payload['data'] as List).map(_parseEntry).toList();
  }

  TimelineEntry _parseEntry(Object? value) {
    if (value is! Map) {
      throw const FormatException('Timeline entries must be objects.');
    }
    final type = value['type'];
    final title = value['title'];
    final detail = value['detail'];
    final occurredAt = value['occurredAt'];
    if (type is! String ||
        title is! String ||
        detail is! String ||
        occurredAt is! String) {
      throw const FormatException('Timeline entry is missing required fields.');
    }
    final time = DateTime.tryParse(occurredAt);
    if (time == null) {
      throw const FormatException(
        'Timeline occurrence time must be an ISO timestamp.',
      );
    }
    final isEvent = type == 'event';
    final color = isEvent ? Colors.amber : Colors.green;
    return TimelineEntry(
      title: title,
      detail: detail,
      time: time.toLocal().toString(),
      icon: isEvent ? Icons.sensors_rounded : Icons.rule_rounded,
      color: color,
    );
  }
}
