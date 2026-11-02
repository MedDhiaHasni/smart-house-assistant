class ClimateSnapshot {
  const ClimateSnapshot({
    required this.roomName,
    required this.temperature,
    required this.heaterDeviceId,
  });

  final String roomName;
  final double temperature;
  final String? heaterDeviceId;
}
