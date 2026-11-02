import 'package:flutter/material.dart';

import '../models/routine_models.dart';

List<RoutineRecord> smartHomeRoutines() {
  return [
    RoutineRecord(
      id: 'good_morning',
      name: 'Good morning',
      trigger: '07:00 weekdays',
      enabled: true,
      health: 'OK',
      healthColor: Colors.green,
      lastRun: 'Today 07:00',
      flow: [
        'Trigger: time = 07:00 on weekdays',
        'Conditions: home occupancy > 0, weather = clear',
        'Actions: open shutters, kitchen lights on, set heating to 21°C',
        'Exception: guest mode disables action',
      ],
      history: [
        ExecutionEntry(
          title: 'Executed',
          detail: 'Shutters opened successfully',
          time: 'Today 07:00',
        ),
        ExecutionEntry(
          title: 'Skipped',
          detail: 'Guest mode active, no kitchen lights',
          time: 'Tue 07:00',
        ),
      ],
    ),
    RoutineRecord(
      id: 'leaving_home',
      name: 'Leaving home',
      trigger: 'Last person leaves',
      enabled: true,
      health: 'Warning',
      healthColor: Colors.amber,
      lastRun: 'Yesterday 19:41',
      flow: [
        'Trigger: last person leaves',
        'Conditions: everyone away = true',
        'Actions: lights off, arm alarm, close shutters',
        'Exception: holiday mode disable',
      ],
      history: [
        ExecutionEntry(
          title: 'Executed',
          detail: 'Alarm armed and shutters closed',
          time: 'Yesterday 19:41',
        ),
        ExecutionEntry(
          title: 'Failed',
          detail: 'Garage light remained on',
          time: 'Tue 18:11',
        ),
      ],
    ),
    RoutineRecord(
      id: 'eco_saver',
      name: 'Eco saver',
      trigger: 'Peak hours',
      enabled: true,
      health: 'OK',
      healthColor: Colors.green,
      lastRun: 'Today 12:14',
      flow: [
        'Trigger: energy > threshold',
        'Conditions: outside peak hours / high consumption',
        'Actions: suspend non-essential devices',
        'Exception: security devices always stay online',
      ],
      history: [
        ExecutionEntry(
          title: 'Executed',
          detail: 'Non-essential devices suspended',
          time: 'Today 12:14',
        ),
      ],
    ),
  ];
}
