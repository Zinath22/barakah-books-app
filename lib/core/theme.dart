import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF0F5C45); // গাঢ় সবুজ
  static const gold = Color(0xFFC9A227);    // সোনালি
  static const cream = Color(0xFFFBF8F1);   // হালকা ক্রিম
}

ThemeData appTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.gold,
    ),
    scaffoldBackgroundColor: AppColors.cream,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
    ),
  );
}