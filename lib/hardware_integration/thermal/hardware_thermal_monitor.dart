import 'dart:async';

enum ThermalState { nominal, warm, overheating, critical }

class ThermalTelemetry {
  final double temperatureCelsius;
  final double temperatureFahrenheit;
  final ThermalState state;
  final double heatingRateCelsiusPerMin;
  final bool isThermalThrottlingActive;

  ThermalTelemetry({
    required this.temperatureCelsius,
    required this.temperatureFahrenheit,
    required this.state,
    required this.heatingRateCelsiusPerMin,
    required this.isThermalThrottlingActive,
  });
}

class HardwareThermalMonitor {
  double _currentTempCelsius = 36.8;
  final _controller = StreamController<ThermalTelemetry>.broadcast();

  Stream<ThermalTelemetry> get thermalStream => _controller.stream;

  ThermalTelemetry get currentTelemetry => _evaluateState(_currentTempCelsius);

  ThermalTelemetry updateTemperature(double celsius) {
    _currentTempCelsius = celsius;
    final telemetry = _evaluateState(celsius);
    _controller.add(telemetry);
    return telemetry;
  }

  ThermalTelemetry _evaluateState(double temp) {
    ThermalState state = ThermalState.nominal;
    bool throttle = false;

    if (temp >= 45.0) {
      state = ThermalState.critical;
      throttle = true;
    } else if (temp >= 41.0) {
      state = ThermalState.overheating;
      throttle = true;
    } else if (temp >= 38.5) {
      state = ThermalState.warm;
    }

    return ThermalTelemetry(
      temperatureCelsius: temp,
      temperatureFahrenheit: (temp * 9 / 5) + 32,
      state: state,
      heatingRateCelsiusPerMin: 0.04,
      isThermalThrottlingActive: throttle,
    );
  }

  void dispose() {
    _controller.close();
  }
}
