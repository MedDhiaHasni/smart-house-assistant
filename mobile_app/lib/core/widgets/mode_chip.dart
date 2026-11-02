import 'package:flutter/material.dart';

class ModeChip extends StatelessWidget {
  final String mode;
  final IconData icon;

  const ModeChip({super.key, required this.mode, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(mode),
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
    );
  }
}
