import 'dart:io';

import 'package:flutter/services.dart';

Future<ByteData> _bytes(String path) async =>
    ByteData.sublistView(await File(path).readAsBytes());

Future<void> loadAppFonts() async {
  final inter = FontLoader('Inter')..addFont(_bytes('assets/fonts/InterVariable.ttf'));
  await inter.load();

  final poppins = FontLoader('Poppins')
    ..addFont(_bytes('assets/fonts/Poppins-Regular.ttf'))
    ..addFont(_bytes('assets/fonts/Poppins-Medium.ttf'))
    ..addFont(_bytes('assets/fonts/Poppins-SemiBold.ttf'))
    ..addFont(_bytes('assets/fonts/Poppins-Bold.ttf'))
    ..addFont(_bytes('assets/fonts/Poppins-ExtraBold.ttf'));
  await poppins.load();
}
