import 'package:flutter/material.dart';
import '../../core_engines/theme/theme_engine_controller.dart';

enum AppView {
  login,
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

class AppState extends ChangeNotifier {
  PyroThemeMode _themeMode = PyroThemeMode.clinicalDark;
  AppView _currentView = AppView.dashboard;
  bool _isLoggedIn = true;
  
  // Live Acquisition DSP Parameters
  bool _isRecording = false;
  int _completedSweeps = 0;
  final int _targetSweeps = 100;
  String _selectedEye = 'OD (Right Eye)';
  
  // Signal DSP Settings
  String _timebase = '30 ms/div';
  String _sensitivity = '5 µV/div';
  String _notchFilter = '50 Hz';
  String _bandpassFilter = '1 - 100 Hz';

  // Getters
  PyroThemeMode get themeMode => _themeMode;
  AppView get currentView => _currentView;
  bool get isLoggedIn => _isLoggedIn;
  bool get isRecording => _isRecording;
  int get completedSweeps => _completedSweeps;
  int get targetSweeps => _targetSweeps;
  String get selectedEye => _selectedEye;
  String get timebase => _timebase;
  String get sensitivity => _sensitivity;
  String get notchFilter => _notchFilter;
  String get bandpassFilter => _bandpassFilter;

  bool get isDark => _themeMode == PyroThemeMode.clinicalDark || _themeMode == PyroThemeMode.glassMode;

  // Setters & Actions
  void setThemeMode(PyroThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  void setCurrentView(AppView view) {
    _currentView = view;
    notifyListeners();
  }

  void toggleRecording() {
    _isRecording = !_isRecording;
    if (!_isRecording) {
      _completedSweeps = 0;
    }
    notifyListeners();
  }

  void setSignalParameters({String? timebase, String? sensitivity, String? notch, String? bandpass}) {
    if (timebase != null) _timebase = timebase;
    if (sensitivity != null) _sensitivity = sensitivity;
    if (notch != null) _notchFilter = notch;
    if (bandpass != null) _bandpassFilter = bandpass;
    notifyListeners();
  }

  void setSelectedEye(String eye) {
    _selectedEye = eye;
    notifyListeners();
  }

  void login() {
    _isLoggedIn = true;
    _currentView = AppView.dashboard;
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    _currentView = AppView.login;
    notifyListeners();
  }
}
