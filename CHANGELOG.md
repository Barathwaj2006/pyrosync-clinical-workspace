# Changelog — PyroSync Clinical Workspace

All notable changes to the **PyroSync Clinical Workspace** platform developed by **Pyromatics Bio Solutions** will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [v1.1.0-CONNECTIVITY] - 2026-08-09

### Added & Fixed
- **Pokidex QR Pairing & Wi-Fi WebSocket Server**:
  - Implemented laptop-hosted WebSocket Server on default port `8765` with automatic LAN IPv4 detection (`NetworkInterface.list()`).
  - Added `PokidexQrPayload` model generating cryptographically random 16-character one-time pairing tokens and 5-minute expirations.
  - Implemented `PokidexQrDialog` presenting a large QR Code matrix canvas, network connection indicators, session tokens, and streaming metrics.
- **Normalized 8-Stage Connection State Machine & Mutual Handshake**:
  - Normalized states: `IDLE` ➔ `SCANNING` ➔ `DEVICE_FOUND` ➔ `CONNECTING` ➔ `DISCOVERING_SERVICES` ➔ `WAITING_FOR_SIGNAL` ➔ `VERIFIED` ➔ `STREAMING` (plus `UNSTABLE`, `DISCONNECTED`, `ERROR`).
  - Implemented mutual application-level handshake: `HELLO` ➔ `HELLO_ACK` ➔ `SESSION_ACCEPTED` ➔ `READY` ➔ `START_STREAM` ➔ `SIGNAL_STREAMING`.
  - Enforced strict state separation: `SOCKET_CONNECTED != DEVICE_VERIFIED` and `DEVICE_VERIFIED != SIGNAL_STREAMING`.
- **Runtime Signal & Sequence Diagnostics Engine**:
  - Created `PokidexDiagnosticsEngine` providing sequence gap detection (`MISSING SEQUENCE: X`), packet loss %, out-of-order/duplicate tracking, actual sampling rate (Hz), timing jitter ($ms$), and transport latency ($ms$).
  - Preserved zero fake sample fabrication policy.
- **Preserved Existing BLE GATT Transport**:
  - Retained `0000fe50`/`0000fe51` notify-only BLE transport with 4-byte chunk header reassembly (`seqHigh`, `seqLow`, `chunkIndex`, `totalChunks`).

---

## [v1.0.0-HARDENED] - 2026-08-08

### Added & Configured
- **Android APK Build Environment (`android/app/build.gradle` & `AndroidManifest.xml`)**:
  - Configured Android package `com.pyromatics.pyrosync` targeting SDK 34 (Android 14) with Min SDK 21.
  - Added permissions for Bluetooth Low Energy, Bluetooth Scan/Connect, and Location for real hardware discovery.
  - Specified exact output path for release APK: `build/app/outputs/flutter-apk/app-release.apk`.
