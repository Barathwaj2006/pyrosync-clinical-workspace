import 'dart:async';
import '../../../core_engines/signal_provider/signal_provider_interface.dart';
import '../../../modules/neurolab/neurolab_signal_provider.dart';

class SimulationDeviceProvider implements ISignalProvider {
  final NeuroLabSignalProvider _neuroLabSignalProvider = NeuroLabSignalProvider();

  @override
  String get providerId => 'SIM-NEUROLAB-01';

  @override
  String get providerName => 'NeuroLab Virtual Laboratory Signal Provider';

  @override
  double get targetSamplingRateHz => 2500.0;

  @override
  int get channelCount => 8;

  @override
  Future<bool> connect() async {
    return await _neuroLabSignalProvider.connect();
  }

  @override
  Future<bool> disconnect() async {
    return await _neuroLabSignalProvider.disconnect();
  }

  @override
  Stream<SignalChunk> get signalStream => _neuroLabSignalProvider.signalStream;

  @override
  Stream<SignalConnectionState> get connectionStateStream => _neuroLabSignalProvider.connectionStateStream;

  @override
  SignalConnectionState get currentConnectionState => _neuroLabSignalProvider.currentConnectionState;

  @override
  Future<Map<String, double>> fetchChannelImpedances() async {
    return await _neuroLabSignalProvider.fetchChannelImpedances();
  }
}
