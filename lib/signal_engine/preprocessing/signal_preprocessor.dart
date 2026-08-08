import '../models/signal_models.dart';

class SignalPreprocessor {
  // 1. DC Offset Removal (Subtract mean value)
  List<double> removeDcOffset(List<double> raw) {
    if (raw.isEmpty) return raw;
    final mean = raw.reduce((a, b) => a + b) / raw.length;
    return raw.map((sample) => sample - mean).toList();
  }

  // 2. Baseline Correction (Linear baseline subtraction)
  List<double> correctBaseline(List<double> raw) {
    if (raw.length < 2) return raw;
    final first = raw.first;
    final last = raw.last;
    final slope = (last - first) / (raw.length - 1);

    List<double> corrected = [];
    for (int i = 0; i < raw.length; i++) {
      corrected.add(raw[i] - (first + slope * i));
    }
    return corrected;
  }

  // 3. Normalization (Z-score or Min-Max scaling)
  List<double> normalizeSignal(List<double> raw) {
    if (raw.isEmpty) return raw;
    final mean = raw.reduce((a, b) => a + b) / raw.length;
    final variance = raw.map((s) => (s - mean) * (s - mean)).reduce((a, b) => a + b) / raw.length;
    final stdDev = variance > 0 ? (variance) : 1.0;

    return raw.map((s) => (s - mean) / stdDev).toList();
  }

  // Master Preprocessing Step
  ProcessedSignal preprocess({
    required List<double> rawSamples,
    required double samplingRateHz,
    required String channelName,
  }) {
    var step1 = removeDcOffset(rawSamples);
    var step2 = correctBaseline(step1);

    return ProcessedSignal(
      samples: step2,
      samplingRateHz: samplingRateHz,
      channelName: channelName,
      isNormalized: false,
    );
  }
}
