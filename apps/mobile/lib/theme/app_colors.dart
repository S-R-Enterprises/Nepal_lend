import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color navy = Color(0xFF12284C);
  static const Color navyDark = Color(0xFF0A1628);
  static const Color teal = Color(0xFF1AA6A6);
  static const Color tealLight = Color(0xFFD4F1F1);
  static const Color mint = Color(0xFFE3F6F1);
  static const Color surface = Color(0xFFF5F8FA);
  static const Color secondary = Color(0xFF5B6472);
  static const Color border = Color(0xFFC9D1DA);
  static const Color white = Color(0xFFFFFFFF);
  static const Color riskLow = Color(0xFF16A34A);
  static const Color riskLowBg = Color(0xFFDCFCE7);
  static const Color riskMed = Color(0xFFD97706);
  static const Color riskMedBg = Color(0xFFFEF3C7);
  static const Color riskHigh = Color(0xFFDC2626);
  static const Color riskHighBg = Color(0xFFFEE2E2);

  static const Color blueBg = Color(0xFFE0F2FE);
  static const Color blueFg = Color(0xFF0369A1);
  static const Color danger = Color(0xFFEF4444);

  static Color alpha(Color color, double opacity) =>
      color.withAlpha((opacity * 255).round());
}
