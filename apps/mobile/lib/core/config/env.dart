/// Runtime configuration for the app.
///
/// Set the environment at build/run time:
///   flutter run --dart-define=ENV=mock
///   flutter build apk --dart-define=ENV=dev --dart-define=API_BASE_URL=http://10.0.2.2:3000/api/v1
enum AppEnvironment { mock, dev, staging, prod }

class Env {
  const Env({
    required this.environment,
    required this.apiBaseUrl,
    this.maxLoanPaisa = 50000000,
    this.maxStakePaisa = 50000000,
  });

  final AppEnvironment environment;
  final String apiBaseUrl;
  final int maxLoanPaisa;
  final int maxStakePaisa;

  bool get isMock => environment == AppEnvironment.mock;
  bool get isProduction => environment == AppEnvironment.prod;

  static Env fromEnvironment() {
    final raw =
        const String.fromEnvironment('ENV', defaultValue: 'mock').toLowerCase();
    final environment = AppEnvironment.values.firstWhere(
      (value) => value.name == raw,
      orElse: () => AppEnvironment.mock,
    );

    final defaultUrl = switch (environment) {
      AppEnvironment.mock => 'https://mock.nepallend.local/api/v1',
      AppEnvironment.dev => 'http://10.0.2.2:3000/api/v1',
      AppEnvironment.staging => 'https://api-staging.nepallend.example/api/v1',
      AppEnvironment.prod => 'https://api.nepallend.example/api/v1',
    };

    return Env(
      environment: environment,
      apiBaseUrl: const String.fromEnvironment('API_BASE_URL').isEmpty
          ? defaultUrl
          : const String.fromEnvironment('API_BASE_URL'),
    );
  }

  @override
  String toString() => 'Env(${environment.name}, apiBaseUrl: $apiBaseUrl)';
}
