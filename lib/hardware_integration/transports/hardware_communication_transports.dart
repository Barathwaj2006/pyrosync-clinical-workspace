import 'dart:async';
import 'dart:typed_data';

enum TransportType { ble, bluetoothClassic, wifiTcp, wifiUdp, usbSerial }
enum TransportConnectionState { disconnected, connecting, connected, reconnecting, error }

abstract class IHardwareTransport {
  TransportType get type;
  TransportConnectionState get connectionState;
  double get latencyMs;
  String get errorState;

  Future<bool> connect(String address);
  Future<void> disconnect();
  Future<bool> send(Uint8List bytes);
  Stream<Uint8List> receive();
  Future<bool> reconnect();
}

class BleTransport implements IHardwareTransport {
  @override
  final TransportType type = TransportType.ble;
  TransportConnectionState _state = TransportConnectionState.disconnected;
  String _error = '';
  final _receiveController = StreamController<Uint8List>.broadcast();

  @override
  TransportConnectionState get connectionState => _state;
  @override
  double get latencyMs => 4.2;
  @override
  String get errorState => _error;

  @override
  Future<bool> connect(String address) async {
    _state = TransportConnectionState.connecting;
    await Future.delayed(const Duration(milliseconds: 50));
    _state = TransportConnectionState.connected;
    return true;
  }

  @override
  Future<void> disconnect() async {
    _state = TransportConnectionState.disconnected;
  }

  @override
  Future<bool> send(Uint8List bytes) async => true;
  @override
  Stream<Uint8List> receive() => _receiveController.stream;
  @override
  Future<bool> reconnect() async => connect('');
}

class WifiTcpTransport implements IHardwareTransport {
  @override
  final TransportType type = TransportType.wifiTcp;
  TransportConnectionState _state = TransportConnectionState.disconnected;

  @override
  TransportConnectionState get connectionState => _state;
  @override
  double get latencyMs => 1.8;
  @override
  String get errorState => '';

  @override
  Future<bool> connect(String address) async {
    _state = TransportConnectionState.connected;
    return true;
  }

  @override
  Future<void> disconnect() async {
    _state = TransportConnectionState.disconnected;
  }

  @override
  Future<bool> send(Uint8List bytes) async => true;
  @override
  Stream<Uint8List> receive() => const Stream.empty();
  @override
  Future<bool> reconnect() async => connect('');
}

class UsbSerialTransport implements IHardwareTransport {
  @override
  final TransportType type = TransportType.usbSerial;
  TransportConnectionState _state = TransportConnectionState.disconnected;

  @override
  TransportConnectionState get connectionState => _state;
  @override
  double get latencyMs => 0.6;
  @override
  String get errorState => '';

  @override
  Future<bool> connect(String address) async {
    _state = TransportConnectionState.connected;
    return true;
  }

  @override
  Future<void> disconnect() async {
    _state = TransportConnectionState.disconnected;
  }

  @override
  Future<bool> send(Uint8List bytes) async => true;
  @override
  Stream<Uint8List> receive() => const Stream.empty();
  @override
  Future<bool> reconnect() async => connect('');
}
