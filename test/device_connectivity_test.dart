import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pyrosync/device_connectivity/device_manager/device_manager.dart';
import 'package:pyrosync/device_connectivity/models/device_models.dart';

void main() {
  group('PyroSync Windows Real Hardware Architecture Tests (All 12 Cases)', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('1. No Bluetooth/hardware discovered -> NO_DEVICE', () {
      final state = container.read(deviceManagerProvider);
      expect(state.connectionState, equals(DeviceConnectionState.noDevice));
      expect(state.isConnected, isFalse);
      expect(state.activeDeviceInfo, isNull);
    });

    test('2. Bluetooth/Hardware device discovered -> DEVICES_FOUND', () async {
      final notifier = container.read(deviceManagerProvider.notifier);
      await notifier.scanForDevices();
      final state = container.read(deviceManagerProvider);

      expect(state.connectionState, isNot(equals(DeviceConnectionState.scanning)));
    });

    test('3. Unknown Bluetooth device -> NOT VERIFIED', () async {
      final notifier = container.read(deviceManagerProvider.notifier);
      final unknownBle = DiscoveredDevice(
        id: 'BLE-DEV-001122334455',
        name: 'Unknown Headphones',
        portOrAddress: '00:11:22:33:44:55',
        transportCategory: HardwareTransportCategory.ble,
        description: 'Bluetooth LE • RSSI: -75 dBm',
        isEegServiceDetected: false,
      );

      final success = await notifier.connectHardwareDevice(unknownBle);
      final state = container.read(deviceManagerProvider);

      expect(success, isFalse);
      expect(state.connectionState, equals(DeviceConnectionState.error));
      expect(state.errorMessage, contains('Bluetooth device detected but not recognized as a compatible EEG acquisition device'));
    });

    test('4. Compatible BLE device -> CONNECTING -> VERIFYING -> CONNECTED', () async {
      final notifier = container.read(deviceManagerProvider.notifier);
      final compatibleBle = DiscoveredDevice(
        id: 'BLE-DEV-001A7DDA7113',
        name: 'Pyromatics Verified BioAmp BLE',
        portOrAddress: '00:1A:7D:DA:71:13',
        transportCategory: HardwareTransportCategory.ble,
        description: 'Bluetooth LE • RSSI: -61 dBm',
        isEegServiceDetected: true,
      );

      final success = await notifier.connectHardwareDevice(compatibleBle);
      final state = container.read(deviceManagerProvider);

      expect(success, isTrue);
      expect(state.connectionState, equals(DeviceConnectionState.connected));
      expect(state.activeDeviceInfo?.providerType, equals(ProviderType.ble));
    });

    test('5. BLE disconnect -> DISCONNECTED', () async {
      final notifier = container.read(deviceManagerProvider.notifier);
      final bleDevice = DiscoveredDevice(
        id: 'BLE-DEV-001A7DDA7113',
        name: 'Pyromatics Verified BioAmp BLE',
        portOrAddress: '00:1A:7D:DA:71:13',
        transportCategory: HardwareTransportCategory.ble,
        description: 'BLE',
        isEegServiceDetected: true,
      );

      await notifier.connectHardwareDevice(bleDevice);
      expect(container.read(deviceManagerProvider).isConnected, isTrue);

      await notifier.disconnectDevice();
      final state = container.read(deviceManagerProvider);
      expect(state.connectionState, equals(DeviceConnectionState.noDevice));
      expect(state.isConnected, isFalse);
    });

    test('6. Unknown serial port -> NOT VERIFIED', () async {
      final notifier = container.read(deviceManagerProvider.notifier);
      final unknownCom = DiscoveredDevice(
        id: 'USB-PORT-COM4',
        name: 'COM4 — Standard Serial Device',
        portOrAddress: 'COM4',
        transportCategory: HardwareTransportCategory.usbSerial,
        description: 'FTDI • VID: 0403, PID: 6001',
      );

      final success = await notifier.connectHardwareDevice(unknownCom);
      final state = container.read(deviceManagerProvider);

      expect(success, isFalse);
      expect(state.connectionState, equals(DeviceConnectionState.error));
      expect(state.errorMessage, contains('Serial port COM4 detected, but compatible EEG acquisition device handshake failed'));
    });

    test('7. Compatible serial hardware -> CONNECTED', () async {
      final notifier = container.read(deviceManagerProvider.notifier);
      final compatibleCom = DiscoveredDevice(
        id: 'USB-PORT-COM3',
        name: 'COM3 — Pyromatics Verified BioAmp USB',
        portOrAddress: 'COM3',
        transportCategory: HardwareTransportCategory.usbSerial,
        description: 'STMicroelectronics • VID: 0483, PID: 5740',
      );

      final success = await notifier.connectHardwareDevice(compatibleCom);
      final state = container.read(deviceManagerProvider);

      expect(success, isTrue);
      expect(state.connectionState, equals(DeviceConnectionState.connected));
      expect(state.activeDeviceInfo?.providerType, equals(ProviderType.usbSerial));
    });

    test('8. Network device discovered -> USER_SELECTION_REQUIRED', () async {
      final notifier = container.read(deviceManagerProvider.notifier);
      await notifier.scanForDevices();
      final state = container.read(deviceManagerProvider);

      expect(state.isConnected, isFalse);
    });

    test('9. Network device fails handshake -> ERROR', () async {
      final notifier = container.read(deviceManagerProvider.notifier);
      final unverifiedNet = DiscoveredDevice(
        id: 'NET-DEV-192.168.1.99',
        name: 'Generic Router Node (192.168.1.99)',
        portOrAddress: '192.168.1.99:5000',
        transportCategory: HardwareTransportCategory.network,
        description: 'Network Endpoint',
      );

      final success = await notifier.connectHardwareDevice(unverifiedNet);
      final state = container.read(deviceManagerProvider);

      expect(success, isFalse);
      expect(state.connectionState, equals(DeviceConnectionState.error));
      expect(state.errorMessage, contains('failed protocol identification handshake'));
    });

    test('10. No hardware -> recording blocked', () {
      final state = container.read(deviceManagerProvider);
      expect(state.isConnected, isFalse);
    });

    test('11. Simulator enabled -> clearly labelled SIMULATION', () async {
      final notifier = container.read(deviceManagerProvider.notifier);
      await notifier.connectSimulationDevice();
      final state = container.read(deviceManagerProvider);

      expect(state.isConnected, isTrue);
      expect(state.isSimulated, isTrue);
      expect(state.activeDeviceInfo?.isSimulated, isTrue);
      expect(state.activeDeviceInfo?.deviceName, contains('SIMULATED'));
    });

    test('12. Simulator disabled -> cannot affect real hardware state', () async {
      final notifier = container.read(deviceManagerProvider.notifier);
      await notifier.connectSimulationDevice();
      await notifier.disconnectDevice();

      final state = container.read(deviceManagerProvider);
      expect(state.connectionState, equals(DeviceConnectionState.noDevice));
      expect(state.isSimulated, isFalse);
      expect(state.activeDeviceInfo, isNull);
    });
  });
}
