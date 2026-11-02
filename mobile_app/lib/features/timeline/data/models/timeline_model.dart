import 'package:flutter/material.dart';

class TimelineEntry {
  final String title;
  final String detail;
  final String time;
  final IconData icon;
  final Color color;

  TimelineEntry({
    required this.title,
    required this.detail,
    required this.time,
    required this.icon,
    required this.color,
  });
}
