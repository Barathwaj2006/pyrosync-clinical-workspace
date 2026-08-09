import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:pyrosync/hardware_integration/pokidex/pokidex_qr_payload.dart';
import 'package:pyrosync/hardware_integration/pokidex/pokidex_qr_pairing_server.dart';
import 'package:pyrosync/hardware_integration/pokidex/pokidex_diagnostics_engine.dart';
import 'package:pyrosync/hardware_integration/pokidex/pokidex_signal_frame.dart';
import 'package:pyrosync/device_connectivity/models/device_models.dart';

void main() {
  group('Pokidex QR Pairing & Mutual Handshake Engineering Test Suite', () {
    test('1. QR Payload Generation & Expiration Validation', () {
      final token = PokidexQrPayload.generateRandomToken();
      final sessionId = PokidexQrPayload.generateSessionId();
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      final payload = PokidexQrPayload(
        sessionId: sessionId,
        host: '192.168.1.15',
        port: 8765,
        token: token,
        expiresAt: now + 300,
      );

      expect(payload.protocol, equals('pyrosync-pokidex'));
      expect(payload.version, equals(1));
      expect(payload.isExpired, isFalse);
      expect(payload.token.length, equals(16));

      final jsonStr = payload.toJsonString();
      final parsed = PokidexQrPayload.fromJsonString(jsonStr);
      expect(parsed.sessionId, equals(sessionId));
      expect(parsed.token, equals(token));

      final expiredPayload = PokidexQrPayload(
        sessionId: sessionId,
        host: '192.168.1.15',
        token: token,
        expiresAt: now - 10,
      );
      expect(expiredPayload.isExpired, isTrue);
    });

    test('2. PokidexDiagnosticsEngine Sequence Gap & Metric Calculations', () {
      final engine = PokidexDiagnosticsEngine();

      PokidexSignalFrame makeFrame(int seq, int timestampMs) {
        return PokidexSignalFrame.fromJsonString('''
        {
          "metadata": {
            "source": "Pokidex-Android",
            "signal_type": "eeg",
            "channel_count": 4,
            "sampling_rate": 250.0,
            "session_id": "PX-88123"
          },
          "data": {
            "timestamp": $timestampMs,
            "sequence": $seq,
            "channel_samples": [[1.0, 2.0], [3.0, 4.0]]
          },
          "events": []
        }
        ''', 'wifi');
      }

      final ts = DateTime.now().millisecondsSinceEpoch;
      // Valid sequential frames: 1, 2, 3
      expect(engine.validateAndRecord(makeFrame(1, ts)), isTrue);
      expect(engine.validateAndRecord(makeFrame(2, ts + 4)), isTrue);
      expect(engine.validateAndRecord(makeFrame(3, ts + 8)), isTrue);

      // Duplicate frame: 3 (Rejected)
      expect(engine.validateAndRecord(makeFrame(3, ts + 12)), isFalse);

      // Missing sequence gap: 5 (Skipped 4)
      expect(engine.validateAndRecord(makeFrame(5, ts + 16)), isTrue);

      final metrics = engine.metrics;
      expect(metrics.packetsReceived, equals(5)); // 1, 2, 3, duplicate 3, 5
      expect(metrics.packetsLost, equals(1)); // Skipped 4
      expect(metrics.duplicatePackets, equals(1));
      expect(metrics.rejectionReasons, contains(contains('DUPLICATE SEQUENCE: 3')));
      expect(metrics.rejectionReasons, contains(contains('MISSING SEQUENCE GAP')));
    });

    test('3. Pokidex QR Pairing WebSocket Server & Mutual Handshake Execution', () async {
      final server = PokidexQrPairingServer();
      final payload = await server.startPairingServer(port: 8766);

      expect(payload, isNotNull);
      expect(server.isRunning, isTrue);
      expect(server.connectionState, equals(DeviceConnectionState.connecting));

      // Connect deterministically using local WebSocket client simulating Pokidex app
      const wsUrl = 'ws://127.0.0.1:8766';
      final socket = await WebSocket.connect(wsUrl);

      final Completer<bool> handshakeCompleter = Completer<bool>();

      socket.listen((data) {
        final Map<String, dynamic> msg = jsonDecode(data.toString());
        final action = msg['action'];

        if (action == 'HELLO') {
          // Pokidex responds HELLO_ACK with token
          socket.add(jsonEncode({
            'type': 'handshake',
            'action': 'HELLO_ACK',
            'version': 1,
            'token': payload!.token,
          }));
        } else if (action == 'SESSION_ACCEPTED') {
          // Pokidex responds READY
          socket.add(jsonEncode({
            'type': 'handshake',
            'action': 'READY',
            'session_id': payload!.sessionId,
          }));
        } else if (action == 'START_STREAM') {
          // Pokidex starts streaming SignalFrames
          socket.add('''
          {
            "metadata": {
              "source": "Pokidex-Android",
              "signal_type": "eeg",
              "channel_count": 4,
              "sampling_rate": 250.0,
              "session_id": "${payload!.sessionId}"
            },
            "data": {
              "timestamp": ${DateTime.now().millisecondsSinceEpoch},
              "sequence": 1,
              "channel_samples": [[10.0], [20.0]]
            },
            "events": []
          }
          ''');
          handshakeCompleter.complete(true);
        }
      });

      final handshakeSuccess = await handshakeCompleter.future.timeout(const Duration(seconds: 4));
      expect(handshakeSuccess, isTrue);

      await Future.delayed(const Duration(milliseconds: 100));
      expect(server.connectionState, equals(DeviceConnectionState.streaming));
      expect(server.handshakePhase, equals(PokidexHandshakePhase.streaming));

      await socket.close();
      await server.stopPairingServer();
      expect(server.connectionState, equals(DeviceConnectionState.noDevice));
    });
  });
}
