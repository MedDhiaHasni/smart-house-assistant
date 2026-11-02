import 'package:flutter/material.dart';

import '../models/timeline_model.dart';

List<TimelineEntry> smartHomeTimeline() {
  return [
    TimelineEntry(
      title: 'Comfort rule fired',
      detail: 'The living room heater was adjusted to 21°C',
      time: 'Now',
      icon: Icons.thermostat_rounded,
      color: Colors.green,
    ),
    TimelineEntry(
      title: 'Window event',
      detail: 'Bedroom window opened',
      time: '18 min ago',
      icon: Icons.warning_amber_rounded,
      color: Colors.amber,
    ),
    TimelineEntry(
      title: 'Alarm armed',
      detail: 'Security mode switched to away',
      time: '1 hour ago',
      icon: Icons.shield_rounded,
      color: Colors.red,
    ),
  ];
}
