import 'package:flutter/material.dart';
import '../../design_system/components/pyro_card.dart';
import '../../design_system/components/pyro_waveform_canvas.dart';
import '../../design_system/typography/pyro_typography.dart';
import '../../design_system/colors/pyro_colors.dart';

class RecordingScreen extends StatelessWidget {
  const RecordingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAlignment.start,
        children: [
          // Top Control Toolbar Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAlignment.start,
                children: [
                  Text('LIVE VEP ACQUISITION WORKSPACE', style: PyroTypography.heading1(true)),
                  Text('Active Protocol: Pattern Reversal 1° Check (Oz - Cz)', style: PyroTypography.body(true)),
                ],
              ),
              Row(
                children: [
                  _buildControlPill('GAIN', '5 µV/div'),
                  const SizedBox(width: 8),
                  _buildControlPill('TIMEBASE', '30 ms/div'),
                  const SizedBox(width: 8),
                  _buildControlPill('NOTCH', '50 Hz'),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PyroColors.statusSuccess,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onPressed: () {},
                    icon: const Icon(Icons.play_arrow, size: 18),
                    label: const Text('START SWEEP AVERAGING', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // High Contrast Solid Canvas Viewport
          const Expanded(
            flex: 3,
            child: WaveformCanvas(
              title: 'Oz - Cz (VEP Pattern Reversal Averaged Trace)',
              showSecondaryTrace: true,
              p100LatencyPrimary: 101.4,
              p100LatencySecondary: 114.8,
            ),
          ),

          const SizedBox(height: 16),

          // Sweep Counter & Telemetry Bar
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: PyroCard(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStat('SWEEPS ACQUIRED', '64 / 100', PyroColors.medicalBlue),
                        _buildStat('REJECTED SWEEPS', '2 (3.1%)', PyroColors.statusWarning),
                        _buildStat('STIMULUS FREQ', '2.0 Hz', PyroColors.textPrimaryDark),
                        _buildStat('SIGNAL SNR', '8.4 dB', PyroColors.statusSuccess),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlPill(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8), fontWeight: FontWeight.bold)),
          Text(value, style: PyroTypography.monoData(isDark: true, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8), letterSpacing: 0.5)),
        const SizedBox(height: 4),
        Text(value, style: PyroTypography.heading2(true).copyWith(color: color, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
