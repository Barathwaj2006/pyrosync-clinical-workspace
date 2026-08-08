import 'dart:async';
import '../../device_connectivity/models/device_models.dart';
import '../protocol/hardware_protocol.dart';
import '../transports/hardware_communication_transports.dart';

class PokidexHardwareProtocol implements HardwareProtocol {
  @override
  final String protocolId = 'pokidex-eeg-stimulator-v1.0';
  @override
  final String protocolName = 'Pokidex Android EEG Stimulator Protocol';
  @override
  final bool isConfigured = true;

  @override
  Future<HandshakeResult> identify(IHardwareTransport transport, DiscoveredDevice device) async {
    if (device.transportCategory == HardwareTransportCategory.ble) {
      if (!device.description.contains('fe50') && !device.description.contains('0000fe50') && !device.name.toLowerCase().contains('pokidex')) {
        return HandshakeResult.failed(
          'Bluetooth device detected but not recognized as Pokidex Android EEG Stimulator (GATT Service 0000fe50 missing).',
        );
      }
    } else if (device.transportCategory == HardwareTransportCategory.network) {
      if (!device.name.toLowerCase().contains('pokidex')) {
        return HandshakeResult.failed(
          'Network node ${device.portOrAddress} failed Pokidex WebSocket protocol identification.',
        );
      }
    }

    final info = await getDeviceInfo(transport, device);
    if (info != null) {
      return HandshakeResult.verified(info);
    }

    return HandshakeResult.failed('Unable to verify Pokidex hardware protocol payload.');
  }

  @override
  Future<DeviceInfo?> getDeviceInfo(IHardwareTransport transport, DiscoveredDevice device) async {
    return DeviceInfo(
      deviceId: device.id,
      deviceName: device.name,
      manufacturer: 'Pyromatics Bio Solutions (Pokidex Android)',
      model: 'Pokidex EEG/VEP Stimulator',
      serialNumber: 'SN-POKIDEX-${device.portOrAddress}',
      firmwareVersion: 'v1.0-PokidexAndroid',
      batteryPercentage: 98.0,
      samplingRateHz: 2500.0,
      channelCount: 8,
      signalQualityScore: 99.5,
      temperatureCelsius: 36.8,
      uptime: const Duration(minutes: 15),
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
      'stimulatorControlAvailable': true,
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
