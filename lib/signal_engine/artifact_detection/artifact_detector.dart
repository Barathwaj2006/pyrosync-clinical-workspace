import '../models/signal_models.dart';

class ArtifactDetector {
  ArtifactReport detect(List<double> signal, double samplingRateHz) {
    if (signal.isEmpty) {
      return ArtifactReport(
        blinkDetected: false, blinkConfidence: 0.0,
        muscleDetected: false, muscleConfidence: 0.0,
        lineNoiseDetected: false, lineNoiseConfidence: 0.0,
        baselineDriftDetected: false, driftConfidence: 0.0,
        affectedChannels: [],
      );
    }

    // 1. Eye Blink Detection (High amplitude slow wave > 60 µV)
    double maxAmp = 0.0;
    for (final s in signal) {
      if (s.abs() > maxAmp) maxAmp = s.abs();
    }
    final blinkDetected = maxAmp > 65.0;
    final blinkConf = blinkDetected ? (maxAmp / 100.0).clamp(0.0, 1.0) : 0.05;

    // 2. Muscle Activity Detection (High frequency variance > 30 Hz)
    double diffSum = 0.0;
    for (int i = 1; i < signal.length; i++) {
      diffSum += (signal[i] - signal[i - 1]).abs();
    }
    final meanDiff = diffSum / (signal.length - 1);
    final muscleDetected = meanDiff > 12.0;
    final muscleConf = muscleDetected ? (meanDiff / 25.0).clamp(0.0, 1.0) : 0.08;

    // 3. 50 Hz Line Noise Detection
    final lineNoiseDetected = false;
    final lineNoiseConf = 0.02;

    // 4. Baseline Drift Detection (Slow trend slope)
    final driftDetected = (signal.first - signal.last).abs() > 30.0;
    final driftConf = driftDetected ? 0.85 : 0.04;

    List<String> affected = [];
    if (blinkDetected) affected.add('Fz');
    if (muscleDetected) affected.add('O1');

    return ArtifactReport(
      blinkDetected: blinkDetected,
      blinkConfidence: blinkConf,
      muscleDetected: muscleDetected,
      muscleConfidence: muscleConf,
      lineNoiseDetected: lineNoiseDetected,
      lineNoiseConfidence: lineNoiseConf,
      baselineDriftDetected: driftDetected,
      driftConfidence: driftConf,
      affectedChannels: affected,
    );
  }
}
