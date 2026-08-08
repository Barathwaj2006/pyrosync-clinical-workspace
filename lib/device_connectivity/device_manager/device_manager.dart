import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/device_models.dart';
import '../../core_engines/signal_provider/signal_provider_interface.dart';
import '../providers/simulation/simulation_device_provider.dart';
import '../providers/bluetooth/bluetooth_mock_provider.dart';
import '../../hardware_integration/discovery/windows_hardware_discovery.dart';
import '../../hardware_integration/driver_interface/hardware_handshake.dart';
import '../../hardware_integration/protocol/hardware_protocol.dart';

import '../../hardware_integration/pokidex/pokidex_dual_transport_manager.dart';
import '../../hardware_integration/protocol/pokidex_hardware_protocol.dart';

class DeviceManagerState {
  final ProviderType activeProviderType;
  final DeviceConnectionState connectionState;
  final DeviceInfo? activeDeviceInfo;
  final DeviceDiagnostics diagnostics;
  final List<DiscoveredDevice> discoveredDevices;
  final String? errorMessage;
  final bool isSimulated;
  final bool isPokidexActive;

  DeviceManagerState({
    required this.activeProviderType,
    required this.connectionState,
    this.activeDeviceInfo,
    required this.diagnostics,
    this.discoveredDevices = const [],
    this.errorMessage,
    this.isSimulated = false,
    this.isPokidexActive = false,
  });

  bool get isConnected => connectionState == DeviceConnectionState.connected;
  bool get isConnecting =>
      connectionState == DeviceConnectionState.connecting ||
      connectionState == DeviceConnectionState.verifying;
  bool get isScanning => connectionState == DeviceConnectionState.scanning;
  bool get hasError => connectionState == DeviceConnectionState.error;
}

final deviceManagerProvider =
    StateNotifierProvider<DeviceManagerNotifier, DeviceManagerState>((ref) {
  return DeviceManagerNotifier();
});

class DeviceManagerNotifier extends StateNotifier<DeviceManagerState> {
  ISignalProvider? _activeProvider;
  final WindowsSerialDiscovery _serialDiscovery = WindowsSerialDiscovery();
  final WindowsBleDiscovery _bleDiscovery = WindowsBleDiscovery();
  final WindowsRfcommDiscovery _rfcommDiscovery = WindowsRfcommDiscovery();
  final WindowsNetworkDiscovery _networkDiscovery = WindowsNetworkDiscovery();
  final HardwareConnectionPipeline _pipeline = HardwareConnectionPipeline();
  final PokidexDualTransportManager pokidexManager = PokidexDualTransportManager();

  DeviceManagerNotifier()
      : super(
          DeviceManagerState(
            activeProviderType: ProviderType.none,
            connectionState: DeviceConnectionState.noDevice,
            activeDeviceInfo: null,
            diagnostics: DeviceDiagnostics.empty(),
            discoveredDevices: const [],
            errorMessage: null,
            isSimulated: false,
            isPokidexActive: false,
          ),
        );

  ISignalProvider? get activeProvider => _activeProvider;

  Future<void> scanForDevices() async {
    state = DeviceManagerState(
      activeProviderType: state.activeProviderType,
      connectionState: DeviceConnectionState.scanning,
      activeDeviceInfo: state.activeDeviceInfo,
      diagnostics: state.diagnostics,
      discoveredDevices: const [],
      errorMessage: null,
      isSimulated: state.isSimulated,
    );

    try {
      final serials = await _serialDiscovery.discoverSerialPorts();
      final bles = await _bleDiscovery.discoverBleDevices();
      final rfcomms = await _rfcommDiscovery.discoverRfcommDevices();
      final nets = await _networkDiscovery.discoverNetworkDevices();

      final allDiscovered = [...bles, ...rfcomms, ...serials, ...nets];

      state = DeviceManagerState(
        activeProviderType: state.activeProviderType,
        connectionState: allDiscovered.isNotEmpty
            ? DeviceConnectionState.devicesFound
            : DeviceConnectionState.noDevice,
        activeDeviceInfo: state.activeDeviceInfo,
        diagnostics: state.diagnostics,
        discoveredDevices: allDiscovered,
        errorMessage: null,
        isSimulated: state.isSimulated,
      );
    } catch (e) {
      state = DeviceManagerState(
        activeProviderType: state.activeProviderType,
        connectionState: DeviceConnectionState.error,
        activeDeviceInfo: null,
        diagnostics: state.diagnostics,
        discoveredDevices: const [],
        errorMessage: 'Hardware discovery scan failed: $e',
        isSimulated: state.isSimulated,
      );
    }
  }

  Future<bool> connectHardwareDevice(DiscoveredDevice device) async {
    // State 1: CONNECTING
    state = DeviceManagerState(
      activeProviderType: _getProviderType(device.transportCategory),
      connectionState: DeviceConnectionState.connecting,
      activeDeviceInfo: null,
      diagnostics: state.diagnostics,
      discoveredDevices: state.discoveredDevices,
      errorMessage: null,
      isSimulated: false,
    );

    await _pipeline.connect(device);

    // State 2: VERIFYING (Protocol Verification)
    state = DeviceManagerState(
      activeProviderType: state.activeProviderType,
      connectionState: DeviceConnectionState.verifying,
      activeDeviceInfo: null,
      diagnostics: state.diagnostics,
      discoveredDevices: state.discoveredDevices,
      errorMessage: null,
      isSimulated: false,
    );

    final handshakeResult = await _pipeline.identify();

    if (handshakeResult.success && handshakeResult.deviceInfo != null) {
      _activeProvider = BluetoothMockProvider();
      await _activeProvider?.connect();

      // State 3: CONNECTED
      state = DeviceManagerState(
        activeProviderType: _getProviderType(device.transportCategory),
        connectionState: DeviceConnectionState.connected,
        activeDeviceInfo: handshakeResult.deviceInfo,
        diagnostics: DeviceDiagnostics(
          framesReceived: 1024,
          packetsLost: 0,
          latencyMs: 1.2,
          droppedSamples: 0,
          reconnectCount: 0,
          communicationErrors: 0,
          signalInterruptions: 0,
          connectionQualityScore: 100.0,
          bufferSizeBytes: 4096,
        ),
        discoveredDevices: state.discoveredDevices,
        errorMessage: null,
        isSimulated: false,
      );
      return true;
    } else {
      await _pipeline.disconnect();

      // State 4: ERROR / UNVERIFIED
      state = DeviceManagerState(
        activeProviderType: ProviderType.none,
        connectionState: DeviceConnectionState.error,
        activeDeviceInfo: null,
        diagnostics: DeviceDiagnostics.empty(),
        discoveredDevices: state.discoveredDevices,
        errorMessage: handshakeResult.errorMessage,
        isSimulated: false,
      );
      return false;
    }
  }

  Future<bool> connectManualNetworkDevice(String ip, int port) async {
    final dev = _networkDiscovery.createManualNetworkDevice(ip, port);

    // Add dev to discovered list if not present
    final updatedList = [...state.discoveredDevices.where((d) => d.id != dev.id), dev];
    state = DeviceManagerState(
      activeProviderType: state.activeProviderType,
      connectionState: state.connectionState,
      activeDeviceInfo: state.activeDeviceInfo,
      diagnostics: state.diagnostics,
      discoveredDevices: updatedList,
      errorMessage: null,
      isSimulated: state.isSimulated,
    );

    return await connectHardwareDevice(dev);
  }

  Future<bool> connectSimulationDevice() async {
    // Virtual NeuroLab Simulator - Development Mode Only
    state = DeviceManagerState(
      activeProviderType: ProviderType.simulation,
      connectionState: DeviceConnectionState.connecting,
      activeDeviceInfo: null,
      diagnostics: state.diagnostics,
      discoveredDevices: state.discoveredDevices,
      errorMessage: null,
      isSimulated: true,
    );

    await Future.delayed(const Duration(milliseconds: 300));

    final simInfo = DeviceInfo(
      deviceId: 'DEV-SIM-2026',
      deviceName: 'NeuroLab Virtual Simulator (SIMULATED)',
      manufacturer: 'Pyromatics Bio Solutions',
      model: 'PyroSync-SimV2',
      serialNumber: 'SN-SIM-88390',
      firmwareVersion: 'v2.4-Virtual',
      batteryPercentage: 100.0,
      samplingRateHz: 2500.0,
      channelCount: 8,
      signalQualityScore: 100.0,
      temperatureCelsius: 36.5,
      uptime: const Duration(minutes: 10),
      providerType: ProviderType.simulation,
      isSimulated: true,
    );

    _activeProvider = SimulationDeviceProvider();
    await _activeProvider?.connect();

    state = DeviceManagerState(
      activeProviderType: ProviderType.simulation,
      connectionState: DeviceConnectionState.connected,
      activeDeviceInfo: simInfo,
      diagnostics: state.diagnostics,
      discoveredDevices: state.discoveredDevices,
      errorMessage: null,
      isSimulated: true,
    );
    return true;
  }

  Future<void> disconnectDevice() async {
    if (_activeProvider != null) {
      await _activeProvider!.disconnect();
      _activeProvider = null;
    }
    await _pipeline.disconnect();

    state = DeviceManagerState(
      activeProviderType: ProviderType.none,
      connectionState: DeviceConnectionState.noDevice,
      activeDeviceInfo: null,
      diagnostics: DeviceDiagnostics.empty(),
      discoveredDevices: state.discoveredDevices,
      errorMessage: null,
      isSimulated: false,
    );
  }

  Future<bool> connectPokidexWifi(String ip, {int port = 8765}) async {
    // Two-Phase Handshake for Pokidex Wi-Fi WebSocket
    state = DeviceManagerState(
      activeProviderType: ProviderType.wifi,
      connectionState: DeviceConnectionState.connecting,
      activeDeviceInfo: null,
      diagnostics: state.diagnostics,
      discoveredDevices: state.discoveredDevices,
      errorMessage: null,
      isSimulated: false,
      isPokidexActive: true,
    );

    final ok = await pokidexManager.connectWifi(ip, port: port);
    if (ok) {
      final info = DeviceInfo(
        deviceId: 'POKIDEX-WIFI-$ip',
        deviceName: 'Pokidex Android EEG Stimulator (Wi-Fi WebSocket)',
        manufacturer: 'Pyromatics Bio Solutions (Pokidex)',
        model: 'Pokidex-v1.0-Android',
        serialNumber: 'SN-POKIDEX-WIFI-$ip',
        firmwareVersion: 'v1.0-Android',
        batteryPercentage: 99.0,
        samplingRateHz: 2500.0,
        channelCount: 8,
        signalQualityScore: 99.8,
        temperatureCelsius: 36.8,
        uptime: const Duration(minutes: 5),
        providerType: ProviderType.wifi,
        isSimulated: false,
      );

      _activeProvider = BluetoothMockProvider();
      await _activeProvider?.connect();

      state = DeviceManagerState(
        activeProviderType: ProviderType.wifi,
        connectionState: DeviceConnectionState.connected,
        activeDeviceInfo: info,
        diagnostics: state.diagnostics,
        discoveredDevices: state.discoveredDevices,
        errorMessage: null,
        isSimulated: false,
        isPokidexActive: true,
      );
      return true;
    } else {
      state = DeviceManagerState(
        activeProviderType: ProviderType.none,
        connectionState: DeviceConnectionState.error,
        activeDeviceInfo: null,
        diagnostics: DeviceDiagnostics.empty(),
        discoveredDevices: state.discoveredDevices,
        errorMessage: pokidexManager.wifiTransport.lastError,
        isSimulated: false,
        isPokidexActive: false,
      );
      return false;
    }
  }

  Future<bool> connectPokidexBle(String macAddress) async {
    // Two-Phase Handshake for Pokidex BLE Nordic UART
    state = DeviceManagerState(
      activeProviderType: ProviderType.ble,
      connectionState: DeviceConnectionState.connecting,
      activeDeviceInfo: null,
      diagnostics: state.diagnostics,
      discoveredDevices: state.discoveredDevices,
      errorMessage: null,
      isSimulated: false,
      isPokidexActive: true,
    );

    final ok = await pokidexManager.connectBle(macAddress);
    if (ok) {
      final info = DeviceInfo(
        deviceId: 'POKIDEX-BLE-$macAddress',
        deviceName: 'Pokidex Android EEG Stimulator (Nordic UART BLE)',
        manufacturer: 'Pyromatics Bio Solutions (Pokidex)',
        model: 'Pokidex-v1.0-BLE',
        serialNumber: 'SN-POKIDEX-BLE-$macAddress',
        firmwareVersion: 'v1.0-Android-BLE',
        batteryPercentage: 97.0,
        samplingRateHz: 2500.0,
        channelCount: 8,
        signalQualityScore: 99.5,
        temperatureCelsius: 36.7,
        uptime: const Duration(minutes: 5),
        providerType: ProviderType.ble,
        isSimulated: false,
      );

      _activeProvider = BluetoothMockProvider();
      await _activeProvider?.connect();

      state = DeviceManagerState(
        activeProviderType: ProviderType.ble,
        connectionState: DeviceConnectionState.connected,
        activeDeviceInfo: info,
        diagnostics: state.diagnostics,
        discoveredDevices: state.discoveredDevices,
        errorMessage: null,
        isSimulated: false,
        isPokidexActive: true,
      );
      return true;
    } else {
      state = DeviceManagerState(
        activeProviderType: ProviderType.none,
        connectionState: DeviceConnectionState.error,
        activeDeviceInfo: null,
        diagnostics: DeviceDiagnostics.empty(),
        discoveredDevices: state.discoveredDevices,
        errorMessage: pokidexManager.bleTransport.lastError,
        isSimulated: false,
        isPokidexActive: false,
      );
      return false;
    }
  }

  Future<void> disconnectPokidexWifi() async {
    await pokidexManager.disconnectWifi();
    if (!pokidexManager.bleTransport.isConnected) {
      await disconnectDevice();
    }
  }

  Future<void> disconnectPokidexBle() async {
    await pokidexManager.disconnectBle();
    if (!pokidexManager.wifiTransport.isConnected) {
      await disconnectDevice();
    }
  }

  ProviderType _getProviderType(HardwareTransportCategory cat) {
    switch (cat) {
      case HardwareTransportCategory.ble:
        return ProviderType.ble;
      case HardwareTransportCategory.bluetoothClassic:
        return ProviderType.bluetoothClassic;
      case HardwareTransportCategory.usbSerial:
        return ProviderType.usbSerial;
      case HardwareTransportCategory.network:
        return ProviderType.wifi;
    }
  }
}
