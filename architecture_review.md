# PyroSync Clinical Workspace — Comprehensive Architecture Review

> **Company**: Pyromatics Bio Solutions  
> **Application**: PyroSync Clinical Workspace  
> **Tagline**: Connecting Brain Signals to Clinical Intelligence  
> **Sprint**: System Integration & Production Readiness (`v0.1.0`)  

---

## 1. Architectural Philosophy & Clean Design

**PyroSync Clinical Workspace** is engineered using a modular, decoupled, clean architecture built on Flutter Desktop and Riverpod state management.

The software architecture is strictly divided into 15 independent, non-overlapping subsystems, ensuring complete separation of concerns between UI representation, business logic state machine, signal acquisition drivers, DSP signal processing, clinical decision support rules, and developer diagnostics.

```
                      ┌────────────────────────────────────────┐
                      │    ISignalProvider Driver Interface    │
                      └───────────────────┬────────────────────┘
                                          │
                  ┌───────────────────────┴───────────────────────┐
                  ▼                                               ▼
      NeuroLab Virtual Device                          Hardware Integration Layer
     (2500 Hz Synthetic Stream)                         (IHardwareDriver BLE/USB)
                  │                                               │
                  └───────────────────────┬───────────────────────┘
                                          │
                                          ▼
                      7-Stage Biomedical Signal Engine
             (Preprocessing ➔ Filtering ➔ FFT ➔ VEP Peak ➔ SNR)
                                          │
                                          ▼
                             PipelineResult Data Contract
                                          │
                 ┌────────────────────────┴────────────────────────┐
                 ▼                                                 ▼
 Professional Visualization Engine                    Clinical Decision Support (CDSS)
(60 FPS Obsidian Canvas & 2D Scalp)                 (Evidence Collector & Rule Engine)
                                                                   │
                                                                   ▼
                                                       Editable Report Builder
                                                    (4 Templates & SHA-256 Lock)
```

---

## 2. Comprehensive Subsystem Registry

| # | Subsystem Name | Directory Path | Core Responsibility |
| :-: | :--- | :--- | :--- |
| **1** | **Design System** | `lib/design_system/` | Theme engine (Dark, Glass 16px, Light) & `#05070A` Obsidian Canvas. |
| **2** | **Desktop Layout Shell** | `lib/modules/shell/` | Ergonomic desktop layout, top bar, sidebar rail & context inspector drawer. |
| **3** | **Core Application Engines** | `lib/core_engines/` | 10 decoupled engines (`auth`, `patient`, `session`, `protocol`, `recording`, etc.). |
| **4** | **NeuroLab Virtual Simulator** | `lib/modules/neurolab/` | Hardware-free virtual laboratory with 2500 Hz stream & artifact generator. |
| **5** | **Biomedical Signal Engine** | `lib/signal_engine/` | Pure Dart 7-stage DSP pipeline (50Hz notch, FFT, VEP peak, SNR dB). |
| **6** | **Clinical Decision Support** | `lib/clinical_decision_support/` | Explainable rule engine, evidence collector & FDA 21 CFR Part 11 SHA-256 lock. |
| **7** | **Device Connectivity Layer** | `lib/device_connectivity/` | Hardware abstraction layer supporting 5 provider types. |
| **8** | **Clinical Workflow Module** | `lib/clinical_workflow/` | Guided 11-step clinical stepper & 8-point pre-recording safety checklist. |
| **9** | **Biomedical Visualization** | `lib/visualization_engine/` | 60 FPS CustomPainter waveform canvas, dual cursors & 2D scalp map. |
| **10** | **Hardware Integration** | `lib/hardware_integration/` | Abstract `IHardwareDriver`, packet parser, ring buffer & test harness. |
| **11** | **Validation Framework** | `lib/validation_framework/` | 48 automated unit tests, 2500 Hz benchmarks & PDF/JSON report exporter. |
| **12** | **Developer Tools & Console** | `lib/developer_tools/` | Hidden engineering console (`CTRL+SHIFT+D`), live logs & feature flags. |
