/// App-wide configuration.
///
/// The API base URL can be overridden at build/run time with:
///   flutter run -d chrome --dart-define=API_BASE_URL=https://api.example.com/api/v1
class AppConfig {
  AppConfig._();

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.kimogames.online/api/v1',
  );
}
