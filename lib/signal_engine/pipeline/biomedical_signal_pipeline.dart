import '../models/signal_models.dart';
import '../preprocessing/signal_preprocessor.dart';
import '../filters/filter_pipeline.dart';
import '../artifact_detection/artifact_detector.dart';
import '../frequency_analysis/frequency_analyzer.dart';
import '../vep_analysis/vep_peak_extractor.dart';
import '../quality_assessment/signal_quality_evaluator.dart';

class BiomedicalSignalPipeline {
  final SignalPreprocessor _preprocessor = SignalPreprocessor();
  final FilterPipeline _filterPipeline = FilterPipeline([
    NotchFilter50Hz(),
    HighPassFilter(cutoffHz: 1.0),
    LowPassFilter(cutoffHz: 100.0),
  ]);
  final ArtifactDetector _artifactDetector = ArtifactDetector();
  final FrequencyAnalyzer _frequencyAnalyzer = FrequencyAnalyzer();
  final VepPeakExtractor _vepExtractor = VepPeakExtractor();
  final SignalQualityEvaluator _qualityEvaluator = SignalQualityEvaluator();

  PipelineResult execute({
    required List<double> rawSignal,
    required double samplingRateHz,
    required String channelName,
    required Map<String, double> impedancesKohm,
    int totalSweeps = 100,
    int rejectedSweeps = 2,
  }) {
    final preprocessed = _preprocessor.preprocess(
      rawSamples: rawSignal,
      samplingRateHz: samplingRateHz,
      channelName: channelName,
    );

    final filteredSamples = _filterPipeline.apply(preprocessed.samples, samplingRateHz);
    final cleanSignal = ProcessedSignal(
      samples: filteredSamples,
      samplingRateHz: samplingRateHz,
      channelName: channelName,
      isNormalized: false,
    );

    final artifactReport = _artifactDetector.detect(filteredSamples, samplingRateHz);
    final frequencyResult = _frequencyAnalyzer.analyze(filteredSamples, samplingRateHz);
    final vepResult = _vepExtractor.extractPeaks(
      averagedTraceMs: filteredSamples,
      samplingRateHz: samplingRateHz,
      totalSweeps: totalSweeps,
      rejectedSweeps: rejectedSweeps,
    );
    final qualityReport = _qualityEvaluator.evaluate(
      signal: filteredSamples,
      artifactReport: artifactReport,
      impedancesKohm: impedancesKohm,
    );

    return PipelineResult(
      cleanSignal: cleanSignal,
      frequencyResult: frequencyResult,
      artifactReport: artifactReport,
      vepResult: vepResult,
      qualityReport: qualityReport,
      processedTimestamp: DateTime.now(),
    );
  }
}
