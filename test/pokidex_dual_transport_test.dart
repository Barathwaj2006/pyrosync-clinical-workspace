import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pyrosync/device_connectivity/device_manager/device_manager.dart';
import 'package:pyrosync/device_connectivity/models/device_models.dart';
import 'package:pyrosync/hardware_integration/pokidex/pokidex_signal_frame.dart';
import 'package:pyrosync/hardware_integration/pokidex/pokidex_dual_transport_manager.dart';
import 'package:pyrosync/hardware_integration/protocol/pokidex_hardware_protocol.dart';
import 'package:pyrosync/hardware_integration/transports/hardware_communication_transports.dart';

void main() {
  group('Pokidex Android EEG Stimulator Dual-Transport (FE50/FE51 GATT & WebSocket) Test Suite', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('1. Pokidex JSON SignalFrame Datagram Parsing', () {
      const rawJson = '''
      {
        "metadata": {
          "source": "Pokidex-Android",
          "signal_type": "vep",
          "channel_count": 8,
          "channel_names": ["O1", "O2", "Oz", "Pz", "Cz", "C3", "C4", "Fz"],
          "sampling_rate": 2500.0,
          "unit": "uV",
          "session_id": "SESS-POKIDEX-101"
        },
        "data": {
          "timestamp": 1775649200000,
          "sequence": 142,
          "channel_samples": [
            [12.4, 15.1, 18.2],
            [-8.2, -5.4, -3.1]
          ]
        },
        "events": ["vep_onset", "flash_trigger"]
      }
      ''';

      final frame = PokidexSignalFrame.fromJsonString(rawJson, 'wifi');
      expect(frame.metadata.source, equals('Pokidex-Android'));
      expect(frame.metadata.signalType, equals('vep'));
      expect(frame.metadata.channelCount, equals(8));
      expect(frame.metadata.samplingRateHz, equals(2500.0));
      expect(frame.sequence, equals(142));
      expect(frame.events, contains('vep_onset'));

      final chunk = frame.toAcquisitionChunk();
      expect(chunk.samplingRateHz, equals(2500.0));
      expect(chunk.eventsOrTriggers, contains(1));
    });

    test('2. Pokidex HardwareProtocol Handshake Verification (0000fe50 GATT Service)', () async {
      final protocol = PokidexHardwareProtocol();
      final validBle = DiscoveredDevice(
        id: 'BLE-POKIDEX-001A7DDA7113',
        name: 'Pokidex EEG Stimulator',
        portOrAddress: '00:1A:7D:DA:71:13',
        transportCategory: HardwareTransportCategory.ble,
        description: '0000fe50 Pokidex GATT Service',
      );

      final transport = BleTransport();
      final result = await protocol.identify(transport, validBle);

      expect(result.success, isTrue);
      expect(result.deviceInfo?.deviceName, contains('Pokidex'));
      expect(result.deviceInfo?.manufacturer, contains('Pokidex'));
    });

    test('3. Pokidex BLE 4-Byte Header Chunk Reassembly & Frame Emitting', () async {
      final manager = PokidexDualTransportManager();
      await manager.connectBle('00:1A:7D:DA:71:13');

      const jsonPart1 = '{"metadata":{"source":"Pokidex-BLE","channel_count":8,"sampling_rate":2500.0},';
      const jsonPart2 = '"data":{"timestamp":1005,"sequence":42,"channel_samples":[[1.1],[2.1]]},"events":["vep_onset"]}';

      final bytesPart1 = utf8.encode(jsonPart1);
      final bytesPart2 = utf8.encode(jsonPart2);

      // Packet 1: Seq 42 (0x00 0x2A), Chunk 0 of 2
      final Uint8List pkt1 = Uint8List.fromList([0x00, 0x2A, 0x00, 0x02, ...bytesPart1]);
      // Packet 2: Seq 42 (0x00 0x2A), Chunk 1 of 2
      final Uint8List pkt2 = Uint8List.fromList([0x00, 0x2A, 0x01, 0x02, ...bytesPart2]);

      late PokidexSignalFrame reassembledFrame;
      final sub = manager.bleTransport.frameStream.listen((frame) {
        reassembledFrame = frame;
      });

      manager.bleTransport.processIncomingBleNotificationBytes(pkt1);
      expect(manager.bleTransport.receivedFramesCount, equals(0));

      manager.bleTransport.processIncomingBleNotificationBytes(pkt2);
      await Future.delayed(const Duration(milliseconds: 50));

      expect(manager.bleTransport.receivedFramesCount, equals(1));
      expect(reassembledFrame.sequence, equals(42));
      expect(reassembledFrame.transportSource, equals('ble'));
      expect(reassembledFrame.events, contains('vep_onset'));

      await sub.cancel();
    });

    test('4. DeviceManager Pokidex Wi-Fi Connection Transition', () async {
      final notifier = container.read(deviceManagerProvider.notifier);

      final ok = await notifier.connectPokidexWifi('127.0.0.1', port: 8765);
      final state = container.read(deviceManagerProvider);

      expect(ok, isTrue);
      expect(state.isPokidexActive, isTrue);
      expect(state.activeDeviceInfo?.deviceName, contains('Pokidex'));
    });

    test('5. DeviceManager Pokidex Disconnection Retains NO_DEVICE Contract', () async {
      final notifier = container.read(deviceManagerProvider.notifier);

      await notifier.connectPokidexWifi('127.0.0.1', port: 8765);
      await notifier.disconnectPokidexWifi();

      final state = container.read(deviceManagerProvider);
      expect(state.connectionState, equals(DeviceConnectionState.noDevice));
      expect(state.isConnected, isFalse);
      expect(state.isPokidexActive, isFalse);
    });
  });
}
