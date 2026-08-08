import 'package:flutter/material.dart';
import '../../design_system/components/pyro_card.dart';
import '../../design_system/typography/pyro_typography.dart';
import '../../design_system/colors/pyro_colors.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAlignment.start,
                children: [
                  Text('CLINICAL DIAGNOSTIC REPORT BUILDER', style: PyroTypography.heading1(true)),
                  Text('Generate standardized PDF, DICOM Structured Reports, and sign off.', style: PyroTypography.body(true)),
                ],
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: PyroColors.medicalBlue,
                  foregroundColor: Colors.black,
                ),
                onPressed: () {},
                icon: const Icon(Icons.picture_as_pdf, size: 16),
                label: const Text('GENERATE & EXPORT PDF REPORT'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Expanded(
            child: PyroCard(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAlignment.start,
                  children: [
                    Text('REPORT PREVIEW — VISUAL EVOKED POTENTIAL EXAMINATION', style: PyroTypography.heading2(true)),
                    const SizedBox(height: 8),
                    Text('Pyromatics Bio Solutions • PyroSync Workstation', style: PyroTypography.caption(true)),
                    const Divider(color: Color(0xFF1E293B)),
                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Patient Name: Arthur Pendelton', style: PyroTypography.bodyLarge(true).copyWith(fontWeight: FontWeight.bold)),
                        Text('MRN: P-10929', style: PyroTypography.monoData(isDark: true)),
                        Text('Exam Date: 2026-08-07', style: PyroTypography.body(true)),
                      ],
                    ),
                    const SizedBox(height: 20),

                    Text('SUMMARY OF CLINICAL FINDINGS:', style: PyroTypography.caption(true).copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    const Text(
                      '1. Pattern Reversal VEP OS (Left Eye): Normal P100 latency (101.4 ms) and amplitude (12.1 µV).\n'
                      '2. Pattern Reversal VEP OD (Right Eye): Prolonged P100 latency (114.8 ms) with reduced amplitude (7.2 µV).\n'
                      '3. Inter-ocular latency difference (ΔP100 = 13.4 ms) exceeds normal clinical threshold (6.0 ms).\n'
                      '4. Impression: Right optic conduction delay, consistent with resolving optic neuritis.',
                      style: TextStyle(fontSize: 13, height: 1.6, color: Colors.white),
                    ),
                    const Spacer(),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Attending Neurologist: Dr. Elena Vance (MD)', style: PyroTypography.body(true)),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: PyroColors.statusSuccess, foregroundColor: Colors.black),
                          onPressed: () {},
                          icon: const Icon(Icons.draw, size: 16),
                          label: const Text('DIGITALLY SIGN & FINALIZE REPORT'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
