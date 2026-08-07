# Changelog — PyroSync Clinical Workspace

All notable changes to the **PyroSync Clinical Workspace** platform developed by **Pyromatics Bio Solutions** will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [v0.1.0] - 2026-08-07

### Added
- **Software Design System & Theme Engine**:
  - Implemented `PyroColors`, `PyroTypography`, `PyroSpacing`, and `PyroTheme`.
  - Built 3 clinical themes: **Clinical Dark Mode**, **Glass Mode (Acrylic 16px blur)**, and **Clinical Light Mode**.
  - Established solid `#05070A` Obsidian Canvas rule for zero-glare, high-contrast biosignal rendering.

- **Desktop Clinical Workspace Shell**:
  - Full Flutter Desktop Shell with top navigation, left sidebar rail, right clinical context inspector drawer, and bottom status bar.
  - Built 10 clinical modules (`Dashboard`, `Patients`, `Sessions`, `Recording`, `Analysis`, `AI Workspace`, `Reports`, `NeuroLab Sim`, `Settings`, `Help`).

- **Core Application Engines**:
  - Implemented 10 decoupled engines: `auth`, `patient`, `session`, `protocol`, `recording`, `signal_provider`, `navigation`, `notification`, `theme`, and hidden `developer` diagnostic overlay (`CTRL + SHIFT + D`).

- **NeuroLab Virtual Simulation Laboratory Subsystem**:
  - Hardware-decoupled virtual acquisition device running at 2500 Hz target rate.
  - Interactive artifact generator (EOG eye blinks, EMG muscle activity, 50 Hz line noise, baseline drift).
  - Educational scenario presets (*Normal VEP*, *Poor Electrode Contact*, *Blink Contamination*, *Resting Alpha EEG*).

- **Biomedical Signal Processing Pipeline**:
  - Built pure Dart 7-stage processing pipeline: `Preprocessing` ➔ `Filtering` (50Hz Notch + BP) ➔ `Artifact Detection` ➔ `FFT & PSD Analysis` ➔ `VEP Peak Extractor` (N75, P100, N145) ➔ `Quality Assessment` ➔ `PipelineResult`.

- **Clinical Decision Support System (CDSS)**:
  - Built explainable CDSS module with Evidence Collector, Biomedical Rule Engine, Explanation Engine ("Why?" modal), and 4 editable report templates (`Doctor Report`, `Patient Report`, `Research Report`, `Hospital Report`).
  - Implemented FDA 21 CFR Part 11 compliant Doctor Approval Workflow with SHA-256 digital signature locking (`SIG-SHA256`).

- **Device Connectivity Layer**:
  - Implemented hardware abstraction layer (`lib/device_connectivity/`) supporting 5 providers: `SimulationDeviceProvider` (functional NeuroLab link), `BluetoothMockProvider`, `WifiMockProvider`, `UsbMockProvider`, and `ReplayMockProvider`.
  - Added Device Manager, Device Registry, Connection State machine, and real-time Device Health Telemetry.

- **Clinical Workflow Integration Module**:
  - Implemented master 11-step Guided Workflow Controller (`lib/clinical_workflow/`) orchestrating Patient ➔ Session ➔ Protocol ➔ Device ➔ Recording ➔ DSP ➔ CDSS ➔ Report ➔ Doctor Sign-off ➔ Archival.
  - Built Pre-Recording Safety Checklist (verifies 8 critical conditions before enabling recording).
  - Built Automated Post-Recording Processing Pipeline.
  - Added Live Chronological Session Timeline Visualizer & Auto-Save Recovery Manager.
