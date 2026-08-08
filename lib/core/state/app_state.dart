import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

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

class PatientModel {
  final String id;
  final String mrn;
  final String name;
  final String dob;
  final String gender;
  final String lastTestDate;
  final String protocol;
  final String status;
  final double p100Latency;
  final double p100Amplitude;

  PatientModel({
    required this.id,
    required this.mrn,
    required this.name,
    required this.dob,
    required this.gender,
    required this.lastTestDate,
    required this.protocol,
    required this.status,
    required this.p100Latency,
    required this.p100Amplitude,
  });
}

class AppState extends ChangeNotifier {
  AppThemeMode _themeMode = AppThemeMode.clinicalDark;
  AppView _currentView = AppView.dashboard;
  bool _isLoggedIn = true;
  String _userRole = 'Neurologist (Dr. Elena Vance)';
  
  // Selected Patient
  PatientModel _selectedPatient = PatientModel(
    id: 'P-10929',
    mrn: 'P-10929',
    name: 'Arthur Pendelton',
    dob: '1962-11-04',
    gender: 'Male',
    lastTestDate: '2026-08-05',
    protocol: 'VEP Pattern Reversal',
    status: 'Delayed Latency (R)',
    p100Latency: 114.8,
    p100Amplitude: 7.2,
  );

  // Live Acquisition Parameters
  bool _isRecording = false;
  int _completedSweeps = 64;
  int _targetSweeps = 100;
  String _selectedEye = 'OD (Right Eye)';
  
  // Signal DSP Settings
  String _timebase = '30 ms/div';
  String _sensitivity = '5 µV/div';
  String _notchFilter = '50 Hz';
  String _bandpassFilter = '1 - 100 Hz';

  // Impedance States (kΩ)
  Map<String, double> _impedances = {
    'Oz': 1.9,
    'O1': 3.2,
    'O2': 2.8,
    'Cz': 1.8,
    'Fz': 2.1,
    'Ref': 1.2,
    'Gnd': 0.9,
  };

  // Getters
  AppThemeMode get themeMode => _themeMode;
  AppView get currentView => _currentView;
  bool get isLoggedIn => _isLoggedIn;
  String get userRole => _userRole;
  PatientModel get selectedPatient => _selectedPatient;
  bool get isRecording => _isRecording;
  int get completedSweeps => _completedSweeps;
  int get targetSweeps => _targetSweeps;
  String get selectedEye => _selectedEye;
  String get timebase => _timebase;
  String get sensitivity => _sensitivity;
  String get notchFilter => _notchFilter;
  String get bandpassFilter => _bandpassFilter;
  Map<String, double> get impedances => _impedances;

  bool get isDark => _themeMode == AppThemeMode.clinicalDark || _themeMode == AppThemeMode.glassMode;

  // Setters & Actions
  void setThemeMode(AppThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  void setCurrentView(AppView view) {
    _currentView = view;
    notifyListeners();
  }

  void setSelectedPatient(PatientModel patient) {
    _selectedPatient = patient;
    notifyListeners();
  }

  void toggleRecording() {
    _isRecording = !_isRecording;
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

  void login(String role) {
    _isLoggedIn = true;
    _userRole = role;
    _currentView = AppView.dashboard;
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    _currentView = AppView.login;
    notifyListeners();
  }
}
