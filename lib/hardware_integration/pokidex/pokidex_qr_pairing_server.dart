import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'pokidex_qr_payload.dart';
import 'pokidex_signal_frame.dart';
import 'pokidex_diagnostics_engine.dart';
import '../../device_connectivity/models/device_models.dart';
import '../transports/hardware_communication_transports.dart';

enum PokidexHandshakePhase {
  none,
  serverStarted,
  socketConnected,
  helloSent,
  helloAckReceived,
  sessionAccepted,
  readyReceived,
  startStreamSent,
  streaming,
}

class PokidexQrPairingServer {
  HttpServer? _server;
  WebSocket? _activeSocket;
  PokidexQrPayload? _activeQrPayload;
  PokidexHandshakePhase _handshakePhase = PokidexHandshakePhase.none;
  DeviceConnectionState _connectionState = DeviceConnectionState.noDevice;

  final PokidexDiagnosticsEngine diagnostics = PokidexDiagnosticsEngine();
  final StreamController<PokidexSignalFrame> _frameController = StreamController<PokidexSignalFrame>.broadcast();
  final StreamController<AcquisitionChunk> _chunkController = StreamController<AcquisitionChunk>.broadcast();
  final StreamController<DeviceConnectionState> _stateController = StreamController<DeviceConnectionState>.broadcast();

  bool get isRunning => _server != null;
  PokidexQrPayload? get activeQrPayload => _activeQrPayload;
  PokidexHandshakePhase get handshakePhase => _handshakePhase;
  DeviceConnectionState get connectionState => _connectionState;

  Stream<PokidexSignalFrame> get frameStream => _frameController.stream;
  Stream<AcquisitionChunk> get chunkStream => _chunkController.stream;
  Stream<DeviceConnectionState> get stateStream => _stateController.stream;

  Future<PokidexQrPayload?> startPairingServer({int port = 8765}) async {
    await stopPairingServer();

    final ip = await _getUsableLocalIpv4();
    final sessionId = PokidexQrPayload.generateSessionId();
    final token = PokidexQrPayload.generateRandomToken();
    final expiresAt = (DateTime.now().millisecondsSinceEpoch ~/ 1000) + 300; // 5 minutes expiration

    _activeQrPayload = PokidexQrPayload(
      sessionId: sessionId,
      host: ip,
      port: port,
      token: token,
      expiresAt: expiresAt,
    );

    _updateState(DeviceConnectionState.connecting);

    try {
      _server = await HttpServer.bind(InternetAddress.anyIPv4, port);
      _handshakePhase = PokidexHandshakePhase.serverStarted;

      _server!.listen((HttpRequest request) async {
        if (WebSocketTransformer.isUpgradeRequest(request)) {
          final socket = await WebSocketTransformer.upgrade(request);
          _handleIncomingSocket(socket);
        } else {
          request.response
            ..statusCode = HttpStatus.forbidden
            ..write('Pokidex WebSocket Pairing Server Only')
            ..close();
        }
      });

      return _activeQrPayload;
    } catch (e) {
      _updateState(DeviceConnectionState.error);
      return null;
    }
  }

  void _handleIncomingSocket(WebSocket socket) {
    _activeSocket = socket;
    _handshakePhase = PokidexHandshakePhase.socketConnected;
    _updateState(DeviceConnectionState.discoveringServices);

    // Mutual Handshake Step 1: PyroSync sends HELLO
    final helloMsg = {
      'type': 'handshake',
      'action': 'HELLO',
      'protocol': 'pyrosync-pokidex',
      'version': 1,
      'session_id': _activeQrPayload?.sessionId ?? '',
    };
    socket.add(jsonEncode(helloMsg));
    _handshakePhase = PokidexHandshakePhase.helloSent;

    socket.listen(
      (data) {
        final text = data.toString().trim();
        _processSocketMessage(text, socket);
      },
      onError: (err) {
        _handleDisconnect();
      },
      onDone: () {
        _handleDisconnect();
      },
    );
  }

  void _processSocketMessage(String rawMessage, WebSocket socket) {
    try {
      final Map<String, dynamic> map = jsonDecode(rawMessage);
      final type = map['type'];

      if (type == 'handshake') {
        final action = map['action'];
        final version = map['version'] ?? 1;
        final token = map['token'] ?? '';

        if (version != 1) {
          _sendError(socket, 'UNSUPPORTED_PROTOCOL_VERSION');
          return;
        }

        if (_activeQrPayload != null && _activeQrPayload!.isExpired) {
          _sendError(socket, 'EXPIRED_PAIRING_TOKEN');
          return;
        }

        if (_activeQrPayload != null && token.isNotEmpty && token != _activeQrPayload!.token) {
          _sendError(socket, 'INVALID_PAIRING_TOKEN');
          return;
        }

        if (action == 'HELLO_ACK') {
          _handshakePhase = PokidexHandshakePhase.helloAckReceived;
          // Step 3: SESSION_ACCEPTED
          final acceptMsg = {
            'type': 'handshake',
            'action': 'SESSION_ACCEPTED',
            'session_id': _activeQrPayload?.sessionId ?? '',
          };
          socket.add(jsonEncode(acceptMsg));
          _handshakePhase = PokidexHandshakePhase.sessionAccepted;
        } else if (action == 'READY') {
          _handshakePhase = PokidexHandshakePhase.readyReceived;
          _updateState(DeviceConnectionState.verified);

          // Step 5: START_STREAM
          final startMsg = {
            'type': 'handshake',
            'action': 'START_STREAM',
            'session_id': _activeQrPayload?.sessionId ?? '',
          };
          socket.add(jsonEncode(startMsg));
          _handshakePhase = PokidexHandshakePhase.startStreamSent;
          _updateState(DeviceConnectionState.waitingForSignal);
        }
      } else {
        // SignalFrame Payload Processing
        final frame = PokidexSignalFrame.fromJsonString(rawMessage, 'wifi');
        final isValid = diagnostics.validateAndRecord(frame, expectedSessionId: _activeQrPayload?.sessionId);

        if (isValid) {
          if (_connectionState != DeviceConnectionState.streaming) {
            _handshakePhase = PokidexHandshakePhase.streaming;
            _updateState(DeviceConnectionState.streaming);
          }
          _frameController.add(frame);
          _chunkController.add(frame.toAcquisitionChunk());
        }
      }
    } catch (_) {
      // Malformed frame handling
    }
  }

  void _sendError(WebSocket socket, String reason) {
    socket.add(jsonEncode({'type': 'error', 'message': reason}));
    _updateState(DeviceConnectionState.error);
    socket.close();
  }

  void _handleDisconnect() {
    _activeSocket = null;
    _handshakePhase = PokidexHandshakePhase.none;
    _updateState(DeviceConnectionState.disconnected);
  }

  void _updateState(DeviceConnectionState state) {
    _connectionState = state;
    _stateController.add(state);
  }

  Future<void> stopPairingServer() async {
    if (_activeSocket != null) {
      await _activeSocket!.close();
      _activeSocket = null;
    }
    if (_server != null) {
      await _server!.close(force: true);
      _server = null;
    }
    diagnostics.reset();
    _handshakePhase = PokidexHandshakePhase.none;
    _updateState(DeviceConnectionState.noDevice);
  }

  Future<String> _getUsableLocalIpv4() async {
    try {
      final interfaces = await NetworkInterface.list(type: InternetAddressType.IPv4);
      for (var interface in interfaces) {
        if (!interface.name.toLowerCase().contains('virtual') &&
            !interface.name.toLowerCase().contains('vmware') &&
            !interface.name.toLowerCase().contains('loopback')) {
          for (var addr in interface.addresses) {
            if (!addr.isLoopback && addr.address.startsWith('192.168.')) {
              return addr.address;
            }
          }
        }
      }
      for (var interface in interfaces) {
        for (var addr in interface.addresses) {
          if (!addr.isLoopback) return addr.address;
        }
      }
    } catch (_) {}
    return '192.168.1.15';
  }
}
