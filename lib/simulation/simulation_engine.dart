import 'dart:async';
import 'dart:math' as math;

abstract class ISignalSourceProvider {
  String get providerName;
  bool get isConnected;
  Stream<List<double>> get signalStream;
  Future<void> connect();
  Future<void> disconnect();
}

class SyntheticSimulationProvider implements ISignalSourceProvider {
  @override
  final String providerName = "Synthetic VEP Signal Generator v1.0";
  
  bool _connected = false;
  StreamController<List<double>>? _controller;
  Timer? _timer;
  int _sweepCounter = 0;

  @override
  bool get isConnected => _connected;

  @override
  Stream<List<double>> get signalStream => _controller?.stream ?? const Stream.empty();

  @override
  Future<void> connect() async {
    _connected = true;
    _controller = StreamController<List<double>>.broadcast();
    _sweepCounter = 0;

    _timer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      _sweepCounter++;
      final signal = _generateVepSweep(_sweepCounter);
      _controller?.add(signal);
    });
  }

  @override
  Future<void> disconnect() async {
    _connected = false;
    _timer?.cancel();
    await _controller?.close();
  }

  List<double> _generateVepSweep(int sweepIndex) {
    // Generates 250 sample points representing a 250ms VEP trace sampled at 1000Hz
    List<double> samples = [];
    final random = math.Random();

    for (int ms = 0; ms < 250; ms++) {
      double y = 0.0;
      
      // N75 dip
      final n75Dist = ms - 74.0;
      y -= 20.0 * math.exp(-math.pow(n75Dist / 10.0, 2));

      // P100 peak (101.4 ms)
      final p100Dist = ms - 101.4;
      y += 60.0 * math.exp(-math.pow(p100Dist / 12.0, 2));

      // N145 dip
      final n145Dist = ms - 145.0;
      y -= 30.0 * math.exp(-math.pow(n145Dist / 16.0, 2));

      // Synthetic noise / alpha rhythm
      final noise = (random.nextDouble() - 0.5) * 4.0;
      y += noise;

      samples.add(y);
    }
    return samples;
  }
}
