import 'dart:async';
import '../models/device_models.dart';
import '../../core_engines/signal_provider/signal_provider_interface.dart';
import '../providers/simulation/simulation_device_provider.dart';
import '../providers/bluetooth/bluetooth_mock_provider.dart';

class DeviceManager {
  ProviderType _activeProviderType = ProviderType.simulation;
  ISignalProvider _activeProvider = SimulationDeviceProvider();
  DeviceConnectionState _connectionState = DeviceConnectionState.connected;
  DeviceInfo _activeDeviceInfo;
  DeviceDiagnostics _diagnostics;

  DeviceManager()
      : _activeDeviceInfo = DeviceInfo(
          deviceId: 'DEV-SIM-2026',
          deviceName: 'NeuroLab Virtual Device',
          manufacturer: 'Pyromatics Bio Solutions',
          model: 'PyroSync-SimV2',
          serialNumber: 'SN-SIM-88390',
          firmwareVersion: 'v2.4-Simulated',
          batteryPercentage: 98.5,
          samplingRateHz: 2500.0,
          channelCount: 8,
          signalQualityScore: 98.2,
          temperatureCelsius: 36.5,
          uptime: const Duration(hours: 4, minutes: 12),
          providerType: ProviderType.simulation,
        ),
        _diagnostics = DeviceDiagnostics(
          framesReceived: 12480,
          packetsLost: 0,
          latencyMs: 1.2,
          droppedSamples: 0,
          reconnectCount: 0,
          communicationErrors: 0,
          signalInterruptions: 0,
          connectionQualityScore: 100.0,
          bufferSizeBytes: 4096,
        );

  ProviderType get activeProviderType => _activeProviderType;
  ISignalProvider get activeProvider => _activeProvider;
  DeviceConnectionState get connectionState => _connectionState;
  DeviceInfo get activeDeviceInfo => _activeDeviceInfo;
  DeviceDiagnostics get diagnostics => _diagnostics;

  void switchProvider(ProviderType newType) {
    _activeProviderType = newType;
    if (newType == ProviderType.simulation) {
      _activeProvider = SimulationDeviceProvider();
      _activeDeviceInfo = DeviceInfo(
        deviceId: 'DEV-SIM-2026',
        deviceName: 'NeuroLab Virtual Device',
        manufacturer: 'Pyromatics Bio Solutions',
        model: 'PyroSync-SimV2',
        serialNumber: 'SN-SIM-88390',
        firmwareVersion: 'v2.4-Simulated',
        batteryPercentage: 98.5,
        samplingRateHz: 2500.0,
        channelCount: 8,
        signalQualityScore: 98.2,
        temperatureCelsius: 36.5,
        uptime: const Duration(hours: 4, minutes: 12),
        providerType: ProviderType.simulation,
      );
    } else {
      _activeProvider = BluetoothMockProvider();
      _activeDeviceInfo = DeviceInfo(
        deviceId: 'DEV-BLE-9920',
        deviceName: 'PyroSync Wireless VEP Headset',
        manufacturer: 'Pyromatics Bio Solutions',
        model: 'PyroSync-Hardware-V1',
        serialNumber: 'SN-BLE-99204',
        firmwareVersion: 'v1.0-HardwareMock',
        batteryPercentage: 86.0,
        samplingRateHz: 2500.0,
        channelCount: 8,
        signalQualityScore: 94.0,
        temperatureCelsius: 37.1,
        uptime: const Duration(hours: 1, minutes: 45),
        providerType: newType,
      );
    }
  }

  Future<bool> connectDevice() async {
    _connectionState = DeviceConnectionState.connecting;
    final success = await _activeProvider.connect();
    if (success) {
      _connectionState = DeviceConnectionState.connected;
    } else {
      _connectionState = DeviceConnectionState.error;
    }
    return success;
  }

  Future<bool> disconnectDevice() async {
    final success = await _activeProvider.disconnect();
    _connectionState = DeviceConnectionState.disconnected;
    return success;
  }
}
