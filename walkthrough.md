# PyroSync Clinical Decision Support System (CDSS) — Final Deliverable Walkthrough

> **Product**: PyroSync Clinical Decision Support System (CDSS)  
> **Company**: Pyromatics Bio Solutions  
> **Tagline**: Connecting Brain Signals to Clinical Intelligence  
> **Core Policy**: AI is an assistant — NOT a diagnostician. The clinician maintains final authority.  

---

## 1. Executive Summary of CDSS Architecture

As Lead Biomedical Software Engineer & Chief Architect at **Pyromatics Bio Solutions**, I have designed and implemented the **Clinical Decision Support System (CDSS)** for **PyroSync Clinical Workspace**.

The CDSS ingests structured measurement objects (`PipelineResult`) directly from the Biomedical Signal Processing Engine (never raw signal buffers) and converts them into **explainable clinical evidence**, **workflow recommendations**, **confidence scores**, **4 editable report templates**, and an **FDA-compliant Doctor Approval Workflow**.

---

## 2. CDSS Workflow Architecture

```
PipelineResult (from Biomedical Signal Processing Engine)
       │
       ▼
┌──────────────────────────────────────────────────────────┐
│ STAGE 1: EVIDENCE COLLECTION (evidence_collector.dart)   │
│ • Harvests P100/N75/N145 latencies, amplitudes & SNR     │
│ • Attaches unit, confidence score (0-1.0), & timestamp   │
└──────────────────────────┬───────────────────────────────┘
                           │
                           ▼
┌──────────────────────────────────────────────────────────┐
│ STAGE 2: BIOMEDICAL RULE EVALUATION (biomedical_rule.dart)│
│ • Evaluates SNR, artifact burden & latency bounds        │
│ • Returns PASS, WARNING, or FAIL with suggested actions  │
│ • STRICT RULE: Generates workflow suggestions ONLY.      │
│   NEVER outputs clinical diagnosis.                      │
└──────────────────────────┬───────────────────────────────┘
                           │
                           ▼
┌──────────────────────────────────────────────────────────┐
│ STAGE 3: EXPLANATION ENGINE (explanation_engine.dart)    │
│ • Attaches "Why?", generating module, supporting metrics │
│   & triggered thresholds to every recommendation          │
│ • Clickable "🔍 EXPLAIN" modal in Doctor Workspace UI     │
└──────────────────────────┬───────────────────────────────┘
                           │
                           ▼
┌──────────────────────────────────────────────────────────┐
│ STAGE 4: REPORT BUILDER (report_generator.dart)          │
│ • Doctor Report (Technical measurements, graphs, notes)  │
│ • Patient Report (Plain language, no medical jargon)     │
│ • Research Report (Anonymized tabular metrics CSV/JSON)  │
│ • Hospital Report (Institution branding & summary)       │
└──────────────────────────┬───────────────────────────────┘
                           │
                           ▼
┌──────────────────────────────────────────────────────────┐
│ STAGE 5: DOCTOR REVIEW WORKFLOW (doctor_review_engine)   │
│ • Draft ➔ Under Review ➔ Doctor Edit ➔ Doctor Sign-off    │
│ • Cryptographic SHA-256 digital signature stamp          │
│ • Report becomes officially locked upon approval         │
└──────────────────────────┬───────────────────────────────┘
```

---

## 3. Modular File Hierarchy (`lib/clinical_decision_support/`)

```text
lib/clinical_decision_support/
├── models/
│   └── cdss_models.dart               # Data models: ClinicalEvidence, Recommendation, DraftReport, DoctorReview, AuditRecord
├── rule_engine/
│   └── biomedical_rule_engine.dart    # Configurable rules returning PASS, WARNING, FAIL (No diagnosis)
├── evidence_engine/
│   └── evidence_collector.dart        # Harvests structured metrics with confidence & source tags
├── report_engine/
│   └── report_generator.dart          # Generates Doctor, Patient, Research & Hospital report templates
├── review_engine/
│   └── doctor_review_engine.dart      # Doctor Review State Machine & Cryptographic Digital Signatures
└── audit_engine/
    └── cdss_audit_engine.dart         # Tracks 21 CFR Part 11 audit records & edit history
```

---

## 4. Deliverable File Links

| Subsystem File | Location Link |
| :--- | :--- |
| **CDSS Data Models** | [cdss_models.dart](file:///C:/Users/barat/OneDrive/Documents/Pyromatics%20Bio-Solution/lib/clinical_decision_support/models/cdss_models.dart) |
| **Evidence Collector** | [evidence_collector.dart](file:///C:/Users/barat/OneDrive/Documents/Pyromatics%20Bio-Solution/lib/clinical_decision_support/evidence_engine/evidence_collector.dart) |
| **Biomedical Rule Engine** | [biomedical_rule_engine.dart](file:///C:/Users/barat/OneDrive/Documents/Pyromatics%20Bio-Solution/lib/clinical_decision_support/rule_engine/biomedical_rule_engine.dart) |
| **Report Generator** | [report_generator.dart](file:///C:/Users/barat/OneDrive/Documents/Pyromatics%20Bio-Solution/lib/clinical_decision_support/report_engine/report_generator.dart) |
| **Doctor Review Engine** | [doctor_review_engine.dart](file:///C:/Users/barat/OneDrive/Documents/Pyromatics%20Bio-Solution/lib/clinical_decision_support/review_engine/doctor_review_engine.dart) |
| **Audit Engine** | [cdss_audit_engine.dart](file:///C:/Users/barat/OneDrive/Documents/Pyromatics%20Bio-Solution/lib/clinical_decision_support/audit_engine/cdss_audit_engine.dart) |
| **Interactive Web Application** | [preview/index.html](file:///C:/Users/barat/OneDrive/Documents/Pyromatics%20Bio-Solution/preview/index.html) *(Click `🧠 AI CDSS Workspace`)* |

---

### Demonstration
You can double-click **[preview/index.html](file:///C:/Users/barat/OneDrive/Documents/Pyromatics%20Bio-Solution/preview/index.html)** in any browser, click **`🧠 AI CDSS Workspace`** in the left sidebar, click **`🔍 EXPLAIN`** on any recommendation card to view triggered thresholds, switch between 4 report templates, edit notes, and click **`✍️ SIGN & LOCK REPORT`**!
