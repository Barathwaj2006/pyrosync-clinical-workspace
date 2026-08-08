# Changelog — PyroSync Clinical Workspace

All notable changes to the **PyroSync Clinical Workspace** platform developed by **Pyromatics Bio Solutions** will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [v1.0.0] - 2026-08-08

### Added
- **Sprint 16: Real Hardware Integration Layer**:
  - Implemented modular communication transports (`BleTransport`, `BluetoothClassicTransport`, `WifiTcpTransport`, `WifiUdpTransport`, `UsbSerialTransport`) under unified `IHardwareTransport` contract.
  - Built hardware-agnostic packet parser (`ConfigurablePacketParser`) supporting variable sampling rates (250 Hz - 5000 Hz) and channel counts (1 - 32 channels).
  - Built connection recovery manager (`ConnectionRecoveryManager`) with exponential retry, packet-loss detection, and safe recording halt on failure.
  - Published comprehensive developer documentation: `hardware_integration_guide.md`.
