import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../providers/context_provider.dart';

class ContextViewerScreen extends ConsumerWidget {
  const ContextViewerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final variables = ref.watch(contextVariablesProvider);
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.contextViewer)),
      body: variables.when(
        data: (items) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final variable = items[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: Icon(_iconFor(variable.id)),
                title: Text(variable.label),
                subtitle: Text('${variable.source} • ${variable.value}'),
                trailing: Text(
                  MaterialLocalizations.of(
                    context,
                  ).formatTimeOfDay(TimeOfDay.fromDateTime(variable.updatedAt)),
                ),
              ),
            );
          },
        ),
        error: (error, stackTrace) => Center(child: Text(error.toString())),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  IconData _iconFor(String id) => switch (id) {
    'occupancy' => Icons.people_outline,
    'weather' => Icons.cloud_outlined,
    'bedroom-window' => Icons.window_outlined,
    _ => Icons.bolt_outlined,
  };
}
