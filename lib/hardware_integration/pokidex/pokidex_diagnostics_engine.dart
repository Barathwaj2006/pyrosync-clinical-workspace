import 'pokidex_signal_frame.dart';
import '../../device_connectivity/models/device_models.dart';

class PokidexDiagnosticsEngine {
  int _packetsReceived = 0;
  int _packetsExpected = 0;
  int _packetsLost = 0;
  int _duplicatePackets = 0;
  int _malformedPackets = 0;
  int _outOfOrderPackets = 0;
  int _lastSequence = -1;

  double _configuredRateHz = 250.0;
  double _actualRateHz = 0.0;
  double _jitterMs = 0.0;
  double _latencyMs = 0.0;

  DateTime? _lastReceiveTime;
  final List<DateTime> _recentReceiveTimes = [];
  final List<String> _rejectionReasons = [];

  int get packetsReceived => _packetsReceived;
  int get packetsLost => _packetsLost;
  double get packetLossPercentage => _packetsExpected > 0 ? (_packetsLost / _packetsExpected * 100.0) : 0.0;

  PokidexDiagnosticsMetrics get metrics {
    String status = 'IDLE';
    if (_packetsReceived > 0) {
      status = packetLossPercentage > 5.0 ? 'UNSTABLE' : 'STREAMING';
    }

    return PokidexDiagnosticsMetrics(
      packetsReceived: _packetsReceived,
      packetsExpected: _packetsExpected,
      packetsLost: _packetsLost,
      packetLossPercentage: double.parse(packetLossPercentage.toStringAsFixed(1)),
      duplicatePackets: _duplicatePackets,
      malformedPackets: _malformedPackets,
      outOfOrderPackets: _outOfOrderPackets,
      configuredRateHz: _configuredRateHz,
      actualRateHz: double.parse(_actualRateHz.toStringAsFixed(1)),
      jitterMs: double.parse(_jitterMs.toStringAsFixed(2)),
      latencyMs: double.parse(_latencyMs.toStringAsFixed(1)),
      statusText: status,
      rejectionReasons: List.unmodifiable(_rejectionReasons),
    );
  }

  bool validateAndRecord(PokidexSignalFrame frame, {String? expectedSessionId}) {
    final now = DateTime.now();

    // 1. Metadata Validation
    if (frame.metadata.channelCount <= 0 || frame.metadata.channelCount > 64) {
      _recordRejection('INVALID CHANNEL COUNT: ${frame.metadata.channelCount}');
      return false;
    }

    if (frame.metadata.samplingRateHz <= 0 || frame.metadata.samplingRateHz > 10000) {
      _recordRejection('INVALID SAMPLING RATE: ${frame.metadata.samplingRateHz} Hz');
      return false;
    }

    if (expectedSessionId != null && expectedSessionId.isNotEmpty && frame.metadata.sessionId != expectedSessionId) {
      _recordRejection('INVALID SESSION ID: Expected $expectedSessionId, got ${frame.metadata.sessionId}');
      return false;
    }

    // 2. Data Validation
    if (frame.channelSamples.isEmpty) {
      _recordRejection('EMPTY CHANNEL SAMPLES PAYLOAD');
      return false;
    }

    // 3. Sequence Tracking & Loss Computation
    final seq = frame.sequence;
    _packetsReceived++;
    _configuredRateHz = frame.metadata.samplingRateHz;

    if (_lastSequence >= 0) {
      if (seq == _lastSequence) {
        _duplicatePackets++;
        _recordRejection('DUPLICATE SEQUENCE: $seq');
        return false;
      } else if (seq < _lastSequence) {
        _outOfOrderPackets++;
        _recordRejection('OUT-OF-ORDER SEQUENCE: Got $seq after $_lastSequence');
      } else if (seq > _lastSequence + 1) {
        final gap = seq - _lastSequence - 1;
        _packetsLost += gap;
        _packetsExpected += (gap + 1);
        _recordRejection('MISSING SEQUENCE GAP: Expected ${_lastSequence + 1}, got $seq (Lost $gap frames)');
      } else {
        _packetsExpected++;
      }
    } else {
      _packetsExpected = 1;
    }
    _lastSequence = seq;

    // 4. Transport Latency Calculation (Source Timestamp vs Receive Timestamp)
    if (frame.timestampMs > 0) {
      final sourceTime = DateTime.fromMillisecondsSinceEpoch(frame.timestampMs);
      final latency = now.difference(sourceTime).inMicroseconds / 1000.0;
      if (latency >= 0 && latency < 60000) {
        _latencyMs = (_latencyMs == 0.0) ? latency : (_latencyMs * 0.8 + latency * 0.2);
      }
    }

    // 5. Sampling Rate & Jitter Calculation
    if (_lastReceiveTime != null) {
      final deltaMs = now.difference(_lastReceiveTime!).inMicroseconds / 1000.0;
      final expectedDeltaMs = 1000.0 / (_configuredRateHz > 0 ? _configuredRateHz : 250.0);
      final jitter = (deltaMs - expectedDeltaMs).abs();
      _jitterMs = (_jitterMs * 0.85) + (jitter * 0.15);

      _recentReceiveTimes.add(now);
      if (_recentReceiveTimes.length > 20) _recentReceiveTimes.removeAt(0);

      if (_recentReceiveTimes.length >= 2) {
        final totalTimeMs = _recentReceiveTimes.last.difference(_recentReceiveTimes.first).inMilliseconds;
        if (totalTimeMs > 0) {
          _actualRateHz = ((_recentReceiveTimes.length - 1) * 1000.0) / totalTimeMs;
        }
      }
    } else {
      _actualRateHz = _configuredRateHz;
    }
    _lastReceiveTime = now;

    return true;
  }

  void _recordRejection(String reason) {
    _malformedPackets++;
    final entry = '[${DateTime.now().toIso8601String().substring(11, 19)}] $reason';
    _rejectionReasons.add(entry);
    if (_rejectionReasons.length > 30) _rejectionReasons.removeAt(0);
  }

  void reset() {
    _packetsReceived = 0;
    _packetsExpected = 0;
    _packetsLost = 0;
    _duplicatePackets = 0;
    _malformedPackets = 0;
    _outOfOrderPackets = 0;
    _lastSequence = -1;
    _actualRateHz = 0.0;
    _jitterMs = 0.0;
    _latencyMs = 0.0;
    _lastReceiveTime = null;
    _recentReceiveTimes.clear();
    _rejectionReasons.clear();
  }
}
