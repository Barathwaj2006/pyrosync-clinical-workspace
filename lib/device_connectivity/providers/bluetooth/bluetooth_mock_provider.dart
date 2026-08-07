import 'dart:async';
import '../../../core_engines/signal_provider/signal_provider_interface.dart';

class BluetoothMockProvider implements ISignalProvider {
  final StreamController<SignalChunk> _chunkController = StreamController<SignalChunk>.broadcast();
  final StreamController<SignalConnectionState> _stateController = StreamController<SignalConnectionState>.broadcast();
  SignalConnectionState _state = SignalConnectionState.disconnected;

  @override
  String get providerId => 'BLE-PYROSYNC-500';

  @override
  String get providerName => 'Bluetooth Low Energy (BLE) Acquisition Driver';

  @override
  double get targetSamplingRateHz => 2500.0;

  @override
  int get channelCount => 8;

  @override
  Future<bool> connect() async {
    _state = SignalConnectionState.connecting;
    _stateController.add(_state);
    await Future.delayed(const Duration(milliseconds: 600));
    _state = SignalConnectionState.connected;
    _stateController.add(_state);
    return true;
  }

  @override
  Future<bool> disconnect() async {
    _state = SignalConnectionState.disconnected;
    _stateController.add(_state);
    return true;
  }

  @override
  Stream<SignalChunk> get signalStream => _chunkController.stream;

  @override
  Stream<SignalConnectionState> get connectionStateStream => _stateController.stream;

  @override
  SignalConnectionState get currentConnectionState => _state;

  @override
  Future<Map<String, double>> fetchChannelImpedances() async {
    return {'Oz': 2.1, 'Cz': 1.8, 'O1': 2.5, 'O2': 2.4, 'Fz': 3.1, 'Pz': 2.0, 'T3': 2.8, 'T4': 2.7};
  }
}
