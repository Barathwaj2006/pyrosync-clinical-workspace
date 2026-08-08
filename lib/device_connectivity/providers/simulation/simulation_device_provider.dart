import 'dart:async';
import '../../../core_engines/signal_provider/signal_provider_interface.dart';
import '../../../modules/neurolab/neurolab_signal_provider.dart';

class SimulationDeviceProvider implements ISignalProvider {
  final NeuroLabSignalProvider _neuroLabSignalProvider = NeuroLabSignalProvider();

  @override
  String get providerId => 'SIM-NEUROLAB-01';

  @override
  String get displayName => 'NeuroLab Virtual Laboratory Signal Provider';

  @override
  SignalConnectionState get connectionState => _neuroLabSignalProvider.connectionState;

  double get targetSamplingRateHz => 2500.0;
  int get channelCount => 8;

  @override
  Future<bool> connect() async {
    return await _neuroLabSignalProvider.connect();
  }

  @override
  Future<void> disconnect() async {
    await _neuroLabSignalProvider.disconnect();
  }

  @override
  Future<void> sendStimulusTrigger(int triggerCode) async {
    await _neuroLabSignalProvider.sendStimulusTrigger(triggerCode);
  }

  @override
  Stream<SignalChunk> get signalStream => _neuroLabSignalProvider.signalStream;

  @override
  Stream<SignalConnectionState> get connectionStateStream => _neuroLabSignalProvider.connectionStateStream;

  Future<Map<String, double>> fetchChannelImpedances() async {
    return {'Oz': 1.5, 'Cz': 2.4, 'O1': 1.8, 'O2': 2.1, 'Fz': 2.0, 'Pz': 1.9, 'T3': 2.2, 'T4': 2.3};
  }
}
