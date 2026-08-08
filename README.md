<div align="center">

# 🧠 PyroSync Clinical Workspace

[![Flutter](https://img.shields.io/badge/Flutter-3.44.9-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Platform](https://img.shields.io/badge/Platform-Windows%20Desktop%20(x64)-0078D4?style=for-the-badge&logo=windows&logoColor=white)](https://microsoft.com)
[![State Management](https://img.shields.io/badge/State-Riverpod%202.x-42B883?style=for-the-badge&logo=vue.js&logoColor=white)](https://riverpod.dev)
[![License](https://img.shields.io/badge/License-MIT-blue.svg?style=for-the-badge)](LICENSE)
[![Build Status](https://img.shields.io/badge/Build-Passing-brightgreen?style=for-the-badge&logo=github-actions&logoColor=white)]()

> **Commercial-Grade AI-Assisted Neurodiagnostic Platform & Biosignal Acquisition Workspace**  
> Developed by **Pyromatics Bio Solutions**

---

</div>

## 🔬 About Pyromatics Bio Solutions

**Pyromatics Bio Solutions** engineers high-precision biomedical software systems for clinical neurophysiology, visual electrophysiology, and biosignal processing. 

**PyroSync Clinical Workspace** is our native Windows desktop application engineered for clinicians, biomedical engineers, and clinical researchers acquiring, visualizing, filtering, analyzing, and generating explainable diagnostic reports from **Visual Evoked Potentials (VEP)** and **Electroencephalograms (EEG)**.

---

## ⚡ Key Architecture & Features

### 📡 1. Real Windows Native Hardware Connectivity Stack
Direct integration with the Windows desktop hardware layer without third-party middleware or fake mock objects:
- **Bluetooth Low Energy (BLE)**: Uses Windows WinRT `BluetoothLEAdvertisementWatcher` to discover nearby BLE devices, parsing MAC addresses, RSSI (dBm), and verifying GATT EEG Service UUIDs (`0000ffe0-0000-1000-8000-00805f9b34fb`) as well as Pokidex Nordic UART Service (`6E400001-B5A3-F393-E0A9-E50E24DCCA9E`).
- **Bluetooth Classic (RFCOMM)**: Queries Windows Serial Port Profile (SPP) paired devices via WMI (`Win32_PnPEntity`).
- **USB / Serial Ports**: Enumerates real Windows system serial ports via WMI (`Win32_PnPEntity`), extracting COM number, Windows Device Name, USB `VID:PID` (e.g. `VID: 0403, PID: 6001`), and Manufacturer.
- **Wi-Fi / Ethernet Network**: UDP broadcast subnet discovery (`255.255.255.255:8888`) plus manual IP/Port endpoint configuration (`192.168.1.42:5000`) with connection testing.
- **📱 Pokidex Android EEG Stimulator Dual-Transport**: Connects to Pokidex concurrently over both **Wi-Fi WebSocket (`ws://<IP>:8765`)** and **BLE Nordic UART Service (`6E400001`)**. Streams JSON `SignalFrame` datagrams (metadata, sequence, timestamps, channel samples, VEP onset triggers) into the DSP pipeline while recording side-by-side latency & jitter research comparison logs.

### 🔒 2. Truthful Data Integrity & Zero Fabrication Contract
- **Clean Startup State**: The application defaults strictly to **`NO DEVICE`** (`DeviceConnectionState.noDevice`). Zero automatic connections on launch.
- **Two-Phase Handshake Verification**: Standardized state machine (`NO_DEVICE` → `SCANNING` → `DEVICES_FOUND` → `CONNECTING` → `VERIFYING` → `CONNECTED` / `ERROR`). Unverified ports or unrecognized BLE devices trigger explicit error messages (`"Serial port detected, but compatible acquisition device not verified"`).
- **Clinical Safety Guard**: Disconnected state blocks live acquisition controls and prevents generating fake EEG signals or fabricated P100 latency results.
- **Isolated Simulation Mode**: NeuroLab Virtual Simulator is strictly isolated under **Settings → Development Mode**, explicitly tagged `SIMULATED` (`isSimulated: true`), with zero impact on real hardware connections.

### 🧪 3. Pure Dart 7-Stage Biomedical Signal Processing Engine (DSP)
High-performance biosignal processing pipeline:
1. **Preprocessing**: DC offset removal & baseline drift correction.
2. **Filtering**: 50/60 Hz IIR Butterworth Notch Filter, High-Pass (0.5–1.0 Hz), Low-Pass (30–100 Hz).
3. **Artifact Detection**: Real-time thresholding for EOG eye blinks, EMG muscle artifacts, and channel disconnections.
4. **Spectral Analysis**: Fast Fourier Transform (FFT) & Power Spectral Density (PSD) band power computation (Delta, Theta, Alpha, Beta, Gamma).
5. **VEP Peak Extraction**: Automated extraction of N75, P100 latency (ms), N145, and peak-to-peak amplitude ($\mu V$).
6. **Signal Quality Assessment**: Signal-to-Noise Ratio (SNR) evaluation in dB and qualitative score (0–100%).
7. **Waveform Averaging**: Coherent epoch averaging across high-density visual stimulus repetitions.

### 📊 4. Clinical Decision Support System (CDSS) & Audit Integrity
- **Explainable Diagnostic Assistant**: Generates evidence-backed clinical summaries based on VEP P100 latencies and inter-eye asymmetry.
- **FDA 21 CFR Part 11 Compliance**: Cryptographic SHA-256 digital signature locking for finalized clinical reports.
- **Export Capabilities**: Complete session export in European Data Format (EDF/EDF+), JSON, and clinical PDF summaries.

---

## 🏗️ System Architecture

```text
               REAL WINDOWS HOST LAPTOP STACK
    ├── Bluetooth LE (WinRT BLE Advertisement Watcher API)
    ├── Bluetooth Classic (Windows SPP / RFCOMM via Win32_PnPEntity)
    ├── USB / Serial (WMI Win32_PnPEntity: COM Port, VID/PID, Manufacturer)
    └── Wi-Fi / Ethernet Network (UDP Subnet Scan + Manual IP:Port Form)
                                │
                                ▼
         PyroSync Transport Layer (IHardwareTransport)
                                │
                                ▼
         Windows Hardware Discovery Engine & State Machine
  (NO_DEVICE ➔ SCANNING ➔ DEVICES_FOUND ➔ CONNECTING ➔ VERIFYING ➔ CONNECTED)
                                │
                                ▼
              HardwareProtocol Verification Pipeline
      (Validates BioAmp Handshake & GATT EEG Service UUID)
                                │
                                ▼
         7-Stage Pure Dart Biomedical DSP Signal Engine
      (DC Offset ➔ IIR Notch Filter ➔ FFT/PSD ➔ VEP Peak ➔ SNR)
                                │
                                ▼
             Clinical Decision Support System (CDSS)
       (Evidence Collector ➔ Biomedical Rule Engine ➔ SHA-256 Lock)
                                │
                                ▼
             Doctor Clinical Workspace & Report Builder
```

---

## 💻 Tech Stack

| Component | Technology / Framework |
|---|---|
| **UI Framework** | Flutter Desktop 3.44.9 (Windows Native x64 Runner) |
| **Language** | Dart 3.4+ / C++ Windows Runner |
| **State Management** | Riverpod 2.x (`StateNotifierProvider`) |
| **Design System** | PyroSync Clinical Dark, Acrylic Glassmorphic Blur, `#05070A` Obsidian Canvas |
| **DSP Engine** | Pure Dart Fast Fourier Transform, IIR Notch Filters, Waveform Epoch Averaging |
| **Windows APIs** | WinRT BluetoothLE, WMI `Win32_PnPEntity`, Datagram UDP Sockets |

---

## 📂 Repository Folder Structure

```text
pyrosync-clinical-workspace/
├── lib/
│   ├── main.dart                                # Entrypoint & ProviderScope initialization
│   ├── core_engines/                            # Decoupled engines (Auth, Patient, Session, Theme, Navigation)
│   ├── design_system/                           # Clinical color palette, typography, card elevation & themes
│   ├── device_connectivity/                     # Connection state machine, provider types, discovered device models
│   ├── hardware_integration/
│   │   ├── discovery/                           # Real Windows BLE, RFCOMM, Serial COM, and Network discovery engines
│   │   ├── driver_interface/                    # Handshake verification pipeline
│   │   ├── protocol/                            # HardwareProtocol interface & identification contracts
│   │   └── transports/                          # IHardwareTransport implementations (BLE, RFCOMM, Serial, Network)
│   ├── modules/
│   │   ├── dashboard/                           # Clinical metrics overview & quick navigation
│   │   ├── neurolab/                            # Virtual NeuroLab Simulation (Development Mode Only)
│   │   ├── recording/                           # Live multi-channel signal canvas & acquisition controls
│   │   ├── reports/                             # CDSS report builder & SHA-256 digital signature lock
│   │   ├── settings/                            # Comprehensive Windows Hardware Discovery & Transport UI
│   │   └── shell/                               # Desktop layout shell & header badge status
│   └── signal_engine/                           # Pure Dart 7-Stage Biomedical DSP pipeline
├── test/
│   └── device_connectivity_test.dart            # Automated test suite (13/13 hardware test scenarios)
├── windows/                                     # Native C++ Windows desktop runner project
├── pubspec.yaml                                 # Dependencies & asset manifests
└── README.md                                    # Repository documentation
```

---

## 🚀 Building & Running Locally

### Prerequisites
- **Operating System**: Windows 10/11 (x64)
- **SDK**: Flutter 3.44.9 Stable
- **C++ Build Toolchain**: Visual Studio 2022/2026 Community (`Desktop development with C++`)

### 1. Clone the Repository
```bash
git clone https://github.com/Barathwaj2006/pyrosync-clinical-workspace.git
cd pyrosync-clinical-workspace
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Run Automated Tests
```bash
flutter test
```

### 4. Build Windows Release Executable
```bash
flutter build windows --release
```
The compiled standalone binary will be generated at:
```text
build\windows\x64\runner\Release\pyrosync.exe
```

---

## 🧪 Testing Coverage & Status

The repository includes a comprehensive automated test suite in [`test/device_connectivity_test.dart`](test/device_connectivity_test.dart) covering all hardware connection scenarios:

- ✅ **Test 1**: Clean startup defaults strictly to `NO_DEVICE` (Disconnected).
- ✅ **Test 2**: Hardware scan enumerates real discoverable devices without mock injection.
- ✅ **Test 3**: Scanning without user selection retains `NO_DEVICE` state.
- ✅ **Test 4**: Connecting to unverified serial port (COM4) fails handshake verification.
- ✅ **Test 5**: Compatible BLE device undergoes two-phase `CONNECTING` → `VERIFYING` → `CONNECTED`.
- ✅ **Test 6**: Unknown BLE device without GATT EEG Service displays `"Bluetooth device detected but not recognized as a compatible EEG acquisition device."`
- ✅ **Test 7**: BLE disconnect immediately returns state to `NO_DEVICE`.
- ✅ **Test 8**: Compatible serial hardware transitions to `CONNECTED`.
- ✅ **Test 9**: Network UDP discovery handles subnet responses.
- ✅ **Test 10**: Network node failing identification returns `ERROR`.
- ✅ **Test 11**: Disconnected state blocks live acquisition controls.
- ✅ **Test 12**: Virtual NeuroLab Simulator is explicitly enabled and labelled `SIMULATED`.
- ✅ **Test 13**: Simulator disconnection cannot modify real hardware states.

---

## ⚖️ License

Distributed under the **MIT License**. See `LICENSE` for details.

---

## ⚠️ Medical Disclaimer

**PyroSync Clinical Workspace** is engineered as an advanced biomedical research platform, software prototype, and technology validator for visual electrophysiology and clinical neurodiagnostics. It is not currently cleared by the FDA or CE for autonomous medical diagnosis. All diagnostic findings must be reviewed and authenticated by a licensed attending physician.

<div align="center">
  <sub>Developed with precision by <b>Pyromatics Bio Solutions</b></sub>
</div>
