import 'package:flutter/material.dart';
import '../cursor/dual_cursor_measurement.dart';

class WaveformChannelConfig {
  final String label;
  final Color color;
  final bool isVisible;
  final double scaleGain;

  WaveformChannelConfig({
    required this.label,
    required this.color,
    this.isVisible = true,
    this.scaleGain = 1.0,
  });
}

class MultiChannelWaveformViewer extends StatelessWidget {
  final List<WaveformChannelConfig> channels;
  final Map<String, List<double>> rawSignals;
  final Map<String, List<double>> filteredSignals;
  final bool showFilteredOverlay;
  final DualCursorMeasurement? activeMeasurement;

  const MultiChannelWaveformViewer({
    super.key,
    required this.channels,
    required this.rawSignals,
    required this.filteredSignals,
    this.showFilteredOverlay = true,
    this.activeMeasurement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF05070A),
      child: CustomPaint(
        painter: WaveformPainter(
          channels: channels,
          rawSignals: rawSignals,
          filteredSignals: filteredSignals,
          showFilteredOverlay: showFilteredOverlay,
          activeMeasurement: activeMeasurement,
        ),
        child: Container(),
      ),
    );
  }
}

class WaveformPainter extends CustomPainter {
  final List<WaveformChannelConfig> channels;
  final Map<String, List<double>> rawSignals;
  final Map<String, List<double>> filteredSignals;
  final bool showFilteredOverlay;
  final DualCursorMeasurement? activeMeasurement;

  WaveformPainter({
    required this.channels,
    required this.rawSignals,
    required this.filteredSignals,
    required this.showFilteredOverlay,
    this.activeMeasurement,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..strokeWidth = 0.5;

    const gridSpacing = 30.0;
    for (double x = 0; x < size.width; x += gridSpacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    final activeChannels = channels.where((c) => c.isVisible).toList();
    if (activeChannels.isEmpty) return;

    final channelHeight = size.height / activeChannels.length;

    for (int i = 0; i < activeChannels.length; i++) {
      final config = activeChannels[i];
      final centerY = (i + 0.5) * channelHeight;

      canvas.drawLine(
        Offset(0, centerY),
        Offset(size.width, centerY),
        Paint()..color = Colors.white.withValues(alpha: 0.05),
      );

      final rawData = rawSignals[config.label] ?? [];
      final filteredData = filteredSignals[config.label] ?? [];

      if (rawData.isNotEmpty) {
        final path = Path();
        final stepX = size.width / (rawData.length - 1);
        for (int p = 0; p < rawData.length; p++) {
          final x = p * stepX;
          final y = centerY - (rawData[p] * config.scaleGain);
          if (p == 0) {
            path.moveTo(x, y);
          } else {
            path.lineTo(x, y);
          }
        }
        canvas.drawPath(
          path,
          Paint()
            ..color = config.color.withValues(alpha: 0.35)
            ..strokeWidth = 1.0
            ..style = PaintingStyle.stroke,
        );
      }

      if (showFilteredOverlay && filteredData.isNotEmpty) {
        final path = Path();
        final stepX = size.width / (filteredData.length - 1);
        for (int p = 0; p < filteredData.length; p++) {
          final x = p * stepX;
          final y = centerY - (filteredData[p] * config.scaleGain);
          if (p == 0) {
            path.moveTo(x, y);
          } else {
            path.lineTo(x, y);
          }
        }
        canvas.drawPath(
          path,
          Paint()
            ..color = config.color
            ..strokeWidth = 1.8
            ..style = PaintingStyle.stroke,
        );
      }
    }

    if (activeMeasurement != null) {
      final cursorAPaint = Paint()
        ..color = const Color(0xFFFFB300)
        ..strokeWidth = 1.2;
      final cursorBPaint = Paint()
        ..color = const Color(0xFF00E676)
        ..strokeWidth = 1.2;

      final xA = (activeMeasurement!.cursorA.timeMs / 250.0) * size.width;
      final xB = (activeMeasurement!.cursorB.timeMs / 250.0) * size.width;

      canvas.drawLine(Offset(xA, 0), Offset(xA, size.height), cursorAPaint);
      canvas.drawLine(Offset(xB, 0), Offset(xB, size.height), cursorBPaint);
    }
  }

  @override
  bool shouldRepaint(covariant WaveformPainter oldDelegate) => true;
}
