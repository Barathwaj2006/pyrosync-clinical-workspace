import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class WaveformCanvas extends StatelessWidget {
  final String title;
  final bool showSecondaryTrace;
  final double p100LatencyPrimary;
  final double p100LatencySecondary;
  final bool isDark;

  const WaveformCanvas({
    Key? key,
    this.title = 'Oz - Cz (VEP Pattern Reversal Averaged Trace)',
    this.showSecondaryTrace = true,
    this.p100LatencyPrimary = 101.4,
    this.p100LatencySecondary = 114.8,
    this.isDark = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.waveformCanvas,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF1E293B), width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: VepPainter(
                  showSecondaryTrace: showSecondaryTrace,
                  p100Primary: p100LatencyPrimary,
                  p100Secondary: p100LatencySecondary,
                ),
              ),
            ),
            // Header Info Bar
            Positioned(
              top: 10,
              left: 14,
              right: 14,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title.toUpperCase(),
                    style: AppTypography.monoData(
                      isDark: true,
                      color: const Color(0xFF94A3B8),
                      fontSize: 11,
                    ),
                  ),
                  Row(
                    children: [
                      _TraceBadge(color: AppColors.vepTraceLeftEye, label: 'OS (Left Eye) P100: ${p100LatencyPrimary.toStringAsFixed(1)}ms'),
                      if (showSecondaryTrace) ...[
                        const SizedBox(width: 10),
                        _TraceBadge(color: AppColors.vepTraceRightEye, label: 'OD (Right Eye) P100: ${p100LatencySecondary.toStringAsFixed(1)}ms'),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            // Scale Indicator Legend
            Positioned(
              bottom: 10,
              right: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF121620).withOpacity(0.8),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: const Color(0xFF1E293B)),
                ),
                child: Text(
                  '30 ms/div | 5 µV/div | Bandpass: 1-100Hz',
                  style: AppTypography.monoData(
                    isDark: true,
                    color: const Color(0xFF94A3B8),
                    fontSize: 10,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TraceBadge extends StatelessWidget {
  final Color color;
  final String label;

  const _TraceBadge({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 10, height: 2, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTypography.monoData(isDark: true, color: color, fontSize: 11),
        ),
      ],
    );
  }
}

class VepPainter extends CustomPainter {
  final bool showSecondaryTrace;
  final double p100Primary;
  final double p100Secondary;

  VepPainter({
    required this.showSecondaryTrace,
    required this.p100Primary,
    required this.p100Secondary,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    final centerY = height / 2;

    // 1. Draw Grid Lines
    final gridPaintMajor = Paint()
      :color = AppColors.waveformGridMajor
      ..strokeWidth = 1.0;

    final gridPaintMinor = Paint()
      :color = AppColors.waveformGridMinor
      ..strokeWidth = 0.5;

    // Horizontal Voltage Grid (every 25px = ~5uV)
    for (double y = 0; y <= height; y += 30) {
      canvas.drawLine(Offset(0, y), Offset(width, y), y == centerY ? gridPaintMajor : gridPaintMinor);
    }

    // Vertical Time Grid (0ms to 250ms)
    final msStep = width / 250;
    for (double ms = 0; ms <= 250; ms += 25) {
      final x = ms * msStep;
      canvas.drawLine(Offset(x, 0), Offset(x, height), (ms % 50 == 0) ? gridPaintMajor : gridPaintMinor);
      
      // Draw Time Labels along bottom
      if (ms % 50 == 0 && ms > 0 && ms < 250) {
        final textSpan = TextSpan(
          text: '${ms.toInt()}ms',
          style: const TextStyle(color: Color(0xFF475569), fontSize: 10, fontFamily: 'RobotoMono'),
        );
        final tp = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
        tp.layout();
        tp.paint(canvas, Offset(x - tp.width / 2, height - 18));
      }
    }

    // 2. Draw Primary VEP Trace (OS Left Eye)
    _drawVepTrace(
      canvas: canvas,
      size: size,
      p100Ms: p100Primary,
      amplitudeScale: 1.0,
      color: AppColors.vepTraceLeftEye,
      strokeWidth: 2.0,
    );

    // 3. Draw Secondary VEP Trace (OD Right Eye)
    if (showSecondaryTrace) {
      _drawVepTrace(
        canvas: canvas,
        size: size,
        p100Ms: p100Secondary,
        amplitudeScale: 0.75, // Slightly lower amplitude for delayed eye
        color: AppColors.vepTraceRightEye,
        strokeWidth: 2.0,
      );
    }
  }

  void _drawVepTrace({
    required Canvas canvas,
    required Size size,
    required double p100Ms,
    required double amplitudeScale,
    required Color color,
    required double strokeWidth,
  }) {
    final width = size.width;
    final height = size.height;
    final centerY = height / 2;
    final msStep = width / 250;

    final path = Path();
    bool isFirst = true;

    for (double ms = 0; ms <= 250; ms += 1) {
      final x = ms * msStep;
      
      // Mathematical VEP Waveform Model: Baseline -> N75 Dip -> P100 Peak -> N145 Dip -> Baseline
      double yOffset = 0.0;

      // N75 component (Negative dip ~74ms)
      final n75Dist = ms - (p100Ms - 27.0);
      yOffset -= 25.0 * math.exp(-math.pow(n75Dist / 12.0, 2)) * amplitudeScale;

      // P100 component (Positive major peak at p100Ms) - Note: In EEG, downward deflection is often positive, but standard display is up/down calibrated
      final p100Dist = ms - p100Ms;
      yOffset += 65.0 * math.exp(-math.pow(p100Dist / 14.0, 2)) * amplitudeScale;

      // N145 component (Negative dip ~145ms)
      final n145Dist = ms - (p100Ms + 44.0);
      yOffset -= 35.0 * math.exp(-math.pow(n145Dist / 18.0, 2)) * amplitudeScale;

      // Subtle high-frequency baseline alpha rhythm noise
      yOffset += math.sin(ms * 0.2) * 1.5;

      final y = centerY - yOffset; // Invert for canvas coordinates

      if (isFirst) {
        path.moveTo(x, y);
        isFirst = false;
      } else {
        path.lineTo(x, y);
      }
    }

    final tracePaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, tracePaint);

    // Draw Peak Marker at P100
    final p100X = p100Ms * msStep;
    double p100YOffset = 65.0 * amplitudeScale;
    final p100Y = centerY - p100YOffset;

    final markerPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(p100X, p100Y), 4, markerPaint);

    // Latency Guide Line
    final guidePaint = Paint()
      ..color = color.withOpacity(0.4)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(p100X, 0), Offset(p100X, height), guidePaint);
  }

  @override
  bool shouldRepaint(covariant VepPainter oldDelegate) =>
      oldDelegate.p100Primary != p100Primary ||
      oldDelegate.p100Secondary != p100Secondary ||
      oldDelegate.showSecondaryTrace != showSecondaryTrace;
}
