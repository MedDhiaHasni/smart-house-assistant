import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../providers/timeline_provider.dart';

class TimelineScreen extends ConsumerWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(timelineProvider);
    return events.when(
      data: (items) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Timeline',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 14),
          ...items.map(
            (event) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: event.color.withValues(alpha: 0.12),
                  child: Icon(event.icon, color: event.color),
                ),
                title: Text(event.title),
                subtitle: Text(event.detail),
                trailing: Text(event.time),
                onTap: () => context.pushNamed(RouteNames.explain),
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
