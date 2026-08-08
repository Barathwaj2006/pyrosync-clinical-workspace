import 'dart:math' as math;
import '../models/signal_models.dart';

class FrequencyAnalyzer {
  FrequencyAnalysisResult analyze(List<double> signal, double samplingRateHz) {
    final n = signal.length;
    if (n == 0) {
      return FrequencyAnalysisResult(
        frequenciesHz: [],
        spectralAmplitudes: [],
        psdValues: [],
        bandPower: BandPowerResult(
          deltaPower: 0, thetaPower: 0, alphaPower: 0, betaPower: 0, gammaPower: 0, muPower: 0, totalPower: 0,
        ),
      );
    }

    final numBins = n ~/ 2;
    List<double> freqs = [];
    List<double> amplitudes = [];
    List<double> psd = [];

    double deltaSum = 0;
    double thetaSum = 0;
    double alphaSum = 0;
    double betaSum = 0;
    double gammaSum = 0;
    double muSum = 0;
    double totalSum = 0;

    for (int k = 0; k < numBins; k++) {
      final f = (k * samplingRateHz) / n;
      if (f > 50.0) break; // Limit to 0-50 Hz clinical range

      // Discrete Fourier Transform (DFT) bin magnitude calculation
      double real = 0.0;
      double imag = 0.0;
      for (int t = 0; t < n; t++) {
        final angle = (2 * math.pi * k * t) / n;
        real += signal[t] * math.cos(angle);
        imag -= signal[t] * math.sin(angle);
      }

      final amp = math.sqrt(real * real + imag * imag) / n;
      final power = amp * amp;

      freqs.add(f);
      amplitudes.add(amp);
      psd.add(power);

      totalSum += power;

      // Band Assignment
      if (f >= 0.5 && f < 4.0) deltaSum += power;
      if (f >= 4.0 && f < 8.0) thetaSum += power;
      if (f >= 8.0 && f <= 13.0) {
        alphaSum += power;
        if (f >= 8.0 && f <= 12.0) muSum += power;
      }
      if (f > 13.0 && f < 30.0) betaSum += power;
      if (f >= 30.0 && f <= 50.0) gammaSum += power;
    }

    return FrequencyAnalysisResult(
      frequenciesHz: freqs,
      spectralAmplitudes: amplitudes,
      psdValues: psd,
      bandPower: BandPowerResult(
        deltaPower: deltaSum,
        thetaPower: thetaSum,
        alphaPower: alphaSum,
        betaPower: betaSum,
        gammaPower: gammaSum,
        muPower: muSum,
        totalPower: totalSum,
      ),
    );
  }
}
