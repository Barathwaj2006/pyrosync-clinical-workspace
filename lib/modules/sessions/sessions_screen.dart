import 'package:flutter/material.dart';
import '../../design_system/components/pyro_card.dart';
import '../../core/widgets/electrode_map.dart';
import '../../design_system/typography/pyro_typography.dart';
import '../../design_system/colors/pyro_colors.dart';

class SessionsScreen extends StatelessWidget {
  const SessionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAlignment.start,
        children: [
          Text('SESSION SETUP & ELECTRODE CALIBRATION', style: PyroTypography.heading1(true)),
          Text('Configure acquisition protocol and verify electrode impedances before recording.', style: PyroTypography.body(true)),
          const SizedBox(height: 24),

          Expanded(
            child: Row(
              children: [
                // 10-20 Electrode Map (Left)
                const Expanded(
                  flex: 3,
                  child: ElectrodeMapWidget(
                    impedances: {
                      'Oz': 1.9,
                      'O1': 3.2,
                      'O2': 2.8,
                      'Cz': 1.8,
                      'Fz': 2.1,
                      'Ref': 1.2,
                      'Gnd': 0.9,
                    },
                    isDark: true,
                  ),
                ),
                const SizedBox(width: 24),

                // Protocol Parameters Panel (Right)
                Expanded(
                  flex: 2,
                  child: PyroCard(
                    child: Column(
                      crossAxisAlignment: CrossAlignment.start,
                      children: [
                        Text('PROTOCOL PARAMETERS', style: PyroTypography.heading2(true)),
                        const SizedBox(height: 16),
                        _buildParamRow('Visual Stimulus', 'Checkerboard Reversal'),
                        _buildParamRow('Check Size', '60 arcmin (1° Field)'),
                        _buildParamRow('Reversal Frequency', '2.0 Hz'),
                        _buildParamRow('Target Sweeps per Eye', '100 Sweeps'),
                        _buildParamRow('Bandpass Filter', '1.0 Hz - 100 Hz'),
                        _buildParamRow('Notch Filter', '50 Hz Active'),
                        const Spacer(),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: PyroColors.medicalBlue,
                            foregroundColor: Colors.black,
                            minimumSize: const Size(double.infinity, 48),
                          ),
                          onPressed: () {},
                          child: const Text('PROCEED TO LIVE RECORDING', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
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

  Widget _buildParamRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
          Text(value, style: PyroTypography.monoData(isDark: true, fontSize: 12)),
        ],
      ),
    );
  }
}
