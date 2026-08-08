class ProtocolModel {
  final String id;
  final String name;
  final String category;
  final String checkSize;
  final double reversalRateHz;
  final int defaultSweeps;
  final String filterBandpass;

  ProtocolModel({
    required this.id,
    required this.name,
    required this.category,
    required this.checkSize,
    required this.reversalRateHz,
    required this.defaultSweeps,
    required this.filterBandpass,
  });

  static List<ProtocolModel> get presets => [
        ProtocolModel(
          id: 'vep-pat-1deg',
          name: 'Pattern Reversal VEP (1° Check)',
          category: 'Visual Evoked Potential',
          checkSize: '60 arcmin (1°)',
          reversalRateHz: 2.0,
          defaultSweeps: 100,
          filterBandpass: '1 - 100 Hz',
        ),
        ProtocolModel(
          id: 'vep-pat-quarter',
          name: 'Pattern Reversal VEP (15\' Check)',
          category: 'Visual Evoked Potential',
          checkSize: '15 arcmin (0.25°)',
          reversalRateHz: 2.0,
          defaultSweeps: 100,
          filterBandpass: '1 - 100 Hz',
        ),
        ProtocolModel(
          id: 'vep-flash',
          name: 'Flash VEP (Ganzfeld Stimulator)',
          category: 'Visual Evoked Potential',
          checkSize: 'N/A (Luminance Flash)',
          reversalRateHz: 1.0,
          defaultSweeps: 60,
          filterBandpass: '1 - 100 Hz',
        ),
        ProtocolModel(
          id: 'eeg-resting-16ch',
          name: 'Routine Resting EEG (16-Channel 10-20)',
          category: 'Electroencephalography',
          checkSize: 'N/A',
          reversalRateHz: 0.0,
          defaultSweeps: 0,
          filterBandpass: '0.5 - 70 Hz',
        ),
      ];
}
