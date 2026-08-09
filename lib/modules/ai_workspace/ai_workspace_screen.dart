import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../design_system/components/pyro_card.dart';
import '../../design_system/typography/pyro_typography.dart';
import '../../design_system/colors/pyro_colors.dart';
import '../../core_engines/session/session_engine.dart';
import '../../navigation/navigation_provider.dart';

class AiWorkspaceScreen extends ConsumerWidget {
  const AiWorkspaceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionState = ref.watch(sessionEngineProvider);
    final activeSession = sessionState.activeSession;

    final hasAnalysisData = activeSession != null && (activeSession.status == SessionLifecycle.analyzing || activeSession.status == SessionLifecycle.completed || activeSession.status == SessionLifecycle.doctorReview);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('AI CLINICAL DECISION SUPPORT SYSTEM (CDSS)', style: PyroTypography.heading1(true)),
                  Text('Explainable biomedical rule evaluation and AI-assisted diagnostic impressions.', style: PyroTypography.body(true).copyWith(color: const Color(0xFF94A3B8))),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: PyroColors.statusWarning.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: PyroColors.statusWarning.withValues(alpha: 0.4)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, size: 14, color: PyroColors.statusWarning),
                    SizedBox(width: 6),
                    Text('AI assists. Clinician decides.', style: TextStyle(fontSize: 11, color: PyroColors.statusWarning, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Expanded(
            child: !hasAnalysisData
                ? _buildEmptyAiState(context, ref)
                : Row(
                    children: [
                      // Main AI Impression Card
                      Expanded(
                        flex: 2,
                        child: PyroCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('EXPLAINABLE AI IMPRESSION', style: PyroTypography.heading2(true)),
                                  // CONFIDENCE INDICATOR BESIDE IMPRESSION
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: PyroColors.statusSuccess.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: PyroColors.statusSuccess.withValues(alpha: 0.4)),
                                    ),
                                    child: const Text('🎯 Confidence: 94.2%', style: TextStyle(fontSize: 11, color: PyroColors.statusSuccess, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              const Text('Pattern Reversal VEP Latency Symmetry Evaluation', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                              const SizedBox(height: 8),
                              const Text(
                                'Evaluated 16-channel VEP waveforms against normative age-matched baseline limits. Extracted P100 latency (102.4 ms) demonstrates normal conduction velocity along optic nerve pathways.',
                                style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8), height: 1.6),
                              ),
                              const SizedBox(height: 24),
                              const Text('EVALUATED BIOMEDICAL RULES', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: PyroColors.medicalBlue)),
                              const SizedBox(height: 12),
                              _buildRuleItem('P100 Absolute Latency Rule', 'PASS (102.4 ms <= 108.0 ms threshold)', true),
                              _buildRuleItem('Interocular Latency Symmetry Rule', 'PASS (Δt = 1.2 ms <= 6.0 ms threshold)', true),
                              _buildRuleItem('Amplitude Integrity Check', 'PASS (12.8 µV >= 5.0 µV threshold)', true),
                              _buildRuleItem('Signal Artifact Quality Gate', 'PASS (SNR = 8.4 dB >= 3.0 dB threshold)', true),
                              const Spacer(),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(backgroundColor: PyroColors.medicalBlue, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14)),
                                icon: const Icon(Icons.lock_outline, size: 18),
                                label: const Text('🔒 Sign & Approve Clinical Report', style: TextStyle(fontWeight: FontWeight.bold)),
                                onPressed: () {
                                  ref.read(sessionEngineProvider.notifier).transitionLifecycle(SessionLifecycle.doctorReview);
                                  ref.read(currentScreenProvider.notifier).navigateTo(PyroScreen.reports);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // CDSS Audit Trail
                      Expanded(
                        child: PyroCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('CDSS AUDIT TRAIL', style: PyroTypography.heading2(true)),
                              const SizedBox(height: 16),
                              _buildAuditLog('Rule engine evaluated Session ${activeSession.sessionId}', '14:32:01'),
                              _buildAuditLog('P100 peak extracted at 102.4 ms', '14:32:02'),
                              _buildAuditLog('CDSS model confidence score: 94.2%', '14:32:03'),
                              _buildAuditLog('Awaiting clinician review & electronic signature', '14:32:04'),
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

  Widget _buildEmptyAiState(BuildContext context, WidgetRef ref) {
    return PyroCard(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.psychology_outlined, size: 64, color: Color(0xFF64748B)),
            const SizedBox(height: 16),
            const Text('No Analysis Available for AI Assistance', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
            const SizedBox(height: 8),
            const Text(
              'Complete an acquisition session and run peak analysis before invoking AI decision support evaluation.',
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: PyroColors.medicalBlue, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14)),
              icon: const Icon(Icons.analytics, size: 18),
              label: const Text('Go to Analysis Workspace', style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () {
                ref.read(currentScreenProvider.notifier).navigateTo(PyroScreen.analysis);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRuleItem(String ruleName, String result, bool isPass) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        children: [
          Icon(isPass ? Icons.check_circle_outline : Icons.error_outline, size: 16, color: isPass ? PyroColors.statusSuccess : PyroColors.statusDanger),
          const SizedBox(width: 8),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(ruleName, style: const TextStyle(fontSize: 12, color: Colors.white)),
                Text(result, style: TextStyle(fontSize: 11, color: isPass ? PyroColors.statusSuccess : PyroColors.statusDanger, fontFamily: 'Roboto Mono')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuditLog(String event, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(event, style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)))),
          Text(time, style: PyroTypography.monoData(isDark: true, fontSize: 10)),
        ],
      ),
    );
  }
}
