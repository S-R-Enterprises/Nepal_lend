import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Android manifest enables FCM installation registration', () {
    final manifest =
        File('android/app/src/main/AndroidManifest.xml').readAsStringSync();

    final flag = RegExp(
      r'<meta-data\s+android:name="firebase_messaging_installation_id_enabled"\s+android:value="true"\s*/>',
    ).firstMatch(manifest);

    expect(flag, isNotNull);
  });
}
