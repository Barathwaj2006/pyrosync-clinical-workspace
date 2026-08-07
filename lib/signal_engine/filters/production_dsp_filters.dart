import 'dart:math';

enum FilterType { butterworth, chebyshev, bessel, iirNotch50Hz, iirNotch60Hz, bandpass }
enum WindowType { hamming, hann, blackman }

class ProductionDspFilters {
  // 1. DC Offset & Baseline Wander Removal
  static List<double> removeDcOffset(List<double> samples) {
    if (samples.isEmpty) return samples;
    final mean = samples.reduce((a, b) => a + b) / samples.length;
    return samples.map((s) => s - mean).toList();
  }

  // 2. 50 Hz & 60 Hz Notch Filters (IIR Narrow Notch)
  static List<double> applyIirNotch(List<double> samples, double notchFreqHz, double samplingRateHz) {
    if (samples.length < 3) return samples;
    final w0 = 2 * pi * notchFreqHz / samplingRateHz;
    final alpha = sin(w0) / (2 * 30.0); // Q = 30
    final b0 = 1.0;
    final b1 = -2 * cos(w0);
    final b2 = 1.0;
    final a0 = 1 + alpha;
    final a1 = -2 * cos(w0);
    final a2 = 1 - alpha;

    final filtered = List<double>.filled(samples.length, 0.0);
    for (int i = 2; i < samples.length; i++) {
      filtered[i] = (b0 / a0) * samples[i] +
          (b1 / a0) * samples[i - 1] +
          (b2 / a0) * samples[i - 2] -
          (a1 / a0) * filtered[i - 1] -
          (a2 / a0) * filtered[i - 2];
    }
    return filtered;
  }

  // 3. Windowing Functions (Hamming, Hann, Blackman)
  static List<double> applyWindow(List<double> samples, WindowType windowType) {
    final N = samples.length;
    final windowed = List<double>.filled(N, 0.0);

    for (int n = 0; n < N; n++) {
      double w = 1.0;
      if (windowType == WindowType.hamming) {
        w = 0.54 - 0.46 * cos(2 * pi * n / (N - 1));
      } else if (windowType == WindowType.hann) {
        w = 0.5 * (1 - cos(2 * pi * n / (N - 1)));
      } else if (windowType == WindowType.blackman) {
        w = 0.42 - 0.5 * cos(2 * pi * n / (N - 1)) + 0.08 * cos(4 * pi * n / (N - 1));
      }
      windowed[n] = samples[n] * w;
    }
    return windowed;
  }

  // 4. RMS & Envelope Detection
  static double calculateRms(List<double> samples) {
    if (samples.isEmpty) return 0.0;
    final sumSquares = samples.fold<double>(0.0, (acc, s) => acc + (s * s));
    return sqrt(sumSquares / samples.length);
  }
}
