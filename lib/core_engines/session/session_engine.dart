import 'package:flutter_riverpod/flutter_riverpod.dart';

enum SessionLifecycle {
  draft,
  preparing,
  ready,
  recording,
  paused,
  analyzing,
  doctorReview,
  completed,
  archived,
}

class ClinicalSession {
  final String sessionId;
  final String patientId;
  final String protocolId;
  final DateTime recordingDate;
  final Duration duration;
  final SessionLifecycle status;
  final String attendingDoctor;
  final double signalQualityScore;

  ClinicalSession({
    required this.sessionId,
    required this.patientId,
    required this.protocolId,
    required this.recordingDate,
    required this.duration,
    required this.status,
    required this.attendingDoctor,
    required this.signalQualityScore,
  });

  ClinicalSession copyWith({
    SessionLifecycle? status,
    Duration? duration,
    double? signalQualityScore,
  }) {
    return ClinicalSession(
      sessionId: sessionId,
      patientId: patientId,
      protocolId: protocolId,
      recordingDate: recordingDate,
      duration: duration ?? this.duration,
      status: status ?? this.status,
      attendingDoctor: attendingDoctor,
      signalQualityScore: signalQualityScore ?? this.signalQualityScore,
    );
  }
}

class SessionState {
  final List<ClinicalSession> sessions;
  final ClinicalSession? activeSession;

  SessionState({required this.sessions, this.activeSession});
}

final sessionEngineProvider = StateNotifierProvider<SessionEngineNotifier, SessionState>((ref) {
  return SessionEngineNotifier();
});

class SessionEngineNotifier extends StateNotifier<SessionState> {
  SessionEngineNotifier()
      : super(
          SessionState(
            sessions: [
              ClinicalSession(
                sessionId: 'SES-2026-0807',
                patientId: 'PAT-10929',
                protocolId: 'vep-pat-1deg',
                recordingDate: DateTime.now(),
                duration: const Duration(minutes: 12, seconds: 45),
                status: SessionLifecycle.analyzing,
                attendingDoctor: 'Dr. Elena Vance',
                signalQualityScore: 94.5,
              ),
              ClinicalSession(
                sessionId: 'SES-2026-0801',
                patientId: 'PAT-10928',
                protocolId: 'vep-pat-1deg',
                recordingDate: DateTime.now().subtract(const Duration(days: 6)),
                duration: const Duration(minutes: 10),
                status: SessionLifecycle.completed,
                attendingDoctor: 'Dr. Elena Vance',
                signalQualityScore: 98.2,
              ),
            ],
          ),
        ) {
    if (state.sessions.isNotEmpty) {
      selectSession(state.sessions.first.sessionId);
    }
  }

  void selectSession(String sessionId) {
    final active = state.sessions.firstWhere((s) => s.sessionId == sessionId, orElse: () => state.sessions.first);
    state = SessionState(sessions: state.sessions, activeSession: active);
  }

  void transitionLifecycle(SessionLifecycle newLifecycle) {
    if (state.activeSession == null) return;
    final updatedSession = state.activeSession!.copyWith(status: newLifecycle);
    final updatedList = state.sessions.map((s) => s.sessionId == updatedSession.sessionId ? updatedSession : s).toList();

    state = SessionState(sessions: updatedList, activeSession: updatedSession);
  }
}
