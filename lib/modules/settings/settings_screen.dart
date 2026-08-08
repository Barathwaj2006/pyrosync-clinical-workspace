import 'package:flutter/material.dart';
import '../../design_system/components/pyro_card.dart';
import '../../design_system/typography/pyro_typography.dart';
import '../../design_system/colors/pyro_colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAlignment.start,
        children: [
          Text('SYSTEM CONFIGURATION & HARDWARE ADMIN', style: PyroTypography.heading1(true)),
          Text('Configure DSP filters, hardware drivers, and appearance settings.', style: PyroTypography.body(true)),
          const SizedBox(height: 24),

          Expanded(
            child: PyroCard(
              child: Column(
                crossAxisAlignment: CrossAlignment.start,
                children: [
                  Text('AMPLIFIER & SIGNAL DSP PRESETS', style: PyroTypography.heading2(true)),
                  const SizedBox(height: 20),
                  _buildSettingRow('Sampling Rate', '2500 Hz (Medical Grade)'),
                  _buildSettingRow('Hardware Driver', 'Pyromatics BioAmp v2.4 Driver'),
                  _buildSettingRow('Default High-Pass Filter', '1.0 Hz'),
                  _buildSettingRow('Default Low-Pass Filter', '100 Hz'),
                  _buildSettingRow('Line Noise Notch Filter', '50 Hz (Active)'),
                  _buildSettingRow('Impedance Threshold Warning', '10.0 kΩ'),
                  const Spacer(),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: PyroColors.medicalBlue, foregroundColor: Colors.black),
                    onPressed: () {},
                    child: const Text('SAVE CLINICAL CONFIGURATION'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
          Text(value, style: PyroTypography.monoData(isDark: true, fontSize: 13)),
        ],
      ),
    );
  }
}
