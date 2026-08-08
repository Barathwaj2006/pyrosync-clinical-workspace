import 'package:flutter/material.dart';
import '../../design_system/components/pyro_card.dart';
import '../../design_system/typography/pyro_typography.dart';
import '../../design_system/colors/pyro_colors.dart';

class PatientsScreen extends StatelessWidget {
  const PatientsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAlignment.start,
                children: [
                  Text('PATIENT DIRECTORY & RECORD ARCHIVE', style: PyroTypography.heading1(true)),
                  Text('Search and inspect historical VEP/EEG recordings and longitudinal latency trends.', style: PyroTypography.body(true)),
                ],
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: PyroColors.medicalBlue,
                  foregroundColor: Colors.black,
                ),
                onPressed: () {},
                icon: const Icon(Icons.person_add, size: 16),
                label: const Text('NEW PATIENT REGISTRATION'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Expanded(
            child: Row(
              children: [
                // Patient Table (Left)
                Expanded(
                  flex: 3,
                  child: PyroCard(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                style: const TextStyle(color: Colors.white, fontSize: 13),
                                decoration: InputDecoration(
                                  hintText: 'Search MRN, Patient Name, DOB...',
                                  hintStyle: const TextStyle(color: Color(0xFF64748B)),
                                  prefixIcon: const Icon(Icons.search, size: 18, color: Color(0xFF64748B)),
                                  filled: true,
                                  fillColor: const Color(0xFF121620),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: ListView(
                            children: [
                              _buildPatientRow('P-10929', 'Arthur Pendelton', '1962-11-04', '2026-08-05', 'VEP Pattern', 'Delayed Latency (R)', true),
                              _buildPatientRow('P-10928', 'Eleanor Vance', '1984-03-12', '2026-08-01', 'VEP Pattern', 'Normal (101.4 ms)', false),
                              _buildPatientRow('P-10930', 'Clara Oswald', '1991-07-22', '2026-08-07', '16-Ch EEG', 'Acquisition Ready', false),
                              _buildPatientRow('P-10931', 'Marcus Brody', '1955-09-18', '2026-07-29', 'Flash VEP', 'Borderline Latency', false),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 24),

                // Selected Patient Detailed Profile (Right)
                Expanded(
                  flex: 2,
                  child: PyroCard(
                    child: Column(
                      crossAxisAlignment: CrossAlignment.start,
                      children: [
                        Text('PATIENT PROFILE: Arthur Pendelton', style: PyroTypography.heading2(true)),
                        Text('MRN: P-10929 • Male • Age 63', style: PyroTypography.body(true)),
                        const SizedBox(height: 16),
                        const Divider(color: Color(0xFF1E293B)),
                        const SizedBox(height: 12),
                        Text('CLINICAL HISTORY', style: PyroTypography.caption(true)),
                        const SizedBox(height: 4),
                        const Text(
                          'Patient presented with optic neuritis in right eye. Baseline VEP recorded 2026-08-05 demonstrated P100 delay (114.8 ms). Follow-up scheduled.',
                          style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                        ),
                        const SizedBox(height: 20),
                        Text('HISTORICAL P100 LATENCY TRAJECTORY', style: PyroTypography.caption(true)),
                        const SizedBox(height: 8),
                        Container(
                          height: 100,
                          decoration: BoxDecoration(
                            color: const Color(0xFF05070A),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFF1E293B)),
                          ),
                          child: Center(
                            child: Text(
                              'Trajectory: Aug 2025 (102ms) ➔ Feb 2026 (104ms) ➔ Aug 2026 (114.8ms)',
                              style: PyroTypography.monoData(isDark: true, fontSize: 11),
                            ),
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

  Widget _buildPatientRow(String mrn, String name, String dob, String testDate, String protocol, String status, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSelected ? PyroColors.medicalBlue.withOpacity(0.1) : const Color(0xFF121620),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isSelected ? PyroColors.medicalBlue : const Color(0xFF1E293B)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
              Text('$mrn • DOB: $dob', style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAlignment.end,
            children: [
              Text(protocol, style: const TextStyle(fontSize: 11, color: Colors.white)),
              Text(status, style: PyroTypography.monoData(isDark: true, color: isSelected ? PyroColors.medicalBlue : const Color(0xFF94A3B8), fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }
}
