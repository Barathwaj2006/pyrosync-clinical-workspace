import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../colors/pyro_colors.dart';

class PyroTypography {
  static TextStyle display(bool isDark) => GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        height: 1.2,
        letterSpacing: -0.5,
        color: isDark ? PyroColors.textPrimaryDark : PyroColors.textPrimaryLight,
      );

  static TextStyle heading1(bool isDark) => GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        height: 1.3,
        letterSpacing: -0.3,
        color: isDark ? PyroColors.textPrimaryDark : PyroColors.textPrimaryLight,
      );

  static TextStyle heading2(bool isDark) => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        height: 1.3,
        letterSpacing: -0.2,
        color: isDark ? PyroColors.textPrimaryDark : PyroColors.textPrimaryLight,
      );

  static TextStyle bodyLarge(bool isDark) => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: isDark ? PyroColors.textPrimaryDark : PyroColors.textPrimaryLight,
      );

  static TextStyle body(bool isDark) => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: isDark ? PyroColors.textSecondaryDark : PyroColors.textSecondaryLight,
      );

  static TextStyle caption(bool isDark) => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        height: 1.3,
        letterSpacing: 0.4,
        color: isDark ? PyroColors.textSecondaryDark : PyroColors.textSecondaryLight,
      );

  // Roboto Mono for numeric latency, microvolts, sampling rate, and impedance
  static TextStyle monoData({required bool isDark, Color? color, double fontSize = 12}) =>
      GoogleFonts.robotoMono(
        fontSize: fontSize,
        fontWeight: FontWeight.w500,
        height: 1.2,
        color: color ?? (isDark ? PyroColors.medicalBlue : PyroColors.deepClinicalBlue),
      );
}
