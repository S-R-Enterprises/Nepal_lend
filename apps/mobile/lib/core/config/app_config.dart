/// Build-time environment selection.
///
/// Set with `--dart-define=ENV=<name>` at build/run time:
/// ```sh
/// flutter run --dart-define=ENV=staging
/// flutter run --dart-define=ENV=mock     # offline canned responses
/// ```
/// Unknown or missing values fall back to [AppEnv.dev].
enum AppEnv {
  dev,
  staging,
  prod,
  mock;

  static AppEnv fromName(String name) =>
      AppEnv.values.firstWhere((e) => e.name == name, orElse: () => AppEnv.dev);
}

class AppConfig {
  AppConfig._();

  static const String _rawEnv = String.fromEnvironment('ENV', defaultValue: 'dev');

  static final AppEnv env = AppEnv.fromName(_rawEnv);

  static bool get useMock => env == AppEnv.mock;
  static bool get isDev => env == AppEnv.dev;

  /// API base URL per environment.
  ///
  /// staging/prod hosts are placeholders until the domain + API hosting are
  /// provisioned (Foundations plan, Week 2 accounts).
  static String get apiBaseUrl => switch (env) {
        AppEnv.dev => 'http://localhost:3000/api/v1',
        AppEnv.staging => 'https://api-staging.nepallend.example.np/api/v1',
        AppEnv.prod => 'https://api.nepallend.example.np/api/v1',
        AppEnv.mock => 'mock://local/api/v1',
      };
}
