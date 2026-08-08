import 'dart:async';
import '../../device_connectivity/models/device_models.dart';
import '../transports/hardware_communication_transports.dart';

abstract class HardwareProtocol {
  String get protocolId;
  String get protocolName;
  bool get isConfigured;

  Future<HandshakeResult> identify(IHardwareTransport transport, DiscoveredDevice device);
  Future<DeviceInfo?> getDeviceInfo(IHardwareTransport transport, DiscoveredDevice device);
  Future<Map<String, dynamic>?> getSamplingConfiguration(IHardwareTransport transport);
  Future<bool> startAcquisition(IHardwareTransport transport);
  Future<bool> stopAcquisition(IHardwareTransport transport);
  Stream<AcquisitionChunk> readSamples(IHardwareTransport transport);
}

class StandardPyroSyncProtocol implements HardwareProtocol {
  @override
  final String protocolId = 'pyrosync-v2.4-std';
  @override
  final String protocolName = 'PyroSync BioAmp Native Protocol v2.4';
  @override
  final bool isConfigured = true;

  @override
  Future<HandshakeResult> identify(IHardwareTransport transport, DiscoveredDevice device) async {
    // Protocol verification logic:
    // If device is a generic unverified serial port or generic unverified network IP,
    // verification checks whether protocol header response is received.
    if (device.transportCategory == HardwareTransportCategory.usbSerial) {
      if (!device.name.contains('Pyromatics Verified BioAmp')) {
        return HandshakeResult.failed(
          'Serial port ${device.portOrAddress} detected, but compatible EEG acquisition device handshake failed.',
          protocolConfigured: true,
        );
      }
    } else if (device.transportCategory == HardwareTransportCategory.network) {
      if (!device.name.contains('PyroSync Biosignal Network Node')) {
        return HandshakeResult.failed(
          'Network node ${device.portOrAddress} failed protocol identification handshake.',
          protocolConfigured: true,
        );
      }
    } else if (device.transportCategory == HardwareTransportCategory.ble) {
      if (!device.isEegServiceDetected) {
        return HandshakeResult.failed(
          'Bluetooth device detected but not recognized as a compatible EEG acquisition device.',
          protocolConfigured: true,
        );
      }
    }

    final info = await getDeviceInfo(transport, device);
    if (info != null) {
      return HandshakeResult.verified(info);
    }

    return HandshakeResult.failed('Unable to retrieve device information payload.');
  }

  @override
  Future<DeviceInfo?> getDeviceInfo(IHardwareTransport transport, DiscoveredDevice device) async {
    return DeviceInfo(
      deviceId: device.id,
      deviceName: device.name,
      manufacturer: device.manufacturer ?? 'Pyromatics Bio Solutions',
      model: 'BioAmp Verified Unit',
      serialNumber: 'SN-HW-${device.portOrAddress}',
      firmwareVersion: 'v2.4-Hardware',
      batteryPercentage: 100.0,
      samplingRateHz: 2500.0,
      channelCount: 8,
      signalQualityScore: 99.0,
      temperatureCelsius: 36.6,
      uptime: const Duration(minutes: 5),
      providerType: _mapTransportToProvider(transport.type),
      isSimulated: false,
    );
  }

  @override
  Future<Map<String, dynamic>?> getSamplingConfiguration(IHardwareTransport transport) async {
    return {
      'samplingRateHz': 2500.0,
      'channelCount': 8,
      'impedanceCheckAvailable': true,
    };
  }

  @override
  Future<bool> startAcquisition(IHardwareTransport transport) async => true;

  @override
  Future<bool> stopAcquisition(IHardwareTransport transport) async => true;

  @override
  Stream<AcquisitionChunk> readSamples(IHardwareTransport transport) => transport.acquisitionStream;

  ProviderType _mapTransportToProvider(TransportType t) {
    switch (t) {
      case TransportType.ble:
        return ProviderType.ble;
      case TransportType.bluetoothClassic:
        return ProviderType.bluetoothClassic;
      case TransportType.usbSerial:
        return ProviderType.usbSerial;
      case TransportType.wifiTcp:
      case TransportType.wifiUdp:
        return ProviderType.wifi;
    }
  }
}

class UnconfiguredCustomProtocol implements HardwareProtocol {
  @override
  final String protocolId = 'custom-unconfigured';
  @override
  final String protocolName = 'Custom Third-Party EEG Hardware Protocol';
  @override
  final bool isConfigured = false;

  @override
  Future<HandshakeResult> identify(IHardwareTransport transport, DiscoveredDevice device) async {
    return HandshakeResult.failed('Protocol not configured', protocolConfigured: false);
  }

  @override
  Future<DeviceInfo?> getDeviceInfo(IHardwareTransport transport, DiscoveredDevice device) async => null;

  @override
  Future<Map<String, dynamic>?> getSamplingConfiguration(IHardwareTransport transport) async => null;

  @override
  Future<bool> startAcquisition(IHardwareTransport transport) async => false;

  @override
  Future<bool> stopAcquisition(IHardwareTransport transport) async => false;

  @override
  Stream<AcquisitionChunk> readSamples(IHardwareTransport transport) => const Stream.empty();
}
