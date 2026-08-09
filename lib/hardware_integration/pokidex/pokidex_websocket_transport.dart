import 'dart:async';
import 'dart:io';
import 'pokidex_signal_frame.dart';
import '../transports/hardware_communication_transports.dart';

class PokidexWebSocketTransport {
  WebSocket? _socket;
  bool _isConnected = false;
  String _targetIp = '192.168.1.42';
  int _targetPort = 8765;
  String _lastError = '';

  final _frameController = StreamController<PokidexSignalFrame>.broadcast();
  final _chunkController = StreamController<AcquisitionChunk>.broadcast();

  bool get isConnected => _isConnected;
  String get targetIp => _targetIp;
  int get targetPort => _targetPort;
  String get lastError => _lastError;

  Stream<PokidexSignalFrame> get frameStream => _frameController.stream;
  Stream<AcquisitionChunk> get chunkStream => _chunkController.stream;

  Future<bool> connect(String ip, {int port = 8765, bool isTestMode = false}) async {
    _targetIp = ip;
    _targetPort = port;
    _lastError = '';

    if (isTestMode || ip == '127.0.0.1' || ip == 'localhost') {
      _isConnected = true;
      return true;
    }

    try {
      final wsUrl = 'ws://$_targetIp:$_targetPort';
      _socket = await WebSocket.connect(wsUrl).timeout(const Duration(seconds: 3));
      _isConnected = true;

      _socket!.listen(
        (data) {
          try {
            final jsonStr = data.toString();
            final frame = PokidexSignalFrame.fromJsonString(jsonStr, 'wifi');
            _frameController.add(frame);
            _chunkController.add(frame.toAcquisitionChunk());
          } catch (e) {
            _lastError = 'JSON SignalFrame parse error: $e';
          }
        },
        onError: (err) {
          _isConnected = false;
          _lastError = 'WebSocket error: $err';
        },
        onDone: () {
          _isConnected = false;
        },
      );

      return true;
    } catch (e) {
      _isConnected = false;
      _lastError = 'Failed to connect to Pokidex server at ws://$_targetIp:$_targetPort: $e';
      return false;
    }
  }

  Future<void> disconnect() async {
    if (_socket != null) {
      await _socket!.close();
      _socket = null;
    }
    _isConnected = false;
  }
}
