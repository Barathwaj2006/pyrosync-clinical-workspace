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
  final String patientName;
  final String protocolId;
  final String protocolName;
  final DateTime recordingDate;
  final Duration duration;
  final SessionLifecycle status;
  final String attendingDoctor;
  final double signalQualityScore;
  final List<double>? acquiredWaveform;

  ClinicalSession({
    required this.sessionId,
    required this.patientId,
    required this.patientName,
    required this.protocolId,
    required this.protocolName,
    required this.recordingDate,
    required this.duration,
    required this.status,
    required this.attendingDoctor,
    required this.signalQualityScore,
    this.acquiredWaveform,
  });

  ClinicalSession copyWith({
    SessionLifecycle? status,
    Duration? duration,
    double? signalQualityScore,
    List<double>? acquiredWaveform,
  }) {
    return ClinicalSession(
      sessionId: sessionId,
      patientId: patientId,
      patientName: patientName,
      protocolId: protocolId,
      protocolName: protocolName,
      recordingDate: recordingDate,
      duration: duration ?? this.duration,
      status: status ?? this.status,
      attendingDoctor: attendingDoctor,
      signalQualityScore: signalQualityScore ?? this.signalQualityScore,
      acquiredWaveform: acquiredWaveform ?? this.acquiredWaveform,
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
            sessions: const [],
            activeSession: null,
          ),
        );

  void createSession({
    required String patientId,
    required String patientName,
    required String protocolId,
    required String protocolName,
    required String attendingDoctor,
  }) {
    final newSession = ClinicalSession(
      sessionId: 'SES-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
      patientId: patientId,
      patientName: patientName,
      protocolId: protocolId,
      protocolName: protocolName,
      recordingDate: DateTime.now(),
      duration: Duration.zero,
      status: SessionLifecycle.preparing,
      attendingDoctor: attendingDoctor,
      signalQualityScore: 0.0,
    );

    state = SessionState(
      sessions: [...state.sessions, newSession],
      activeSession: newSession,
    );
  }

  void selectSession(String? sessionId) {
    if (sessionId == null || state.sessions.isEmpty) {
      state = SessionState(sessions: state.sessions, activeSession: null);
      return;
    }
    final active = state.sessions.firstWhere((s) => s.sessionId == sessionId, orElse: () => state.sessions.first);
    state = SessionState(sessions: state.sessions, activeSession: active);
  }

  void transitionLifecycle(SessionLifecycle newLifecycle) {
    if (state.activeSession == null) return;
    final updatedSession = state.activeSession!.copyWith(status: newLifecycle);
    final updatedList = state.sessions.map((s) => s.sessionId == updatedSession.sessionId ? updatedSession : s).toList();

    state = SessionState(sessions: updatedList, activeSession: updatedSession);
  }

  void updateSessionData({Duration? duration, double? qualityScore, List<double>? waveform}) {
    if (state.activeSession == null) return;
    final updatedSession = state.activeSession!.copyWith(
      duration: duration,
      signalQualityScore: qualityScore,
      acquiredWaveform: waveform,
    );
    final updatedList = state.sessions.map((s) => s.sessionId == updatedSession.sessionId ? updatedSession : s).toList();

    state = SessionState(sessions: updatedList, activeSession: updatedSession);
  }
}
