import '../../signal_engine/models/signal_models.dart';
import '../models/cdss_models.dart';

class EvidenceCollector {
  List<ClinicalEvidence> collectEvidence(PipelineResult pipelineResult) {
    final now = DateTime.now();
    List<ClinicalEvidence> evidence = [];

    // 1. VEP Peak Evidence
    evidence.add(ClinicalEvidence(
      metricName: 'P100 Latency',
      value: pipelineResult.vepResult.p100LatencyMs,
      unit: 'ms',
      sourceModule: 'VEPPeakExtractor',
      confidenceScore: 0.98,
      timestamp: now,
    ));

    evidence.add(ClinicalEvidence(
      metricName: 'N75 Latency',
      value: pipelineResult.vepResult.n75LatencyMs,
      unit: 'ms',
      sourceModule: 'VEPPeakExtractor',
      confidenceScore: 0.96,
      timestamp: now,
    ));

    evidence.add(ClinicalEvidence(
      metricName: 'N145 Latency',
      value: pipelineResult.vepResult.n145LatencyMs,
      unit: 'ms',
      sourceModule: 'VEPPeakExtractor',
      confidenceScore: 0.95,
      timestamp: now,
    ));

    evidence.add(ClinicalEvidence(
      metricName: 'P100-N145 Amplitude',
      value: pipelineResult.vepResult.p100N145PeakToPeakUv,
      unit: 'µV',
      sourceModule: 'VEPPeakExtractor',
      confidenceScore: 0.97,
      timestamp: now,
    ));

    // 2. Signal Quality & SNR Evidence
    evidence.add(ClinicalEvidence(
      metricName: 'Signal-to-Noise Ratio (SNR)',
      value: pipelineResult.qualityReport.snrDb,
      unit: 'dB',
      sourceModule: 'SignalQualityEvaluator',
      confidenceScore: 0.99,
      timestamp: now,
    ));

    evidence.add(ClinicalEvidence(
      metricName: 'Overall Recording Quality',
      value: pipelineResult.qualityReport.overallQualityScore,
      unit: '%',
      sourceModule: 'SignalQualityEvaluator',
      confidenceScore: 0.99,
      timestamp: now,
    ));

    // 3. Artifact Contamination Evidence
    evidence.add(ClinicalEvidence(
      metricName: 'Blink Contamination Confidence',
      value: pipelineResult.artifactReport.blinkConfidence * 100.0,
      unit: '%',
      sourceModule: 'ArtifactDetector',
      confidenceScore: 0.94,
      timestamp: now,
    ));

    evidence.add(ClinicalEvidence(
      metricName: 'Muscle Contamination Confidence',
      value: pipelineResult.artifactReport.muscleConfidence * 100.0,
      unit: '%',
      sourceModule: 'ArtifactDetector',
      confidenceScore: 0.93,
      timestamp: now,
    ));

    // 4. EEG Band Power Evidence
    evidence.add(ClinicalEvidence(
      metricName: 'Alpha Band Relative Power',
      value: pipelineResult.frequencyResult.bandPower.alphaPercentage,
      unit: '%',
      sourceModule: 'FrequencyAnalyzer',
      confidenceScore: 0.97,
      timestamp: now,
    ));

    return evidence;
  }
}
