# PyroSync Clinical Workspace — Integration & Data Flow Report

> **Company**: Pyromatics Bio Solutions  
> **Application**: PyroSync Clinical Workspace  
> **Tagline**: Connecting Brain Signals to Clinical Intelligence  
> **Status**: Verified End-to-End System Integration (`v0.1.0`)  

---

## 1. Verified End-to-End Clinical Data Flow

Every subsystem in **PyroSync Clinical Workspace** is fully integrated. No isolated modules, orphaned state objects, or duplicate data models exist.

```
[Step 1: Patient Selection]
PatientRecord (Arthur Pendelton, P-10929) -> PatientEngineNotifier
   ↓
[Step 2: Session Creation]
ClinicalSession (SES-2026-0807) initialized -> SessionLifecycle State Machine
   ↓
[Step 3: Protocol Loading]
NeuroProtocol (VEP Pattern Reversal 1° Check @ 2500 Hz) -> ProtocolEngine
   ↓
[Step 4: Device Connection]
ISignalProvider -> DeviceManager -> SimulationDeviceProvider (NeuroLab @ 2500 Hz)
   ↓
[Step 5: Pre-Recording Safety Checklist]
WorkflowChecklist (8/8 Checks Passed) -> Start Recording Enabled
   ↓
[Step 6: Biosignal Acquisition]
Stream<SignalChunk> (2500 Hz, 8 Channels: Oz, Cz, O1, O2, Fz, Pz, T3, T4)
   ↓
[Step 7: 7-Stage DSP Pipeline Execution]
BiomedicalSignalPipeline -> SignalPreprocessor -> FilterPipeline (50Hz Notch) -> FFT -> VEP Peak Extractor -> PipelineResult
   ↓
[Step 8: Real-Time Visualization Update]
PipelineResult -> MultiChannelWaveformViewer (60 FPS Obsidian Canvas) + BrainMap2dHeatmap (10-20 Scalp)
   ↓
[Step 9: Clinical Decision Support Evaluation]
PipelineResult -> EvidenceCollector -> BiomedicalRuleEngine -> List<Recommendation> & ClinicalEvidence
   ↓
[Step 10: Draft Report Generation]
Recommendations & Evidence -> ReportGenerator -> DraftReport (Doctor, Patient, Research, Hospital Templates)
   ↓
[Step 11: Doctor Approval & SHA-256 Digital Sign-off]
DraftReport -> DoctorReviewEngine -> FinalReport + DigitalSignature ("SIG-SHA256-locked")
   ↓
[Step 12: Session Archival]
FinalReport & PipelineResult -> SessionArchivalEngine (Permanent Encrypted Database Entry)
```

---

## 2. Zero-Duplication & Model Unification Matrix

- **Unified Signal Interface**: Single abstract `ISignalProvider` (`lib/core_engines/signal_provider/signal_provider_interface.dart`) consumed by NeuroLab, Device Connectivity, and Hardware Integration Framework.
- **Unified Pipeline Contract**: Single immutable `PipelineResult` (`lib/signal_engine/models/signal_models.dart`) consumed by Visualization Engine, CDSS, and Report Generator.
- **Unified CDSS Data Contract**: Single `ClinicalEvidence` & `Recommendation` model (`lib/clinical_decision_support/models/cdss_models.dart`) consumed by Rule Engine, Explanation Modal, and Doctor Approval Panel.
