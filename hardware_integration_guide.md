# PyroSync Hardware Integration Guide — ESP32 / Custom Hardware Developer Specification

> **Company**: Pyromatics Bio Solutions  
> **Target Hardware**: ESP32, ESP8266, BLE, Wi-Fi TCP/UDP, USB Serial  
> **Status**: Hardware-Ready Framework Architecture Complete (`v0.1.0`)  

---

## 1. Overview for Physical Hardware Engineers

This document provides exact specifications for physical hardware developers building ESP32/ESP8266 acquisition boards for **PyroSync Clinical Workspace**.

PyroSync uses a hardware-agnostic abstraction layer. Downstream medical software (Signal Processing, Real-Time Waveform Visualization, CDSS Rule Engine, Report Generator) relies strictly on the `ISignalProvider` contract and is **completely decoupled** from the physical transport or MCU firmware implementation.

---

## 2. Reference Binary Packet Specification (Reference Test Protocol)

When transmitting raw EEG/VEP data over BLE, Wi-Fi TCP/UDP, or USB Serial, incoming binary packets should adhere to the reference frame format:

```text
 0         1         2         3         4                     36        40        42 (Bytes)
+---------+---------+---------+---------+---------------------+---------+---------+
| Header  | Header  | Sample  | Channel | Payload Data        | CRC32   | Footer  |
| 0xA5    | 0x5A    | Count   | Count   | (8-32 Ch x 4B float)| Check   | 0x5BB5  |
+---------+---------+---------+---------+---------------------+---------+---------+
```

### Packet Field Definitions:
- **Header**: 2 Bytes fixed magic sequence (`0xA5 0x5A`).
- **Sample Count**: 1 Byte unsigned integer (Number of samples per channel in frame, e.g. `1` to `10`).
- **Channel Count**: 1 Byte unsigned integer (e.g. `8` or `32`).
- **Payload Data**: IEEE-754 Single-Precision 32-bit Floating Point values in Microvolts ($\mu\text{V}$) or ADC raw counts.
- **CRC32**: 4-Byte IEEE 802.3 Polynomial CRC checksum calculated over header + payload bytes.
- **Footer**: 2 Bytes fixed magic sequence (`0x5B 0xB5`).

---

## 3. How to Connect a New ESP32 Hardware Implementation

1. **Implement `IHardwareDriver`**:
   Extend `IHardwareDriver` in `lib/hardware_integration/driver_interface/hardware_driver_interface.dart`.
2. **Select Communication Transport**:
   Instantiate `BleTransport`, `WifiTcpTransport`, or `UsbSerialTransport`.
3. **Register Driver in `DeviceManager`**:
   Add driver instance to `DeviceManager` in `lib/device_connectivity/device_manager/device_manager.dart`.
4. **Validation & Testing**:
   Run the test harness (`VirtualHardwareTester`) to simulate 2500 Hz streaming, packet loss, and CRC corruption.
