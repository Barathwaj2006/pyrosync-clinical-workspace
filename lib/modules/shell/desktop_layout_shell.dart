import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../design_system/colors/pyro_colors.dart';
import '../../design_system/spacing/pyro_spacing.dart';
import '../../design_system/theme/pyro_theme.dart';
import '../../design_system/typography/pyro_typography.dart';
import '../../navigation/navigation_provider.dart';
import '../../core_engines/signal_provider/signal_provider_interface.dart';
import '../dashboard/dashboard_screen.dart';
import '../patients/patients_screen.dart';
import '../sessions/sessions_screen.dart';
import '../recording/recording_screen.dart';
import '../analysis/analysis_screen.dart';
import '../ai_workspace/ai_workspace_screen.dart';
import '../reports/reports_screen.dart';
import '../neurolab/neurolab_dashboard.dart';
import '../neurolab/neurolab_engine.dart';
import '../settings/settings_screen.dart';
import '../help/help_screen.dart';

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
    final labState = ref.watch(neurolabEngineProvider);
    final isSimConnected = labState.deviceTelemetry.connectionState == SignalConnectionState.connected;

    return Scaffold(
      backgroundColor: isDark ? PyroColors.darkCanvas : PyroColors.lightCanvas,
      body: SafeArea(
        child: Column(
          children: [
            // 1. TOP NAVIGATION BAR (GLASS UI)
            _buildTopNavBar(context, ref, isDark, themeMode, themeNotifier, isSimConnected),

            // 2. MAIN BODY (LEFT SIDEBAR + WORKSPACE AREA + RIGHT CONTEXT PANEL)
            Expanded(
              child: Row(
                children: [
                  // Left Navigation Sidebar Rail
                  _buildSidebarRail(context, ref, currentScreen, isDark),

                  // Main Dynamic Workspace Area
                  Expanded(
                    child: Container(
                      color: isDark ? PyroColors.darkCanvas : PyroColors.lightCanvas,
                      child: _buildScreenContent(currentScreen),
                    ),
                  ),

                  // Right Context Inspector Panel (Collapsible)
                  if (isRightPanelOpen) _buildRightContextPanel(context, ref, isDark),
                ],
              ),
            ),

            // 3. BOTTOM HARDWARE TELEMETRY STATUS BAR
            _buildBottomStatusBar(context, isDark, isSimConnected),
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
    bool isSimConnected,
  ) {
    final isRightPanelOpen = ref.watch(rightPanelOpenProvider);

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
                      crossAxisAlignment: CrossAlignment.start,
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
                const SizedBox(width: 24),

                _buildTopBadge(
                  icon: Icons.person_outline,
                  label: 'PATIENT: Arthur Pendelton (P-10929)',
                  isDark: isDark,
                ),
                const SizedBox(width: 8),
                _buildTopBadge(
                  icon: Icons.assignment_outlined,
                  label: 'SESSION: SES-2026-0807 (VEP Pattern)',
                  isDark: isDark,
                ),
                const SizedBox(width: 8),
                _buildTopBadge(
                  icon: Icons.science_outlined,
                  label: isSimConnected ? 'NEUROLAB DEVICE: Connected (2500 Hz)' : 'NEUROLAB DEVICE: Disconnected',
                  statusColor: isSimConnected ? PyroColors.statusSuccess : PyroColors.statusDanger,
                  isDark: isDark,
                ),

                const Spacer(),

                // Theme Mode Selector
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? PyroColors.darkCanvas : PyroColors.lightSurfaceCard,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isDark ? PyroColors.darkBorder : PyroColors.lightBorder),
                  ),
                  padding: const EdgeInsets.all(2),
                  child: Row(
                    children: [
                      _ThemeButton(
                        label: 'Clinical',
                        icon: Icons.dark_mode_outlined,
                        isSelected: themeMode == PyroThemeMode.clinicalDark,
                        onTap: () => themeNotifier.setTheme(PyroThemeMode.clinicalDark),
                        isDark: isDark,
                      ),
                      _ThemeButton(
                        label: 'Glass',
                        icon: Icons.blur_on,
                        isSelected: themeMode == PyroThemeMode.glassMode,
                        onTap: () => themeNotifier.setTheme(PyroThemeMode.glassMode),
                        isDark: isDark,
                      ),
                      _ThemeButton(
                        label: 'Light',
                        icon: Icons.light_mode_outlined,
                        isSelected: themeMode == PyroThemeMode.clinicalLight,
                        onTap: () => themeNotifier.setTheme(PyroThemeMode.clinicalLight),
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

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

                Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: PyroColors.medicalBlue.withOpacity(0.2),
                      child: Text(
                        'EV',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isDark ? PyroColors.medicalBlue : PyroColors.deepClinicalBlue,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Dr. E. Vance',
                      style: PyroTypography.body(isDark).copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
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
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? PyroColors.darkBorder : PyroColors.lightBorder),
      ),
      child: Row(
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

  Widget _buildRightContextPanel(BuildContext context, WidgetRef ref, bool isDark) {
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
                crossAxisAlignment: CrossAlignment.start,
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
                    child: Column(
                      crossAxisAlignment: CrossAlignment.start,
                      children: [
                        Text('Arthur Pendelton', style: PyroTypography.bodyLarge(isDark).copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text('MRN: P-10929 • Male • Age 63', style: PyroTypography.caption(isDark)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildContextSection(
                    title: 'SIGNAL TELEMETRY',
                    isDark: isDark,
                    child: Column(
                      children: [
                        _buildMetricRow('Impedance (Oz)', '1.9 kΩ', PyroColors.statusSuccess, isDark),
                        _buildMetricRow('Signal SNR', '8.4 dB', PyroColors.statusSuccess, isDark),
                        _buildMetricRow('Provider', 'NeuroLab Virtual', PyroColors.medicalBlue, isDark),
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
        crossAxisAlignment: CrossAlignment.start,
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
        return const NeuroLabDashboard(); // NeuroLab Virtual Lab Screen
      default:
        return const DashboardScreen();
    }
  }

  Widget _buildBottomStatusBar(BuildContext context, bool isDark, bool isSimConnected) {
    return Container(
      height: 28,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0D1117) : const Color(0xFFE2E8F0),
        border: Border(top: BorderSide(color: isDark ? PyroColors.darkBorder : PyroColors.lightBorder)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(color: isSimConnected ? PyroColors.statusSuccess : PyroColors.statusDanger, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Text(
                isSimConnected ? 'SIGNAL PROVIDER: NEUROLAB VIRTUAL DEVICE (2500 Hz)' : 'SIGNAL PROVIDER: DISCONNECTED',
                style: PyroTypography.monoData(isDark: isDark, color: isSimConnected ? PyroColors.statusSuccess : PyroColors.statusDanger, fontSize: 10),
              ),
            ],
          ),
          const SizedBox(width: 24),
          Text(
            'SIGNAL IMPEDANCE: ALL CHANNELS < 3.2 kΩ',
            style: PyroTypography.monoData(isDark: isDark, color: const Color(0xFF94A3B8), fontSize: 10),
          ),
          const Spacer(),
          Text(
            'PyroSync NeuroLab Simulation Engine v1.0 | Pyromatics Bio Solutions',
            style: TextStyle(
              fontSize: 10,
              fontFamily: 'Inter',
              color: isDark ? PyroColors.textSecondaryDark : PyroColors.textSecondaryLight,
            ),
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
    final isSelected = screen == currentScreen;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? PyroColors.medicalBlue.withOpacity(0.15) : PyroColors.deepClinicalBlue.withOpacity(0.1))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: isSelected
                ? Border.all(color: PyroColors.medicalBlue.withOpacity(0.4), width: 1)
                : Border.all(color: Colors.transparent),
          ),
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
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected
                      ? (isDark ? PyroColors.textPrimaryDark : PyroColors.deepClinicalBlue)
                      : (isDark ? PyroColors.textSecondaryDark : PyroColors.textSecondaryLight),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const _ThemeButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? PyroColors.medicalBlue.withOpacity(0.2) : PyroColors.deepClinicalBlue)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 12,
              color: isSelected
                  ? (isDark ? PyroColors.medicalBlue : Colors.white)
                  : (isDark ? PyroColors.textSecondaryDark : PyroColors.textSecondaryLight),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? (isDark ? PyroColors.medicalBlue : Colors.white)
                    : (isDark ? PyroColors.textSecondaryDark : PyroColors.textSecondaryLight),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
