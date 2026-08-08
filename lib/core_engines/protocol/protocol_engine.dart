import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChannelLayoutSpec {
  final String activeChannel;
  final String referenceChannel;
  final String groundChannel;
  final List<String> auxChannels;

  ChannelLayoutSpec({
    required this.activeChannel,
    required this.referenceChannel,
    required this.groundChannel,
    required this.auxChannels,
  });
}

class NeuroProtocol {
  final String protocolId;
  final String name;
  final String category;
  final int targetSamplingRateHz;
  final String stimulusType;
  final ChannelLayoutSpec channelLayout;
  final String bandpassFilter;
  final String notchFilter;
  final int defaultSweeps;
  final List<String> expectedOutputs;

  NeuroProtocol({
    required this.protocolId,
    required this.name,
    required this.category,
    required this.targetSamplingRateHz,
    required this.stimulusType,
    required this.channelLayout,
    required this.bandpassFilter,
    required this.notchFilter,
    required this.defaultSweeps,
    required this.expectedOutputs,
  });
}

class ProtocolState {
  final List<NeuroProtocol> availableProtocols;
  final NeuroProtocol activeProtocol;

  ProtocolState({required this.availableProtocols, required this.activeProtocol});
}

final protocolEngineProvider = StateNotifierProvider<ProtocolEngineNotifier, ProtocolState>((ref) {
  return ProtocolEngineNotifier();
});

class ProtocolEngineNotifier extends StateNotifier<ProtocolState> {
  ProtocolEngineNotifier()
      : super(
          ProtocolState(
            availableProtocols: [
              NeuroProtocol(
                protocolId: 'vep-pat-1deg',
                name: 'Pattern Reversal VEP (1° Check)',
                category: 'Visual Evoked Potential',
                targetSamplingRateHz: 2500,
                stimulusType: 'Checkerboard Reversal (60 arcmin)',
                channelLayout: ChannelLayoutSpec(
                  activeChannel: 'Oz',
                  referenceChannel: 'Cz',
                  groundChannel: 'Fz',
                  auxChannels: ['O1', 'O2'],
                ),
                bandpassFilter: '1.0 Hz - 100 Hz',
                notchFilter: '50 Hz',
                defaultSweeps: 100,
                expectedOutputs: ['N75 Latency', 'P100 Latency', 'N145 Latency', 'P100-N145 Amplitude'],
              ),
              NeuroProtocol(
                protocolId: 'vep-flash',
                name: 'Flash VEP (Ganzfeld Stimulator)',
                category: 'Visual Evoked Potential',
                targetSamplingRateHz: 2500,
                stimulusType: 'Luminance Flash (1.0 Hz)',
                channelLayout: ChannelLayoutSpec(
                  activeChannel: 'Oz',
                  referenceChannel: 'Cz',
                  groundChannel: 'Fz',
                  auxChannels: ['O1', 'O2'],
                ),
                bandpassFilter: '1.0 Hz - 100 Hz',
                notchFilter: '50 Hz',
                defaultSweeps: 60,
                expectedOutputs: ['P2 Latency', 'N2 Peak'],
              ),
              NeuroProtocol(
                protocolId: 'eeg-routine-16ch',
                name: 'Routine 16-Channel EEG (10-20 System)',
                category: 'Electroencephalography',
                targetSamplingRateHz: 1000,
                stimulusType: 'Resting State (Eyes Open / Eyes Closed)',
                channelLayout: ChannelLayoutSpec(
                  activeChannel: 'Fp1-F7, F7-T3, T3-T5, T5-O1',
                  referenceChannel: 'A1-A2 Average',
                  groundChannel: 'Fz',
                  auxChannels: ['Cz', 'Pz'],
                ),
                bandpassFilter: '0.5 Hz - 70 Hz',
                notchFilter: '50 Hz',
                defaultSweeps: 0,
                expectedOutputs: ['FFT Power Spectrum', 'Alpha Peak Frequency', 'PSD Band Power'],
              ),
            ],
            activeProtocol: NeuroProtocol(
              protocolId: 'vep-pat-1deg',
              name: 'Pattern Reversal VEP (1° Check)',
              category: 'Visual Evoked Potential',
              targetSamplingRateHz: 2500,
              stimulusType: 'Checkerboard Reversal (60 arcmin)',
              channelLayout: ChannelLayoutSpec(
                activeChannel: 'Oz',
                referenceChannel: 'Cz',
                groundChannel: 'Fz',
                auxChannels: ['O1', 'O2'],
              ),
              bandpassFilter: '1.0 Hz - 100 Hz',
              notchFilter: '50 Hz',
              defaultSweeps: 100,
              expectedOutputs: ['N75 Latency', 'P100 Latency', 'N145 Latency', 'P100-N145 Amplitude'],
            ),
          ),
        );

  void selectProtocol(String protocolId) {
    final selected = state.availableProtocols.firstWhere((p) => p.protocolId == protocolId, orElse: () => state.activeProtocol);
    state = ProtocolState(availableProtocols: state.availableProtocols, activeProtocol: selected);
  }
}
