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
  });

  PatientRecord copyWith({
    String? fullName,
    String? primaryDiagnosis,
    String? doctorNotes,
    List<String>? medicalHistory,
  }) {
    return PatientRecord(
      id: id,
      mrn: mrn,
      fullName: fullName ?? this.fullName,
      dob: dob,
      gender: gender,
      primaryDiagnosis: primaryDiagnosis ?? this.primaryDiagnosis,
      medicalHistory: medicalHistory ?? this.medicalHistory,
      previousSessionIds: previousSessionIds,
      doctorNotes: doctorNotes ?? this.doctorNotes,
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
            patientList: [
              PatientRecord(
                id: 'PAT-10929',
                mrn: 'P-10929',
                fullName: 'Arthur Pendelton',
                dob: '1962-11-04',
                gender: 'Male',
                primaryDiagnosis: 'Optic Neuritis (OD)',
                medicalHistory: ['Optic neuritis (2025)', 'Hypertension'],
                previousSessionIds: ['SES-2025-1102', 'SES-2026-0210', 'SES-2026-0807'],
                doctorNotes: 'Patient presented with blurry vision in right eye. Baseline VEP demonstrated P100 delay (114.8 ms).',
              ),
              PatientRecord(
                id: 'PAT-10928',
                mrn: 'P-10928',
                fullName: 'Eleanor Vance',
                dob: '1984-03-12',
                gender: 'Female',
                primaryDiagnosis: 'Routine Screening',
                medicalHistory: ['No prior visual pathology'],
                previousSessionIds: ['SES-2026-0801'],
                doctorNotes: 'Normal P100 latency (101.4 ms) across both eyes.',
              ),
              PatientRecord(
                id: 'PAT-10930',
                mrn: 'P-10930',
                fullName: 'Clara Oswald',
                dob: '1991-07-22',
                gender: 'Female',
                primaryDiagnosis: 'Epilepsy Screening',
                medicalHistory: ['Absence seizure history'],
                previousSessionIds: ['SES-2026-0807'],
                doctorNotes: 'Routine 16-channel EEG requested.',
              ),
            ],
          ),
        ) {
    // Select first patient as active by default
    selectPatient(state.patientList.first.id);
  }

  void selectPatient(String patientId) {
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
    state = PatientState(
      patientList: [...state.patientList, patient],
      activePatient: patient,
      searchQuery: state.searchQuery,
    );
  }

  void updateDoctorNotes(String patientId, String notes) {
    final updatedList = state.patientList.map((p) {
      if (p.id == patientId) {
        return p.copyWith(doctorNotes: notes);
      }
      return p;
    }).toList();

    state = PatientState(
      patientList: updatedList,
      activePatient: state.activePatient?.id == patientId ? state.activePatient!.copyWith(doctorNotes: notes) : state.activePatient,
      searchQuery: state.searchQuery,
    );
  }
}
