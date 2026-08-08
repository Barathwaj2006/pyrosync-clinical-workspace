import 'dart:ui';
import 'package:flutter/material.dart';
import '../colors/pyro_colors.dart';
import '../spacing/pyro_spacing.dart';

class PyroCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final bool isDark;
  final VoidCallback? onTap;
  final double borderRadius;
  final Border? customBorder;

  const PyroCard({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.isDark = true,
    this.onTap,
    this.borderRadius = PyroSpacing.radiusMd,
    this.customBorder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cardContent = Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: customBorder ??
            Border.all(
              color: isDark ? PyroColors.glassBorderDark : PyroColors.glassBorderLight,
              width: 1,
            ),
        color: isDark ? PyroColors.darkSurfaceCard.withOpacity(0.7) : PyroColors.lightSurfaceBase.withOpacity(0.85),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.35 : 0.05),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: PyroSpacing.glassBlurDark,
            sigmaY: PyroSpacing.glassBlurDark,
          ),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(PyroSpacing.md),
            child: child,
          ),
        ),
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: cardContent,
      );
    }

    return cardContent;
  }
}
