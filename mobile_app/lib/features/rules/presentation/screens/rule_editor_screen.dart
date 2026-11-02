import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../providers/rules_provider.dart';

class RuleEditorScreen extends ConsumerWidget {
  const RuleEditorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rules = ref.watch(rulesControllerProvider);
    final controller = ref.read(rulesControllerProvider.notifier);
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.ruleEditor)),
      body: rules.when(
        data: (items) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final rule = items[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(rule.name),
                      subtitle: Text('${l10n.priority}: ${rule.priority}'),
                      value: rule.enabled,
                      onChanged: (enabled) =>
                          controller.toggleRule(rule.id, enabled),
                    ),
                    const Divider(),
                    _RuleStep(label: 'Trigger', value: rule.trigger),
                    _RuleStep(label: 'Condition', value: rule.condition),
                    _RuleStep(label: 'Action', value: rule.action),
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

class _RuleStep extends StatelessWidget {
  const _RuleStep({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 8),
    child: Text('$label: $value'),
  );
}
