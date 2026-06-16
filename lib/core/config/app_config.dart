class AppConfig {
  const AppConfig._();

  static const appName = 'Fresh Farm';
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.freshfarm.local',
  );
}
