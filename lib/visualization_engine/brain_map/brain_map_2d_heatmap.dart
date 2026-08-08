import 'package:flutter/material.dart';

class BrainMap2dHeatmap extends StatelessWidget {
  final Map<String, double> channelPowers;

  const BrainMap2dHeatmap({
    super.key,
    required this.channelPowers,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF121620),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          const Text(
            '2D SCALP POWER MAP (10-20 SYSTEM)',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Color(0xFF00E5FF),
              fontFamily: 'Roboto Mono',
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: CustomPaint(
              painter: ScalpPainter(channelPowers: channelPowers),
              child: Container(),
            ),
          ),
        ],
      ),
    );
  }
}

class ScalpPainter extends CustomPainter {
  final Map<String, double> channelPowers;

  ScalpPainter({required this.channelPowers});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width < size.height ? size.width * 0.4 : size.height * 0.4;

    final headPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(center, radius, headPaint);

    final nosePath = Path()
      ..moveTo(center.dx - 10, center.dy - radius)
      ..lineTo(center.dx, center.dy - radius - 15)
      ..lineTo(center.dx + 10, center.dy - radius);
    canvas.drawPath(nosePath, headPaint);

    final Map<String, Offset> electrodePositions = {
      'Fz': Offset(center.dx, center.dy - radius * 0.5),
      'Cz': Offset(center.dx, center.dy),
      'Pz': Offset(center.dx, center.dy + radius * 0.5),
      'Oz': Offset(center.dx, center.dy + radius * 0.8),
      'O1': Offset(center.dx - radius * 0.4, center.dy + radius * 0.75),
      'O2': Offset(center.dx + radius * 0.4, center.dy + radius * 0.75),
      'T3': Offset(center.dx - radius * 0.75, center.dy),
      'T4': Offset(center.dx + radius * 0.75, center.dy),
    };

    electrodePositions.forEach((label, pos) {
      final power = channelPowers[label] ?? 12.0;
      final intensity = (power / 40.0).clamp(0.0, 1.0);

      final nodeColor = Color.lerp(
        const Color(0xFF0088FF),
        const Color(0xFF00E676),
        intensity,
      )!;

      canvas.drawCircle(
        pos,
        14.0,
        Paint()..color = nodeColor.withOpacity(0.25),
      );

      canvas.drawCircle(pos, 6.0, Paint()..color = nodeColor);
    });
  }

  @override
  bool shouldRepaint(covariant ScalpPainter oldDelegate) => true;
}
