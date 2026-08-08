import 'package:flutter/material.dart';
import '../../core_engines/theme/theme_engine_controller.dart';

class PyroColors {
  // Clinical Dark Theme (Default)
  static const Color darkCanvas = Color(0xFF0A0D12);
  static const Color darkSurfaceBase = Color(0xFF121620);
  static const Color darkSurfaceCard = Color(0xFF1A202C);
  static const Color darkBorder = Color(0x1AFFFFFF);
  
  // Waveform Viewport (STRICTLY SOLID OBSIDIAN - ZERO TRANSPARENCY)
  static const Color waveformCanvas = Color(0xFF05070A);
  static const Color waveformGridMajor = Color(0xFF1E293B);
  static const Color waveformGridMinor = Color(0xFF0F172A);

  // Primary Medical Colors
  static const Color medicalBlue = Color(0xFF00E5FF);
  static const Color deepClinicalBlue = Color(0xFF0088FF);
  static const Color vepTraceLeftEye = Color(0xFFFFB300);  // OS (Gold)
  static const Color vepTraceRightEye = Color(0xFF00E676); // OD (Emerald)
  static const Color vepTraceAveraged = Color(0xFF00E5FF); // Mean (Cyan)

  // Status & Telemetry
  static const Color statusSuccess = Color(0xFF00E676); // Impedance < 5 kΩ
  static const Color statusWarning = Color(0xFFFFB300); // Impedance 5-10 kΩ
  static const Color statusDanger = Color(0xFFFF3D00);  // Impedance > 10 kΩ
  static const Color statusNeutral = Color(0xFF64748B);

  // Text Colors (Dark Mode)
  static const Color textPrimaryDark = Color(0xFFF1F5F9);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textDisabledDark = Color(0xFF475569);

  // Light Mode Colors
  static const Color lightCanvas = Color(0xFFF8FAFC);
  static const Color lightSurfaceBase = Color(0xFFFFFFFF);
  static const Color lightSurfaceCard = Color(0xFFF1F5F9);
  static const Color lightBorder = Color(0x1F000000);
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF475569);

  // Glassmorphic Colors
  static const Color glassFillDark = Color(0x991A202C);
  static const Color glassBorderDark = Color(0x1AFFFFFF);
  static const Color glassFillLight = Color(0xCCFFFFFF);
  static const Color glassBorderLight = Color(0x1F000000);
}
