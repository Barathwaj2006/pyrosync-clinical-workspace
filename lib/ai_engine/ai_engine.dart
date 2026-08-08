class AiQualityAssessment {
  final double qualityScore; // 0.0 to 100.0
  final double snrRatio;
  final bool artifactDetected;
  final String artifactType;
  final String draftImpression;

  AiQualityAssessment({
    required this.qualityScore,
    required this.snrRatio,
    required this.artifactDetected,
    required this.artifactType,
    required this.draftImpression,
  });
}

class PyroAiEngine {
  AiQualityAssessment evaluateVepQuality(List<double> signal) {
    return AiQualityAssessment(
      qualityScore: 94.5,
      snrRatio: 8.4,
      artifactDetected: false,
      artifactType: 'None (Clean Baseline)',
      draftImpression:
          'AI Note: Left eye P100 latency (101.4 ms) is within normative limits. Right eye P100 latency (114.8 ms) demonstrates a unilateral 13.4 ms conduction delay. Clinician verification required.',
    );
  }
}
