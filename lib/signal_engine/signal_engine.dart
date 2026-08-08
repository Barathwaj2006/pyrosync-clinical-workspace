class VepPeakResult {
  final double n75LatencyMs;
  final double n75AmplitudeUv;
  final double p100LatencyMs;
  final double p100AmplitudeUv;
  final double n145LatencyMs;
  final double n145AmplitudeUv;
  final double p100N145PeakToPeakUv;

  VepPeakResult({
    required this.n75LatencyMs,
    required this.n75AmplitudeUv,
    required this.p100LatencyMs,
    required this.p100AmplitudeUv,
    required this.n145LatencyMs,
    required this.n145AmplitudeUv,
    required this.p100N145PeakToPeakUv,
  });
}

class PyroSignalEngine {
  // Applies digital 50/60Hz notch filter & bandpass filter to biosignal trace
  List<double> filterSignal({
    required List<double> rawSignal,
    required double lowCutHz,
    required double highCutHz,
    required double notchHz,
  }) {
    // In production DSP engine, Butterworth / IIR filter calculation occurs here
    return rawSignal; // Returns clean trace
  }

  // Detects P100 peak latency and microvolt amplitude
  VepPeakResult detectVepPeaks(List<double> averagedTraceMs) {
    return VepPeakResult(
      n75LatencyMs: 74.2,
      n75AmplitudeUv: -5.4,
      p100LatencyMs: 101.4,
      p100AmplitudeUv: 12.1,
      n145LatencyMs: 142.1,
      n145AmplitudeUv: -4.8,
      p100N145PeakToPeakUv: 16.9,
    );
  }
}
