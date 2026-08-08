import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'pokidex_signal_frame.dart';
import '../transports/hardware_communication_transports.dart';

class PokidexBleTransport {
  static const String serviceUuid = '0000fe50-0000-1000-8000-00805f9b34fb';
  static const String notifyCharUuid = '0000fe51-0000-1000-8000-00805f9b34fb';

  bool _isConnected = false;
  String _deviceMac = '';
  String _lastError = '';

  // Sequence -> (ChunkIndex -> Bytes)
  final Map<int, Map<int, List<int>>> _reassemblyBuffers = {};
  // Track received complete frame count
  int _receivedFramesCount = 0;

  final _frameController = StreamController<PokidexSignalFrame>.broadcast();
  final _chunkController = StreamController<AcquisitionChunk>.broadcast();

  bool get isConnected => _isConnected;
  String get deviceMac => _deviceMac;
  String get lastError => _lastError;
  int get receivedFramesCount => _receivedFramesCount;

  Stream<PokidexSignalFrame> get frameStream => _frameController.stream;
  Stream<AcquisitionChunk> get chunkStream => _chunkController.stream;

  Future<bool> connect(String macAddress) async {
    _deviceMac = macAddress;
    _lastError = '';
    _isConnected = true;
    _reassemblyBuffers.clear();
    return true;
  }

  /// Processes raw BLE notification packet payload bytes:
  /// Byte 0: sequence high byte
  /// Byte 1: sequence low byte
  /// Byte 2: chunk index (0-based)
  /// Byte 3: total chunk count
  /// Bytes 4+: UTF-8 JSON fragment
  void processIncomingBleNotificationBytes(Uint8List bytes) {
    if (!_isConnected || bytes.length < 4) return;

    final int seqHigh = bytes[0] & 0xFF;
    final int seqLow = bytes[1] & 0xFF;
    final int sequence = (seqHigh << 8) | seqLow;
    final int chunkIndex = bytes[2] & 0xFF;
    final int totalChunks = bytes[3] & 0xFF;

    final fragment = bytes.sublist(4);

    _addChunk(sequence, chunkIndex, totalChunks, fragment);
  }

  /// Helper method for string/fragment testing
  void processIncomingBlePayloadChunk(int sequence, int chunkIndex, int totalChunks, String payloadFragment) {
    if (!_isConnected) return;
    final fragmentBytes = utf8.encode(payloadFragment);
    _addChunk(sequence, chunkIndex, totalChunks, fragmentBytes);
  }

  void _addChunk(int sequence, int chunkIndex, int totalChunks, List<int> fragmentBytes) {
    _reassemblyBuffers.putIfAbsent(sequence, () => {});
    _reassemblyBuffers[sequence]![chunkIndex] = fragmentBytes;

    final seqMap = _reassemblyBuffers[sequence]!;
    if (seqMap.length == totalChunks) {
      // Reassemble in chunkIndex order (0..totalChunks-1)
      final List<int> completeBytes = [];
      for (int i = 0; i < totalChunks; i++) {
        if (seqMap.containsKey(i)) {
          completeBytes.addAll(seqMap[i]!);
        } else {
          // Missing chunk
          _lastError = 'Incomplete BLE frame reassembly for sequence $sequence (missing chunk $i)';
          return;
        }
      }

      _reassemblyBuffers.remove(sequence);
      _parseAndEmit(completeBytes);
    }

    // Cleanup old sequence buffers to prevent memory leak
    if (_reassemblyBuffers.length > 50) {
      final oldestSeq = _reassemblyBuffers.keys.first;
      _reassemblyBuffers.remove(oldestSeq);
    }
  }

  void _parseAndEmit(List<int> completeUtf8Bytes) {
    try {
      final jsonStr = utf8.decode(completeUtf8Bytes);
      final frame = PokidexSignalFrame.fromJsonString(jsonStr, 'ble');
      _receivedFramesCount++;
      _frameController.add(frame);
      _chunkController.add(frame.toAcquisitionChunk());
    } catch (e) {
      _lastError = 'BLE SignalFrame JSON reassembly parse error: $e';
    }
  }

  Future<void> disconnect() async {
    _isConnected = false;
    _reassemblyBuffers.clear();
  }
}
