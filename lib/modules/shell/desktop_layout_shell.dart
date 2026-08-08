import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../design_system/colors/pyro_colors.dart';
import '../../design_system/spacing/pyro_spacing.dart';
import '../../design_system/theme/pyro_theme.dart';
import '../../core_engines/theme/theme_engine_controller.dart';
import '../../design_system/typography/pyro_typography.dart';
import '../../navigation/navigation_provider.dart';
import '../../core_engines/auth/auth_engine.dart';
import '../../core_engines/patient/patient_engine.dart';
import '../../core_engines/session/session_engine.dart';
import '../../device_connectivity/device_manager/device_manager.dart';

import '../dashboard/dashboard_screen.dart';
import '../patients/patients_screen.dart';
import '../sessions/sessions_screen.dart';
import '../recording/recording_screen.dart';
import '../analysis/analysis_screen.dart';
import '../ai_workspace/ai_workspace_screen.dart';
import '../reports/reports_screen.dart';
import '../neurolab/neurolab_dashboard.dart';
import '../settings/settings_screen.dart';

final rightPanelOpenProvider = StateProvider<bool>((ref) => true);

class DesktopLayoutShell extends ConsumerWidget {
  const DesktopLayoutShell({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentScreen = ref.watch(currentScreenProvider);
    final themeMode = ref.watch(themeModeProvider);
    final themeNotifier = ref.read(themeModeProvider.notifier);
    final isDark = themeNotifier.isDark;
    final isRightPanelOpen = ref.watch(rightPanelOpenProvider);
    final deviceState = ref.watch(deviceManagerProvider);
    final authState = ref.watch(authEngineProvider);
    final patientState = ref.watch(patientEngineProvider);
    final sessionState = ref.watch(sessionEngineProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!authState.profile.isConfigured) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const ClinicianSetupDialog(),
        );
      }
    });

    return Scaffold(
      backgroundColor: isDark ? PyroColors.darkCanvas : PyroColors.lightCanvas,
      body: SafeArea(
        child: Column(
          children: [
            // 1. TOP NAVIGATION BAR
            _buildTopNavBar(context, ref, isDark, themeMode, themeNotifier, deviceState, authState, patientState, sessionState),

            // 2. MAIN BODY
            Expanded(
              child: Row(
                children: [
                  // Left Navigation Sidebar Rail
                  _buildSidebarRail(context, ref, currentScreen, isDark),

                  // Main Workspace Area
                  Expanded(
                    child: Container(
                      color: isDark ? PyroColors.darkCanvas : PyroColors.lightCanvas,
                      child: _buildScreenContent(currentScreen),
                    ),
                  ),

                  // Right Context Inspector Panel (Collapsible)
                  if (isRightPanelOpen) _buildRightContextPanel(context, ref, isDark, patientState, sessionState, deviceState),
                ],
              ),
            ),

            // 3. BOTTOM TELEMETRY STATUS BAR
            _buildBottomStatusBar(context, isDark, deviceState),
          ],
        ),
      ),
    );
  }

  Widget _buildTopNavBar(
    BuildContext context,
    WidgetRef ref,
    bool isDark,
    PyroThemeMode themeMode,
    PyroThemeNotifier themeNotifier,
    DeviceManagerState deviceState,
    AuthState authState,
    PatientState patientState,
    SessionState sessionState,
  ) {
    final isRightPanelOpen = ref.watch(rightPanelOpenProvider);
    final activePatient = patientState.activePatient;
    final activeSession = sessionState.activeSession;

    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: isDark ? PyroColors.darkSurfaceBase.withOpacity(0.85) : PyroColors.lightSurfaceBase.withOpacity(0.9),
        border: Border(
          bottom: BorderSide(
            color: isDark ? PyroColors.darkBorder : PyroColors.lightBorder,
            width: 1,
          ),
        ),
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: PyroSpacing.md),
            child: Row(
              children: [
                Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [PyroColors.medicalBlue, PyroColors.deepClinicalBlue],
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Center(
                        child: Icon(Icons.bolt, color: Colors.black, size: 18),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PYROSYNC',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            color: isDark ? PyroColors.textPrimaryDark : PyroColors.textPrimaryLight,
                          ),
                        ),
                        Text(
                          'Pyromatics Bio Solutions',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 9,
                            color: isDark ? PyroColors.textSecondaryDark : PyroColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(width: 16),

                Flexible(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildTopBadge(
                          icon: Icons.person_outline,
                          label: activePatient != null ? 'PATIENT: ${activePatient.fullName} (${activePatient.mrn})' : 'PATIENT: None Selected',
                          isDark: isDark,
                        ),
                        const SizedBox(width: 8),
                        _buildTopBadge(
                          icon: Icons.assignment_outlined,
                          label: activeSession != null ? 'SESSION: ${activeSession.sessionId} (${activeSession.protocolName})' : 'SESSION: No Active Session',
                          isDark: isDark,
                        ),
                        const SizedBox(width: 8),
                        _buildTopBadge(
                          icon: Icons.developer_board,
                          label: deviceState.isConnected ? 'HARDWARE: Connected (${deviceState.activeDeviceInfo?.deviceName})' : 'NO DEVICE',
                          statusColor: deviceState.isConnected ? PyroColors.statusSuccess : PyroColors.statusWarning,
                          isDark: isDark,
                          onTap: () => ref.read(currentScreenProvider.notifier).navigateTo(PyroScreen.settings),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                IconButton(
                  icon: Icon(
                    isRightPanelOpen ? Icons.view_sidebar : Icons.view_sidebar_outlined,
                    size: 20,
                  ),
                  color: isRightPanelOpen ? PyroColors.medicalBlue : (isDark ? PyroColors.textSecondaryDark : PyroColors.textSecondaryLight),
                  onPressed: () {
                    ref.read(rightPanelOpenProvider.notifier).state = !isRightPanelOpen;
                  },
                ),
                const SizedBox(width: 8),

                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: PyroColors.medicalBlue.withOpacity(0.2),
                        child: Text(
                          authState.profile.fullName.isNotEmpty ? authState.profile.fullName[0].toUpperCase() : 'C',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isDark ? PyroColors.medicalBlue : PyroColors.deepClinicalBlue,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          authState.profile.fullName,
                          style: PyroTypography.body(isDark).copyWith(fontWeight: FontWeight.w600, fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBadge({
    required IconData icon,
    required String label,
    Color? statusColor,
    required bool isDark,
    VoidCallback? onTap,
  }) {
    final badge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? PyroColors.darkBorder : PyroColors.lightBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: statusColor ?? PyroColors.medicalBlue),
          const SizedBox(width: 6),
          Text(
            label,
            style: PyroTypography.caption(isDark).copyWith(fontSize: 10, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: badge,
      );
    }
    return badge;
  }

  Widget _buildSidebarRail(
    BuildContext context,
    WidgetRef ref,
    PyroScreen currentScreen,
    bool isDark,
  ) {
    return Container(
      width: 220,
      decoration: BoxDecoration(
        color: isDark ? PyroColors.darkSurfaceBase.withOpacity(0.9) : PyroColors.lightSurfaceBase,
        border: Border(
          right: BorderSide(
            color: isDark ? PyroColors.darkBorder : PyroColors.lightBorder,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: PyroSpacing.sm),
          _NavItem(icon: Icons.dashboard_outlined, label: 'Dashboard', screen: PyroScreen.dashboard, currentScreen: currentScreen, isDark: isDark, onTap: () => ref.read(currentScreenProvider.notifier).navigateTo(PyroScreen.dashboard)),
          _NavItem(icon: Icons.people_outline, label: 'Patients', screen: PyroScreen.patients, currentScreen: currentScreen, isDark: isDark, onTap: () => ref.read(currentScreenProvider.notifier).navigateTo(PyroScreen.patients)),
          _NavItem(icon: Icons.tune_outlined, label: 'Sessions', screen: PyroScreen.sessions, currentScreen: currentScreen, isDark: isDark, onTap: () => ref.read(currentScreenProvider.notifier).navigateTo(PyroScreen.sessions)),
          _NavItem(icon: Icons.show_chart_outlined, label: 'Recording', screen: PyroScreen.recording, currentScreen: currentScreen, isDark: isDark, onTap: () => ref.read(currentScreenProvider.notifier).navigateTo(PyroScreen.recording)),
          _NavItem(icon: Icons.analytics_outlined, label: 'Analysis', screen: PyroScreen.analysis, currentScreen: currentScreen, isDark: isDark, onTap: () => ref.read(currentScreenProvider.notifier).navigateTo(PyroScreen.analysis)),
          _NavItem(icon: Icons.psychology_outlined, label: 'AI Workspace', screen: PyroScreen.aiWorkspace, currentScreen: currentScreen, isDark: isDark, onTap: () => ref.read(currentScreenProvider.notifier).navigateTo(PyroScreen.aiWorkspace)),
          _NavItem(icon: Icons.description_outlined, label: 'Reports', screen: PyroScreen.reports, currentScreen: currentScreen, isDark: isDark, onTap: () => ref.read(currentScreenProvider.notifier).navigateTo(PyroScreen.reports)),
          const Divider(height: 12, color: Color(0x1AFFFFFF)),
          _NavItem(icon: Icons.science_outlined, label: 'NeuroLab Sim', screen: PyroScreen.help, currentScreen: currentScreen, isDark: isDark, onTap: () => ref.read(currentScreenProvider.notifier).navigateTo(PyroScreen.help)),
          const Spacer(),
          const Divider(height: 1, color: Color(0x1AFFFFFF)),
          _NavItem(icon: Icons.settings_outlined, label: 'Settings', screen: PyroScreen.settings, currentScreen: currentScreen, isDark: isDark, onTap: () => ref.read(currentScreenProvider.notifier).navigateTo(PyroScreen.settings)),
          const SizedBox(height: PyroSpacing.sm),
        ],
      ),
    );
  }

  Widget _buildRightContextPanel(
    BuildContext context,
    WidgetRef ref,
    bool isDark,
    PatientState patientState,
    SessionState sessionState,
    DeviceManagerState deviceState,
  ) {
    final activePatient = patientState.activePatient;
    final activeSession = sessionState.activeSession;

    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: isDark ? PyroColors.darkSurfaceBase.withOpacity(0.9) : PyroColors.lightSurfaceBase,
        border: Border(
          left: BorderSide(
            color: isDark ? PyroColors.darkBorder : PyroColors.lightBorder,
            width: 1,
          ),
        ),
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Padding(
            padding: const EdgeInsets.all(PyroSpacing.md),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'CLINICAL CONTEXT INSPECTOR',
                        style: PyroTypography.caption(isDark).copyWith(letterSpacing: 1.0, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 16),
                        color: isDark ? PyroColors.textSecondaryDark : PyroColors.textSecondaryLight,
                        onPressed: () {
                          ref.read(rightPanelOpenProvider.notifier).state = false;
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  _buildContextSection(
                    title: 'ACTIVE PATIENT DETAILS',
                    isDark: isDark,
                    child: activePatient == null
                        ? const Text('No active patient selected.', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11))
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(activePatient.fullName, style: PyroTypography.bodyLarge(isDark).copyWith(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 2),
                              Text('MRN: ${activePatient.mrn} • ${activePatient.gender} • Born ${activePatient.dob}', style: PyroTypography.caption(isDark)),
                            ],
                          ),
                  ),
                  const SizedBox(height: 16),

                  _buildContextSection(
                    title: 'HARDWARE & SIGNAL TELEMETRY',
                    isDark: isDark,
                    child: Column(
                      children: [
                        _buildMetricRow('Device Status', deviceState.isConnected ? 'CONNECTED' : 'DISCONNECTED', deviceState.isConnected ? PyroColors.statusSuccess : PyroColors.statusWarning, isDark),
                        _buildMetricRow('Hardware Name', deviceState.isConnected ? (deviceState.activeDeviceInfo?.deviceName ?? 'BioAmp') : 'None', PyroColors.medicalBlue, isDark),
                        _buildMetricRow('Sampling Frequency', deviceState.isConnected ? '${deviceState.activeDeviceInfo?.samplingRateHz} Hz' : '0 Hz', PyroColors.medicalBlue, isDark),
                        _buildMetricRow('Active Session', activeSession != null ? activeSession.sessionId : 'None', PyroColors.medicalBlue, isDark),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContextSection({required String title, required Widget child, required bool isDark}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? PyroColors.darkSurfaceCard.withOpacity(0.6) : PyroColors.lightSurfaceCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isDark ? PyroColors.darkBorder : PyroColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5, color: isDark ? PyroColors.medicalBlue : PyroColors.deepClinicalBlue)),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, Color color, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
          Text(value, style: PyroTypography.monoData(isDark: isDark, color: color, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildScreenContent(PyroScreen screen) {
    switch (screen) {
      case PyroScreen.dashboard:
        return const DashboardScreen();
      case PyroScreen.patients:
        return const PatientsScreen();
      case PyroScreen.sessions:
        return const SessionsScreen();
      case PyroScreen.recording:
        return const RecordingScreen();
      case PyroScreen.analysis:
        return const AnalysisScreen();
      case PyroScreen.aiWorkspace:
        return const AiWorkspaceScreen();
      case PyroScreen.reports:
        return const ReportsScreen();
      case PyroScreen.settings:
        return const SettingsScreen();
      case PyroScreen.help:
        return const NeuroLabDashboard(); // Virtual NeuroLab Simulator
      default:
        return const DashboardScreen();
    }
  }

  Widget _buildBottomStatusBar(BuildContext context, bool isDark, DeviceManagerState deviceState) {
    return Container(
      height: 30,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF07090E) : const Color(0xFFE2E8F0),
        border: Border(top: BorderSide(color: isDark ? PyroColors.darkBorder : PyroColors.lightBorder)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: deviceState.isConnected ? PyroColors.statusSuccess : PyroColors.statusWarning,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                deviceState.isConnected
                    ? 'PYROSYNC HARDWARE ACTIVE | ${deviceState.activeDeviceInfo?.deviceName} (${deviceState.activeDeviceInfo?.samplingRateHz} Hz)'
                    : 'PYROSYNC HARDWARE DISCONNECTED | CONNECT DEVICE IN SETTINGS',
                style: TextStyle(fontSize: 10, fontFamily: 'Roboto Mono', color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569), fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Text(
            'Pyromatics Bio Solutions © 2026',
            style: TextStyle(fontSize: 10, fontFamily: 'Roboto Mono', color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final PyroScreen screen;
  final PyroScreen currentScreen;
  final bool isDark;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.screen,
    required this.currentScreen,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = currentScreen == screen;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Material(
        color: isSelected ? PyroColors.medicalBlue.withOpacity(0.12) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? PyroColors.medicalBlue.withOpacity(0.5) : Colors.transparent,
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    icon,
                    size: 18,
                    color: isSelected
                        ? PyroColors.medicalBlue
                        : (isDark ? PyroColors.textSecondaryDark : PyroColors.textSecondaryLight),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected
                            ? (isDark ? Colors.white : PyroColors.deepClinicalBlue)
                            : (isDark ? PyroColors.textSecondaryDark : PyroColors.textSecondaryLight),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ClinicianSetupDialog extends ConsumerStatefulWidget {
  const ClinicianSetupDialog({Key? key}) : super(key: key);

  @override
  ConsumerState<ClinicianSetupDialog> createState() => _ClinicianSetupDialogState();
}

class _ClinicianSetupDialogState extends ConsumerState<ClinicianSetupDialog> {
  final _nameController = TextEditingController();
  final _titleController = TextEditingController(text: 'Attending Neurologist');
  final _institutionController = TextEditingController(text: 'Pyromatics Medical Center');
  final _credentialsController = TextEditingController(text: 'MD, PhD');

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF151C2C),
      title: const Row(
        children: [
          Icon(Icons.person_pin, color: PyroColors.medicalBlue),
          SizedBox(width: 10),
          Text('First-Launch Clinician Setup', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
      content: SizedBox(
        width: 440,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome to PyroSync Clinical Workspace. Please enter your professional profile details to initialize the clinical workspace.',
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, height: 1.5),
            ),
            const SizedBox(height: 16),
            _buildField('Full Name', _nameController, 'e.g. Dr. Jane Smith'),
            _buildField('Professional Title', _titleController, 'e.g. Attending Neurologist'),
            _buildField('Institution / Hospital', _institutionController, 'e.g. Pyromatics Bio Solutions Center'),
            _buildField('Credentials', _credentialsController, 'e.g. MD, PhD'),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: PyroColors.medicalBlue, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
          onPressed: () {
            if (_nameController.text.trim().isEmpty) return;
            ref.read(authEngineProvider.notifier).updateProfile(
                  fullName: _nameController.text.trim(),
                  title: _titleController.text.trim(),
                  institution: _institutionController.text.trim(),
                  credentials: _credentialsController.text.trim(),
                );
            Navigator.of(context).pop();
          },
          child: const Text('Save Profile & Begin Workspace', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildField(String label, TextEditingController controller, String hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white, fontSize: 13),
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
