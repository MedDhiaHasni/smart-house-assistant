import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/di/providers.dart';

class StatusChipsRow extends ConsumerWidget {
  const StatusChipsRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(connectionModeProvider);
    final socketStatus = ref.watch(socketStatusProvider).valueOrNull;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        const Chip(
          label: Text('Home mode'),
          avatar: Icon(Icons.home_outlined, size: 18),
        ),
        Chip(
          label: Text('${mode.name} · ${socketStatus ?? 'connecting'}'),
          avatar: const Icon(Icons.wifi_rounded, size: 18),
        ),
        const Chip(
          label: Text('Security armed'),
          avatar: Icon(Icons.shield_rounded, size: 18),
        ),
      ],
    );
  }
}
