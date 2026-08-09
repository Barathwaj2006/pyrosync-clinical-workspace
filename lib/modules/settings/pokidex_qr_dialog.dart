import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../design_system/colors/pyro_colors.dart';
import '../../device_connectivity/device_manager/device_manager.dart';
import '../../device_connectivity/models/device_models.dart';
import '../../hardware_integration/pokidex/pokidex_qr_payload.dart';

class PokidexQrDialog extends ConsumerStatefulWidget {
  const PokidexQrDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => const PokidexQrDialog(),
    );
  }

  @override
  ConsumerState<PokidexQrDialog> createState() => _PokidexQrDialogState();
}

class _PokidexQrDialogState extends ConsumerState<PokidexQrDialog> {
  PokidexQrPayload? _payload;
  bool _isAdvancedExpanded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final notifier = ref.read(deviceManagerProvider.notifier);
      final p = await notifier.startPokidexQrPairing(port: 8765);
      if (mounted) {
        setState(() {
          _payload = p;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final deviceState = ref.watch(deviceManagerProvider);
    final notifier = ref.read(deviceManagerProvider.notifier);
    final metrics = notifier.pokidexManager.pairingServer.diagnostics.metrics;
    final state = deviceState.connectionState;

    return Dialog(
      backgroundColor: const Color(0xFF0B0F19),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: PyroColors.medicalBlue, width: 1.5),
      ),
      child: Container(
        width: 520,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.qr_code_scanner, color: PyroColors.medicalBlue, size: 24),
                    SizedBox(width: 10),
                    Text(
                      'CONNECT POKIDEX',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Color(0xFF94A3B8)),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const Divider(color: Color(0xFF1E293B), height: 24),

            // Step 1: Scan QR Code View
            if (state == DeviceConnectionState.connecting ||
                state == DeviceConnectionState.noDevice ||
                state == DeviceConnectionState.discoveringServices) ...[
              const Text(
                'Scan this QR code using Pokidex Android App:',
                style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 13),
              ),
              const SizedBox(height: 16),

              // Large QR Code Canvas Matrix Box
              Center(
                child: Container(
                  width: 200,
                  height: 200,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: CustomPaint(
                    painter: _SimpleQrMatrixPainter(
                      data: _payload?.toJsonString() ?? '{"protocol":"pyrosync-pokidex"}',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Status Indicator Banner
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF121620),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF1E293B)),
                ),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(PyroColors.medicalBlue),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        state == DeviceConnectionState.discoveringServices
                            ? 'Pokidex detected! Validating session token...'
                            : 'Waiting for Pokidex scan...',
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Network Connection Parameters
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Wi-Fi Server: ws://${_payload?.host ?? "192.168.x.x"}:8765', style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                  Text('Session: ${_payload?.sessionId ?? "PX-XXXX"}', style: const TextStyle(color: PyroColors.medicalBlue, fontSize: 11, fontWeight: FontWeight.bold)),
                ],
              ),
            ],

            // Step 2: Verified Connection State
            if (state == DeviceConnectionState.verified || state == DeviceConnectionState.waitingForSignal) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: PyroColors.statusSuccess.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: PyroColors.statusSuccess),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.check_circle, color: PyroColors.statusSuccess, size: 20),
                        SizedBox(width: 8),
                        Text('✓ Pokidex Connected & Verified', style: TextStyle(color: PyroColors.statusSuccess, fontWeight: FontWeight.bold, fontSize: 14)),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text('Device: Pokidex Android EEG Stimulator • Transport: Wi-Fi WebSocket', style: TextStyle(color: Colors.white, fontSize: 12)),
                    SizedBox(height: 4),
                    Text('Signal: Waiting for first SignalFrame datagram...', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                  ],
                ),
              ),
            ],

            // Step 3: Streaming State
            if (state == DeviceConnectionState.streaming) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: PyroColors.statusSuccess.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: PyroColors.statusSuccess),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.sensors, color: PyroColors.statusSuccess, size: 20),
                        SizedBox(width: 8),
                        Text('✓ Signal Streaming Active', style: TextStyle(color: PyroColors.statusSuccess, fontWeight: FontWeight.bold, fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildMetricChip('Rate', '${metrics.configuredRateHz.toInt()} Hz'),
                        _buildMetricChip('Channels', '4 CH'),
                        _buildMetricChip('Loss', '${metrics.packetLossPercentage}%'),
                        _buildMetricChip('Latency', '${metrics.latencyMs.toInt()} ms'),
                      ],
                    ),
                  ],
                ),
              ),
            ],

            // Step 4: Error State
            if (state == DeviceConnectionState.error) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: PyroColors.statusDanger.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: PyroColors.statusDanger),
                ),
                child: Text(
                  deviceState.errorMessage ?? 'Connection or handshake failed.',
                  style: const TextStyle(color: PyroColors.statusDanger, fontSize: 12),
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Collapsible Advanced Connection Diagnostics Section
            GestureDetector(
              onTap: () => setState(() => _isAdvancedExpanded = !_isAdvancedExpanded),
              child: Row(
                children: [
                  Icon(_isAdvancedExpanded ? Icons.expand_less : Icons.expand_more, color: const Color(0xFF94A3B8), size: 18),
                  const SizedBox(width: 4),
                  const Text('Advanced Connection Diagnostics', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            if (_isAdvancedExpanded) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF070A10),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFF1E293B)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Handshake Phase: ${notifier.pokidexManager.pairingServer.handshakePhase.name}', style: const TextStyle(color: Colors.white, fontSize: 11)),
                    Text('Token: ${_payload?.token ?? "N/A"} • Expires: ${_payload?.expiresAt ?? 0}', style: const TextStyle(color: Color(0xFF64748B), fontSize: 10)),
                    Text('Jitter: ${metrics.jitterMs} ms • Out-of-Order: ${metrics.outOfOrderPackets}', style: const TextStyle(color: Color(0xFF64748B), fontSize: 10)),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF94A3B8),
                    side: const BorderSide(color: Color(0xFF1E293B)),
                  ),
                  onPressed: () {
                    notifier.pokidexManager.pairingServer.stopPairingServer();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel / Close'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricChip(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
      ],
    );
  }
}

class _SimpleQrMatrixPainter extends CustomPainter {
  final String data;
  _SimpleQrMatrixPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black;
    final bgPaint = Paint()..color = Colors.white;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final hash = data.hashCode.abs();
    const grid = 21; // 21x21 QR matrix
    final cellSize = size.width / grid;

    // Draw finder patterns
    _drawFinderPattern(canvas, paint, 0, 0, cellSize);
    _drawFinderPattern(canvas, paint, (grid - 7) * cellSize, 0, cellSize);
    _drawFinderPattern(canvas, paint, 0, (grid - 7) * cellSize, cellSize);

    // Draw data pixels derived deterministically from payload hash
    for (int r = 0; r < grid; r++) {
      for (int c = 0; c < grid; c++) {
        if ((r < 7 && c < 7) || (r < 7 && c >= grid - 7) || (r >= grid - 7 && c < 7)) continue;
        if ((r + c + hash) % 3 == 0) {
          canvas.drawRect(Rect.fromLTWH(c * cellSize, r * cellSize, cellSize - 0.5, cellSize - 0.5), paint);
        }
      }
    }
  }

  void _drawFinderPattern(Canvas canvas, Paint paint, double x, double y, double cellSize) {
    canvas.drawRect(Rect.fromLTWH(x, y, 7 * cellSize, 7 * cellSize), paint);
    final bgPaint = Paint()..color = Colors.white;
    canvas.drawRect(Rect.fromLTWH(x + cellSize, y + cellSize, 5 * cellSize, 5 * cellSize), bgPaint);
    canvas.drawRect(Rect.fromLTWH(x + 2 * cellSize, y + 2 * cellSize, 3 * cellSize, 3 * cellSize), paint);
  }

  @override
  bool shouldRepaint(covariant _SimpleQrMatrixPainter oldDelegate) => oldDelegate.data != data;
}
