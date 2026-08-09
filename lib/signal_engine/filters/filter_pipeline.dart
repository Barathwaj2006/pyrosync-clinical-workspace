import 'dart:math' as math;

abstract class ISignalFilter {
  String get filterName;
  List<double> process(List<double> input, double samplingRateHz);
}

// 1. 50 Hz Notch Filter (IIR Bandstop)
class NotchFilter50Hz implements ISignalFilter {
  @override
  final String filterName = "50 Hz Line Noise Notch Filter";

  @override
  List<double> process(List<double> input, double samplingRateHz) {
    if (input.length < 3) return input;
    const f0 = 50.0;
    final w0 = 2 * math.pi * f0 / samplingRateHz;
    final alpha = math.sin(w0) / (2 * 30.0); // Q = 30

    const b0 = 1.0;
    final b1 = -2 * math.cos(w0);
    const b2 = 1.0;
    final a0 = 1 + alpha;
    final a1 = -2 * math.cos(w0);
    final a2 = 1 - alpha;

    List<double> output = List.filled(input.length, 0.0);
    for (int i = 2; i < input.length; i++) {
      output[i] = (b0 / a0) * input[i] +
          (b1 / a0) * input[i - 1] +
          (b2 / a0) * input[i - 2] -
          (a1 / a0) * output[i - 1] -
          (a2 / a0) * output[i - 2];
    }
    return output;
  }
}

// 2. High-Pass Filter (DC & slow drift suppression > 1.0 Hz)
class HighPassFilter implements ISignalFilter {
  final double cutoffHz;
  HighPassFilter({this.cutoffHz = 1.0});

  @override
  String get filterName => "High-Pass Filter ($cutoffHz Hz)";

  @override
  List<double> process(List<double> input, double samplingRateHz) {
    if (input.length < 2) return input;
    final dt = 1.0 / samplingRateHz;
    final rc = 1.0 / (2 * math.pi * cutoffHz);
    final alpha = rc / (rc + dt);

    List<double> output = List.filled(input.length, 0.0);
    output[0] = input[0];
    for (int i = 1; i < input.length; i++) {
      output[i] = alpha * (output[i - 1] + input[i] - input[i - 1]);
    }
    return output;
  }
}

// 3. Low-Pass Filter (High frequency noise suppression < 100 Hz)
class LowPassFilter implements ISignalFilter {
  final double cutoffHz;
  LowPassFilter({this.cutoffHz = 100.0});

  @override
  String get filterName => "Low-Pass Filter ($cutoffHz Hz)";

  @override
  List<double> process(List<double> input, double samplingRateHz) {
    if (input.length < 2) return input;
    final dt = 1.0 / samplingRateHz;
    final rc = 1.0 / (2 * math.pi * cutoffHz);
    final alpha = dt / (rc + dt);

    List<double> output = List.filled(input.length, 0.0);
    output[0] = input[0];
    for (int i = 1; i < input.length; i++) {
      output[i] = output[i - 1] + alpha * (input[i] - output[i - 1]);
    }
    return output;
  }
}

// Filter Chain Pipeline
class FilterPipeline {
  final List<ISignalFilter> filters;

  FilterPipeline(this.filters);

  List<double> apply(List<double> signal, double samplingRateHz) {
    List<double> current = List.from(signal);
    for (final f in filters) {
      current = f.process(current, samplingRateHz);
    }
    return current;
  }
}
