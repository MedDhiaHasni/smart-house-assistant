import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../modes/presentation/providers/modes_provider.dart';
import '../providers/security_provider.dart';

class SecurityScreen extends ConsumerWidget {
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(securitySnapshotProvider);
    final modeController = ref.read(modesControllerProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: const Text('Security')),
      body: snapshot.when(
        data: (security) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Alarm status'),
                        Text(
                          security.isArmed
                              ? 'Armed • ${security.activeMode} mode'
                              : 'Disarmed • ${security.activeMode} mode',
                        ),
                      ],
                    ),
                    Switch(
                      value: security.isArmed,
                      onChanged: (armed) =>
                          modeController.setMode(armed ? 'Away' : 'Home'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            for (final alert in security.alerts)
              ListTile(
                leading: const Icon(Icons.warning_amber_rounded),
                title: Text(alert),
              ),
            ...security.devices.map(
              (device) => Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Icon(_iconFor(device.name), color: Colors.red),
                  title: Text(device.name),
                  subtitle: Text(device.status),
                  trailing: const Icon(Icons.chevron_right),
                ),
              ),
            ),
          ],
        ),
        error: (error, stackTrace) => Center(child: Text(error.toString())),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  IconData _iconFor(String name) => switch (name.toLowerCase()) {
    final value when value.contains('garage') => Icons.garage_rounded,
    final value when value.contains('door') => Icons.door_front_door_rounded,
    _ => Icons.videocam_rounded,
  };
}
