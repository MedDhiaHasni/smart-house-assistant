import 'package:flutter/material.dart';

class RoutineRecord {
  final String id;
  final String name;
  final String trigger;
  final bool enabled;
  final String health;
  final Color healthColor;
  final List<String> flow;
  final List<ExecutionEntry> history;
  final String lastRun;

  RoutineRecord({
    required this.id,
    required this.name,
    required this.trigger,
    required this.enabled,
    required this.health,
    required this.healthColor,
    required this.flow,
    required this.history,
    required this.lastRun,
  });
}

class ExecutionEntry {
  final String title;
  final String detail;
  final String time;

  ExecutionEntry({
    required this.title,
    required this.detail,
    required this.time,
  });
}
