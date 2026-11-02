import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../providers/conflicts_provider.dart';

class ConflictsScreen extends ConsumerWidget {
  const ConflictsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conflicts = ref.watch(conflictsControllerProvider);
    final controller = ref.read(conflictsControllerProvider.notifier);
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.conflictsAndRobustness)),
      body: conflicts.when(
        data: (items) => items.isEmpty
            ? Center(child: Text(l10n.noConflicts))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final conflict = items[index];
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.warning_amber_rounded),
                            title: Text(conflict.deviceName),
                            subtitle: Text(
                              '${conflict.firstRule} • ${conflict.secondRule}',
                            ),
                          ),
                          Text(l10n.resolveByPriority),
                          Text(conflict.resolution),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => controller.resolve(conflict.id),
                              child: Text(l10n.resolve),
                            ),
                          ),
                        ],
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
}
