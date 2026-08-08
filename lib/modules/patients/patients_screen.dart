import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../design_system/components/pyro_card.dart';
import '../../design_system/typography/pyro_typography.dart';
import '../../design_system/colors/pyro_colors.dart';
import '../../core_engines/patient/patient_engine.dart';
import '../../core_engines/session/session_engine.dart';
import '../../navigation/navigation_provider.dart';

class PatientsScreen extends ConsumerWidget {
  const PatientsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patientState = ref.watch(patientEngineProvider);
    final patientNotifier = ref.read(patientEngineProvider.notifier);
    final filtered = patientState.filteredPatients;
    final active = patientState.activePatient;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('PATIENT DIRECTORY & CLINICAL RECORDS', style: PyroTypography.heading1(true)),
                  Text('Manage patient profiles, clinical history, and session associations.', style: PyroTypography.body(true).copyWith(color: const Color(0xFF94A3B8))),
                ],
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: PyroColors.medicalBlue,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                icon: const Icon(Icons.person_add, size: 18),
                label: const Text('Register Patient', style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () {
                  showDialog(context: context, builder: (context) => const RegisterPatientDialog());
                },
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Search Bar
          TextField(
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search patient name, MRN, or diagnosis...',
              hintStyle: const TextStyle(color: Color(0xFF64748B)),
              prefixIcon: const Icon(Icons.search, color: PyroColors.medicalBlue),
              filled: true,
              fillColor: const Color(0xFF121620),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF1E293B))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF1E293B))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: PyroColors.medicalBlue)),
            ),
            onChanged: (val) => patientNotifier.setSearchQuery(val),
          ),
          const SizedBox(height: 20),

          // Main Directory Area
          Expanded(
            child: patientState.patientList.isEmpty
                ? _buildEmptyPatientState(context)
                : Row(
                    children: [
                      // Patient List Column
                      Expanded(
                        flex: 1,
                        child: PyroCard(
                          child: ListView.builder(
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final p = filtered[index];
                              final isSelected = active?.id == p.id;
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: isSelected ? PyroColors.medicalBlue.withOpacity(0.15) : const Color(0xFF121620),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: isSelected ? PyroColors.medicalBlue : const Color(0xFF1E293B)),
                                ),
                                child: ListTile(
                                  title: Text(p.fullName, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? PyroColors.medicalBlue : Colors.white)),
                                  subtitle: Text('MRN: ${p.mrn} • ${p.gender} • DOB: ${p.dob}', style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                                  onTap: () => patientNotifier.selectPatient(p.id),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Patient Details Column
                      Expanded(
                        flex: 2,
                        child: active == null
                            ? const PyroCard(child: Center(child: Text('Select a patient from the list to view details.')))
                            : PyroCard(
                                child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(active.fullName, style: PyroTypography.heading1(true).copyWith(fontSize: 22)),
                                              Text('MRN: ${active.mrn} • ${active.gender} • Born ${active.dob}', style: const TextStyle(color: Color(0xFF94A3B8))),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              OutlinedButton.icon(
                                                style: OutlinedButton.styleFrom(foregroundColor: PyroColors.statusDanger, side: const BorderSide(color: PyroColors.statusDanger)),
                                                icon: const Icon(Icons.delete_outline, size: 16),
                                                label: const Text('Delete'),
                                                onPressed: () {
                                                  patientNotifier.deletePatient(active.id);
                                                },
                                              ),
                                              const SizedBox(width: 8),
                                              ElevatedButton.icon(
                                                style: ElevatedButton.styleFrom(backgroundColor: PyroColors.medicalBlue, foregroundColor: Colors.black),
                                                icon: const Icon(Icons.play_arrow, size: 16),
                                                label: const Text('Create Session'),
                                                onPressed: () {
                                                  ref.read(sessionEngineProvider.notifier).createSession(
                                                        patientId: active.id,
                                                        patientName: active.fullName,
                                                        protocolId: 'vep-pattern',
                                                        protocolName: 'VEP Pattern Reversal',
                                                        attendingDoctor: 'Attending Clinician',
                                                      );
                                                  ref.read(currentScreenProvider.notifier).navigateTo(PyroScreen.sessions);
                                                },
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const Divider(height: 32, color: Color(0xFF1E293B)),

                                      _buildSectionHeader('PRIMARY DIAGNOSIS & REASON FOR REFERRAL'),
                                      Text(active.primaryDiagnosis.isEmpty ? 'No diagnosis entered' : active.primaryDiagnosis, style: const TextStyle(fontSize: 14, color: Colors.white)),
                                      const SizedBox(height: 20),

                                      _buildSectionHeader('MEDICAL HISTORY'),
                                      active.medicalHistory.isEmpty
                                          ? const Text('No prior medical history entered', style: TextStyle(color: Color(0xFF94A3B8)))
                                          : Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: active.medicalHistory.map((item) => Text('• $item', style: const TextStyle(color: Colors.white, height: 1.5))).toList(),
                                            ),
                                      const SizedBox(height: 20),

                                      _buildSectionHeader('CLINICIAN NOTES'),
                                      Text(active.doctorNotes.isEmpty ? 'No notes recorded for this patient.' : active.doctorNotes, style: const TextStyle(color: Color(0xFF94A3B8), height: 1.5)),
                                    ],
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyPatientState(BuildContext context) {
    return PyroCard(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.people_outline, size: 64, color: Color(0xFF64748B)),
            const SizedBox(height: 16),
            const Text('No Patients Registered Yet', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
            const SizedBox(height: 8),
            const Text(
              'Your patient database is currently empty. Register a patient to begin clinical acquisition and analysis.',
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: PyroColors.medicalBlue, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14)),
              icon: const Icon(Icons.person_add, size: 18),
              label: const Text('Register Patient Now', style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () {
                showDialog(context: context, builder: (context) => const RegisterPatientDialog());
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: PyroColors.medicalBlue, letterSpacing: 0.5)),
    );
  }
}

class RegisterPatientDialog extends ConsumerStatefulWidget {
  const RegisterPatientDialog({Key? key}) : super(key: key);

  @override
  ConsumerState<RegisterPatientDialog> createState() => _RegisterPatientDialogState();
}

class _RegisterPatientDialogState extends ConsumerState<RegisterPatientDialog> {
  final _nameController = TextEditingController();
  final _mrnController = TextEditingController();
  final _dobController = TextEditingController();
  final _diagnosisController = TextEditingController();
  final _notesController = TextEditingController();
  String _gender = 'Male';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF151C2C),
      title: const Text('Register New Patient', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 480,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField('Full Name', _nameController, 'e.g. John Doe'),
              _buildTextField('Medical Record Number (MRN)', _mrnController, 'e.g. MRN-1002'),
              _buildTextField('Date of Birth (YYYY-MM-DD)', _dobController, 'e.g. 1980-05-15'),
              DropdownButtonFormField<String>(
                value: _gender,
                dropdownColor: const Color(0xFF151C2C),
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Gender', labelStyle: TextStyle(color: PyroColors.medicalBlue)),
                items: ['Male', 'Female', 'Other'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _gender = val);
                },
              ),
              _buildTextField('Primary Referral Diagnosis', _diagnosisController, 'e.g. Suspected Optic Neuritis'),
              _buildTextField('Clinician Notes', _notesController, 'e.g. Patient reports blurred vision', maxLines: 3),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel', style: TextStyle(color: Color(0xFF94A3B8))),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: PyroColors.medicalBlue, foregroundColor: Colors.black),
          onPressed: () {
            if (_nameController.text.trim().isEmpty) return;
            final newPatient = PatientRecord(
              id: 'PAT-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}',
              mrn: _mrnController.text.trim().isEmpty ? 'MRN-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}' : _mrnController.text.trim(),
              fullName: _nameController.text.trim(),
              dob: _dobController.text.trim().isEmpty ? '1985-01-01' : _dobController.text.trim(),
              gender: _gender,
              primaryDiagnosis: _diagnosisController.text.trim(),
              medicalHistory: const [],
              previousSessionIds: const [],
              doctorNotes: _notesController.text.trim(),
            );
            ref.read(patientEngineProvider.notifier).addPatient(newPatient);
            Navigator.of(context).pop();
          },
          child: const Text('Save & Register'),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, String hint, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: PyroColors.medicalBlue, fontSize: 12),
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
        ),
      ),
    );
  }
}
