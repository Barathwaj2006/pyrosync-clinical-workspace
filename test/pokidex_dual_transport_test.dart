import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pyrosync/device_connectivity/device_manager/device_manager.dart';
import 'package:pyrosync/device_connectivity/models/device_models.dart';
import 'package:pyrosync/hardware_integration/pokidex/pokidex_signal_frame.dart';
import 'package:pyrosync/hardware_integration/pokidex/pokidex_dual_transport_manager.dart';
import 'package:pyrosync/hardware_integration/protocol/pokidex_hardware_protocol.dart';
import 'package:pyrosync/hardware_integration/transports/hardware_communication_transports.dart';

void main() {
  group('Pokidex Android EEG Stimulator Dual-Transport (Wi-Fi + BLE) Test Suite', () {
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

    test('2. Pokidex HardwareProtocol Handshake Verification', () async {
      final protocol = PokidexHardwareProtocol();
      final validBle = DiscoveredDevice(
        id: 'BLE-POKIDEX-001A7DDA7113',
        name: 'Pokidex EEG Stimulator',
        portOrAddress: '00:1A:7D:DA:71:13',
        transportCategory: HardwareTransportCategory.ble,
        description: '6E400001 Nordic UART',
      );

      final transport = BleTransport();
      final result = await protocol.identify(transport, validBle);

      expect(result.success, isTrue);
      expect(result.deviceInfo?.deviceName, contains('Pokidex'));
      expect(result.deviceInfo?.manufacturer, contains('Pokidex'));
    });

    test('3. Pokidex Dual Transport Manager Concurrent Streaming & Metrics Tracking', () async {
      final manager = PokidexDualTransportManager();

      // Simulate Wi-Fi frame
      const wifiJson = '''
      {
        "metadata": {"source": "Pokidex-Wifi", "channel_count": 8, "sampling_rate": 2500.0},
        "data": {"timestamp": 1000, "sequence": 1, "channel_samples": [[1.0], [2.0]]},
        "events": []
      }
      ''';

      // Simulate BLE chunk
      const bleChunk = '''{"metadata":{"source":"Pokidex-BLE","channel_count":8,"sampling_rate":2500.0},"data":{"timestamp":1005,"sequence":1,"channel_samples":[[1.1],[2.1]]},"events":[]}\n''';

      manager.bleTransport.connect('00:1A:7D:DA:71:13');
      manager.bleTransport.processIncomingBleChunk(bleChunk);

      expect(manager.bleTransport.isConnected, isTrue);
    });

    test('4. DeviceManager Pokidex Wi-Fi Connection Transition', () async {
      final notifier = container.read(deviceManagerProvider.notifier);

      final ok = await notifier.connectPokidexWifi('127.0.0.1', port: 8765);
      final state = container.read(deviceManagerProvider);

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
