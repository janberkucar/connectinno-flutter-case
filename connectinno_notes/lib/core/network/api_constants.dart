/// API base URL and path segments. Override with `--dart-define=API_BASE_URL=...`
abstract final class ApiConstants {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000',
  );

  static const String authSignUp = '/auth/signup';
  static const String authLogin = '/auth/login';
  static const String notes = '/notes';
}
