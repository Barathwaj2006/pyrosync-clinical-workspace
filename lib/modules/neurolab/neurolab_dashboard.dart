import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../design_system/components/pyro_card.dart';
import '../../design_system/typography/pyro_typography.dart';
import '../../design_system/colors/pyro_colors.dart';
import '../../core_engines/signal_provider/signal_provider_interface.dart';
import 'neurolab_engine.dart';

class NeuroLabDashboard extends ConsumerWidget {
  const NeuroLabDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final labState = ref.watch(neurolabEngineProvider);
    final labNotifier = ref.read(neurolabEngineProvider.notifier);
    final device = labState.deviceTelemetry;
    final isConnected = device.connectionState == SignalConnectionState.connected;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.science, color: PyroColors.medicalBlue, size: 24),
                      const SizedBox(width: 10),
                      Text('NEUROLAB VIRTUAL NEUROPHYSIOLOGY LABORATORY', style: PyroTypography.heading1(true)),
                    ],
                  ),
                  Text('Hardware-Free Biosignal Simulation, Training Scenarios & Artifact Injection System', style: PyroTypography.body(true)),
                ],
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isConnected ? PyroColors.statusDanger : PyroColors.statusSuccess,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                onPressed: () => labNotifier.toggleDeviceConnection(),
                icon: Icon(isConnected ? Icons.power_off : Icons.power, size: 18),
                label: Text(
                  isConnected ? 'DISCONNECT VIRTUAL DEVICE' : 'CONNECT VIRTUAL DEVICE',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Expanded(
            child: Row(
              children: [
                // Left Column: Virtual Device Telemetry & Preset Library
                Expanded(
                  flex: 3,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Virtual Device Card
                        PyroCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('VIRTUAL ACQUISITION DEVICE', style: PyroTypography.heading2(true)),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isConnected ? PyroColors.statusSuccess.withValues(alpha: 0.15) : PyroColors.statusDanger.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: isConnected ? PyroColors.statusSuccess : PyroColors.statusDanger),
                                    ),
                                    child: Text(
                                      isConnected ? '● CONNECTED (2500 Hz)' : '○ DISCONNECTED',
                                      style: PyroTypography.monoData(isDark: true, color: isConnected ? PyroColors.statusSuccess : PyroColors.statusDanger, fontSize: 10),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _buildDeviceMetric('FIRMWARE', device.firmwareVersion),
                                  _buildDeviceMetric('BATTERY', '${device.batteryPercentage.toStringAsFixed(1)}%'),
                                  _buildDeviceMetric('TEMP', '${device.temperatureCelsius.toStringAsFixed(1)}°C'),
                                  _buildDeviceMetric('CHANNELS', '${device.activeChannels} (10-20 System)'),
                                ],
                              ),
                              const SizedBox(height: 12),
                              const Divider(color: Color(0xFF1E293B)),
                              Text('VIRTUAL DEVICE LOGS', style: PyroTypography.caption(true)),
                              const SizedBox(height: 6),
                              Container(
                                height: 70,
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF05070A),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: ListView.builder(
                                  itemCount: device.deviceLogs.length,
                                  itemBuilder: (context, index) => Text(
                                    device.deviceLogs[index],
                                    style: PyroTypography.monoData(isDark: true, color: const Color(0xFF94A3B8), fontSize: 10),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Training Preset Library Card
                        PyroCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('SIMULATION & TRAINING PRESET LIBRARY', style: PyroTypography.heading2(true)),
                              const SizedBox(height: 12),
                              _buildPresetTile('Normal VEP Pattern Reversal (Oz-Cz)', labState.selectedLibraryPreset, labNotifier),
                              _buildPresetTile('Poor Electrode Contact (High Noise)', labState.selectedLibraryPreset, labNotifier),
                              _buildPresetTile('Blink Contamination Case', labState.selectedLibraryPreset, labNotifier),
                              _buildPresetTile('Resting EEG (Eyes Closed Alpha 10Hz)', labState.selectedLibraryPreset, labNotifier),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 20),

                // Right Column: EEG Rhythm Generator & Artifact Controls
                Expanded(
                  flex: 3,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Artifact Generator Card
                        PyroCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('ARTIFACT GENERATOR (INJECT NOISE)', style: PyroTypography.heading2(true)),
                              const SizedBox(height: 16),
                              _buildArtifactControl(
                                label: 'Eye Blink Contamination (EOG)',
                                enabled: labState.isBlinkArtifactEnabled,
                                severity: labState.blinkSeverity,
                                onToggle: (val) => labNotifier.toggleArtifact(blink: val),
                                onSeverityChanged: (val) => labNotifier.setArtifactSeverity(blink: val),
                              ),
                              _buildArtifactControl(
                                label: 'Muscle Contamination (EMG)',
                                enabled: labState.isMuscleArtifactEnabled,
                                severity: labState.muscleSeverity,
                                onToggle: (val) => labNotifier.toggleArtifact(muscle: val),
                                onSeverityChanged: (val) => labNotifier.setArtifactSeverity(muscle: val),
                              ),
                              _buildArtifactControl(
                                label: 'Powerline Noise (50 Hz Interference)',
                                enabled: labState.isLineNoiseEnabled,
                                severity: labState.lineNoiseSeverity,
                                onToggle: (val) => labNotifier.toggleArtifact(lineNoise: val),
                                onSeverityChanged: (val) => labNotifier.setArtifactSeverity(lineNoise: val),
                              ),
                              _buildArtifactControl(
                                label: 'Electrode Baseline Drift',
                                enabled: labState.isBaselineDriftEnabled,
                                severity: labState.driftSeverity,
                                onToggle: (val) => labNotifier.toggleArtifact(drift: val),
                                onSeverityChanged: (val) => labNotifier.setArtifactSeverity(drift: val),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // EEG Rhythm Generator Card
                        PyroCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('EEG RHYTHM MIXER', style: PyroTypography.heading2(true)),
                              const SizedBox(height: 12),
                              _buildRhythmSlider('Alpha Rhythm (8 - 13 Hz)', labState.alphaGain, (val) => labNotifier.setRhythmGains(alpha: val)),
                              _buildRhythmSlider('Beta Rhythm (13 - 30 Hz)', labState.betaGain, (val) => labNotifier.setRhythmGains(beta: val)),
                              _buildRhythmSlider('Theta Rhythm (4 - 8 Hz)', labState.thetaGain, (val) => labNotifier.setRhythmGains(theta: val)),
                            ],
                          ),
                        ),
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

  Widget _buildDeviceMetric(String label, String val) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
        const SizedBox(height: 4),
        Text(val, style: PyroTypography.monoData(isDark: true, fontSize: 12)),
      ],
    );
  }

  Widget _buildPresetTile(String title, String activePreset, NeuroLabEngineNotifier notifier) {
    final isSelected = title == activePreset;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSelected ? PyroColors.medicalBlue.withValues(alpha: 0.15) : const Color(0xFF121620),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isSelected ? PyroColors.medicalBlue : const Color(0xFF1E293B)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: Colors.white)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isSelected ? PyroColors.medicalBlue : const Color(0xFF1E293B),
              foregroundColor: isSelected ? Colors.black : Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            ),
            onPressed: () => notifier.selectPreset(title),
            child: Text(isSelected ? 'LOADED' : 'LOAD SCENARIO', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildArtifactControl({
    required String label,
    required bool enabled,
    required double severity,
    required ValueChanged<bool> onToggle,
    required ValueChanged<double> onSeverityChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: Colors.white)),
              Switch(
                value: enabled,
                activeThumbColor: PyroColors.statusWarning,
                onChanged: onToggle,
              ),
            ],
          ),
          if (enabled) ...[
            Row(
              children: [
                const Text('Severity: ', style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                Expanded(
                  child: Slider(
                    value: severity,
                    activeColor: PyroColors.statusWarning,
                    onChanged: onSeverityChanged,
                  ),
                ),
                Text('${(severity * 100).toInt()}%', style: PyroTypography.monoData(isDark: true, color: PyroColors.statusWarning, fontSize: 10)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRhythmSlider(String label, double val, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
            Text('${(val * 100).toInt()}%', style: PyroTypography.monoData(isDark: true, fontSize: 11)),
          ],
        ),
        Slider(
          value: val,
          activeColor: PyroColors.medicalBlue,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
