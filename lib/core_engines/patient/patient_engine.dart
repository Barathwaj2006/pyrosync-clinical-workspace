import 'package:flutter_riverpod/flutter_riverpod.dart';

class PatientRecord {
  final String id;
  final String mrn;
  final String fullName;
  final String dob;
  final String gender;
  final String primaryDiagnosis;
  final List<String> medicalHistory;
  final List<String> previousSessionIds;
  final String doctorNotes;
  final DateTime createdAt;

  PatientRecord({
    required this.id,
    required this.mrn,
    required this.fullName,
    required this.dob,
    required this.gender,
    required this.primaryDiagnosis,
    required this.medicalHistory,
    required this.previousSessionIds,
    required this.doctorNotes,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  PatientRecord copyWith({
    String? fullName,
    String? mrn,
    String? dob,
    String? gender,
    String? primaryDiagnosis,
    String? doctorNotes,
    List<String>? medicalHistory,
    List<String>? previousSessionIds,
  }) {
    return PatientRecord(
      id: id,
      mrn: mrn ?? this.mrn,
      fullName: fullName ?? this.fullName,
      dob: dob ?? this.dob,
      gender: gender ?? this.gender,
      primaryDiagnosis: primaryDiagnosis ?? this.primaryDiagnosis,
      medicalHistory: medicalHistory ?? this.medicalHistory,
      previousSessionIds: previousSessionIds ?? this.previousSessionIds,
      doctorNotes: doctorNotes ?? this.doctorNotes,
      createdAt: createdAt,
    );
  }
}

class PatientState {
  final List<PatientRecord> patientList;
  final PatientRecord? activePatient;
  final String searchQuery;

  PatientState({
    required this.patientList,
    this.activePatient,
    this.searchQuery = '',
  });

  List<PatientRecord> get filteredPatients {
    if (searchQuery.isEmpty) return patientList;
    final q = searchQuery.toLowerCase();
    return patientList.where((p) => p.fullName.toLowerCase().contains(q) || p.mrn.toLowerCase().contains(q)).toList();
  }
}

final patientEngineProvider = StateNotifierProvider<PatientEngineNotifier, PatientState>((ref) {
  return PatientEngineNotifier();
});

class PatientEngineNotifier extends StateNotifier<PatientState> {
  PatientEngineNotifier()
      : super(
          PatientState(
            patientList: const [],
            activePatient: null,
          ),
        );

  void selectPatient(String? patientId) {
    if (patientId == null || state.patientList.isEmpty) {
      state = PatientState(
        patientList: state.patientList,
        activePatient: null,
        searchQuery: state.searchQuery,
      );
      return;
    }
    final found = state.patientList.firstWhere((p) => p.id == patientId, orElse: () => state.patientList.first);
    state = PatientState(
      patientList: state.patientList,
      activePatient: found,
      searchQuery: state.searchQuery,
    );
  }

  void setSearchQuery(String query) {
    state = PatientState(
      patientList: state.patientList,
      activePatient: state.activePatient,
      searchQuery: query,
    );
  }

  void addPatient(PatientRecord patient) {
    final newList = [...state.patientList, patient];
    state = PatientState(
      patientList: newList,
      activePatient: patient,
      searchQuery: state.searchQuery,
    );
  }

  void updatePatient(PatientRecord updated) {
    final updatedList = state.patientList.map((p) => p.id == updated.id ? updated : p).toList();
    state = PatientState(
      patientList: updatedList,
      activePatient: state.activePatient?.id == updated.id ? updated : state.activePatient,
      searchQuery: state.searchQuery,
    );
  }

  void deletePatient(String patientId) {
    final updatedList = state.patientList.where((p) => p.id != patientId).toList();
    final newActive = state.activePatient?.id == patientId
        ? (updatedList.isNotEmpty ? updatedList.first : null)
        : state.activePatient;
    state = PatientState(
      patientList: updatedList,
      activePatient: newActive,
      searchQuery: state.searchQuery,
    );
  }
}
