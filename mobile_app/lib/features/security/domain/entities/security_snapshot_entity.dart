class SecurityDeviceEntity {
  const SecurityDeviceEntity({required this.name, required this.status});

  final String name;
  final String status;
}

class SecuritySnapshotEntity {
  const SecuritySnapshotEntity({
    required this.activeMode,
    required this.alerts,
    required this.devices,
  });

  final String activeMode;
  final List<String> alerts;
  final List<SecurityDeviceEntity> devices;

  bool get isArmed => activeMode == 'Away' || activeMode == 'Vacation';
}
