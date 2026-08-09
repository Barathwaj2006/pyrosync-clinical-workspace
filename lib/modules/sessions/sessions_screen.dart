import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../design_system/components/pyro_card.dart';
import '../../design_system/typography/pyro_typography.dart';
import '../../design_system/colors/pyro_colors.dart';
import '../../core_engines/session/session_engine.dart';
import '../../core_engines/patient/patient_engine.dart';
import '../../navigation/navigation_provider.dart';

class SessionsScreen extends ConsumerWidget {
  const SessionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionState = ref.watch(sessionEngineProvider);
    final sessionNotifier = ref.read(sessionEngineProvider.notifier);
    final patientState = ref.watch(patientEngineProvider);

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
                  Text('CLINICAL EXAMINATION SESSIONS', style: PyroTypography.heading1(true)),
                  Text('Acquisition session history, protocol selection, and examination status.', style: PyroTypography.body(true).copyWith(color: const Color(0xFF94A3B8))),
                ],
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: PyroColors.medicalBlue,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Create New Session', style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () {
                  if (patientState.patientList.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please register a patient before creating a session.')),
                    );
                    ref.read(currentScreenProvider.notifier).navigateTo(PyroScreen.patients);
                    return;
                  }
                  _showCreateSessionDialog(context, ref);
                },
              ),
            ],
          ),
          const SizedBox(height: 24),

          Expanded(
            child: sessionState.sessions.isEmpty
                ? _buildEmptySessionState(context, ref, patientState.patientList.isNotEmpty)
                : ListView.builder(
                    itemCount: sessionState.sessions.length,
                    itemBuilder: (context, index) {
                      final s = sessionState.sessions[index];
                      final isSelected = sessionState.activeSession?.sessionId == s.sessionId;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected ? PyroColors.medicalBlue.withValues(alpha: 0.12) : const Color(0xFF151C2C),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: isSelected ? PyroColors.medicalBlue : const Color(0xFF1E293B)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.show_chart, color: isSelected ? PyroColors.medicalBlue : const Color(0xFF94A3B8), size: 28),
                                const SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Session ${s.sessionId} • ${s.patientName}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
                                    const SizedBox(height: 4),
                                    Text('Protocol: ${s.protocolName} • Recorded ${s.recordingDate.toString().substring(0, 16)}', style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                                  ],
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: PyroColors.medicalBlue.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: PyroColors.medicalBlue.withValues(alpha: 0.4)),
                                  ),
                                  child: Text(s.status.name.toUpperCase(), style: const TextStyle(fontSize: 10, color: PyroColors.medicalBlue, fontWeight: FontWeight.bold)),
                                ),
                                const SizedBox(width: 16),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: PyroColors.medicalBlue, foregroundColor: Colors.black),
                                  onPressed: () {
                                    sessionNotifier.selectSession(s.sessionId);
                                    ref.read(currentScreenProvider.notifier).navigateTo(PyroScreen.recording);
                                  },
                                  child: const Text('Open Recording Workspace'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySessionState(BuildContext context, WidgetRef ref, bool hasPatients) {
    return PyroCard(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.tune_outlined, size: 64, color: Color(0xFF64748B)),
            const SizedBox(height: 16),
            const Text('No Clinical Sessions Created', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
            const SizedBox(height: 8),
            Text(
              hasPatients
                  ? 'Select a registered patient and create an acquisition session to begin.'
                  : 'Register a patient first before creating a clinical examination session.',
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: PyroColors.medicalBlue, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14)),
              icon: Icon(hasPatients ? Icons.add : Icons.person_add, size: 18),
              label: Text(hasPatients ? 'Create New Session' : 'Register Patient First', style: const TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () {
                if (hasPatients) {
                  _showCreateSessionDialog(context, ref);
                } else {
                  ref.read(currentScreenProvider.notifier).navigateTo(PyroScreen.patients);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateSessionDialog(BuildContext context, WidgetRef ref) {
    final patientState = ref.read(patientEngineProvider);
    String selectedPatientId = patientState.patientList.first.id;
    String selectedProtocol = 'VEP Pattern Reversal';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF151C2C),
            title: const Text('Create New Clinical Session', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            content: SizedBox(
              width: 440,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Select Patient', style: TextStyle(color: PyroColors.medicalBlue, fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: selectedPatientId,
                    dropdownColor: const Color(0xFF151C2C),
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    items: patientState.patientList.map((p) => DropdownMenuItem(value: p.id, child: Text('${p.fullName} (MRN: ${p.mrn})'))).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => selectedPatientId = val);
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text('Acquisition Protocol', style: TextStyle(color: PyroColors.medicalBlue, fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: selectedProtocol,
                    dropdownColor: const Color(0xFF151C2C),
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    items: ['VEP Pattern Reversal', 'Routine 16-Channel EEG', 'Flash VEP Protocol'].map((pr) => DropdownMenuItem(value: pr, child: Text(pr))).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => selectedProtocol = val);
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel', style: TextStyle(color: Color(0xFF94A3B8)))),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: PyroColors.medicalBlue, foregroundColor: Colors.black),
                onPressed: () {
                  final patient = patientState.patientList.firstWhere((p) => p.id == selectedPatientId);
                  ref.read(sessionEngineProvider.notifier).createSession(
                        patientId: patient.id,
                        patientName: patient.fullName,
                        protocolId: selectedProtocol.toLowerCase().replaceAll(' ', '-'),
                        protocolName: selectedProtocol,
                        attendingDoctor: 'Attending Clinician',
                      );
                  Navigator.of(context).pop();
                },
                child: const Text('Create & Open Session'),
              ),
            ],
          );
        },
      ),
    );
  }
}
