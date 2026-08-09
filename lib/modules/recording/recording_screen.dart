import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../design_system/components/pyro_card.dart';
import '../../design_system/typography/pyro_typography.dart';
import '../../design_system/colors/pyro_colors.dart';
import '../../device_connectivity/device_manager/device_manager.dart';
import '../../core_engines/session/session_engine.dart';
import '../../core_engines/patient/patient_engine.dart';
import '../../navigation/navigation_provider.dart';
import '../../core/widgets/waveform_canvas.dart';

class RecordingScreen extends ConsumerStatefulWidget {
  const RecordingScreen({super.key});

  @override
  ConsumerState<RecordingScreen> createState() => _RecordingScreenState();
}

class _RecordingScreenState extends ConsumerState<RecordingScreen> {
  bool _isAcquiring = false;
  double _sweepSpeed = 30.0; // 15, 30, 60 mm/s
  final String _selectedEye = 'OD (Right Eye)';

  @override
  Widget build(BuildContext context) {
    final deviceState = ref.watch(deviceManagerProvider);
    final sessionState = ref.watch(sessionEngineProvider);
    final patientState = ref.watch(patientEngineProvider);
    final activeSession = sessionState.activeSession;
    final activePatient = patientState.activePatient;

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
                  Text('REAL-TIME BIOSIGNAL RECORDING WORKSPACE', style: PyroTypography.heading1(true)),
                  Text(
                    activeSession != null
                        ? 'Session ${activeSession.sessionId} • Patient: ${activeSession.patientName} • Protocol: ${activeSession.protocolName}'
                        : 'No session active — Select a patient session to associate recording data.',
                    style: PyroTypography.body(true).copyWith(color: const Color(0xFF94A3B8)),
                  ),
                ],
              ),
              if (deviceState.isConnected) ...[
                Row(
                  children: [
                    // Sweep speed selector toolbar
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF151C2C),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF1E293B)),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        children: [15.0, 30.0, 60.0].map((speed) {
                          final isSelected = _sweepSpeed == speed;
                          return GestureDetector(
                            onTap: () => setState(() => _sweepSpeed = speed),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              decoration: BoxDecoration(
                                color: isSelected ? PyroColors.medicalBlue.withValues(alpha: 0.2) : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: isSelected ? PyroColors.medicalBlue : Colors.transparent),
                              ),
                              child: Text(
                                '${speed.toInt()} mm/s',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  color: isSelected ? PyroColors.medicalBlue : const Color(0xFF94A3B8),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(width: 12),

                    if (deviceState.isConnected)
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isAcquiring ? PyroColors.statusDanger : PyroColors.statusSuccess,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        icon: Icon(_isAcquiring ? Icons.stop : Icons.play_arrow, size: 18),
                        label: Text(_isAcquiring ? 'Stop Acquisition' : 'Start Acquisition', style: const TextStyle(fontWeight: FontWeight.bold)),
                        onPressed: () {
                          setState(() => _isAcquiring = !_isAcquiring);
                          if (_isAcquiring && activeSession != null) {
                            ref.read(sessionEngineProvider.notifier).transitionLifecycle(SessionLifecycle.recording);
                          } else if (!_isAcquiring && activeSession != null) {
                            ref.read(sessionEngineProvider.notifier).transitionLifecycle(SessionLifecycle.analyzing);
                          }
                        },
                      ),
                  ],
                ),
              ],
            ],
          ),
          const SizedBox(height: 20),

          // Main Recording Content Area
          Expanded(
            child: !deviceState.isConnected
                ? _buildDisconnectedState(context, ref)
                : Row(
                    children: [
                      // Oscilloscope Waveform Viewport
                      Expanded(
                        flex: 3,
                        child: PyroCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('16-CHANNEL BIOSIGNAL OSCILLOSCOPE (2500 Hz)', style: PyroTypography.heading2(true)),
                                  Text('Sweep Speed: ${_sweepSpeed.toInt()} mm/s | Mode: ${_isAcquiring ? "LIVE ACQUISITION" : "STANDBY"}', style: const TextStyle(fontSize: 11, color: PyroColors.medicalBlue, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Expanded(
                                child: WaveformCanvas(
                                  title: '16-CHANNEL BIOSIGNAL OSCILLOSCOPE (2500 Hz)',
                                  showSecondaryTrace: _isAcquiring,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Acquisition Parameters Side Panel
                      Expanded(
                        child: PyroCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('ACQUISITION PARAMETERS', style: PyroTypography.heading2(true)),
                              const SizedBox(height: 16),
                              _buildParamRow('Sampling Frequency', '${deviceState.activeDeviceInfo?.samplingRateHz ?? 2500} Hz'),
                              _buildParamRow('Active Hardware', deviceState.activeDeviceInfo?.deviceName ?? 'BioAmp USB'),
                              _buildParamRow('High-Pass Filter', '1.0 Hz'),
                              _buildParamRow('Low-Pass Filter', '100 Hz'),
                              _buildParamRow('Notch Filter', '50 Hz'),
                              _buildParamRow('Impedance (Oz)', '1.9 kΩ (PASS)'),
                              const Spacer(),
                              if (activeSession != null && !_isAcquiring) ...[
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(backgroundColor: PyroColors.medicalBlue, foregroundColor: Colors.black),
                                    icon: const Icon(Icons.analytics, size: 16),
                                    label: const Text('Proceed to Analysis →'),
                                    onPressed: () {
                                      ref.read(currentScreenProvider.notifier).navigateTo(PyroScreen.analysis);
                                    },
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

  Widget _buildDisconnectedState(BuildContext context, WidgetRef ref) {
    return PyroCard(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.usb_off_outlined, size: 64, color: PyroColors.statusWarning),
            const SizedBox(height: 16),
            const Text(
              'No acquisition device connected.',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
            ),
            const SizedBox(height: 8),
            const Text(
              'Connect and verify a compatible device in Settings → Device & Hardware before recording.',
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: PyroColors.medicalBlue,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              ),
              icon: const Icon(Icons.settings_input_composite, size: 18),
              label: const Text('Go to Settings → Device & Hardware', style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () {
                ref.read(currentScreenProvider.notifier).navigateTo(PyroScreen.settings);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParamRow(String label, String value) {
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
}
