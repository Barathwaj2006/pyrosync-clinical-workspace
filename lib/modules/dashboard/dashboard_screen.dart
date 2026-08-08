import 'package:flutter/material.dart';
import '../../design_system/components/pyro_card.dart';
import '../../design_system/typography/pyro_typography.dart';
import '../../design_system/colors/pyro_colors.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAlignment.start,
        children: [
          Text(
            'DOCTOR COMMAND CENTER',
            style: PyroTypography.heading1(true),
          ),
          Text(
            'Welcome back, Dr. Elena Vance (MD) — 4 patient sessions queued for today.',
            style: PyroTypography.body(true),
          ),
          const SizedBox(height: 24),

          // Top Metric Cards Row
          Row(
            children: [
              Expanded(
                child: PyroCard(
                  child: Column(
                    crossAxisAlignment: CrossAlignment.start,
                    children: [
                      Text('SESSIONS COMPLETED', style: PyroTypography.caption(true)),
                      const SizedBox(height: 8),
                      Text('6', style: PyroTypography.display(true).copyWith(color: PyroColors.medicalBlue)),
                      Text('Target: 8 sessions', style: PyroTypography.caption(true)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: PyroCard(
                  child: Column(
                    crossAxisAlignment: CrossAlignment.start,
                    children: [
                      Text('AVG P100 LATENCY', style: PyroTypography.caption(true)),
                      const SizedBox(height: 8),
                      Text('101.4 ms', style: PyroTypography.display(true).copyWith(color: PyroColors.statusSuccess)),
                      Text('Normative limits: 95-108 ms', style: PyroTypography.caption(true)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: PyroCard(
                  child: Column(
                    crossAxisAlignment: CrossAlignment.start,
                    children: [
                      Text('AI QUALITY NOTIFICATIONS', style: PyroTypography.caption(true)),
                      const SizedBox(height: 8),
                      Text('1 Pending', style: PyroTypography.display(true).copyWith(color: PyroColors.statusWarning)),
                      Text('Unilateral delay detected', style: PyroTypography.caption(true)),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Main Queue & Recent Sessions
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: PyroCard(
                    child: Column(
                      crossAxisAlignment: CrossAlignment.start,
                      children: [
                        Text('TODAY\'S PATIENT APPOINTMENT QUEUE', style: PyroTypography.heading2(true)),
                        const SizedBox(height: 16),
                        _buildAppointmentRow('09:30 AM', 'Marcus Brody', 'MRN: P-88390', 'Pattern Reversal VEP', 'Ready'),
                        _buildAppointmentRow('10:45 AM', 'Sarah Connor', 'MRN: P-88391', 'Routine 16-Ch EEG', 'Acquiring'),
                        _buildAppointmentRow('01:15 PM', 'David Miller', 'MRN: P-88392', 'Flash VEP Protocol', 'Scheduled'),
                        _buildAppointmentRow('03:00 PM', 'Clara Oswald', 'MRN: P-88393', 'VEP Follow-up', 'Scheduled'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: PyroCard(
                    child: Column(
                      crossAxisAlignment: CrossAlignment.start,
                      children: [
                        Text('SYSTEM HARDWARE STATUS', style: PyroTypography.heading2(true)),
                        const SizedBox(height: 16),
                        _buildTelemetryItem('Amplifier Sampling', '2500 Hz (COM3)'),
                        _buildTelemetryItem('Stimulus Monitor', 'Pattern Gen @ 60Hz'),
                        _buildTelemetryItem('Signal DSP Engine', 'Notch 50Hz ACTIVE'),
                        _buildTelemetryItem('Impedance Check', 'All < 3.2 kΩ (Pass)'),
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

  Widget _buildAppointmentRow(String time, String name, String mrn, String protocol, String status) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
              Text(time, style: PyroTypography.monoData(isDark: true, fontSize: 11)),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
                  Text('$mrn • $protocol', style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: PyroColors.medicalBlue.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: PyroColors.medicalBlue.withOpacity(0.4)),
            ),
            child: Text(status, style: PyroTypography.monoData(isDark: true, fontSize: 10)),
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
}
