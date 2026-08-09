import 'dart:core';

enum ProviderType { usbSerial, ble, bluetoothClassic, wifi, simulation, none }

enum DeviceConnectionState {
  noDevice,
  idle,
  scanning,
  devicesFound,
  userSelectionRequired,
  connecting,
  discoveringServices,
  verifying,
  waitingForSignal,
  verified,
  streaming,
  unstable,
  connected,
  disconnecting,
  disconnected,
  error,
}

enum HardwareTransportCategory {
  ble,
  bluetoothClassic,
  usbSerial,
  network,
}

class DiscoveredDevice {
  final String id;
  final String name;
  final String portOrAddress;
  final HardwareTransportCategory transportCategory;
  final String description;
  final int? rssiDbm;
  final String? vidPid;
  final String? manufacturer;
  final bool isEegServiceDetected;
  final bool isAvailable;
  final String? statusNote;

  DiscoveredDevice({
    required this.id,
    required this.name,
    required this.portOrAddress,
    required this.transportCategory,
    required this.description,
    this.rssiDbm,
    this.vidPid,
    this.manufacturer,
    this.isEegServiceDetected = false,
    this.isAvailable = true,
    this.statusNote,
  });
}

class HandshakeResult {
  final bool success;
  final DeviceInfo? deviceInfo;
  final String errorMessage;
  final bool isProtocolConfigured;

  HandshakeResult({
    required this.success,
    this.deviceInfo,
    required this.errorMessage,
    this.isProtocolConfigured = true,
  });

  factory HandshakeResult.failed(String reason, {bool protocolConfigured = true}) {
    return HandshakeResult(
      success: false,
      deviceInfo: null,
      errorMessage: reason,
      isProtocolConfigured: protocolConfigured,
    );
  }

  factory HandshakeResult.verified(DeviceInfo info) {
    return HandshakeResult(
      success: true,
      deviceInfo: info,
      errorMessage: '',
      isProtocolConfigured: true,
    );
  }
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
  final bool isSimulated;

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
    this.isSimulated = false,
  });

  DeviceInfo copyWith({
    double? batteryPercentage,
    double? signalQualityScore,
    double? temperatureCelsius,
    Duration? uptime,
    bool? isSimulated,
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
      isSimulated: isSimulated ?? this.isSimulated,
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
  final double connectionQualityScore;
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

  factory DeviceDiagnostics.empty() {
    return DeviceDiagnostics(
      framesReceived: 0,
      packetsLost: 0,
      latencyMs: 0.0,
      droppedSamples: 0,
      reconnectCount: 0,
      communicationErrors: 0,
      signalInterruptions: 0,
      connectionQualityScore: 0.0,
      bufferSizeBytes: 4096,
    );
  }
}

class PokidexDiagnosticsMetrics {
  final int packetsReceived;
  final int packetsExpected;
  final int packetsLost;
  final double packetLossPercentage;
  final int duplicatePackets;
  final int malformedPackets;
  final int outOfOrderPackets;
  final double configuredRateHz;
  final double actualRateHz;
  final double jitterMs;
  final double latencyMs;
  final String statusText;
  final List<String> rejectionReasons;

  PokidexDiagnosticsMetrics({
    required this.packetsReceived,
    required this.packetsExpected,
    required this.packetsLost,
    required this.packetLossPercentage,
    required this.duplicatePackets,
    required this.malformedPackets,
    required this.outOfOrderPackets,
    required this.configuredRateHz,
    required this.actualRateHz,
    required this.jitterMs,
    required this.latencyMs,
    required this.statusText,
    required this.rejectionReasons,
  });

  factory PokidexDiagnosticsMetrics.empty() {
    return PokidexDiagnosticsMetrics(
      packetsReceived: 0,
      packetsExpected: 0,
      packetsLost: 0,
      packetLossPercentage: 0.0,
      duplicatePackets: 0,
      malformedPackets: 0,
      outOfOrderPackets: 0,
      configuredRateHz: 250.0,
      actualRateHz: 0.0,
      jitterMs: 0.0,
      latencyMs: 0.0,
      statusText: 'NO DEVICE CONNECTED',
      rejectionReasons: const [],
    );
  }
}
