import 'dart:async';
import 'dart:math' as math;
import '../../core_engines/signal_provider/signal_provider_interface.dart';

class NeuroLabSignalProvider implements ISignalProvider {
  @override
  final String providerId = 'neurolab-virtual-device-v2.4';
  
  @override
  final String displayName = 'PyroSync Virtual Device (NeuroLab Simulation)';

  SignalConnectionState _connectionState = SignalConnectionState.disconnected;
  final StreamController<SignalChunk> _signalController = StreamController<SignalChunk>.broadcast();
  final StreamController<SignalConnectionState> _connectionController = StreamController<SignalConnectionState>.broadcast();
  Timer? _streamTimer;
  int _sampleIndex = 0;

  // Artifact Injection Flags & Severities (0.0 to 1.0)
  bool enableBlinkArtifact = false;
  double blinkSeverity = 0.5;
  bool enableMuscleArtifact = false;
  double muscleSeverity = 0.5;
  bool enableLineNoise = false;
  double lineNoiseSeverity = 0.5;
  bool enableBaselineDrift = false;
  double driftSeverity = 0.5;

  // Rhythm Gain Factors
  double alphaGain = 1.0;
  double betaGain = 0.2;
  double thetaGain = 0.3;
  double deltaGain = 0.1;

  @override
  SignalConnectionState get connectionState => _connectionState;

  @override
  Stream<SignalChunk> get signalStream => _signalController.stream;

  @override
  Stream<SignalConnectionState> get connectionStateStream => _connectionController.stream;

  @override
  Future<bool> connect() async {
    _connectionState = SignalConnectionState.connecting;
    _connectionController.add(_connectionState);
    
    await Future.delayed(const Duration(milliseconds: 400));
    _connectionState = SignalConnectionState.connected;
    _connectionController.add(_connectionState);

    _sampleIndex = 0;
    _streamTimer?.cancel();
    _streamTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (_connectionState != SignalConnectionState.connected) return;
      _emitSyntheticChunk();
    });

    return true;
  }

  @override
  Future<void> disconnect() async {
    _connectionState = SignalConnectionState.disconnected;
    _connectionController.add(_connectionState);
    _streamTimer?.cancel();
  }

  @override
  Future<void> sendStimulusTrigger(int triggerCode) async {
    // Virtual trigger acknowledgment
  }

  void _emitSyntheticChunk() {
    List<double> samples = [];
    final random = math.Random();

    for (int i = 0; i < 40; i++) {
      _sampleIndex++;
      final tSec = _sampleIndex / 2500.0;
      final ms = (_sampleIndex % 250) * 1.0;

      // 1. Synthetic VEP Base Signal (Oz-Cz)
      double y = 0.0;
      y -= 25.0 * math.exp(-math.pow((ms - 74.0) / 12.0, 2));
      y += 65.0 * math.exp(-math.pow((ms - 101.4) / 14.0, 2));
      y -= 35.0 * math.exp(-math.pow((ms - 145.0) / 18.0, 2));

      // 2. Synthetic EEG Rhythms
      y += 8.0 * alphaGain * math.sin(2 * math.pi * 10.0 * tSec); // Alpha 10Hz
      y += 4.0 * betaGain * math.sin(2 * math.pi * 22.0 * tSec);  // Beta 22Hz
      y += 6.0 * thetaGain * math.sin(2 * math.pi * 6.0 * tSec);  // Theta 6Hz
      y += 10.0 * deltaGain * math.sin(2 * math.pi * 2.0 * tSec); // Delta 2Hz

      // 3. Artifact Injection
      if (enableBlinkArtifact && (_sampleIndex % 1250 < 100)) {
        y += 80.0 * blinkSeverity * math.sin(math.pi * (_sampleIndex % 1250) / 100.0);
      }
      if (enableMuscleArtifact) {
        y += (random.nextDouble() - 0.5) * 30.0 * muscleSeverity;
      }
      if (enableLineNoise) {
        y += 15.0 * lineNoiseSeverity * math.sin(2 * math.pi * 50.0 * tSec);
      }
      if (enableBaselineDrift) {
        y += 20.0 * driftSeverity * math.sin(2 * math.pi * 0.2 * tSec);
      }

      samples.add(y);
    }

    final chunk = SignalChunk(
      channelId: 1,
      channelName: 'Oz',
      samples: samples,
      samplingRateHz: 2500.0,
      timestamp: DateTime.now(),
    );

    _signalController.add(chunk);
  }
}
