import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../providers/routines_provider.dart';

class RoutinesScreen extends ConsumerWidget {
  const RoutinesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routines = ref.watch(routinesControllerProvider);
    final controller = ref.read(routinesControllerProvider.notifier);
    return routines.when(
      data: (items) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Routines',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          ...items.map(
            (routine) => Card(
              margin: const EdgeInsets.only(bottom: 14),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: routine.healthColor.withValues(alpha: 0.12),
                  child: Icon(Icons.auto_awesome, color: routine.healthColor),
                ),
                title: Text(routine.name),
                subtitle: Text(
                  '${routine.trigger} • ${routine.lastRun} • ${routine.health}',
                ),
                trailing: Switch(
                  value: routine.enabled,
                  onChanged: (enabled) =>
                      controller.setEnabled(routine.id, enabled),
                ),
                onTap: () => context.pushNamed(
                  RouteNames.routineDetail,
                  pathParameters: {'id': routine.id},
                ),
              ),
            ),
          ),
        ],
      ),
      error: (error, stackTrace) => Center(child: Text(error.toString())),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }
}
