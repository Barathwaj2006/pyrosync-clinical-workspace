import 'dart:math';

enum ValidationDatasetType {
  normalVep,
  delayedP100,
  highNoise,
  eyeBlinkArtifact,
  emgMuscleArtifact,
  powerline50HzNoise,
  flatLineSignal,
  missingSamples,
  packetLoss,
  randomGaussianNoise,
}

class SyntheticValidationDataset {
  final ValidationDatasetType type;
  final String name;
  final String description;
  final double samplingRateHz;
  final int sampleCount;
  final List<double> signalSamples;
  final double expectedP100LatencyMs;

  SyntheticValidationDataset({
    required this.type,
    required this.name,
    required this.description,
    required this.samplingRateHz,
    required this.sampleCount,
    required this.signalSamples,
    required this.expectedP100LatencyMs,
  });

  static SyntheticValidationDataset generate(ValidationDatasetType type) {
    const double fs = 2500.0;
    const int count = 625; // 250ms epoch @ 2500Hz
    final samples = <double>[];
    final rand = Random(42);

    switch (type) {
      case ValidationDatasetType.normalVep:
        for (int i = 0; i < count; i++) {
          final tMs = (i / fs) * 1000.0;
          double val = 0.0;
          if (tMs >= 70 && tMs <= 85) val -= 5.0 * sin((tMs - 70) / 15.0 * pi);
          if (tMs >= 95 && tMs <= 115) val += 12.0 * sin((tMs - 95) / 20.0 * pi); // P100 @ 102.4ms
          if (tMs >= 135 && tMs <= 155) val -= 6.0 * sin((tMs - 135) / 20.0 * pi);
          val += (rand.nextDouble() - 0.5) * 1.5;
          samples.add(val);
        }
        return SyntheticValidationDataset(
          type: type,
          name: 'Normal VEP Benchmark Dataset',
          description: 'Standard VEP waveform with expected P100 latency at 102.4 ms.',
          samplingRateHz: fs,
          sampleCount: count,
          signalSamples: samples,
          expectedP100LatencyMs: 102.4,
        );

      case ValidationDatasetType.delayedP100:
        for (int i = 0; i < count; i++) {
          final tMs = (i / fs) * 1000.0;
          double val = 0.0;
          if (tMs >= 85 && tMs <= 100) val -= 4.5 * sin((tMs - 85) / 15.0 * pi);
          if (tMs >= 115 && tMs <= 135) val += 10.5 * sin((tMs - 115) / 20.0 * pi); // Delayed P100 @ 125.0ms
          if (tMs >= 155 && tMs <= 175) val -= 5.5 * sin((tMs - 155) / 20.0 * pi);
          val += (rand.nextDouble() - 0.5) * 1.5;
          samples.add(val);
        }
        return SyntheticValidationDataset(
          type: type,
          name: 'Delayed P100 Latency Dataset (Demyelination Pattern)',
          description: 'Pathological VEP with P100 delayed to 125.0 ms.',
          samplingRateHz: fs,
          sampleCount: count,
          signalSamples: samples,
          expectedP100LatencyMs: 125.0,
        );

      default:
        for (int i = 0; i < count; i++) {
          samples.add((rand.nextDouble() - 0.5) * 20.0);
        }
        return SyntheticValidationDataset(
          type: type,
          name: 'Synthetic Test Dataset',
          description: 'High-noise verification signal.',
          samplingRateHz: fs,
          sampleCount: count,
          signalSamples: samples,
          expectedP100LatencyMs: 0.0,
        );
    }
  }
}
