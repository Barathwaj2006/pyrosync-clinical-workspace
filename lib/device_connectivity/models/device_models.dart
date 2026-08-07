import 'dart:core';

enum ProviderType { simulation, bluetooth, wifi, usb, replay }

enum DeviceConnectionState {
  disconnected,
  scanning,
  connecting,
  connected,
  streaming,
  paused,
  error,
  reconnecting,
}

class DeviceInfo {
  final String deviceId;
  final String deviceName;
  final String manufacturer;
  final String model;
  final String serialNumber;
  final String firmwareVersion;
  final double batteryPercentage;
  final double samplingRateHz;
  final int channelCount;
  final double signalQualityScore;
  final double temperatureCelsius;
  final Duration uptime;
  final ProviderType providerType;

  DeviceInfo({
    required this.deviceId,
    required this.deviceName,
    required this.manufacturer,
    required this.model,
    required this.serialNumber,
    required this.firmwareVersion,
    required this.batteryPercentage,
    required this.samplingRateHz,
    required this.channelCount,
    required this.signalQualityScore,
    required this.temperatureCelsius,
    required this.uptime,
    required this.providerType,
  });

  DeviceInfo copyWith({
    double? batteryPercentage,
    double? signalQualityScore,
    double? temperatureCelsius,
    Duration? uptime,
  }) {
    return DeviceInfo(
      deviceId: deviceId,
      deviceName: deviceName,
      manufacturer: manufacturer,
      model: model,
      serialNumber: serialNumber,
      firmwareVersion: firmwareVersion,
      batteryPercentage: batteryPercentage ?? this.batteryPercentage,
      samplingRateHz: samplingRateHz,
      channelCount: channelCount,
      signalQualityScore: signalQualityScore ?? this.signalQualityScore,
      temperatureCelsius: temperatureCelsius ?? this.temperatureCelsius,
      uptime: uptime ?? this.uptime,
      providerType: providerType,
    );
  }
}

class DeviceDiagnostics {
  final int framesReceived;
  final int packetsLost;
  final double latencyMs;
  final int droppedSamples;
  final int reconnectCount;
  final int communicationErrors;
  final int signalInterruptions;
  final double connectionQualityScore; // 0.0 to 100.0%
  final int bufferSizeBytes;

  DeviceDiagnostics({
    required this.framesReceived,
    required this.packetsLost,
    required this.latencyMs,
    required this.droppedSamples,
    required this.reconnectCount,
    required this.communicationErrors,
    required this.signalInterruptions,
    required this.connectionQualityScore,
    required this.bufferSizeBytes,
  });
}
