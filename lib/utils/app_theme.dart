// lib/utils/app_theme.dart

import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF3B7BF8);
  static const primaryLight = Color(0xFFE8EFFF);
  static const background = Color(0xFFF2F4F8);
  static const cardBg = Color(0xFFFFFFFF);
  static const textDark = Color(0xFF1A1D23);
  static const textGrey = Color(0xFF8E97A8);
  static const disabled = Color(0xFFCDD2DA);
  static const success = Color(0xFF34C759);
}

class AppTheme {
  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          background: AppColors.background,
        ),
        fontFamily: 'SF Pro Display',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: AppColors.textDark,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
          iconTheme: IconThemeData(color: AppColors.textDark),
        ),
        cardTheme: CardThemeData(
          color: AppColors.cardBg,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
}
