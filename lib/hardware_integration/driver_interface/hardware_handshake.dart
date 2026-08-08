import 'dart:async';
import '../../device_connectivity/models/device_models.dart';
import '../protocol/hardware_protocol.dart';
import '../transports/hardware_communication_transports.dart';

abstract class IDeviceConnection {
  Future<bool> connect(DiscoveredDevice device);
  Future<HandshakeResult> identify();
  Future<bool> configure();
  Future<void> disconnect();
}

class HardwareConnectionPipeline implements IDeviceConnection {
  DiscoveredDevice? _connectedDevice;
  IHardwareTransport? _transport;
  HardwareProtocol _protocol = StandardPyroSyncProtocol();
  bool _isOpen = false;

  DiscoveredDevice? get currentDevice => _connectedDevice;
  IHardwareTransport? get activeTransport => _transport;
  HardwareProtocol get protocol => _protocol;

  void setProtocol(HardwareProtocol newProtocol) {
    _protocol = newProtocol;
  }

  @override
  Future<bool> connect(DiscoveredDevice device) async {
    _connectedDevice = device;

    switch (device.transportCategory) {
      case HardwareTransportCategory.ble:
        _transport = BleTransport();
        break;
      case HardwareTransportCategory.bluetoothClassic:
        _transport = RfcommTransport();
        break;
      case HardwareTransportCategory.usbSerial:
        _transport = UsbSerialTransport();
        break;
      case HardwareTransportCategory.network:
        _transport = NetworkTransport();
        break;
    }

    _isOpen = await _transport!.connect(device.portOrAddress);
    return _isOpen;
  }

  @override
  Future<HandshakeResult> identify() async {
    if (!_isOpen || _connectedDevice == null || _transport == null) {
      return HandshakeResult.failed('Transport port not opened.');
    }

    final dev = _connectedDevice!;

    if (!_protocol.isConfigured) {
      return HandshakeResult.failed(
        'Protocol not configured for third-party device ${dev.name}.',
        protocolConfigured: false,
      );
    }

    await Future.delayed(const Duration(milliseconds: 300));
    return await _protocol.identify(_transport!, dev);
  }

  @override
  Future<bool> configure() async {
    return true;
  }

  @override
  Future<void> disconnect() async {
    if (_transport != null) {
      await _transport!.disconnect();
      _transport = null;
    }
    _isOpen = false;
    _connectedDevice = null;
  }
}
