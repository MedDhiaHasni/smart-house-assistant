import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../providers/modes_provider.dart';

class ModesScreen extends ConsumerWidget {
  const ModesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(modesControllerProvider);
    final controller = ref.read(modesControllerProvider.notifier);
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.modesAndOverrides)),
      body: state.when(
        data: (modeState) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(l10n.modeHome, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            RadioGroup<String>(
              groupValue: modeState.activeMode,
              onChanged: (mode) {
                if (mode != null) controller.setMode(mode);
              },
              child: Column(
                children: [
                  for (final mode in modeState.availableModes)
                    RadioListTile<String>(value: mode, title: Text(mode)),
                ],
              ),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.modesAndOverrides,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  tooltip: l10n.addOverride,
                  onPressed: () => controller.addTemporaryOverride(
                    deviceName: 'Living room lights',
                    value: 'On',
                  ),
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
            for (final override in modeState.overrides)
              Card(
                child: ListTile(
                  title: Text(override.deviceName),
                  subtitle: Text(
                    '${override.value} • ${MaterialLocalizations.of(context).formatTimeOfDay(TimeOfDay.fromDateTime(override.expiresAt))}',
                  ),
                  trailing: IconButton(
                    tooltip: l10n.cancel,
                    onPressed: () => controller.removeOverride(override.id),
                    icon: const Icon(Icons.close),
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
}
