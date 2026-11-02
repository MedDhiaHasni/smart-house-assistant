class OverrideEntity {
  const OverrideEntity({
    required this.id,
    required this.deviceName,
    required this.value,
    required this.expiresAt,
  });

  final String id;
  final String deviceName;
  final String value;
  final DateTime expiresAt;
}

class ModeState {
  const ModeState({
    required this.activeMode,
    required this.availableModes,
    required this.overrides,
  });

  final String activeMode;
  final List<String> availableModes;
  final List<OverrideEntity> overrides;

  ModeState copyWith({String? activeMode, List<OverrideEntity>? overrides}) =>
      ModeState(
        activeMode: activeMode ?? this.activeMode,
        availableModes: availableModes,
        overrides: overrides ?? this.overrides,
      );
}
