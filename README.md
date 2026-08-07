# PyroSync Clinical Workspace

![PyroSync Logo Placeholder](https://via.placeholder.com/150x150.png?text=PyroSync+Logo)  
![PyroSync Banner Placeholder](https://via.placeholder.com/1200x300.png?text=PyroSync+Clinical+Workspace+Banner)

> **Connecting Brain Signals to Clinical Intelligence**  
> Developed by **Pyromatics Bio Solutions**  

---

## 🔬 About Pyromatics Bio Solutions

**Pyromatics Bio Solutions** is a biomedical software platform developer focused on advancing clinical neurophysiology and visual electrophysiology. **PyroSync Clinical Workspace** is our commercial-grade neurodiagnostic desktop platform designed to assist clinicians, biomedical engineers, researchers, and students in acquiring, visualizing, filtering, analyzing, and generating explainable reports from Visual Evoked Potential (VEP) and Electroencephalogram (EEG) recordings.

---

## ⚡ Product Overview

PyroSync Clinical Workspace is an AI-assisted neurodiagnostic desktop application built for high-precision VEP and EEG workflows. 

### Key Features:
- **Ergonomic Fatigue-Reducing UI**: Built with Clinical Dark, Glass Mode (Acrylic 16px blur), and Clinical Light themes with a solid `#05070A` Obsidian Canvas for sub-pixel biosignal accuracy.
- **10 Decoupled Core Application Engines**: Hardware abstraction layer (`ISignalProvider`), user role permissions, patient records, session lifecycle state machine, and hidden developer diagnostics overlay (`CTRL + SHIFT + D`).
- **NeuroLab Virtual Simulation Laboratory**: Full hardware-free virtual acquisition device streaming 2500 Hz synthetic signals with live artifact generators (EOG blinks, EMG muscle, 50 Hz line noise, drift).
- **7-Stage Biomedical Signal Processing Pipeline**: Pure Dart processing engine performing DC offset removal, 50 Hz notch filtering, FFT/PSD band power, N75/P100/N145 peak extraction, and SNR quality evaluation.
- **Clinical Decision Support System (CDSS)**: Explainable workflow recommendation engine with 4 editable report templates (`Doctor`, `Patient`, `Research`, `Hospital`) and FDA 21 CFR Part 11 digital signature locking.

---

## 🏗️ Architecture Overview

```
                        ISignalProvider Interface
                                    │
           ┌────────────────────────┴────────────────────────┐
           ▼                                                 ▼
  NeuroLab Virtual Device                           Physical Hardware / Replay
  (Synthetic Signal Stream)                           (Bluetooth / USB Driver)
           │                                                 │
           └────────────────────────┬────────────────────────┘
                                    │
                                    ▼
                 7-Stage Biomedical Signal Engine
         (Preprocessing ➔ Filtering ➔ FFT ➔ VEP Peak ➔ SNR)
                                    │
                                    ▼
                  Clinical Decision Support System (CDSS)
          (Evidence Collector ➔ Rule Engine ➔ Explanation)
                                    │
                                    ▼
                Doctor Clinical Workspace & Report Builder
              (Editable Drafts ➔ SHA-256 Digital Lock)
```

---

## 🧰 Technology Stack

- **UI Framework**: Flutter Desktop Engine (Windows/macOS/Linux)
- **State Management**: Flutter Riverpod (`StateNotifierProvider`)
- **Typography & Aesthetics**: Google Fonts (`Inter`, `Roboto Mono`), Custom Design System
- **Signal Processing**: Pure Dart DSP (Fast Fourier Transform, Power Spectral Density, IIR Notch Filters, Waveform Averaging)
- **Architecture**: Modular Decoupled Clean Architecture

---

## 📁 Repository Folder Structure

```text
pyrosync-clinical-workspace/
├── pubspec.yaml                       # Flutter & Riverpod dependencies
├── README.md                          # Repository documentation
├── CHANGELOG.md                       # Version changelog
├── LICENSE                            # MIT License
├── preview/
│   └── index.html                     # Single-file interactive web app demonstration
└── lib/
    ├── main.dart                      # Application entrypoint & ProviderScope
    ├── design_system/                 # Colors, Typography, Spacing, Themes & Components
    ├── core_engines/                  # 10 Decoupled Core Application Engines
    ├── signal_engine/                 # Pure Dart 7-Stage Biomedical Signal Engine
    ├── clinical_decision_support/     # CDSS Engine, Rules, Evidence & Report Builder
    └── modules/                       # UI Workspaces & NeuroLab Virtual Simulation
```

---

## 🚀 Development Roadmap

### [v0.1.0] - Foundation Release (Completed)
- [x] Design System & Theme Engine (Dark, Glass, Light)
- [x] Full Desktop Layout Shell & 10 Module Screens
- [x] 10 Core Decoupled Application Engines
- [x] NeuroLab Virtual Simulation Laboratory & Artifact Generator
- [x] 7-Stage Pure Dart Biomedical Signal Processing Pipeline
- [x] Clinical Decision Support System (CDSS) & FDA 21 CFR Part 11 Digital Signatures

### [v0.2.0] - Future Hardware & AI Expansion (Planned)
- [ ] Bluetooth Low Energy (BLE) & USB Hardware Driver Bridges
- [ ] Multi-Channel EEG Topographic Brain Mapping
- [ ] HL7 / FHIR Electronic Health Record (EHR) Integration
- [ ] DICOM-Waveform Export Engine

---

## 🖼️ Application Screenshots

![Dashboard Overview](https://via.placeholder.com/800x450.png?text=PyroSync+Doctor+Dashboard)  
![Live VEP Acquisition](https://via.placeholder.com/800x450.png?text=Live+VEP+Acquisition+Canvas)  
![NeuroLab Simulator](https://via.placeholder.com/800x450.png?text=NeuroLab+Virtual+Laboratory)  
![CDSS Report Builder](https://via.placeholder.com/800x450.png?text=CDSS+Explainable+Report+Builder)

---

## ⚖️ License

Distributed under the **MIT License**. See `LICENSE` for details.

---

## ⚠️ Medical Disclaimer

**PyroSync Clinical Workspace** is currently developed as an educational software prototype, research platform, and technology validator for visual electrophysiology and clinical neurodiagnostics. It is not currently cleared by the FDA or CE for autonomous medical diagnosis. All clinical findings must be reviewed and signed off by a licensed attending physician.
