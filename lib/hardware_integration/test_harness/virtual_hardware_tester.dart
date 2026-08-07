import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

class HardwareTestHarnessConfig {
  final double simulatedPacketLossRatio; // 0.0 to 0.5
  final double simulatedCorruptionRatio; // 0.0 to 0.1
  final int simulatedLatencyMs;
  final bool isDisconnectSimulated;

  HardwareTestHarnessConfig({
    this.simulatedPacketLossRatio = 0.0,
    this.simulatedCorruptionRatio = 0.0,
    this.simulatedLatencyMs = 0,
    this.isDisconnectSimulated = false,
  });
}

class VirtualHardwareTester {
  final Random _random = Random();
  HardwareTestHarnessConfig _config = HardwareTestHarnessConfig();

  HardwareTestHarnessConfig get config => _config;

  void updateConfig(HardwareTestHarnessConfig newConfig) {
    _config = newConfig;
  }

  Uint8List processPacketWithTestHarness(Uint8List rawBytes) {
    if (_config.isDisconnectSimulated) {
      throw Exception('[VIRTUAL_HARDWARE_TESTER] Simulated hardware disconnection.');
    }

    if (_config.simulatedPacketLossRatio > 0.0 &&
        _random.nextDouble() < _config.simulatedPacketLossRatio) {
      // Packet dropped
      return Uint8List(0);
    }

    if (_config.simulatedCorruptionRatio > 0.0 &&
        _random.nextDouble() < _config.simulatedCorruptionRatio) {
      // Corrupt last byte CRC
      final corrupted = Uint8List.fromList(rawBytes);
      corrupted[corrupted.length - 1] = 0xFF;
      return corrupted;
    }

    return rawBytes;
  }
}
