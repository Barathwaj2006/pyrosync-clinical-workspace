import 'dart:async';
import 'dart:io';
import '../../device_connectivity/models/device_models.dart';

class WindowsSerialDiscovery {
  Future<List<DiscoveredDevice>> discoverSerialPorts() async {
    final List<DiscoveredDevice> result = [];

    if (!Platform.isWindows) return result;

    try {
      // Query Windows WMI / CIM for Ports with PNP details (COM number, Name, VID/PID, Manufacturer)
      final cmd = '''
      Get-CimInstance Win32_PnPEntity | Where-Object { \$_.PNPClass -eq 'Ports' -or \$_.Name -match 'COM\\d+' } | Select-Object Name, Manufacturer, PNPDeviceID | ConvertTo-Json
      ''';

      final processResult = await Process.run('powershell', ['-Command', cmd]).timeout(const Duration(seconds: 3));

      if (processResult.exitCode == 0 && processResult.stdout.toString().trim().isNotEmpty) {
        final rawJson = processResult.stdout.toString().trim();
        // Parse COM port entries
        RegExp nameRegex = RegExp(r'"Name":\s*"([^"]+)"');
        RegExp mfrRegex = RegExp(r'"Manufacturer":\s*"([^"]+)"');
        RegExp pnpRegex = RegExp(r'"PNPDeviceID":\s*"([^"]+)"');

        final nameMatches = nameRegex.allMatches(rawJson).toList();
        final mfrMatches = mfrRegex.allMatches(rawJson).toList();
        final pnpMatches = pnpRegex.allMatches(rawJson).toList();

        for (int i = 0; i < nameMatches.length; i++) {
          final fullName = nameMatches[i].group(1) ?? 'Serial Port';
          final mfr = i < mfrMatches.length ? (mfrMatches[i].group(1) ?? 'Generic') : 'Generic';
          final pnp = i < pnpMatches.length ? (pnpMatches[i].group(1) ?? '') : '';

          // Extract COM number
          final comMatch = RegExp(r'(COM\d+)').firstMatch(fullName);
          final comNumber = comMatch != null ? comMatch.group(1)! : 'COM?';

          // Extract VID/PID from PNPDeviceID (e.g. USB\VID_0403&PID_6001\...)
          String vidPidStr = 'VID: N/A, PID: N/A';
          final vidMatch = RegExp(r'VID_([0-9A-Fa-f]{4})').firstMatch(pnp);
          final pidMatch = RegExp(r'PID_([0-9A-Fa-f]{4})').firstMatch(pnp);
          if (vidMatch != null && pidMatch != null) {
            vidPidStr = 'VID: ${vidMatch.group(1)}, PID: ${pidMatch.group(1)}';
          }

          result.add(
            DiscoveredDevice(
              id: 'USB-PORT-$comNumber',
              name: '$comNumber — $fullName',
              portOrAddress: comNumber,
              transportCategory: HardwareTransportCategory.usbSerial,
              description: '$mfr • $vidPidStr',
              vidPid: vidPidStr,
              manufacturer: mfr,
              isAvailable: true,
              statusNote: 'Unverified — Protocol Handshake Required',
            ),
          );
        }
      }
    } catch (_) {
      // Return whatever valid ports were extracted
    }

    return result;
  }
}

class WindowsBleDiscovery {
  Future<List<DiscoveredDevice>> discoverBleDevices() async {
    final List<DiscoveredDevice> bleDevices = [];

    if (!Platform.isWindows) return bleDevices;

    try {
      // Execute Windows WinRT BluetoothLEAdvertisementWatcher via PowerShell to scan nearby BLE advertisements
      const script = '''
      [Windows.Devices.Bluetooth.Advertisement.BluetoothLEAdvertisementWatcher, Windows.Devices.Bluetooth, ContentType = WindowsRuntime] | Out-Null
      \$watcher = New-Object Windows.Devices.Bluetooth.Advertisement.BluetoothLEAdvertisementWatcher
      \$watcher.ScanningMode = [Windows.Devices.Bluetooth.Advertisement.BluetoothLEScanningMode]::Active
      \$devices = @()
      \$handler = [Windows.Foundation.TypedEventHandler[Windows.Devices.Bluetooth.Advertisement.BluetoothLEAdvertisementWatcher, Windows.Devices.Bluetooth.Advertisement.BluetoothLEAdvertisementReceivedEventArgs]]{
        param(\$sender, \$args)
        \$name = \$args.Advertisement.LocalName
        if ([string]::IsNullOrWhiteSpace(\$name)) { \$name = "Unknown BLE Device" }
        \$addr = \$args.BluetoothAddress.ToString("X12")
        \$rssi = \$args.RawSignalStrengthInDBm
        \$services = (\$args.Advertisement.ServiceUuids | ForEach-Object { \$_.ToString() }) -join ";"
        \$devices += "\$name|\$addr|\$rssi|\$services"
      }
      \$watcher.add_Received(\$handler)
      \$watcher.Start()
      Start-Sleep -Milliseconds 1200
      \$watcher.Stop()
      \$devices | Select-Object -Unique
      ''';

      final processResult = await Process.run('powershell', ['-Command', script]).timeout(const Duration(seconds: 4));

      if (processResult.exitCode == 0) {
        final lines = processResult.stdout.toString().split(RegExp(r'\r?\n'));
        for (var line in lines) {
          final parts = line.trim().split('|');
          if (parts.length >= 3) {
            final name = parts[0];
            final rawAddr = parts[1];
            final rssi = int.tryParse(parts[2]) ?? -70;
            final services = parts.length > 3 ? parts[3] : '';

            // Format MAC address
            String formattedAddr = rawAddr;
            if (rawAddr.length == 12) {
              formattedAddr = rawAddr.replaceAllMapped(RegExp(r'.{2}'), (match) => '${match.group(0)}:').substring(0, 17);
            }

            // Check if Pokidex BLE GATT Service (0000fe50) or EEG Service is exposed
            final bool isPokidex = services.toLowerCase().contains('fe50') || name.toLowerCase().contains('pokidex');
            final bool isEeg = isPokidex || services.toLowerCase().contains('ffe0') || name.toLowerCase().contains('eeg') || name.toLowerCase().contains('bioamp');

            String note = 'Bluetooth device detected but not recognized as a compatible EEG acquisition device.';
            if (isPokidex) {
              note = 'Pokidex Android EEG Stimulator (GATT Service 0000fe50 Detected)';
            } else if (isEeg) {
              note = 'GATT EEG Service Detected';
            }

            bleDevices.add(
              DiscoveredDevice(
                id: isPokidex ? 'BLE-POKIDEX-$formattedAddr' : 'BLE-DEV-$formattedAddr',
                name: isPokidex && !name.contains('Pokidex') ? 'Pokidex EEG Stimulator ($name)' : name,
                portOrAddress: formattedAddr,
                transportCategory: HardwareTransportCategory.ble,
                description: isPokidex
                    ? 'Pokidex Android BLE Peripheral (GATT 0000fe50 / FE51 Notify-Only) • RSSI: $rssi dBm'
                    : 'Bluetooth LE • RSSI: $rssi dBm',
                rssiDbm: rssi,
                isEegServiceDetected: isEeg,
                isAvailable: true,
                statusNote: note,
              ),
            );
          }
        }
      }
    } catch (_) {
      // Failure to execute scan yields empty list (no fake devices created)
    }

    return bleDevices;
  }
}

class WindowsRfcommDiscovery {
  Future<List<DiscoveredDevice>> discoverRfcommDevices() async {
    final List<DiscoveredDevice> rfcommDevices = [];

    if (!Platform.isWindows) return rfcommDevices;

    try {
      // Query Windows Bluetooth Serial Port Profile (SPP) / RFCOMM paired services
      const script = '''
      Get-CimInstance Win32_PnPEntity | Where-Object { \$_.PNPClass -eq 'Bluetooth' -and \$_.Name -match 'Standard Serial over Bluetooth' } | Select-Object Name, DeviceID | ConvertTo-Json
      ''';

      final processResult = await Process.run('powershell', ['-Command', script]).timeout(const Duration(seconds: 2));

      if (processResult.exitCode == 0 && processResult.stdout.toString().trim().isNotEmpty) {
        final rawJson = processResult.stdout.toString().trim();
        RegExp nameRegex = RegExp(r'"Name":\s*"([^"]+)"');
        final matches = nameRegex.allMatches(rawJson);

        for (var m in matches) {
          final name = m.group(1) ?? 'Bluetooth RFCOMM SPP Device';
          rfcommDevices.add(
            DiscoveredDevice(
              id: 'RFCOMM-${name.hashCode}',
              name: name,
              portOrAddress: 'RFCOMM / SPP Channel',
              transportCategory: HardwareTransportCategory.bluetoothClassic,
              description: 'Bluetooth Classic Serial Port Profile (RFCOMM)',
              isAvailable: true,
              statusNote: 'SPP Connection Ready — Protocol Verification Required',
            ),
          );
        }
      }
    } catch (_) {}

    return rfcommDevices;
  }
}

class WindowsNetworkDiscovery {
  Future<List<DiscoveredDevice>> discoverNetworkDevices() async {
    final List<DiscoveredDevice> discovered = [];

    try {
      RawDatagramSocket socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
      socket.broadcastEnabled = true;

      // Broadcast UDP discovery ping to port 8888
      socket.send([0x50, 0x59, 0x52, 0x4F, 0x5F, 0x44, 0x49, 0x53, 0x43], InternetAddress('255.255.255.255'), 8888);

      socket.listen((RawSocketEvent event) {
        if (event == RawSocketEvent.read) {
          Datagram? dg = socket.receive();
          if (dg != null && dg.data.length >= 4) {
            if (dg.data[0] == 0x50 && dg.data[1] == 0x59 && dg.data[2] == 0x52 && dg.data[3] == 0x4F) {
              final ip = dg.address.address;
              discovered.add(
                DiscoveredDevice(
                  id: 'NET-DEV-$ip',
                  name: 'PyroSync Biosignal Network Node ($ip)',
                  portOrAddress: '$ip:5000',
                  transportCategory: HardwareTransportCategory.network,
                  description: 'Network-Attached UDP/TCP Acquisition Unit',
                  isAvailable: true,
                  statusNote: 'Verified Network Subnet Node',
                ),
              );
            }
          }
        }
      });

      await Future.delayed(const Duration(milliseconds: 600));
      socket.close();
    } catch (_) {}

    return discovered;
  }

  DiscoveredDevice createManualNetworkDevice(String ip, int port) {
    return DiscoveredDevice(
      id: 'NET-MANUAL-$ip-$port',
      name: 'Manual Network Device ($ip:$port)',
      portOrAddress: '$ip:$port',
      transportCategory: HardwareTransportCategory.network,
      description: 'User-Configured TCP/UDP Endpoint ($ip:$port)',
      isAvailable: true,
      statusNote: 'Manual Network Entry — Connection Verification Pending',
    );
  }
}
