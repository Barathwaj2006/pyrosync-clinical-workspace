import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../design_system/components/pyro_card.dart';
import '../../design_system/typography/pyro_typography.dart';
import '../../design_system/colors/pyro_colors.dart';
import '../../core_engines/auth/auth_engine.dart';
import '../../core_engines/patient/patient_engine.dart';
import '../../core_engines/session/session_engine.dart';
import '../../device_connectivity/device_manager/device_manager.dart';
import '../../navigation/navigation_provider.dart';
import '../patients/patients_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authEngineProvider);
    final patientState = ref.watch(patientEngineProvider);
    final sessionState = ref.watch(sessionEngineProvider);
    final deviceState = ref.watch(deviceManagerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final patientCount = patientState.patientList.length;
    final sessionCount = sessionState.sessions.length;

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
                  Text('CLINICAL COMMAND CENTER', style: PyroTypography.heading1(true)),
                  const SizedBox(height: 4),
                  Text(
                    'Welcome back, ${authState.profile.fullName} (${authState.profile.title}) — ${authState.profile.institution}',
                    style: PyroTypography.body(true).copyWith(color: const Color(0xFF94A3B8)),
                  ),
                ],
              ),
              Row(
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PyroColors.medicalBlue,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    icon: const Icon(Icons.person_add, size: 18),
                    label: const Text('Register Patient', style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: () {
                      ref.read(currentScreenProvider.notifier).navigateTo(PyroScreen.patients);
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Metric Cards Row
          Row(
            children: [
              Expanded(
                child: PyroCard(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('REGISTERED PATIENTS', style: PyroTypography.caption(true)),
                      const SizedBox(height: 8),
                      Text('$patientCount', style: PyroTypography.display(true).copyWith(color: PyroColors.medicalBlue)),
                      Text(patientCount == 0 ? 'No patients on record' : 'Total active records', style: PyroTypography.caption(true)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: PyroCard(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('CLINICAL SESSIONS', style: PyroTypography.caption(true)),
                      const SizedBox(height: 8),
                      Text('$sessionCount', style: PyroTypography.display(true).copyWith(color: PyroColors.statusSuccess)),
                      Text(sessionCount == 0 ? 'No sessions created' : 'Sessions recorded', style: PyroTypography.caption(true)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: PyroCard(
                  onTap: () => ref.read(currentScreenProvider.notifier).navigateTo(PyroScreen.settings),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('HARDWARE STATUS', style: PyroTypography.caption(true)),
                      const SizedBox(height: 8),
                      Text(
                        deviceState.isConnected ? 'ONLINE' : 'DISCONNECTED',
                        style: PyroTypography.display(true).copyWith(
                          color: deviceState.isConnected ? PyroColors.statusSuccess : PyroColors.statusWarning,
                          fontSize: 20,
                        ),
                      ),
                      Text(
                        deviceState.isConnected ? (deviceState.activeDeviceInfo?.deviceName ?? 'Connected') : 'No device detected',
                        style: PyroTypography.caption(true),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Main Queue & Hardware Panel
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: PyroCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('PATIENT DIRECTORY SUMMARY', style: PyroTypography.heading2(true)),
                            TextButton(
                              onPressed: () {
                                ref.read(currentScreenProvider.notifier).navigateTo(PyroScreen.patients);
                              },
                              child: const Text('View All Patients →', style: TextStyle(color: PyroColors.medicalBlue)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: patientState.patientList.isEmpty
                              ? _buildEmptyState(
                                  context: context,
                                  icon: Icons.people_outline,
                                  title: 'No Patients Registered',
                                  subtitle: 'Click "Register Patient" to add your first clinical record.',
                                  buttonLabel: 'Register Patient Now',
                                  onPressed: () => _showRegisterPatientDialog(context, ref),
                                )
                              : ListView.builder(
                                  itemCount: patientState.patientList.length,
                                  itemBuilder: (context, index) {
                                    final p = patientState.patientList[index];
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF121620),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: const Color(0xFF1E293B)),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              CircleAvatar(
                                                radius: 16,
                                                backgroundColor: PyroColors.medicalBlue.withValues(alpha: 0.2),
                                                child: Text(p.fullName[0], style: const TextStyle(color: PyroColors.medicalBlue, fontWeight: FontWeight.bold)),
                                              ),
                                              const SizedBox(width: 12),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(p.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
                                                  Text('MRN: ${p.mrn} • ${p.gender} • DOB: ${p.dob}', style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                                                ],
                                              ),
                                            ],
                                          ),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: PyroColors.medicalBlue.withValues(alpha: 0.15),
                                              foregroundColor: PyroColors.medicalBlue,
                                              elevation: 0,
                                            ),
                                            onPressed: () {
                                              ref.read(patientEngineProvider.notifier).selectPatient(p.id);
                                              ref.read(currentScreenProvider.notifier).navigateTo(PyroScreen.sessions);
                                            },
                                            child: const Text('Open Sessions'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: PyroCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('HARDWARE TELEMETRY', style: PyroTypography.heading2(true)),
                        const SizedBox(height: 16),
                        if (!deviceState.isConnected) ...[
                          const Icon(Icons.usb_off_outlined, size: 48, color: PyroColors.statusWarning),
                          const SizedBox(height: 12),
                          const Text('No Acquisition Device Connected', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
                          const SizedBox(height: 6),
                          const Text(
                            'Connect a USB Serial or BLE Bio-Amplifier to begin acquiring signals.',
                            style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                          ),
                          const Spacer(),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(backgroundColor: PyroColors.medicalBlue, foregroundColor: Colors.black),
                              icon: const Icon(Icons.settings, size: 16),
                              label: const Text('Hardware Settings'),
                              onPressed: () {
                                ref.read(currentScreenProvider.notifier).navigateTo(PyroScreen.settings);
                              },
                            ),
                          ),
                        ] else ...[
                          _buildTelemetryItem('Connected Device', deviceState.activeDeviceInfo?.deviceName ?? 'BioAmp'),
                          _buildTelemetryItem('Sampling Frequency', '${deviceState.activeDeviceInfo?.samplingRateHz ?? 2500} Hz'),
                          _buildTelemetryItem('Channels', '${deviceState.activeDeviceInfo?.channelCount ?? 8} Channels'),
                          _buildTelemetryItem('Firmware Version', deviceState.activeDeviceInfo?.firmwareVersion ?? 'v2.4'),
                          _buildTelemetryItem('Signal Quality Score', '${deviceState.activeDeviceInfo?.signalQualityScore ?? 98.5}%'),
                          const Spacer(),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(foregroundColor: PyroColors.statusDanger, side: const BorderSide(color: PyroColors.statusDanger)),
                              onPressed: () {
                                ref.read(deviceManagerProvider.notifier).disconnectDevice();
                              },
                              child: const Text('Disconnect Hardware'),
                            ),
                          ),
                        ],
                      ],
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

  Widget _buildEmptyState({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required String buttonLabel,
    required VoidCallback onPressed,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 56, color: const Color(0xFF64748B)),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
          const SizedBox(height: 6),
          Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: PyroColors.medicalBlue, foregroundColor: Colors.black),
            icon: const Icon(Icons.add, size: 16),
            label: Text(buttonLabel),
            onPressed: onPressed,
          ),
        ],
      ),
    );
  }

  Widget _buildTelemetryItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
          Text(value, style: PyroTypography.monoData(isDark: true, fontSize: 11)),
        ],
      ),
    );
  }

  void _showRegisterPatientDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => const RegisterPatientDialog(),
    );
  }
}
