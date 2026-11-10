import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../providers/rules_provider.dart';

class RuleEditorScreen extends ConsumerWidget {
  const RuleEditorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final rules = ref.watch(rulesControllerProvider);
    final controller = ref.read(rulesControllerProvider.notifier);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.ruleEditor),
        centerTitle: false,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: rules.when(
        data: (items) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(rulesControllerProvider);
            await Future<void>.delayed(const Duration(milliseconds: 600));
          },
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final rule = items[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _RuleCard(
                  rule: rule,
                  priorityLabel: '${l10n.priority}: ${rule.priority}',
                  onToggle: (enabled) =>
                      controller.toggleRule(rule.id, enabled),
                )
                    .animate(delay: (60 * index).ms)
                    .fadeIn(duration: 350.ms)
                    .slideY(begin: 0.06, end: 0, curve: Curves.easeOut),
              );
            },
          ),
        ),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 48,
                  color: scheme.error,
                ),
                const SizedBox(height: 12),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: scheme.onSurfaceVariant),
                ),
                const SizedBox(height: 16),
                FilledButton.tonalIcon(
                  onPressed: () => ref.invalidate(rulesControllerProvider),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _RuleCard extends StatelessWidget {
  const _RuleCard({
    required this.rule,
    required this.priorityLabel,
    required this.onToggle,
  });

  final dynamic rule;
  final String priorityLabel;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final bool enabled = rule.enabled;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 12, 18),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${rule.name}',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: enabled
                            ? scheme.onSurface
                            : scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: scheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.flag_rounded,
                            size: 14,
                            color: scheme.onSecondaryContainer,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            priorityLabel,
                            style: textTheme.labelMedium?.copyWith(
                              color: scheme.onSecondaryContainer,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Switch(value: enabled, onChanged: onToggle),
            ],
          ),
          const SizedBox(height: 16),
          _RuleStep(
            icon: Icons.bolt_rounded,
            label: 'Trigger',
            value: '${rule.trigger}',
            background: scheme.primaryContainer,
            foreground: scheme.onPrimaryContainer,
            showConnector: true,
          ),
          _RuleStep(
            icon: Icons.rule_rounded,
            label: 'Condition',
            value: '${rule.condition}',
            background: scheme.tertiaryContainer,
            foreground: scheme.onTertiaryContainer,
            showConnector: true,
          ),
          _RuleStep(
            icon: Icons.play_arrow_rounded,
            label: 'Action',
            value: '${rule.action}',
            background: scheme.secondaryContainer,
            foreground: scheme.onSecondaryContainer,
            showConnector: false,
          ),
        ],
      ),
    );
  }
}

class _RuleStep extends StatelessWidget {
  const _RuleStep({
    required this.icon,
    required this.label,
    required this.value,
    required this.background,
    required this.foreground,
    required this.showConnector,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color background;
  final Color foreground;
  final bool showConnector;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Container(
                  height: 36,
                  width: 36,
                  decoration: BoxDecoration(
                    color: background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: foreground, size: 20),
                ),
                if (showConnector)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: scheme.outlineVariant,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: showConnector ? 14 : 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: textTheme.labelMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}