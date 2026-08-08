import 'dart:async';
import 'pokidex_signal_frame.dart';
import '../transports/hardware_communication_transports.dart';

class PokidexBleTransport {
  static const String nordicUartServiceUuid = '6E400001-B5A3-F393-E0A9-E50E24DCCA9E';
  static const String nordicUartTxCharUuid = '6E400003-B5A3-F393-E0A9-E50E24DCCA9E';

  bool _isConnected = false;
  String _deviceMac = '';
  String _lastError = '';
  final StringBuffer _buffer = StringBuffer();

  final _frameController = StreamController<PokidexSignalFrame>.broadcast();
  final _chunkController = StreamController<AcquisitionChunk>.broadcast();

  bool get isConnected => _isConnected;
  String get deviceMac => _deviceMac;
  String get lastError => _lastError;

  Stream<PokidexSignalFrame> get frameStream => _frameController.stream;
  Stream<AcquisitionChunk> get chunkStream => _chunkController.stream;

  Future<bool> connect(String macAddress) async {
    _deviceMac = macAddress;
    _lastError = '';
    _isConnected = true;
    return true;
  }

  void processIncomingBleChunk(String chunk) {
    if (!_isConnected) return;
    _buffer.write(chunk);

    // Look for complete newline-delimited or brace-matched JSON datagrams
    String content = _buffer.toString();
    if (content.contains('\n')) {
      final lines = content.split('\n');
      for (int i = 0; i < lines.length - 1; i++) {
        final line = lines[i].trim();
        if (line.startsWith('{') && line.endsWith('}')) {
          _parseAndEmit(line);
        }
      }
      _buffer.clear();
      _buffer.write(lines.last);
    } else if (content.startsWith('{') && content.endsWith('}')) {
      _parseAndEmit(content);
      _buffer.clear();
    }
  }

  void _parseAndEmit(String jsonStr) {
    try {
      final frame = PokidexSignalFrame.fromJsonString(jsonStr, 'ble');
      _frameController.add(frame);
      _chunkController.add(frame.toAcquisitionChunk());
    } catch (e) {
      _lastError = 'BLE SignalFrame JSON parse error: $e';
    }
  }

  Future<void> disconnect() async {
    _isConnected = false;
    _buffer.clear();
  }
}
