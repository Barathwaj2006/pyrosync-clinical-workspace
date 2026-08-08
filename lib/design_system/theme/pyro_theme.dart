import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../colors/pyro_colors.dart';
import '../../core_engines/theme/theme_engine_controller.dart';

final themeModeProvider = StateNotifierProvider<PyroThemeNotifier, PyroThemeMode>((ref) {
  return PyroThemeNotifier();
});

class PyroThemeNotifier extends StateNotifier<PyroThemeMode> {
  PyroThemeNotifier() : super(PyroThemeMode.clinicalDark);

  void setTheme(PyroThemeMode mode) {
    state = mode;
  }

  bool get isDark => state == PyroThemeMode.clinicalDark || state == PyroThemeMode.glassMode;
}

class PyroTheme {
  static ThemeData getThemeData(PyroThemeMode mode) {
    final isDark = mode == PyroThemeMode.clinicalDark || mode == PyroThemeMode.glassMode;

    return ThemeData(
      brightness: isDark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: isDark ? PyroColors.darkCanvas : PyroColors.lightCanvas,
      cardColor: isDark ? PyroColors.darkSurfaceCard : PyroColors.lightSurfaceCard,
      colorScheme: ColorScheme(
        brightness: isDark ? Brightness.dark : Brightness.light,
        primary: PyroColors.medicalBlue,
        onPrimary: Colors.black,
        secondary: PyroColors.deepClinicalBlue,
        onSecondary: Colors.white,
        error: PyroColors.statusDanger,
        onError: Colors.white,
        background: isDark ? PyroColors.darkCanvas : PyroColors.lightCanvas,
        onBackground: isDark ? PyroColors.textPrimaryDark : PyroColors.textPrimaryLight,
        surface: isDark ? PyroColors.darkSurfaceBase : PyroColors.lightSurfaceBase,
        onSurface: isDark ? PyroColors.textPrimaryDark : PyroColors.textPrimaryLight,
      ),
      fontFamily: 'Inter',
    );
  }
}
