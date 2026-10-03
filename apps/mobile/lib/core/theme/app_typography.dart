import 'package:flutter/material.dart';
import 'app_colors.dart';

const String kPoppins = 'Poppins';
const String kInter = 'Inter';

class AppText {
  AppText._();

  static const TextStyle display = TextStyle(
    fontFamily: kPoppins,
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: AppColors.navy,
    height: 1.2,
  );

  static const TextStyle h1 = TextStyle(
    fontFamily: kPoppins,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.navy,
    height: 1.25,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: kPoppins,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.navy,
    height: 1.3,
  );

  static const TextStyle h3 = TextStyle(
    fontFamily: kPoppins,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: AppColors.navy,
    height: 1.25,
  );

  static const TextStyle h4 = TextStyle(
    fontFamily: kPoppins,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.navy,
    height: 1.35,
  );

  static const TextStyle body = TextStyle(
    fontFamily: kInter,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.navy,
    height: 1.6,
  );

  static const TextStyle bodySm = TextStyle(
    fontFamily: kInter,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.navy,
    height: 1.5,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: kInter,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.secondary,
    height: 1.4,
  );

  static const TextStyle label = TextStyle(
    fontFamily: kPoppins,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.navy,
    height: 1.3,
  );

  static const TextStyle overline = TextStyle(
    fontFamily: kPoppins,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.secondary,
    letterSpacing: 0.6,
    height: 1.3,
  );

  static const TextStyle amount = TextStyle(
    fontFamily: kPoppins,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.navy,
    height: 1.2,
  );

  static const TextStyle amountLg = TextStyle(
    fontFamily: kPoppins,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.teal,
    height: 1.2,
  );

  static const TextStyle button = TextStyle(
    fontFamily: kPoppins,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );
}
