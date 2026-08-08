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
          currentStepIndex: 0,
          steps: [
            ClinicalWorkflowStep(stepNumber: 1, stepEnum: ClinicalStepEnum.selectPatient, title: 'Select Patient', description: 'Select or register patient profile', isCompleted: false, isActive: true),
            ClinicalWorkflowStep(stepNumber: 2, stepEnum: ClinicalStepEnum.createSession, title: 'Create Session', description: 'Initialize examination session', isCompleted: false, isActive: false),
            ClinicalWorkflowStep(stepNumber: 3, stepEnum: ClinicalStepEnum.selectProtocol, title: 'Select Protocol', description: 'Select acquisition protocol', isCompleted: false, isActive: false),
            ClinicalWorkflowStep(stepNumber: 4, stepEnum: ClinicalStepEnum.connectDevice, title: 'Connect Device', description: 'Connect neuro bio-amplifier', isCompleted: false, isActive: false),
            ClinicalWorkflowStep(stepNumber: 5, stepEnum: ClinicalStepEnum.electrodeCheck, title: 'Electrode Check', description: 'Verify contact impedance', isCompleted: false, isActive: false),
            ClinicalWorkflowStep(stepNumber: 6, stepEnum: ClinicalStepEnum.startRecording, title: 'Start Recording', description: 'Acquire biosignals', isCompleted: false, isActive: false),
            ClinicalWorkflowStep(stepNumber: 7, stepEnum: ClinicalStepEnum.signalProcessing, title: 'Signal Processing', description: 'DSP filtering & FFT', isCompleted: false, isActive: false),
            ClinicalWorkflowStep(stepNumber: 8, stepEnum: ClinicalStepEnum.clinicalReview, title: 'Clinical Review', description: 'VEP peak extraction', isCompleted: false, isActive: false),
            ClinicalWorkflowStep(stepNumber: 9, stepEnum: ClinicalStepEnum.generateReport, title: 'Generate Report', description: 'Report template generation', isCompleted: false, isActive: false),
            ClinicalWorkflowStep(stepNumber: 10, stepEnum: ClinicalStepEnum.doctorApproval, title: 'Doctor Approval', description: 'Electronic signature sign-off', isCompleted: false, isActive: false),
            ClinicalWorkflowStep(stepNumber: 11, stepEnum: ClinicalStepEnum.archiveSession, title: 'Archive Session', description: 'Session database archiving', isCompleted: false, isActive: false),
          ],
          checklist: WorkflowChecklist(
            patientSelected: false,
            sessionCreated: false,
            protocolSelected: false,
            deviceConnected: false,
            batterySufficient: false,
            signalStable: false,
            electrodeContactAcceptable: false,
            parametersLoaded: false,
          ),
          timeline: const [],
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
    advanceToNextStep();
  }
}
