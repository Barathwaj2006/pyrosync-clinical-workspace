import 'package:flutter_riverpod/flutter_riverpod.dart';

enum PyroScreen {
  auth,
  dashboard,
  patients,
  sessions,
  recording,
  analysis,
  aiWorkspace,
  reports,
  settings,
  help,
}

final currentScreenProvider = StateNotifierProvider<ScreenNotifier, PyroScreen>((ref) {
  return ScreenNotifier();
});

class ScreenNotifier extends StateNotifier<PyroScreen> {
  ScreenNotifier() : super(PyroScreen.dashboard);

  void navigateTo(PyroScreen screen) {
    state = screen;
  }
}
