import 'package:flutter/material.dart';
import '../../design_system/components/pyro_card.dart';
import '../../design_system/typography/pyro_typography.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAlignment.start,
        children: [
          Text('CLINICAL GUIDELINES & STANDARDS', style: PyroTypography.heading1(true)),
          Text('International Federation of Clinical Neurophysiology (IFCN) VEP Standards.', style: PyroTypography.body(true)),
          const SizedBox(height: 24),

          Expanded(
            child: PyroCard(
              child: Column(
                crossAxisAlignment: CrossAlignment.start,
                children: [
                  Text('RECOMMENDED VEP ELECTRODE PLACEMENT (10-20 SYSTEM)', style: PyroTypography.heading2(true)),
                  const SizedBox(height: 16),
                  const Text(
                    '• Oz (Active): Placed on the midline 5% of the nasion-inion distance above the inion.\n'
                    '• O1 & O2 (Lateral): Placed 5% of the inter-ear distance lateral to Oz.\n'
                    '• Cz (Reference): Midline vertex position.\n'
                    '• Fz (Ground): Midline frontal position.\n\n'
                    'Target Impedance: Keep all electrodes under 5.0 kΩ with inter-electrode differential under 1.0 kΩ.',
                    style: TextStyle(fontSize: 13, height: 1.6, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
