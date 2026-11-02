class AppSettings {
  const AppSettings({
    required this.themeMode,
    required this.languageCode,
    required this.connectionMode,
  });

  final String themeMode;
  final String? languageCode;
  final String connectionMode;
}
