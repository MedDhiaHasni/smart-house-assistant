import 'package:flutter/material.dart';

class ConnectionChip extends StatelessWidget {
  final String label;
  final bool connected;

  const ConnectionChip({
    super.key,
    required this.label,
    required this.connected,
  });

  @override
  Widget build(BuildContext context) {
    final color = connected
        ? Colors.green
        : Theme.of(context).colorScheme.error;
    return Chip(
      avatar: Icon(
        connected ? Icons.wifi_rounded : Icons.wifi_off_rounded,
        size: 18,
        color: color,
      ),
      label: Text(label),
    );
  }
}
