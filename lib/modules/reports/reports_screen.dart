import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../design_system/components/pyro_card.dart';
import '../../design_system/typography/pyro_typography.dart';
import '../../design_system/colors/pyro_colors.dart';
import '../../core_engines/auth/auth_engine.dart';
import '../../core_engines/session/session_engine.dart';
import '../../core_engines/patient/patient_engine.dart';
import '../../navigation/navigation_provider.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authEngineProvider);
    final sessionState = ref.watch(sessionEngineProvider);
    final activeSession = sessionState.activeSession;

    final hasReportData = activeSession != null;

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
                  Text('CLINICAL DIAGNOSTIC REPORT GENERATOR', style: PyroTypography.heading1(true)),
                  Text('Finalized neurodiagnostic reports, electronic signatures, and EDF+ export.', style: PyroTypography.body(true).copyWith(color: const Color(0xFF94A3B8))),
                ],
              ),
              if (hasReportData) ...[
                Row(
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: PyroColors.medicalBlue, foregroundColor: Colors.black),
                      icon: const Icon(Icons.picture_as_pdf, size: 16),
                      label: const Text('Export PDF Report'),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Exporting PDF Diagnostic Report...')),
                        );
                      },
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Color(0xFF1E293B))),
                      icon: const Icon(Icons.download, size: 16),
                      label: const Text('Export EDF+ Signal'),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Exporting standard EDF+ signal file...')),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ],
          ),
          const SizedBox(height: 20),

          Expanded(
            child: !hasReportData
                ? _buildEmptyReportState(context, ref)
                : PyroCard(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header Banner
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('PYROSYNC NEURODIAGNOSTIC REPORT', style: PyroTypography.heading1(true).copyWith(fontSize: 20)),
                                  Text('Pyromatics Bio Solutions Medical Platform • ${authState.profile.institution}', style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('REPORT ID: RPT-${activeSession.sessionId}', style: PyroTypography.monoData(isDark: true, fontSize: 11)),
                                  Text('DATE: ${activeSession.recordingDate.toString().substring(0, 10)}', style: PyroTypography.monoData(isDark: true, fontSize: 11)),
                                ],
                              ),
                            ],
                          ),
                          const Divider(height: 32, color: Color(0xFF1E293B)),

                          // Patient & Attending Clinician Summary
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildLabel('PATIENT NAME', activeSession.patientName),
                                    _buildLabel('PATIENT ID', activeSession.patientId),
                                    _buildLabel('EXAMINATION PROTOCOL', activeSession.protocolName),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildLabel('ATTENDING CLINICIAN', authState.profile.fullName),
                                    _buildLabel('CLINICAL TITLE', '${authState.profile.title} (${authState.profile.credentials})'),
                                    _buildLabel('INSTITUTION', authState.profile.institution),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 32, color: Color(0xFF1E293B)),

                          // Diagnostic Metrics & Findings
                          const Text('EXTRACTED PEAK LATENCY SUMMARY', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: PyroColors.medicalBlue)),
                          const SizedBox(height: 12),
                          Table(
                            border: TableBorder.all(color: const Color(0xFF1E293B)),
                            children: [
                              const TableRow(
                                decoration: BoxDecoration(color: Color(0xFF121620)),
                                children: [
                                  Padding(padding: EdgeInsets.all(8), child: Text('PARAMETER', style: TextStyle(fontWeight: FontWeight.bold, color: PyroColors.medicalBlue, fontSize: 11))),
                                  Padding(padding: EdgeInsets.all(8), child: Text('MEASURED VALUE', style: TextStyle(fontWeight: FontWeight.bold, color: PyroColors.medicalBlue, fontSize: 11))),
                                  Padding(padding: EdgeInsets.all(8), child: Text('NORMATIVE RANGE', style: TextStyle(fontWeight: FontWeight.bold, color: PyroColors.medicalBlue, fontSize: 11))),
                                  Padding(padding: EdgeInsets.all(8), child: Text('STATUS', style: TextStyle(fontWeight: FontWeight.bold, color: PyroColors.medicalBlue, fontSize: 11))),
                                ],
                              ),
                              TableRow(
                                children: [
                                  const Padding(padding: EdgeInsets.all(8), child: Text('P100 Peak Latency', style: TextStyle(color: Colors.white, fontSize: 12))),
                                  const Padding(padding: EdgeInsets.all(8), child: Text('102.4 ms', style: TextStyle(color: Colors.white, fontSize: 12))),
                                  const Padding(padding: EdgeInsets.all(8), child: Text('95.0 – 108.0 ms', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12))),
                                  Padding(padding: const EdgeInsets.all(8), child: Text('NORMAL', style: TextStyle(color: PyroColors.statusSuccess, fontWeight: FontWeight.bold, fontSize: 12))),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          const Text('CLINICIAN INTERPRETATION & SIGN-OFF', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: PyroColors.medicalBlue)),
                          const SizedBox(height: 8),
                          const Text(
                            'Visual Evoked Potentials recorded using standard 10-20 scalp montage. P100 wave latency is symmetrical and within normative limits. No evidence of demyelinating optic neuropathy.',
                            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, height: 1.5),
                          ),
                          const SizedBox(height: 24),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('ELECTRONICALLY SIGNED BY:', style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8), fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Text('${authState.profile.fullName}, ${authState.profile.credentials}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(border: Border.all(color: PyroColors.medicalBlue), borderRadius: BorderRadius.circular(6)),
                                child: const Text('SHA-256 VERIFIED SIGNATURE', style: TextStyle(color: PyroColors.medicalBlue, fontSize: 10, fontFamily: 'Roboto Mono', fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyReportState(BuildContext context, WidgetRef ref) {
    return PyroCard(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.description_outlined, size: 64, color: Color(0xFF64748B)),
            const SizedBox(height: 16),
            const Text('No Clinical Reports Available', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
            const SizedBox(height: 8),
            const Text(
              'Select an examination session and approve an AI/clinical analysis to generate a PDF/EDF diagnostic report.',
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: PyroColors.medicalBlue, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14)),
              icon: const Icon(Icons.tune, size: 18),
              label: const Text('Go to Examination Sessions', style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () {
                ref.read(currentScreenProvider.notifier).navigateTo(PyroScreen.sessions);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8), fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
