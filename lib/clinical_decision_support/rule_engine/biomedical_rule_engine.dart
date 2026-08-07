import '../../signal_engine/models/signal_models.dart';
import '../models/cdss_models.dart';

class BiomedicalRuleEngine {
  List<Recommendation> evaluateRules(PipelineResult pipelineResult, List<ClinicalEvidence> evidenceList) {
    List<Recommendation> recommendations = [];

    // Rule 1: Signal SNR & Quality Assessment
    final snr = pipelineResult.qualityReport.snrDb;
    final snrEvidence = evidenceList.firstWhere(
      (e) => e.metricName.contains('SNR'),
      orElse: () => ClinicalEvidence(metricName: 'SNR', value: snr, unit: 'dB', sourceModule: 'SignalQualityEvaluator', confidenceScore: 0.9, timestamp: DateTime.now()),
    );

    if (snr >= 6.0) {
      recommendations.add(Recommendation(
        id: 'REC-SNR-01',
        title: 'Signal-to-Noise Ratio Acceptable',
        description: 'Recording SNR ($snr dB) exceeds the minimum clinical threshold of 6.0 dB.',
        severity: RuleSeverity.pass,
        suggestedAction: 'Proceed with sweep averaging and clinical reporting.',
        explanation: Explanation(
          why: 'High signal quality ensures accurate P100 peak identification.',
          generatingModule: 'SignalQualityEvaluator',
          supportingEvidence: [snrEvidence],
          triggeredThreshold: 'SNR >= 6.0 dB (Actual: $snr dB)',
          suggestedDoctorAction: 'No action required. Signal quality is optimal.',
        ),
      ));
    } else {
      recommendations.add(Recommendation(
        id: 'REC-SNR-02',
        title: 'Low Signal SNR Detected',
        description: 'Recording SNR ($snr dB) is below the recommended 6.0 dB threshold.',
        severity: RuleSeverity.warning,
        suggestedAction: 'Consider acquiring 32 additional sweeps or checking electrode impedance.',
        explanation: Explanation(
          why: 'Low SNR increases waveform peak uncertainty.',
          generatingModule: 'SignalQualityEvaluator',
          supportingEvidence: [snrEvidence],
          triggeredThreshold: 'SNR < 6.0 dB (Actual: $snr dB)',
          suggestedDoctorAction: 'Re-check Oz/Cz electrode skin contact and extend sweep duration.',
        ),
      ));
    }

    // Rule 2: Artifact Burden Rule
    if (pipelineResult.artifactReport.blinkDetected) {
      final blinkEv = evidenceList.firstWhere((e) => e.metricName.contains('Blink'), orElse: () => snrEvidence);
      recommendations.add(Recommendation(
        id: 'REC-ART-01',
        title: 'EOG Eye Blink Artifact Contamination',
        description: 'High amplitude slow waves detected during recording window.',
        severity: RuleSeverity.warning,
        suggestedAction: 'Instruct patient to focus on fixation cross without blinking during stimulus sweeps.',
        explanation: Explanation(
          why: 'Blink artifacts introduce low frequency baseline deflection.',
          generatingModule: 'ArtifactDetector',
          supportingEvidence: [blinkEv],
          triggeredThreshold: 'Blink Confidence > 0.60',
          suggestedDoctorAction: 'Instruct patient on visual fixation and re-run rejected sweeps.',
        ),
      ));
    }

    // Rule 3: P100 Peak Latency Verification
    final p100Lat = pipelineResult.vepResult.p100LatencyMs;
    final p100Ev = evidenceList.firstWhere((e) => e.metricName == 'P100 Latency', orElse: () => snrEvidence);

    if (p100Lat >= 95.0 && p100Lat <= 108.0) {
      recommendations.add(Recommendation(
        id: 'REC-VEP-01',
        title: 'P100 Latency Within Normative Limits',
        description: 'P100 peak latency ($p100Lat ms) is within normal adult reference bounds (95 - 108 ms).',
        severity: RuleSeverity.pass,
        suggestedAction: 'Recording suitable for doctor sign-off and clinical report generation.',
        explanation: Explanation(
          why: 'Normal P100 latency reflects intact anterior visual pathway conduction speed.',
          generatingModule: 'VEPPeakExtractor',
          supportingEvidence: [p100Ev],
          triggeredThreshold: '95.0 ms <= P100 <= 108.0 ms (Actual: $p100Lat ms)',
          suggestedDoctorAction: 'Review and approve draft clinical report.',
        ),
      ));
    } else if (p100Lat > 108.0) {
      recommendations.add(Recommendation(
        id: 'REC-VEP-02',
        title: 'Prolonged P100 Peak Latency Flagged',
        description: 'P100 peak latency ($p100Lat ms) exceeds normative upper limit (108.0 ms).',
        severity: RuleSeverity.warning,
        suggestedAction: 'Verify visual acuity and check contralateral eye response for interocular delay.',
        explanation: Explanation(
          why: 'Delayed P100 latency indicates slowed conduction in optic nerve fibers.',
          generatingModule: 'VEPPeakExtractor',
          supportingEvidence: [p100Ev],
          triggeredThreshold: 'P100 > 108.0 ms (Actual: $p100Lat ms)',
          suggestedDoctorAction: 'Perform interocular latency comparison and document findings.',
        ),
      ));
    }

    return recommendations;
  }
}
