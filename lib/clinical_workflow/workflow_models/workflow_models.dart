import 'dart:core';

enum ClinicalStepEnum {
  selectPatient,
  createSession,
  selectProtocol,
  connectDevice,
  electrodeCheck,
  startRecording,
  signalProcessing,
  clinicalReview,
  generateReport,
  doctorApproval,
  archiveSession,
}

class ClinicalWorkflowStep {
  final int stepNumber;
  final ClinicalStepEnum stepEnum;
  final String title;
  final String description;
  final bool isCompleted;
  final bool isActive;

  ClinicalWorkflowStep({
    required this.stepNumber,
    required this.stepEnum,
    required this.title,
    required this.description,
    required this.isCompleted,
    required this.isActive,
  });

  ClinicalWorkflowStep copyWith({
    bool? isCompleted,
    bool? isActive,
  }) {
    return ClinicalWorkflowStep(
      stepNumber: stepNumber,
      stepEnum: stepEnum,
      title: title,
      description: description,
      isCompleted: isCompleted ?? this.isCompleted,
      isActive: isActive ?? this.isActive,
    );
  }
}

class WorkflowChecklist {
  final bool patientSelected;
  final bool sessionCreated;
  final bool protocolSelected;
  final bool deviceConnected;
  final bool batterySufficient; // > 20%
  final bool signalStable;
  final bool electrodeContactAcceptable;
  final bool parametersLoaded;

  WorkflowChecklist({
    required this.patientSelected,
    required this.sessionCreated,
    required this.protocolSelected,
    required this.deviceConnected,
    required this.batterySufficient,
    required this.signalStable,
    required this.electrodeContactAcceptable,
    required this.parametersLoaded,
  });

  bool get isReadyToRecord =>
      patientSelected &&
      sessionCreated &&
      protocolSelected &&
      deviceConnected &&
      batterySufficient &&
      signalStable &&
      electrodeContactAcceptable &&
      parametersLoaded;

  String? get firstFailingReason {
    if (!patientSelected) return 'No active patient selected.';
    if (!sessionCreated) return 'Clinical session not initialized.';
    if (!protocolSelected) return 'Neuro protocol parameters not loaded.';
    if (!deviceConnected) return 'Acquisition device disconnected.';
    if (!batterySufficient) return 'Device battery is below 20%.';
    if (!signalStable) return 'Baseline signal instability detected.';
    if (!electrodeContactAcceptable) return 'Electrode skin contact impedance > 5.0 kΩ.';
    if (!parametersLoaded) return 'Sampling rate parameters missing.';
    return null;
  }
}

class WorkflowTimelineEvent {
  final String eventId;
  final String timeFormatted;
  final String title;
  final String category;
  final DateTime timestamp;

  WorkflowTimelineEvent({
    required this.eventId,
    required this.timeFormatted,
    required this.title,
    required this.category,
    required this.timestamp,
  });
}
