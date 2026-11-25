import 'package:flutter_test/flutter_test.dart';
import 'package:nepal_lend/core/config/env.dart';

void main() {
  test('default environment is mock', () {
    final env = Env.fromEnvironment();
    expect(env.environment, AppEnvironment.mock);
    expect(env.isMock, isTrue);
    expect(env.apiBaseUrl, contains('/api/v1'));
  });
}
