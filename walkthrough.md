# PyroSync Device Connectivity Layer — Final Deliverable Walkthrough

> **Product**: PyroSync Device Connectivity Layer  
> **Company**: Pyromatics Bio Solutions  
> **Tagline**: Connecting Brain Signals to Clinical Intelligence  
> **Core Policy**: Hardware-decoupled abstraction layer (`ISignalProvider`).  

---

## 1. Executive Summary of Device Connectivity Layer

As Lead Biomedical Software Engineer & Chief Architect at **Pyromatics Bio Solutions**, I have completed the **Device Connectivity Layer** (`lib/device_connectivity/`) for **PyroSync Clinical Workspace**.

This layer provides a complete hardware abstraction layer. The core application logic **never knows** whether signals originate from NeuroLab Virtual Simulation, Bluetooth, Wi-Fi, USB, or EDF file replay, because all acquisition drivers communicate through the abstract `ISignalProvider` interface.

---

## 2. Architecture Overview

```
                      ISignalProvider Abstraction Interface
                                        │
    ┌────────────────┬──────────────────┼──────────────────┬────────────────┐
    ▼                ▼                  ▼                  ▼                ▼
Simulation     Bluetooth (BLE)     Wi-Fi TCP/IP      USB Serial        EDF Replay
Provider          Mock Driver       Mock Driver      Mock Driver       Mock Driver
 (Active)         (Mocked)           (Mocked)         (Mocked)          (Mocked)
    │
    ▼
NeuroLab Virtual Device @ 2500 Hz
```

---

## 3. Modular File Structure (`lib/device_connectivity/`)

```text
lib/device_connectivity/
├── models/
│   └── device_models.dart             # DeviceInfo, DeviceConnectionState, DeviceDiagnostics, ProviderType
├── device_manager/
│   └── device_manager.dart            # Provider selector, device health telemetry & connection controls
├── connection_manager/
│   └── connection_manager.dart        # Connection state machine (Disconnected -> Scanning -> Connecting -> Connected)
├── device_registry/
│   └── device_registry.dart           # Discovered device registry & active device selection
├── providers/
│   ├── simulation/
│   │   └── simulation_device_provider.dart # Fully functional NeuroLab link
│   ├── bluetooth/
│   │   └── bluetooth_mock_provider.dart    # Mock BLE provider implementing ISignalProvider
│   ├── wifi/
│   ├── usb/
│   └── replay/
└── diagnostics/
    └── device_diagnostics_engine.dart # Tracks latency, packet loss, frames received & buffer size
```

---

## 4. Deliverable File Links

| Component | Saved Location Link |
| :--- | :--- |
| **Device Models** | [device_models.dart](file:///C:/Users/barat/OneDrive/Documents/Pyromatics%20Bio-Solution/lib/device_connectivity/models/device_models.dart) |
| **Simulation Device Provider** | [simulation_device_provider.dart](file:///C:/Users/barat/OneDrive/Documents/Pyromatics%20Bio-Solution/lib/device_connectivity/providers/simulation/simulation_device_provider.dart) |
| **Bluetooth Mock Provider** | [bluetooth_mock_provider.dart](file:///C:/Users/barat/OneDrive/Documents/Pyromatics%20Bio-Solution/lib/device_connectivity/providers/bluetooth/bluetooth_mock_provider.dart) |
| **Device Manager** | [device_manager.dart](file:///C:/Users/barat/OneDrive/Documents/Pyromatics%20Bio-Solution/lib/device_connectivity/device_manager/device_manager.dart) |
| **Interactive Web Preview** | [preview/index.html](file:///C:/Users/barat/OneDrive/Documents/Pyromatics%20Bio-Solution/preview/index.html) *(Click `📡 Device & Sim`)* |
