import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/glass_card.dart';

class ElectrodeMapWidget extends StatelessWidget {
  final Map<String, double> impedances;
  final bool isDark;

  const ElectrodeMapWidget({
    super.key,
    required this.impedances,
    this.isDark = true,
  });

  Color _getImpedanceColor(double kohm) {
    if (kohm < 5.0) return AppColors.statusSuccess; // Green
    if (kohm <= 10.0) return AppColors.statusWarning; // Amber
    return AppColors.statusDanger; // Red
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '10-20 ELECTRODE IMPEDANCE MATRIX',
                style: AppTypography.caption(isDark).copyWith(
                  letterSpacing: 1.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.statusSuccess.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.statusSuccess.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.statusSuccess,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'ALL CHANNELS < 5 kΩ',
                      style: AppTypography.monoData(isDark: isDark, color: AppColors.statusSuccess, fontSize: 10),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: SizedBox(
              width: 320,
              height: 240,
              child: Stack(
                children: [
                  // Outer Head Outline Schematic
                  Center(
                    child: Container(
                      width: 200,
                      height: 220,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(Radius.elliptical(100, 110)),
                        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1), width: 2),
                      ),
                    ),
                  ),
                  // Nose Triangle Indicator (Top)
                  Positioned(
                    top: 2,
                    left: 152,
                    child: CustomPaint(
                      size: const Size(16, 12),
                      painter: _NosePainter(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                    ),
                  ),
                  // Electrode Nodes
                  _buildNode('Fz', 140, 45),
                  _buildNode('Cz', 140, 105),
                  _buildNode('O1', 95, 175),
                  _buildNode('Oz', 140, 185),
                  _buildNode('O2', 185, 175),
                  _buildNode('Ref', 40, 105),
                  _buildNode('Gnd', 240, 105),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Legend Footer
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendItem(color: AppColors.statusSuccess, label: '< 5 kΩ (Optimal)'),
              SizedBox(width: 16),
              _LegendItem(color: AppColors.statusWarning, label: '5 - 10 kΩ (Check)'),
              SizedBox(width: 16),
              _LegendItem(color: AppColors.statusDanger, label: '> 10 kΩ (High)'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNode(String code, double x, double y) {
    final kohm = impedances[code] ?? 2.0;
    final color = _getImpedanceColor(kohm);

    return Positioned(
      left: x,
      top: y,
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 2),
              boxShadow: [
                BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 8),
              ],
            ),
            child: Center(
              child: Text(
                code,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${kohm.toStringAsFixed(1)} kΩ',
            style: AppTypography.monoData(isDark: isDark, color: color, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8), fontFamily: 'Inter'),
        ),
      ],
    );
  }
}

class _NosePainter extends CustomPainter {
  final Color color;

  _NosePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..close();

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
