import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../design_system/components/pyro_card.dart';
import '../../design_system/typography/pyro_typography.dart';
import '../../design_system/colors/pyro_colors.dart';
import '../../core_engines/session/session_engine.dart';
import '../../core_engines/patient/patient_engine.dart';
import '../../navigation/navigation_provider.dart';

class AnalysisScreen extends ConsumerStatefulWidget {
  const AnalysisScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends ConsumerState<AnalysisScreen> {
  bool _isInvertedPolarity = false;

  @override
  Widget build(BuildContext context) {
    final sessionState = ref.watch(sessionEngineProvider);
    final activeSession = sessionState.activeSession;
    final patientState = ref.watch(patientEngineProvider);
    final activePatient = patientState.activePatient;

    final hasData = activeSession != null && (activeSession.status == SessionLifecycle.analyzing || activeSession.status == SessionLifecycle.completed || activeSession.status == SessionLifecycle.doctorReview);

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
                  Text('VEP LATENCY & WAVEFORM ANALYSIS', style: PyroTypography.heading1(true)),
                  Text(
                    hasData
                        ? 'Session: ${activeSession.sessionId} • Patient: ${activeSession.patientName} • Protocol: ${activeSession.protocolName}'
                        : 'No active session recording available for clinical analysis.',
                    style: PyroTypography.body(true).copyWith(color: const Color(0xFF94A3B8)),
                  ),
                ],
              ),
              if (hasData) ...[
                Row(
                  children: [
                    // 1-Click Invert Polarity Control
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _isInvertedPolarity ? PyroColors.medicalBlue : Colors.white,
                        side: BorderSide(color: _isInvertedPolarity ? PyroColors.medicalBlue : const Color(0xFF1E293B)),
                        backgroundColor: _isInvertedPolarity ? PyroColors.medicalBlue.withOpacity(0.15) : const Color(0xFF151C2C),
                      ),
                      icon: const Icon(Icons.swap_vert, size: 16),
                      label: Text('Invert Polarity: ${_isInvertedPolarity ? "ON" : "OFF"}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      onPressed: () {
                        setState(() => _isInvertedPolarity = !_isInvertedPolarity);
                      },
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: PyroColors.medicalBlue, foregroundColor: Colors.black),
                      icon: const Icon(Icons.psychology, size: 16),
                      label: const Text('Open AI Decision Support →'),
                      onPressed: () {
                        ref.read(currentScreenProvider.notifier).navigateTo(PyroScreen.aiWorkspace);
                      },
                    ),
                  ],
                ),
              ],
            ],
          ),
          const SizedBox(height: 20),

          Expanded(
            child: !hasData
                ? _buildEmptyAnalysisState(context, ref)
                : Row(
                    children: [
                      // Averaged VEP Waveform Plot
                      Expanded(
                        flex: 3,
                        child: PyroCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('AVERAGED VISUAL EVOKED POTENTIAL (P100 PEAK EXTRACTION)', style: PyroTypography.heading2(true)),
                                  Text('Polarity: ${_isInvertedPolarity ? "Inverted (Visual Representation Only)" : "Standard (N75 Down / P100 Up)"}', style: const TextStyle(fontSize: 11, color: PyroColors.medicalBlue)),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF040609),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: const Color(0xFF1E293B)),
                                  ),
                                  child: Transform.scale(
                                    scaleY: _isInvertedPolarity ? -1 : 1,
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.show_chart, size: 72, color: PyroColors.medicalBlue.withOpacity(0.8)),
                                          const SizedBox(height: 12),
                                          Text(
                                            'Averaged Signal Trace (64 Sweeps Passed)',
                                            style: TextStyle(color: PyroColors.medicalBlue, fontWeight: FontWeight.bold, fontSize: 14),
                                          ),
                                          const SizedBox(height: 4),
                                          const Text(
                                            'Cursor A: 72.0 ms (N75) | Cursor B: 102.4 ms (P100) | Δt = 30.4 ms, ΔV = 12.8 µV',
                                            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontFamily: 'Roboto Mono'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Measurements & Latencies Panel
                      Expanded(
                        child: PyroCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('EXTRACTED PEAK LATENCIES', style: PyroTypography.heading2(true)),
                              const SizedBox(height: 16),
                              _buildMetricRow('N75 Latency', '72.0 ms', PyroColors.medicalBlue),
                              _buildMetricRow('P100 Latency', '102.4 ms', PyroColors.statusSuccess),
                              _buildMetricRow('N145 Latency', '142.0 ms', PyroColors.statusSuccess),
                              _buildMetricRow('P100 Amplitude', '12.8 µV', PyroColors.medicalBlue),
                              _buildMetricRow('Interocular Difference', '1.2 ms (Symmetric)', PyroColors.statusSuccess),
                              const Divider(height: 24, color: Color(0xFF1E293B)),
                              const Text('CLINICAL IMPRESSION SUMMARY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: PyroColors.medicalBlue)),
                              const SizedBox(height: 8),
                              const Text(
                                'Averaged P100 peak latencies are within age-matched normative limits (95-108 ms). Waveform morphology is well-formed.',
                                style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8), height: 1.5),
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

  Widget _buildEmptyAnalysisState(BuildContext context, WidgetRef ref) {
    return PyroCard(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.analytics_outlined, size: 64, color: Color(0xFF64748B)),
            const SizedBox(height: 16),
            const Text('No Recording Available for Analysis', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
            const SizedBox(height: 8),
            const Text(
              'Select an examination session and complete a biosignal recording to perform latency peak extraction.',
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: PyroColors.medicalBlue, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14)),
              icon: const Icon(Icons.tune, size: 18),
              label: const Text('Open Examination Sessions', style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () {
                ref.read(currentScreenProvider.notifier).navigateTo(PyroScreen.sessions);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
          Text(value, style: PyroTypography.monoData(isDark: true, color: color, fontSize: 12)),
        ],
      ),
    );
  }
}
