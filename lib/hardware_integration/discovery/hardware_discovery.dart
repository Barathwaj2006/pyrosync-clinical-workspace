import 'dart:async';
import 'dart:io';
import '../../device_connectivity/models/device_models.dart';

abstract class DeviceDiscoveryProvider {
  HardwareTransportCategory get category;
  Future<List<DiscoveredDevice>> discoverDevices();
}

class SerialHardwareDiscovery implements DeviceDiscoveryProvider {
  @override
  HardwareTransportCategory get category => HardwareTransportCategory.usbSerial;

  @override
  Future<List<DiscoveredDevice>> discoverDevices() async {
    final List<DiscoveredDevice> result = [];

    if (!Platform.isWindows) {
      return result;
    }

    try {
      // Query Windows for actual serial ports available on system
      final processResult = await Process.run(
        'powershell',
        ['-Command', '[System.IO.Ports.SerialPort]::GetPortNames()'],
      ).timeout(const Duration(seconds: 2));

      if (processResult.exitCode == 0) {
        final lines = processResult.stdout.toString().split(RegExp(r'\r?\n'));
        for (var rawLine in lines) {
          final port = rawLine.trim();
          if (port.startsWith('COM')) {
            result.add(
              DiscoveredDevice(
                id: 'USB-PORT-$port',
                name: 'Serial Communications Port ($port)',
                portOrAddress: port,
                transportCategory: HardwareTransportCategory.usbSerial,
                description: 'Windows Serial Communications Device ($port)',
                isAvailable: true,
                statusNote: 'Unverified - Handshake required',
              ),
            );
          }
        }
      }
    } catch (_) {
      // Return whatever actual serial ports were found, or empty list
    }

    return result;
  }
}

class BluetoothHardwareDiscovery implements DeviceDiscoveryProvider {
  @override
  HardwareTransportCategory get category => HardwareTransportCategory.bluetooth;

  @override
  Future<List<DiscoveredDevice>> discoverDevices() async {
    // Truthful implementation: Do NOT fake Bluetooth devices.
    // If native Windows BLE plugin is missing, report 0 devices discovered.
    return [];
  }

  String get availabilityMessage =>
      'Bluetooth discovery unavailable (Requires native Windows BLE driver)';
}

class NetworkHardwareDiscovery implements DeviceDiscoveryProvider {
  @override
  HardwareTransportCategory get category => HardwareTransportCategory.network;

  @override
  Future<List<DiscoveredDevice>> discoverDevices() async {
    final List<DiscoveredDevice> discovered = [];

    try {
      // Send UDP discovery packet to local broadcast port 8888
      RawDatagramSocket socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
      socket.broadcastEnabled = true;

      // Broadcast query
      socket.send([0x50, 0x59, 0x52, 0x4F, 0x5F, 0x44, 0x49, 0x53, 0x43], InternetAddress('255.255.255.255'), 8888);

      final Completer<void> completer = Completer();

      socket.listen((RawSocketEvent event) {
        if (event == RawSocketEvent.read) {
          Datagram? dg = socket.receive();
          if (dg != null && dg.data.length >= 8) {
            // Verify PyroSync Magic Header [0x50, 0x59, 0x52, 0x4F] ('PYRO')
            if (dg.data[0] == 0x50 && dg.data[1] == 0x59 && dg.data[2] == 0x52 && dg.data[3] == 0x4F) {
              final ip = dg.address.address;
              discovered.add(
                DiscoveredDevice(
                  id: 'NET-DEV-$ip',
                  name: 'PyroSync Biosignal Network Node ($ip)',
                  portOrAddress: '$ip:8888',
                  transportCategory: HardwareTransportCategory.network,
                  description: 'Network-Attached Acquisition Unit',
                  isAvailable: true,
                  statusNote: 'Verified mDNS/UDP Node',
                ),
              );
            }
          }
        }
      });

      // Listen for 800ms
      await Future.delayed(const Duration(milliseconds: 800));
      socket.close();
      if (!completer.isCompleted) completer.complete();
    } catch (_) {
      // Network broadcast unavailable or blocked by firewall
    }

    return discovered;
  }
}
