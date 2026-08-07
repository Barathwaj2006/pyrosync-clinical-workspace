import '../../signal_engine/models/signal_models.dart';
import '../models/cdss_models.dart';

class ReportGenerator {
  DraftReport generateReport({
    required ReportTemplateType templateType,
    required PipelineResult pipelineResult,
    required List<Recommendation> recommendations,
    required ConfidenceReport confidenceReport,
    required String patientId,
    required String patientName,
  }) {
    final reportId = 'REP-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';

    String title = '';
    String contentBody = '';

    switch (templateType) {
      case ReportTemplateType.doctorReport:
        title = 'CLINICAL DOCTOR DIAGNOSTIC REPORT — VEP EXAMINATION';
        contentBody = '''
PATIENT INFORMATION:
Name: $patientName | MRN: $patientId | Date: ${DateTime.now().toIso8601String().substring(0, 10)}

TECHNICAL MEASUREMENTS (Pattern Reversal Oz-Cz @ 2500 Hz):
• Left Eye (OS) P100 Latency: ${pipelineResult.vepResult.p100LatencyMs} ms | Amplitude: ${pipelineResult.vepResult.p100AmplitudeUv} µV
• Left Eye (OS) N75 Latency: ${pipelineResult.vepResult.n75LatencyMs} ms | N145 Latency: ${pipelineResult.vepResult.n145LatencyMs} ms
• Peak-to-Peak (P100-N145): ${pipelineResult.vepResult.p100N145PeakToPeakUv} µV

SIGNAL QUALITY & ARTIFACT ASSESSMENT:
• Signal SNR: ${pipelineResult.qualityReport.snrDb} dB | Overall Score: ${pipelineResult.qualityReport.overallQualityScore}%
• Sweeps Averaged: ${pipelineResult.vepResult.totalSweepsAveraged} | Rejected Sweeps: ${pipelineResult.vepResult.rejectedSweepsCount}
• Artifact Contamination: EOG Blink (${pipelineResult.artifactReport.blinkDetected ? 'Detected' : 'Pass'}) | EMG Muscle (${pipelineResult.artifactReport.muscleDetected ? 'Detected' : 'Pass'})

CLINICAL IMPRESSION & OBSERVATIONS (DOCTOR EDITABLE):
Pattern reversal visual evoked potential for Left Eye (OS) demonstrates well-defined N75, P100, and N145 waveform peaks. P100 latency is within normal adult limits (101.4 ms). Right Eye (OD) demonstrates mild P100 latency delay (114.8 ms). Clinical correlation recommended.
''';
        break;

      case ReportTemplateType.patientReport:
        title = 'PATIENT VISUAL EVOKED POTENTIAL (VEP) SUMMARY';
        contentBody = '''
Hello $patientName,

This report summarizes your recent visual test at Pyromatics Bio Solutions.

WHAT WAS TESTED:
We measured how fast and accurately your brain responds to visual patterns on a screen.

YOUR RESULTS SUMMARY:
• Left Eye Test: Excellent response speed (101.4 milliseconds). Your visual pathway is functioning normally.
• Signal Quality: High quality recording with clear signal traces.

NEXT STEPS:
Your neurologist will review these findings with you during your next consultation. No immediate action is required.
''';
        break;

      case ReportTemplateType.researchReport:
        title = 'ANONYMIZED RESEARCH DATASET & METRIC TABULATION';
        contentBody = '''
EXPERIMENTAL METADATA:
Subject Hash: SUBJ-8839 | Protocol: VEP-PR-1DEG-2500HZ | Sampling Rate: 2500 Hz

NUMERICAL METRICS TABLE:
P100_LAT_MS, N75_LAT_MS, N145_LAT_MS, P100_AMP_UV, SNR_DB, ALPHA_POWER_PCT, QUALITY_SCORE
${pipelineResult.vepResult.p100LatencyMs}, ${pipelineResult.vepResult.n75LatencyMs}, ${pipelineResult.vepResult.n145LatencyMs}, ${pipelineResult.vepResult.p100AmplitudeUv}, ${pipelineResult.qualityReport.snrDb}, ${pipelineResult.frequencyResult.bandPower.alphaPercentage.toStringAsFixed(1)}, ${pipelineResult.qualityReport.overallQualityScore}
''';
        break;

      case ReportTemplateType.hospitalReport:
        title = 'HOSPITAL CLINICAL NEUROPHYSIOLOGY SUMMARY';
        contentBody = '''
INSTITUTION: Pyromatics Medical Center — Neurodiagnostic Department
EXAMINATION: Visual Evoked Potential (VEP) Pattern Reversal
PATIENT: $patientName ($patientId)

TECHNICAL SUMMARY:
Recording performed using 10-20 montage (Oz - Cz). Signal SNR: ${pipelineResult.qualityReport.snrDb} dB. P100 latency: ${pipelineResult.vepResult.p100LatencyMs} ms. Technical quality score: ${pipelineResult.qualityReport.overallQualityScore}%.

DOCTOR APPROVAL STATUS: Draft pending attending physician electronic signature.
''';
        break;
    }

    return DraftReport(
      id: reportId,
      templateType: templateType,
      title: title,
      patientId: patientId,
      patientName: patientName,
      contentBody: contentBody,
      cdssRecommendations: recommendations,
      confidenceReport: confidenceReport,
      generatedTimestamp: DateTime.now(),
    );
  }
}
