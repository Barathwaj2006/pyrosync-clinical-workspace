import 'dart:convert';
import '../transports/hardware_communication_transports.dart';

class PokidexFrameMetadata {
  final String source;
  final String signalType; // 'eeg' or 'vep'
  final int channelCount;
  final List<String> channelNames;
  final double samplingRateHz;
  final String unit;
  final String sessionId;

  PokidexFrameMetadata({
    required this.source,
    required this.signalType,
    required this.channelCount,
    required this.channelNames,
    required this.samplingRateHz,
    required this.unit,
    required this.sessionId,
  });

  factory PokidexFrameMetadata.fromJson(Map<String, dynamic> json) {
    final names = (json['channel_names'] as List?)?.map((e) => e.toString()).toList() ??
        List.generate(json['channel_count'] ?? 8, (i) => 'CH${i + 1}');

    return PokidexFrameMetadata(
      source: json['source'] ?? 'Pokidex-Android',
      signalType: json['signal_type'] ?? 'eeg',
      channelCount: json['channel_count'] ?? 8,
      channelNames: names,
      samplingRateHz: (json['sampling_rate'] as num?)?.toDouble() ?? 2500.0,
      unit: json['unit'] ?? 'uV',
      sessionId: json['session_id'] ?? 'POKIDEX-SESS-001',
    );
  }
}

class PokidexSignalFrame {
  final PokidexFrameMetadata metadata;
  final int timestampMs;
  final int sequence;
  final List<List<double>> channelSamples;
  final List<String> events;
  final String transportSource; // 'wifi' or 'ble'
  final DateTime arrivalTimestamp;

  PokidexSignalFrame({
    required this.metadata,
    required this.timestampMs,
    required this.sequence,
    required this.channelSamples,
    required this.events,
    required this.transportSource,
    required this.arrivalTimestamp,
  });

  factory PokidexSignalFrame.fromJsonString(String rawJson, String transportSource) {
    final Map<String, dynamic> map = jsonDecode(rawJson);
    final meta = PokidexFrameMetadata.fromJson(map['metadata'] ?? {});

    final dataMap = map['data'] ?? {};
    final ts = dataMap['timestamp'] ?? DateTime.now().millisecondsSinceEpoch;
    final seq = dataMap['sequence'] ?? 0;

    final rawSamples = dataMap['channel_samples'] as List? ?? [];
    List<List<double>> samples = [];

    for (var item in rawSamples) {
      if (item is List) {
        samples.add(item.map((e) => (e as num).toDouble()).toList());
      } else if (item is num) {
        samples.add([item.toDouble()]);
      }
    }

    final evts = (map['events'] as List?)?.map((e) => e.toString()).toList() ?? [];

    return PokidexSignalFrame(
      metadata: meta,
      timestampMs: ts,
      sequence: seq,
      channelSamples: samples,
      events: evts,
      transportSource: transportSource,
      arrivalTimestamp: DateTime.now(),
    );
  }

  AcquisitionChunk toAcquisitionChunk() {
    List<int> triggers = [];
    if (events.contains('vep_onset') || events.contains('flash_trigger')) {
      triggers.add(1);
    }

    return AcquisitionChunk(
      timestamp: arrivalTimestamp,
      sequence: sequence,
      channelSamples: channelSamples,
      samplingRateHz: metadata.samplingRateHz,
      channelCount: metadata.channelCount,
      eventsOrTriggers: triggers,
      isSimulatedData: false,
    );
  }
}
