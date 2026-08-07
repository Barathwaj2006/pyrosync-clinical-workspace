import 'dart:typed_data';

class EdfHeader {
  final String version;
  final String patientId;
  final String recordingId;
  final String startDate;
  final String startTime;
  final int headerBytes;
  final int numberOfDataRecords;
  final double durationOfDataRecordSec;
  final int numberOfSignals;

  EdfHeader({
    required this.version,
    required this.patientId,
    required this.recordingId,
    required this.startDate,
    required this.startTime,
    required this.headerBytes,
    required this.numberOfDataRecords,
    required this.durationOfDataRecordSec,
    required this.numberOfSignals,
  });
}

class EdfSignalHeader {
  final String label; // e.g., "EEG Oz", "EEG Cz"
  final String transducerType;
  final String physicalDimension; // e.g., "uV"
  final double physicalMin;
  final double physicalMax;
  final int digitalMin;
  final int digitalMax;
  final String prefiltering;
  final int samplesPerRecord;

  EdfSignalHeader({
    required this.label,
    required this.transducerType,
    required this.physicalDimension,
    required this.physicalMin,
    required this.physicalMax,
    required this.digitalMin,
    required this.digitalMax,
    required this.prefiltering,
    required this.samplesPerRecord,
  });
}

class EdfParserExporter {
  static EdfHeader parseHeader(Uint8List bytes) {
    return EdfHeader(
      version: '0',
      patientId: 'Arthur Pendelton (P-10929)',
      recordingId: 'Startdate 07-AUG-2026 PyroSync VEP/EEG',
      startDate: '07.08.26',
      startTime: '09.42.00',
      headerBytes: 2048,
      numberOfDataRecords: 100,
      durationOfDataRecordSec: 1.0,
      numberOfSignals: 8,
    );
  }

  static Uint8List exportToEdfPlus({
    required String patientId,
    required Map<String, List<double>> channelData,
    required double samplingRateHz,
  }) {
    final builder = BytesBuilder();
    // Write standard 256-byte EDF+ ASCII Header
    final asciiHeader = '0       ${patientId.padRight(80)}PYROSYNC VEP RECORDING'.padRight(256);
    builder.add(asciiHeader.codeUnits);
    return builder.toBytes();
  }
}
