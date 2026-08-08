import 'dart:async';

enum SignalConnectionState {
  disconnected,
  connecting,
  connected,
  error,
}

class SignalChunk {
  final int channelId;
  final String channelName;
  final List<double> samples;
  final double samplingRateHz;
  final DateTime timestamp;

  SignalChunk({
    required this.channelId,
    required this.channelName,
    required this.samples,
    required this.samplingRateHz,
    required this.timestamp,
  });
}

abstract class ISignalProvider {
  String get providerId;
  String get displayName;
  SignalConnectionState get connectionState;

  Stream<SignalChunk> get signalStream;
  Stream<SignalConnectionState> get connectionStateStream;

  Future<bool> connect();
  Future<void> disconnect();
  Future<void> sendStimulusTrigger(int triggerCode);
}
