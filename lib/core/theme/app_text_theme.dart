import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextTheme {
  AppTextTheme._();

  static const textTheme = TextTheme(
    displayLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      color: AppColors.onSurface,
      height: 1.2,
    ),
    headlineMedium: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: AppColors.onSurface,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      color: AppColors.onSurface,
      height: 1.5,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      color: AppColors.onSurfaceDim,
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppColors.onSurface,
      letterSpacing: 0.5,
    ),
    titleMedium: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: AppColors.onSurface,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      color: AppColors.onSurfaceDim,
    ),
  );
}
