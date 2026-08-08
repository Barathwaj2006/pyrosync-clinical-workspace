import 'package:flutter_riverpod/flutter_riverpod.dart';

enum RecordingWorkflowState {
  idle,
  preparing,
  recording,
  paused,
  stopped,
  saved,
}

class RecordingState {
  final RecordingWorkflowState workflowState;
  final int sweepsAcquired;
  final int targetSweeps;
  final int rejectedSweeps;
  final Duration elapsedDuration;
  final String activeEye;

  RecordingState({
    required this.workflowState,
    required this.sweepsAcquired,
    required this.targetSweeps,
    required this.rejectedSweeps,
    required this.elapsedDuration,
    required this.activeEye,
  });

  RecordingState copyWith({
    RecordingWorkflowState? workflowState,
    int? sweepsAcquired,
    int? rejectedSweeps,
    Duration? elapsedDuration,
    String? activeEye,
  }) {
    return RecordingState(
      workflowState: workflowState ?? this.workflowState,
      sweepsAcquired: sweepsAcquired ?? this.sweepsAcquired,
      targetSweeps: targetSweeps,
      rejectedSweeps: rejectedSweeps ?? this.rejectedSweeps,
      elapsedDuration: elapsedDuration ?? this.elapsedDuration,
      activeEye: activeEye ?? this.activeEye,
    );
  }
}

final recordingEngineProvider = StateNotifierProvider<RecordingEngineNotifier, RecordingState>((ref) {
  return RecordingEngineNotifier();
});

class RecordingEngineNotifier extends StateNotifier<RecordingState> {
  RecordingEngineNotifier()
      : super(
          RecordingState(
            workflowState: RecordingWorkflowState.idle,
            sweepsAcquired: 64,
            targetSweeps: 100,
            rejectedSweeps: 2,
            elapsedDuration: const Duration(minutes: 2, seconds: 15),
            activeEye: 'OD (Right Eye)',
          ),
        );

  void startRecording() {
    state = state.copyWith(workflowState: RecordingWorkflowState.recording);
  }

  void pauseRecording() {
    state = state.copyWith(workflowState: RecordingWorkflowState.paused);
  }

  void stopRecording() {
    state = state.copyWith(workflowState: RecordingWorkflowState.stopped);
  }

  void saveRecording() {
    state = state.copyWith(workflowState: RecordingWorkflowState.saved);
  }

  void setActiveEye(String eye) {
    state = state.copyWith(activeEye: eye);
  }
}
