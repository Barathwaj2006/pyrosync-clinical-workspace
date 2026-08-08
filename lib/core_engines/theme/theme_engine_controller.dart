import 'package:flutter_riverpod/flutter_riverpod.dart';

enum PyroThemeMode {
  clinicalDark,
  glassMode,
  clinicalLight,
}

final themeEngineProvider = StateNotifierProvider<ThemeEngineNotifier, PyroThemeMode>((ref) {
  return ThemeEngineNotifier();
});

class ThemeEngineNotifier extends StateNotifier<PyroThemeMode> {
  ThemeEngineNotifier() : super(PyroThemeMode.clinicalDark);

  void setThemeMode(PyroThemeMode mode) {
    state = mode;
    _persistPreference(mode);
  }

  void _persistPreference(PyroThemeMode mode) {
    // Abstracted persistence layer (e.g. SharedPreferences)
  }

  bool get isDark => state == PyroThemeMode.clinicalDark || state == PyroThemeMode.glassMode;
}
