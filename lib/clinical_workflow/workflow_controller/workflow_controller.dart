import 'dart:async';
import '../workflow_models/workflow_models.dart';

class WorkflowState {
  final int currentStepIndex;
  final List<ClinicalWorkflowStep> steps;
  final WorkflowChecklist checklist;
  final List<WorkflowTimelineEvent> timeline;
  final bool isAutoSaved;

  WorkflowState({
    required this.currentStepIndex,
    required this.steps,
    required this.checklist,
    required this.timeline,
    required this.isAutoSaved,
  });

  ClinicalWorkflowStep get activeStep => steps[currentStepIndex];

  double get progressPercentage => (currentStepIndex + 1) / steps.length;
}

class WorkflowController {
  WorkflowState _state;

  WorkflowController()
      : _state = WorkflowState(
          currentStepIndex: 5, // Step 6: Start Recording active by default
          steps: [
            ClinicalWorkflowStep(stepNumber: 1, stepEnum: ClinicalStepEnum.selectPatient, title: 'Select Patient', description: 'Arthur Pendelton (P-10929)', isCompleted: true, isActive: false),
            ClinicalWorkflowStep(stepNumber: 2, stepEnum: ClinicalStepEnum.createSession, title: 'Create Session', description: 'SES-2026-0807', isCompleted: true, isActive: false),
            ClinicalWorkflowStep(stepNumber: 3, stepEnum: ClinicalStepEnum.selectProtocol, title: 'Select Protocol', description: 'VEP Pattern Reversal 1° Check (2500 Hz)', isCompleted: true, isActive: false),
            ClinicalWorkflowStep(stepNumber: 4, stepEnum: ClinicalStepEnum.connectDevice, title: 'Connect Device', description: 'NeuroLab Virtual Device (98.5% Battery)', isCompleted: true, isActive: false),
            ClinicalWorkflowStep(stepNumber: 5, stepEnum: ClinicalStepEnum.electrodeCheck, title: 'Electrode Check', description: 'Impedance < 3.2 kΩ Passed', isCompleted: true, isActive: false),
            ClinicalWorkflowStep(stepNumber: 6, stepEnum: ClinicalStepEnum.startRecording, title: 'Start Recording', description: 'Acquiring 100 Sweeps (Oz - Cz)', isCompleted: false, isActive: true),
            ClinicalWorkflowStep(stepNumber: 7, stepEnum: ClinicalStepEnum.signalProcessing, title: 'Signal Processing', description: '7-Stage DSP Pipeline & FFT', isCompleted: false, isActive: false),
            ClinicalWorkflowStep(stepNumber: 8, stepEnum: ClinicalStepEnum.clinicalReview, title: 'Clinical Review', description: 'CDSS Evidence & Latency Analysis', isCompleted: false, isActive: false),
            ClinicalWorkflowStep(stepNumber: 9, stepEnum: ClinicalStepEnum.generateReport, title: 'Generate Report', description: '4 Editable Templates', isCompleted: false, isActive: false),
            ClinicalWorkflowStep(stepNumber: 10, stepEnum: ClinicalStepEnum.doctorApproval, title: 'Doctor Approval', description: 'Digital SHA-256 Signature Sign-off', isCompleted: false, isActive: false),
            ClinicalWorkflowStep(stepNumber: 11, stepEnum: ClinicalStepEnum.archiveSession, title: 'Archive Session', description: 'Permanent Session Database Entry', isCompleted: false, isActive: false),
          ],
          checklist: WorkflowChecklist(
            patientSelected: true,
            sessionCreated: true,
            protocolSelected: true,
            deviceConnected: true,
            batterySufficient: true,
            signalStable: true,
            electrodeContactAcceptable: true,
            parametersLoaded: true,
          ),
          timeline: [
            WorkflowTimelineEvent(eventId: 'EVT-01', timeFormatted: '09:42', title: 'Arthur Pendelton (P-10929) Selected', category: 'Patient', timestamp: DateTime.now().subtract(const Duration(minutes: 16))),
            WorkflowTimelineEvent(eventId: 'EVT-02', timeFormatted: '09:43', title: 'Session SES-2026-0807 Created', category: 'Session', timestamp: DateTime.now().subtract(const Duration(minutes: 15))),
            WorkflowTimelineEvent(eventId: 'EVT-03', timeFormatted: '09:44', title: 'Protocol VEP Pattern Reversal Loaded', category: 'Protocol', timestamp: DateTime.now().subtract(const Duration(minutes: 14))),
            WorkflowTimelineEvent(eventId: 'EVT-04', timeFormatted: '09:45', title: 'NeuroLab Virtual Device Connected @ 2500 Hz', category: 'Device', timestamp: DateTime.now().subtract(const Duration(minutes: 13))),
            WorkflowTimelineEvent(eventId: 'EVT-05', timeFormatted: '09:46', title: 'Electrode Impedance Check Passed (< 3.2 kΩ)', category: 'Quality', timestamp: DateTime.now().subtract(const Duration(minutes: 12))),
            WorkflowTimelineEvent(eventId: 'EVT-06', timeFormatted: '09:47', title: 'Sweep Averaging Recording Started', category: 'Recording', timestamp: DateTime.now().subtract(const Duration(minutes: 11))),
          ],
          isAutoSaved: true,
        );

  WorkflowState get state => _state;

  void advanceToNextStep() {
    if (_state.currentStepIndex < _state.steps.length - 1) {
      final nextIdx = _state.currentStepIndex + 1;
      final updatedSteps = List<ClinicalWorkflowStep>.generate(_state.steps.length, (i) {
        if (i < nextIdx) {
          return _state.steps[i].copyWith(isCompleted: true, isActive: false);
        } else if (i == nextIdx) {
          return _state.steps[i].copyWith(isCompleted: false, isActive: true);
        } else {
          return _state.steps[i].copyWith(isCompleted: false, isActive: false);
        }
      });

      _state = WorkflowState(
        currentStepIndex: nextIdx,
        steps: updatedSteps,
        checklist: _state.checklist,
        timeline: _state.timeline,
        isAutoSaved: true,
      );
    }
  }

  void triggerAutomatedPipelineAfterRecording() {
    // Automatically triggers DSP Pipeline -> CDSS -> Draft Report
    advanceToNextStep(); // Step 7: Signal Processing
  }
}
