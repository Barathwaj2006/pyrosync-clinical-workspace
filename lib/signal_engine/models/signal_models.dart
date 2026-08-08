import 'dart:core';

class ProcessedSignal {
  final List<double> samples;
  final double samplingRateHz;
  final String channelName;
  final bool isNormalized;

  ProcessedSignal({
    required this.samples,
    required this.samplingRateHz,
    required this.channelName,
    required this.isNormalized,
  });
}

class BandPowerResult {
  final double deltaPower; // 0.5 - 4 Hz
  final double thetaPower; // 4 - 8 Hz
  final double alphaPower; // 8 - 13 Hz
  final double betaPower;  // 13 - 30 Hz
  final double gammaPower; // 30 - 50 Hz
  final double muPower;    // 8 - 12 Hz
  final double totalPower;

  BandPowerResult({
    required this.deltaPower,
    required this.thetaPower,
    required this.alphaPower,
    required this.betaPower,
    required this.gammaPower,
    required this.muPower,
    required this.totalPower,
  });

  double get alphaPercentage => (alphaPower / (totalPower == 0 ? 1 : totalPower)) * 100.0;
}

class FrequencyAnalysisResult {
  final List<double> frequenciesHz;
  final List<double> spectralAmplitudes;
  final List<double> psdValues;
  final BandPowerResult bandPower;

  FrequencyAnalysisResult({
    required this.frequenciesHz,
    required this.spectralAmplitudes,
    required this.psdValues,
    required this.bandPower,
  });
}

class ArtifactReport {
  final bool blinkDetected;
  final double blinkConfidence;
  final bool muscleDetected;
  final double muscleConfidence;
  final bool lineNoiseDetected;
  final double lineNoiseConfidence;
  final bool baselineDriftDetected;
  final double driftConfidence;
  final List<String> affectedChannels;

  ArtifactReport({
    required this.blinkDetected,
    required this.blinkConfidence,
    required this.muscleDetected,
    required this.muscleConfidence,
    required this.lineNoiseDetected,
    required this.lineNoiseConfidence,
    required this.baselineDriftDetected,
    required this.driftConfidence,
    required this.affectedChannels,
  });
}

class VEPResult {
  final double n75LatencyMs;
  final double n75AmplitudeUv;
  final double p100LatencyMs;
  final double p100AmplitudeUv;
  final double n145LatencyMs;
  final double n145AmplitudeUv;
  final double n75P100PeakToPeakUv;
  final double p100N145PeakToPeakUv;
  final int totalSweepsAveraged;
  final int rejectedSweepsCount;

  VEPResult({
    required this.n75LatencyMs,
    required this.n75AmplitudeUv,
    required this.p100LatencyMs,
    required this.p100AmplitudeUv,
    required this.n145LatencyMs,
    required this.n145AmplitudeUv,
    required this.n75P100PeakToPeakUv,
    required this.p100N145PeakToPeakUv,
    required this.totalSweepsAveraged,
    required this.rejectedSweepsCount,
  });
}

class SignalQualityReport {
  final double snrDb;
  final int droppedSamples;
  final double noisePercentage;
  final int artifactCount;
  final Map<String, double> electrodeQualityKohm;
  final double overallQualityScore; // 0.0 to 100.0

  SignalQualityReport({
    required this.snrDb,
    required this.droppedSamples,
    required this.noisePercentage,
    required this.artifactCount,
    required this.electrodeQualityKohm,
    required this.overallQualityScore,
  });
}

class PipelineResult {
  final ProcessedSignal cleanSignal;
  final FrequencyAnalysisResult frequencyResult;
  final ArtifactReport artifactReport;
  final VEPResult vepResult;
  final SignalQualityReport qualityReport;
  final DateTime processedTimestamp;

  PipelineResult({
    required this.cleanSignal,
    required this.frequencyResult,
    required this.artifactReport,
    required this.vepResult,
    required this.qualityReport,
    required this.processedTimestamp,
  });
}
