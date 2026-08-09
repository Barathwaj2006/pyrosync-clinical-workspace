import 'dart:async';
import 'dart:typed_data';

enum TransportType { ble, bluetoothClassic, wifiTcp, wifiUdp, usbSerial }
enum TransportConnectionState { disconnected, connecting, connected, reconnecting, error }

class AcquisitionChunk {
  final DateTime timestamp;
  final int sequence;
  final List<List<double>> channelSamples;
  final double samplingRateHz;
  final int channelCount;
  final List<int> eventsOrTriggers;
  final bool isSimulatedData;

  AcquisitionChunk({
    required this.timestamp,
    required this.sequence,
    required this.channelSamples,
    required this.samplingRateHz,
    required this.channelCount,
    required this.eventsOrTriggers,
    this.isSimulatedData = false,
  });
}

abstract class IHardwareTransport {
  TransportType get type;
  TransportConnectionState get connectionState;
  double get latencyMs;
  String get errorState;

  Future<bool> connect(String addressOrPort);
  Future<void> disconnect();
  Future<bool> send(Uint8List bytes);
  Stream<Uint8List> receive();
  Stream<AcquisitionChunk> get acquisitionStream;
  Future<bool> reconnect();
}

class BleTransport implements IHardwareTransport {
  @override
  final TransportType type = TransportType.ble;
  TransportConnectionState _state = TransportConnectionState.disconnected;
  final String _error = '';
  final _receiveController = StreamController<Uint8List>.broadcast();
  final _chunkController = StreamController<AcquisitionChunk>.broadcast();

  @override
  TransportConnectionState get connectionState => _state;
  @override
  double get latencyMs => 4.2;
  @override
  String get errorState => _error;

  @override
  Future<bool> connect(String addressOrPort) async {
    _state = TransportConnectionState.connecting;
    await Future.delayed(const Duration(milliseconds: 100));
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
  Stream<AcquisitionChunk> get acquisitionStream => _chunkController.stream;
  @override
  Future<bool> reconnect() async => connect('');
}

class RfcommTransport implements IHardwareTransport {
  @override
  final TransportType type = TransportType.bluetoothClassic;
  TransportConnectionState _state = TransportConnectionState.disconnected;
  final String _error = '';
  final _receiveController = StreamController<Uint8List>.broadcast();
  final _chunkController = StreamController<AcquisitionChunk>.broadcast();

  @override
  TransportConnectionState get connectionState => _state;
  @override
  double get latencyMs => 3.5;
  @override
  String get errorState => _error;

  @override
  Future<bool> connect(String addressOrPort) async {
    _state = TransportConnectionState.connecting;
    await Future.delayed(const Duration(milliseconds: 100));
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
  Stream<AcquisitionChunk> get acquisitionStream => _chunkController.stream;
  @override
  Future<bool> reconnect() async => connect('');
}

class UsbSerialTransport implements IHardwareTransport {
  @override
  final TransportType type = TransportType.usbSerial;
  TransportConnectionState _state = TransportConnectionState.disconnected;
  final String _error = '';
  final _receiveController = StreamController<Uint8List>.broadcast();
  final _chunkController = StreamController<AcquisitionChunk>.broadcast();

  @override
  TransportConnectionState get connectionState => _state;
  @override
  double get latencyMs => 0.6;
  @override
  String get errorState => _error;

  @override
  Future<bool> connect(String addressOrPort) async {
    _state = TransportConnectionState.connecting;
    await Future.delayed(const Duration(milliseconds: 100));
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
  Stream<AcquisitionChunk> get acquisitionStream => _chunkController.stream;
  @override
  Future<bool> reconnect() async => connect('');
}

class NetworkTransport implements IHardwareTransport {
  @override
  final TransportType type = TransportType.wifiTcp;
  TransportConnectionState _state = TransportConnectionState.disconnected;
  final String _error = '';
  final _receiveController = StreamController<Uint8List>.broadcast();
  final _chunkController = StreamController<AcquisitionChunk>.broadcast();

  @override
  TransportConnectionState get connectionState => _state;
  @override
  double get latencyMs => 1.8;
  @override
  String get errorState => _error;

  @override
  Future<bool> connect(String addressOrPort) async {
    _state = TransportConnectionState.connecting;
    await Future.delayed(const Duration(milliseconds: 100));
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
  Stream<AcquisitionChunk> get acquisitionStream => _chunkController.stream;
  @override
  Future<bool> reconnect() async => connect('');
}
