import 'package:flutter/material.dart';
import '../../design_system/components/pyro_card.dart';
import '../../design_system/components/pyro_waveform_canvas.dart';
import '../../design_system/typography/pyro_typography.dart';
import '../../design_system/colors/pyro_colors.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({Key? key}) : super(key: key);

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAlignment.start,
        children: [
          // Header Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAlignment.start,
                children: [
                  Text('SIGNAL ANALYSIS & SPECTRAL WORKSPACE', style: PyroTypography.heading1(true)),
                  Text('VEP Latency Peak Inspection, FFT Frequency Spectrum & Power Spectral Density (PSD)', style: PyroTypography.body(true)),
                ],
              ),
              Row(
                children: [
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: PyroColors.medicalBlue,
                      side: const BorderSide(color: PyroColors.medicalBlue),
                    ),
                    onPressed: () {},
                    icon: const Icon(Icons.file_download, size: 16),
                    label: const Text('EXPORT SIGNAL DATA (EDF+)'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Analysis Tab Bar
          Container(
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFF121620),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF1E293B)),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: PyroColors.medicalBlue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: PyroColors.medicalBlue.withOpacity(0.4)),
              ),
              labelColor: PyroColors.medicalBlue,
              unselectedLabelColor: const Color(0xFF94A3B8),
              labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Inter'),
              tabs: const [
                Tab(text: 'VEP PEAK LATENCY OVERLAY'),
                Tab(text: 'SPECTRAL FFT & BAND POWER (0-50 Hz)'),
                Tab(text: 'ARTIFACT DETECTION & CLINICAL METRICS'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Tab Body
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildVepPeakTab(),
                _buildFftTab(),
                _buildArtifactMetricsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVepPeakTab() {
    return Column(
      children: [
        // Waveform Viewport
        const Expanded(
          flex: 3,
          child: WaveformCanvas(
            title: 'Superimposed Left Eye vs Right Eye Traces (Oz-Cz)',
            showSecondaryTrace: true,
            p100LatencyPrimary: 101.4,
            p100LatencySecondary: 114.8,
          ),
        ),
        const SizedBox(height: 16),

        // Latency Table
        Expanded(
          flex: 2,
          child: PyroCard(
            child: Column(
              crossAxisAlignment: CrossAlignment.start,
              children: [
                Text('VEP PEAK MEASUREMENTS TABLE', style: PyroTypography.heading2(true)),
                const SizedBox(height: 12),
                Table(
                  border: TableBorder.all(color: const Color(0xFF1E293B)),
                  columnWidths: const {
                    0: FlexColumnWidth(1.5),
                    1: FlexColumnWidth(1),
                    2: FlexColumnWidth(1),
                    3: FlexColumnWidth(1),
                    4: FlexColumnWidth(1.2),
                  },
                  children: [
                    TableRow(
                      decoration: const BoxDecoration(color: Color(0xFF121620)),
                      children: [
                        _buildCell('STIMULUS EYE', isHeader: true),
                        _buildCell('N75 (ms)', isHeader: true),
                        _buildCell('P100 (ms)', isHeader: true),
                        _buildCell('N145 (ms)', isHeader: true),
                        _buildCell('P100-N145 AMP (µV)', isHeader: true),
                      ],
                    ),
                    TableRow(
                      children: [
                        _buildCell('OS (Left Eye)'),
                        _buildCell('74.2 ms'),
                        _buildCell('101.4 ms', color: PyroColors.statusSuccess),
                        _buildCell('142.1 ms'),
                        _buildCell('12.1 µV'),
                      ],
                    ),
                    TableRow(
                      children: [
                        _buildCell('OD (Right Eye)'),
                        _buildCell('78.1 ms'),
                        _buildCell('114.8 ms [!]', color: PyroColors.statusDanger),
                        _buildCell('149.0 ms'),
                        _buildCell('7.2 µV [!]'),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFftTab() {
    return Row(
      children: [
        // FFT Power Graph Simulation (Left)
        Expanded(
          flex: 3,
          child: PyroCard(
            child: Column(
              crossAxisAlignment: CrossAlignment.start,
              children: [
                Text('FAST FOURIER TRANSFORM (FFT) SPECTRAL DENSITY', style: PyroTypography.heading2(true)),
                const SizedBox(height: 12),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF05070A),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF1E293B)),
                    ),
                    child: CustomPaint(
                      painter: _FftPainter(),
                      child: Container(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),

        // EEG Band Power Breakdown (Right)
        Expanded(
          flex: 2,
          child: PyroCard(
            child: Column(
              crossAxisAlignment: CrossAlignment.start,
              children: [
                Text('EEG BAND POWER DISTRIBUTION', style: PyroTypography.heading2(true)),
                const SizedBox(height: 16),
                _buildBandBar('Delta (0.5 - 4 Hz)', '8.2%', PyroColors.deepClinicalBlue, 0.08),
                _buildBandBar('Theta (4 - 8 Hz)', '14.5%', PyroColors.medicalBlue, 0.14),
                _buildBandBar('Alpha (8 - 13 Hz) [Occipital]', '64.1%', PyroColors.statusSuccess, 0.64),
                _buildBandBar('Beta (13 - 30 Hz)', '11.2%', PyroColors.statusWarning, 0.11),
                _buildBandBar('Gamma (30 - 50 Hz)', '2.0%', const Color(0xFF94A3B8), 0.02),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildArtifactMetricsTab() {
    return PyroCard(
      child: Column(
        crossAxisAlignment: CrossAlignment.start,
        children: [
          Text('ARTIFACT DETECTION & CLINICAL MEASUREMENTS', style: PyroTypography.heading2(true)),
          const SizedBox(height: 16),
          _buildMetricRow('EOG Blinks Detected', '2 events (Auto-Rejected)', PyroColors.statusSuccess),
          _buildMetricRow('EMG Muscle Activity Contamination', '0.5% (Very Low)', PyroColors.statusSuccess),
          _buildMetricRow('Line Noise Contamination (50 Hz)', '< 0.1 µV (Notch Active)', PyroColors.statusSuccess),
          _buildMetricRow('Signal-to-Noise Ratio (SNR)', '8.4 dB (High Resolution)', PyroColors.medicalBlue),
        ],
      ),
    );
  }

  Widget _buildCell(String text, {bool isHeader = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Text(
        text,
        style: isHeader
            ? const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8))
            : PyroTypography.monoData(isDark: true, color: color ?? Colors.white, fontSize: 12),
      ),
    );
  }

  Widget _buildBandBar(String label, String pct, Color color, double factor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: Column(
        crossAxisAlignment: CrossAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
              Text(pct, style: PyroTypography.monoData(isDark: true, color: color)),
            ],
          ),
          const SizedBox(height: 6),
          FractionallySizedBox(
            widthFactor: factor,
            child: Container(
              height: 6,
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, String val, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
          Text(val, style: PyroTypography.monoData(isDark: true, color: color, fontSize: 12)),
        ],
      ),
    );
  }
}

class _FftPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final axisPaint = Paint()..color = const Color(0xFF1E293B)..strokeWidth = 1.0;
    canvas.drawLine(Offset(0, h - 20), Offset(w, h - 20), axisPaint);

    final linePaint = Paint()..color = PyroColors.medicalBlue..strokeWidth = 2.0..style = PaintingStyle.stroke;
    final path = Path();

    bool first = true;
    for (double x = 0; x <= w; x += 2) {
      final hz = (x / w) * 50.0;
      double amplitude = 5.0;

      // Peak around Alpha rhythm (10 Hz)
      amplitude += 80.0 * (1.0 / (1.0 + (hz - 10.0) * (hz - 10.0)));

      final y = h - 25 - amplitude * (h / 140);
      if (first) { path.moveTo(x, y); first = false; } else { path.lineTo(x, y); }
    }
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
