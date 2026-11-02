import 'package:flutter/material.dart';

import '../models/dashboard_models.dart';

DashboardData smartHomeDashboard() {
  return DashboardData(
    events: [
      EventItem(
        title: 'Heating optimized',
        description: 'Comfort rule adjusted to 21°C',
        time: '2 min ago',
        icon: Icons.thermostat_rounded,
        severityColor: Colors.green,
      ),
      EventItem(
        title: 'Bedroom window open',
        description: 'Heating blocked for safety',
        time: '18 min ago',
        icon: Icons.warning_amber_rounded,
        severityColor: Colors.amber,
      ),
      EventItem(
        title: 'Night mode enabled',
        description: 'Doors locked and lights off',
        time: '1 hour ago',
        icon: Icons.lock_rounded,
        severityColor: Colors.blue,
      ),
    ],
    routines: [
      RoutineCard(
        id: 'good_morning',
        name: 'Good morning',
        trigger: '07:00 weekdays',
        lastRun: 'Today 7:00',
        enabled: true,
        health: 'OK',
        healthColor: Colors.green,
      ),
      RoutineCard(
        id: 'leaving_home',
        name: 'Leaving home',
        trigger: 'Last person leaves',
        lastRun: 'Yesterday 19:41',
        enabled: true,
        health: 'Warning',
        healthColor: Colors.amber,
      ),
      RoutineCard(
        id: 'eco_saver',
        name: 'Eco saver',
        trigger: 'Peak hours',
        lastRun: 'Today 12:14',
        enabled: true,
        health: 'OK',
        healthColor: Colors.green,
      ),
    ],
  );
}
