import 'package:flutter/material.dart';
import '../../design_system/components/pyro_card.dart';
import '../../design_system/typography/pyro_typography.dart';
import '../../design_system/colors/pyro_colors.dart';

class AiWorkspaceScreen extends StatelessWidget {
  const AiWorkspaceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAlignment.start,
        children: [
          Text('AI ASSISTANT & QUALITY SCORECARD WORKSPACE', style: PyroTypography.heading1(true)),
          Text('Automated quality scoring, artifact detection, and draft clinical findings (Clinician Decides).', style: PyroTypography.body(true)),
          const SizedBox(height: 24),

          Expanded(
            child: Row(
              children: [
                // Quality Scorecard Card
                Expanded(
                  child: PyroCard(
                    child: Column(
                      crossAxisAlignment: CrossAlignment.start,
                      children: [
                        Text('SIGNAL QUALITY SCORECARD', style: PyroTypography.heading2(true)),
                        const SizedBox(height: 20),
                        Center(
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: PyroColors.statusSuccess, width: 4),
                            ),
                            child: Center(
                              child: Text('94.5%', style: PyroTypography.display(true).copyWith(color: PyroColors.statusSuccess)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildAiMetric('Signal-to-Noise Ratio (SNR)', '8.4 dB (High Precision)'),
                        _buildAiMetric('Ocular Artifact Contamination', '0.2% (Low Blink)'),
                        _buildAiMetric('Muscle EMG Contamination', '0.5% (Relaxed)'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 24),

                // AI Draft Impression
                Expanded(
                  flex: 2,
                  child: PyroCard(
                    child: Column(
                      crossAxisAlignment: CrossAlignment.start,
                      children: [
                        Text('AI DRAFT CLINICAL IMPRESSION SUGGESTION', style: PyroTypography.heading2(true)),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF121620),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: PyroColors.medicalBlue.withOpacity(0.4)),
                          ),
                          child: const Text(
                            'AI Assessment: Pattern reversal visual evoked potential recorded for Left Eye (OS) demonstrates normal P100 wave latency (101.4 ms) and amplitude. Right Eye (OD) demonstrates prolonged P100 latency (114.8 ms), representing a unilateral conduction delay in the right anterior visual pathway. Consistent with clinical history of optic neuritis.',
                            style: TextStyle(fontSize: 13, height: 1.5, color: Colors.white),
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: PyroColors.statusSuccess,
                                foregroundColor: Colors.black,
                              ),
                              onPressed: () {},
                              child: const Text('ACCEPT AI SUGGESTIONS INTO REPORT'),
                            ),
                            const SizedBox(width: 12),
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(foregroundColor: Colors.white),
                              onPressed: () {},
                              child: const Text('MANUALLY EDIT IMPRESSION'),
                            ),
                          ],
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

  Widget _buildAiMetric(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
          Text(value, style: PyroTypography.monoData(isDark: true, fontSize: 11)),
        ],
      ),
    );
  }
}
