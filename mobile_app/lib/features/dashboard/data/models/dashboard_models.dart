import 'package:flutter/material.dart';

class DashboardData {
  final List<EventItem> events;
  final List<RoutineCard> routines;
  final String mode;
  final String climateValue;
  final String energyValue;
  final String securityAlerts;
  final int activeRoutineCount;

  DashboardData({
    required this.events,
    required this.routines,
    this.mode = 'Home',
    this.climateValue = '21.4°C',
    this.energyValue = '6.3 kWh',
    this.securityAlerts = '2 alerts',
    this.activeRoutineCount = 5,
  });
}

class EventItem {
  final String title;
  final String description;
  final String time;
  final IconData icon;
  final Color severityColor;

  EventItem({
    required this.title,
    required this.description,
    required this.time,
    required this.icon,
    required this.severityColor,
  });
}

class RoutineCard {
  final String id;
  final String name;
  final String trigger;
  final String lastRun;
  final bool enabled;
  final String health;
  final Color healthColor;

  RoutineCard({
    required this.id,
    required this.name,
    required this.trigger,
    required this.lastRun,
    required this.enabled,
    required this.health,
    required this.healthColor,
  });
}
