import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core_engines/signal_provider/signal_provider_interface.dart';
import 'neurolab_signal_provider.dart';

class VirtualDeviceTelemetry {
  final String deviceName;
  final String firmwareVersion;
  final double batteryPercentage;
  final double temperatureCelsius;
  final int activeChannels;
  final SignalConnectionState connectionState;
  final List<String> deviceLogs;

  VirtualDeviceTelemetry({
    required this.deviceName,
    required this.firmwareVersion,
    required this.batteryPercentage,
    required this.temperatureCelsius,
    required this.activeChannels,
    required this.connectionState,
    required this.deviceLogs,
  });

  VirtualDeviceTelemetry copyWith({
    SignalConnectionState? connectionState,
    List<String>? deviceLogs,
  }) {
    return VirtualDeviceTelemetry(
      deviceName: deviceName,
      firmwareVersion: firmwareVersion,
      batteryPercentage: batteryPercentage,
      temperatureCelsius: temperatureCelsius,
      activeChannels: activeChannels,
      connectionState: connectionState ?? this.connectionState,
      deviceLogs: deviceLogs ?? this.deviceLogs,
    );
  }
}

class NeuroLabState {
  final VirtualDeviceTelemetry deviceTelemetry;
  final String selectedLibraryPreset;
  final bool isBlinkArtifactEnabled;
  final double blinkSeverity;
  final bool isMuscleArtifactEnabled;
  final double muscleSeverity;
  final bool isLineNoiseEnabled;
  final double lineNoiseSeverity;
  final bool isBaselineDriftEnabled;
  final double driftSeverity;
  final double alphaGain;
  final double betaGain;
  final double thetaGain;
  final String playbackState;
  final double playbackSpeed;

  NeuroLabState({
    required this.deviceTelemetry,
    required this.selectedLibraryPreset,
    required this.isBlinkArtifactEnabled,
    required this.blinkSeverity,
    required this.isMuscleArtifactEnabled,
    required this.muscleSeverity,
    required this.isLineNoiseEnabled,
    required this.lineNoiseSeverity,
    required this.isBaselineDriftEnabled,
    required this.driftSeverity,
    required this.alphaGain,
    required this.betaGain,
    required this.thetaGain,
    required this.playbackState,
    required this.playbackSpeed,
  });

  NeuroLabState copyWith({
    VirtualDeviceTelemetry? deviceTelemetry,
    String? selectedLibraryPreset,
    bool? isBlinkArtifactEnabled,
    double? blinkSeverity,
    bool? isMuscleArtifactEnabled,
    double? muscleSeverity,
    bool? isLineNoiseEnabled,
    double? lineNoiseSeverity,
    bool? isBaselineDriftEnabled,
    double? driftSeverity,
    double? alphaGain,
    double? betaGain,
    double? thetaGain,
    String? playbackState,
    double? playbackSpeed,
  }) {
    return NeuroLabState(
      deviceTelemetry: deviceTelemetry ?? this.deviceTelemetry,
      selectedLibraryPreset: selectedLibraryPreset ?? this.selectedLibraryPreset,
      isBlinkArtifactEnabled: isBlinkArtifactEnabled ?? this.isBlinkArtifactEnabled,
      blinkSeverity: blinkSeverity ?? this.blinkSeverity,
      isMuscleArtifactEnabled: isMuscleArtifactEnabled ?? this.isMuscleArtifactEnabled,
      muscleSeverity: muscleSeverity ?? this.muscleSeverity,
      isLineNoiseEnabled: isLineNoiseEnabled ?? this.isLineNoiseEnabled,
      lineNoiseSeverity: lineNoiseSeverity ?? this.lineNoiseSeverity,
      isBaselineDriftEnabled: isBaselineDriftEnabled ?? this.isBaselineDriftEnabled,
      driftSeverity: driftSeverity ?? this.driftSeverity,
      alphaGain: alphaGain ?? this.alphaGain,
      betaGain: betaGain ?? this.betaGain,
      thetaGain: thetaGain ?? this.thetaGain,
      playbackState: playbackState ?? this.playbackState,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
    );
  }
}

final neurolabSignalProviderInstance = NeuroLabSignalProvider();

final neurolabEngineProvider = StateNotifierProvider<NeuroLabEngineNotifier, NeuroLabState>((ref) {
  return NeuroLabEngineNotifier(neurolabSignalProviderInstance);
});

class NeuroLabEngineNotifier extends StateNotifier<NeuroLabState> {
  final NeuroLabSignalProvider _signalProvider;

  NeuroLabEngineNotifier(this._signalProvider)
      : super(
          NeuroLabState(
            deviceTelemetry: VirtualDeviceTelemetry(
              deviceName: 'PyroSync Virtual Acquisition Device',
              firmwareVersion: 'v2.4-Simulated',
              batteryPercentage: 98.5,
              temperatureCelsius: 36.5,
              activeChannels: 8,
              connectionState: SignalConnectionState.connected,
              deviceLogs: [
                '[00:00:01] Virtual Device Power ON.',
                '[00:00:02] Self-diagnostics passed (All 8 channels OK).',
                '[00:00:03] Stream initialized at 2500 Hz.',
              ],
            ),
            selectedLibraryPreset: 'Normal VEP Pattern Reversal (Oz-Cz)',
            isBlinkArtifactEnabled: false,
            blinkSeverity: 0.5,
            isMuscleArtifactEnabled: false,
            muscleSeverity: 0.5,
            isLineNoiseEnabled: false,
            lineNoiseSeverity: 0.5,
            isBaselineDriftEnabled: false,
            driftSeverity: 0.5,
            alphaGain: 1.0,
            betaGain: 0.2,
            thetaGain: 0.3,
            playbackState: 'Stopped',
            playbackSpeed: 1.0,
          ),
        ) {
    // Automatically connect virtual signal provider
    _signalProvider.connect();
  }

  void toggleDeviceConnection() async {
    if (state.deviceTelemetry.connectionState == SignalConnectionState.connected) {
      await _signalProvider.disconnect();
      final updatedLogs = [...state.deviceTelemetry.deviceLogs, '[${DateTime.now().toIso8601String().substring(11, 19)}] User pressed Disconnect. Stream paused.'];
      state = state.copyWith(
        deviceTelemetry: state.deviceTelemetry.copyWith(
          connectionState: SignalConnectionState.disconnected,
          deviceLogs: updatedLogs,
        ),
      );
    } else {
      await _signalProvider.connect();
      final updatedLogs = [...state.deviceTelemetry.deviceLogs, '[${DateTime.now().toIso8601String().substring(11, 19)}] User pressed Connect. Stream active @ 2500 Hz.'];
      state = state.copyWith(
        deviceTelemetry: state.deviceTelemetry.copyWith(
          connectionState: SignalConnectionState.connected,
          deviceLogs: updatedLogs,
        ),
      );
    }
  }

  void toggleArtifact({bool? blink, bool? muscle, bool? lineNoise, bool? drift}) {
    if (blink != null) {
      state = state.copyWith(isBlinkArtifactEnabled: blink);
      _signalProvider.enableBlinkArtifact = blink;
    }
    if (muscle != null) {
      state = state.copyWith(isMuscleArtifactEnabled: muscle);
      _signalProvider.enableMuscleArtifact = muscle;
    }
    if (lineNoise != null) {
      state = state.copyWith(isLineNoiseEnabled: lineNoise);
      _signalProvider.enableLineNoise = lineNoise;
    }
    if (drift != null) {
      state = state.copyWith(isBaselineDriftEnabled: drift);
      _signalProvider.enableBaselineDrift = drift;
    }
  }

  void setArtifactSeverity({double? blink, double? muscle, double? lineNoise, double? drift}) {
    if (blink != null) {
      state = state.copyWith(blinkSeverity: blink);
      _signalProvider.blinkSeverity = blink;
    }
    if (muscle != null) {
      state = state.copyWith(muscleSeverity: muscle);
      _signalProvider.muscleSeverity = muscle;
    }
    if (lineNoise != null) {
      state = state.copyWith(lineNoiseSeverity: lineNoise);
      _signalProvider.lineNoiseSeverity = lineNoise;
    }
    if (drift != null) {
      state = state.copyWith(driftSeverity: drift);
      _signalProvider.driftSeverity = drift;
    }
  }

  void setRhythmGains({double? alpha, double? beta, double? theta}) {
    if (alpha != null) {
      state = state.copyWith(alphaGain: alpha);
      _signalProvider.alphaGain = alpha;
    }
    if (beta != null) {
      state = state.copyWith(betaGain: beta);
      _signalProvider.betaGain = beta;
    }
    if (theta != null) {
      state = state.copyWith(thetaGain: theta);
      _signalProvider.thetaGain = theta;
    }
  }

  void selectPreset(String presetName) {
    state = state.copyWith(selectedLibraryPreset: presetName);

    // Auto-configure scenario parameters based on training preset
    if (presetName.contains('Blink Contamination')) {
      toggleArtifact(blink: true, muscle: false, lineNoise: false, drift: false);
      setArtifactSeverity(blink: 0.8);
    } else if (presetName.contains('Poor Electrode Contact')) {
      toggleArtifact(blink: false, muscle: true, lineNoise: true, drift: true);
      setArtifactSeverity(muscle: 0.7, lineNoise: 0.9, drift: 0.8);
    } else if (presetName.contains('Normal')) {
      toggleArtifact(blink: false, muscle: false, lineNoise: false, drift: false);
    }
  }
}
