import 'dart:async';
import 'pokidex_signal_frame.dart';
import 'pokidex_websocket_transport.dart';
import 'pokidex_ble_transport.dart';
import '../transports/hardware_communication_transports.dart';

class TransportStats {
  final String transportName; // 'Wi-Fi (WebSocket)' or 'Bluetooth LE (Nordic UART)'
  int framesReceived = 0;
  int bytesReceived = 0;
  int droppedSequenceFrames = 0;
  int lastSequence = -1;
  double averageLatencyMs = 0.0;
  double jitterMs = 0.0;
  int connectionEventsCount = 0;
  int disconnectionEventsCount = 0;
  DateTime? lastFrameTimestamp;
  List<String> eventLogs = [];

  TransportStats(this.transportName);

  void recordFrame(PokidexSignalFrame frame) {
    framesReceived++;
    final now = DateTime.now();

    if (lastFrameTimestamp != null) {
      final deltaMs = now.difference(lastFrameTimestamp!).inMicroseconds / 1000.0;
      final expectedDeltaMs = 1000.0 / (frame.metadata.samplingRateHz > 0 ? frame.metadata.samplingRateHz : 2500.0);
      final diff = (deltaMs - expectedDeltaMs).abs();
      jitterMs = (jitterMs * 0.9) + (diff * 0.1);
    }
    lastFrameTimestamp = now;

    if (lastSequence >= 0 && frame.sequence > lastSequence + 1) {
      droppedSequenceFrames += (frame.sequence - lastSequence - 1);
    }
    lastSequence = frame.sequence;
  }

  void logEvent(String msg) {
    final entry = '[${DateTime.now().toIso8601String().substring(11, 19)}] $msg';
    eventLogs.add(entry);
    if (eventLogs.length > 50) eventLogs.removeAt(0);
  }
}

class PokidexDualTransportManager {
  final PokidexWebSocketTransport wifiTransport = PokidexWebSocketTransport();
  final PokidexBleTransport bleTransport = PokidexBleTransport();

  final TransportStats wifiStats = TransportStats('Wi-Fi (WebSocket)');
  final TransportStats bleStats = TransportStats('Bluetooth LE (Nordic UART)');

  final _mergedChunkController = StreamController<AcquisitionChunk>.broadcast();
  StreamSubscription? _wifiSub;
  StreamSubscription? _bleSub;

  Stream<AcquisitionChunk> get mergedChunkStream => _mergedChunkController.stream;

  Future<bool> connectWifi(String ip, {int port = 8765}) async {
    wifiStats.connectionEventsCount++;
    wifiStats.logEvent('Initiating Wi-Fi WebSocket connection to ws://$ip:$port...');

    final success = await wifiTransport.connect(ip, port: port);
    if (success) {
      wifiStats.logEvent('Wi-Fi WebSocket CONNECTED successfully.');
      _wifiSub?.cancel();
      _wifiSub = wifiTransport.frameStream.listen((frame) {
        wifiStats.recordFrame(frame);
        _mergedChunkController.add(frame.toAcquisitionChunk());
      });
    } else {
      wifiStats.logEvent('Wi-Fi WebSocket Connection FAILED: ${wifiTransport.lastError}');
    }
    return success;
  }

  Future<bool> connectBle(String macAddress) async {
    bleStats.connectionEventsCount++;
    bleStats.logEvent('Initiating BLE Nordic UART connection to MAC: $macAddress...');

    final success = await bleTransport.connect(macAddress);
    if (success) {
      bleStats.logEvent('Bluetooth LE Nordic UART CONNECTED.');
      _bleSub?.cancel();
      _bleSub = bleTransport.frameStream.listen((frame) {
        bleStats.recordFrame(frame);
        _mergedChunkController.add(frame.toAcquisitionChunk());
      });
    } else {
      bleStats.logEvent('Bluetooth LE Connection FAILED: ${bleTransport.lastError}');
    }
    return success;
  }

  Future<void> disconnectWifi() async {
    wifiStats.disconnectionEventsCount++;
    wifiStats.logEvent('Wi-Fi WebSocket DISCONNECTED by user.');
    await wifiTransport.disconnect();
    await _wifiSub?.cancel();
  }

  Future<void> disconnectBle() async {
    bleStats.disconnectionEventsCount++;
    bleStats.logEvent('Bluetooth LE DISCONNECTED by user.');
    await bleTransport.disconnect();
    await _bleSub?.cancel();
  }

  Future<void> disconnectAll() async {
    await disconnectWifi();
    await disconnectBle();
  }
}
