import 'dart:core';

class BiosignalCursor {
  final double timeMs;
  final double amplitudeUv;
  final String? peakLabel; // N75, P100, N145
  final bool isSnappedToPeak;

  BiosignalCursor({
    required this.timeMs,
    required this.amplitudeUv,
    this.peakLabel,
    this.isSnappedToPeak = false,
  });
}

class DualCursorMeasurement {
  final BiosignalCursor cursorA;
  final BiosignalCursor cursorB;

  DualCursorMeasurement({
    required this.cursorA,
    required this.cursorB,
  });

  double get deltaLatencyMs => (cursorB.timeMs - cursorA.timeMs).abs();
  double get deltaAmplitudeUv => (cursorB.amplitudeUv - cursorA.amplitudeUv).abs();
}

class ClinicalAnnotation {
  final String annotationId;
  final double timeMs;
  final String channelLabel;
  final String note;
  final String category; // Artifact, Peak, Note, UserMarker
  final DateTime createdAt;

  ClinicalAnnotation({
    required this.annotationId,
    required this.timeMs,
    required this.channelLabel,
    required this.note,
    required this.category,
    required this.createdAt,
  });
}
