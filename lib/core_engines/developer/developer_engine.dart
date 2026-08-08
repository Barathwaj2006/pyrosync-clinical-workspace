import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum LogType {
  navigation,
  session,
  signal,
  ai,
  performance,
  error,
}

class DeveloperLogEntry {
  final LogType type;
  final String message;
  final DateTime timestamp;

  DeveloperLogEntry({
    required this.type,
    required this.message,
    required this.timestamp,
  });
}

class DeveloperEngineState {
  final bool isOverlayVisible;
  final List<DeveloperLogEntry> logs;
  final double memoryUsageMb;
  final double fps;

  DeveloperEngineState({
    required this.isOverlayVisible,
    required this.logs,
    required this.memoryUsageMb,
    required this.fps,
  });
}

final developerEngineProvider = StateNotifierProvider<DeveloperEngineNotifier, DeveloperEngineState>((ref) {
  return DeveloperEngineNotifier();
});

class DeveloperEngineNotifier extends StateNotifier<DeveloperEngineState> {
  DeveloperEngineNotifier()
      : super(
          DeveloperEngineState(
            isOverlayVisible: false,
            logs: [
              DeveloperLogEntry(type: LogType.navigation, message: 'App launched. Shell initialized.', timestamp: DateTime.now()),
              DeveloperLogEntry(type: LogType.session, message: 'Session SES-2026-0807 loaded for Patient P-10929.', timestamp: DateTime.now()),
              DeveloperLogEntry(type: LogType.signal, message: 'Hardware provider COM3 attached (2500 Hz).', timestamp: DateTime.now()),
              DeveloperLogEntry(type: LogType.ai, message: 'AI Quality Engine initialized (Model v2.1-v).', timestamp: DateTime.now()),
            ],
            memoryUsageMb: 84.2,
            fps: 60.0,
          ),
        );

  void toggleOverlay() {
    state = DeveloperEngineState(
      isOverlayVisible: !state.isOverlayVisible,
      logs: state.logs,
      memoryUsageMb: state.memoryUsageMb,
      fps: state.fps,
    );
  }

  void log(LogType type, String message) {
    final entry = DeveloperLogEntry(type: type, message: message, timestamp: DateTime.now());
    state = DeveloperEngineState(
      isOverlayVisible: state.isOverlayVisible,
      logs: [entry, ...state.logs],
      memoryUsageMb: state.memoryUsageMb,
      fps: state.fps,
    );
  }
}

// Global Keyboard Shortcut Listener Widget for CTRL + SHIFT + D
class DeveloperShortcutListener extends ConsumerWidget {
  final Widget child;

  const DeveloperShortcutListener({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Focus(
      autofocus: true,
      onKey: (node, event) {
        if (event is RawKeyDownEvent) {
          final isControl = event.isControlPressed;
          final isShift = event.isShiftPressed;
          if (isControl && isShift && event.logicalKey == LogicalKeyboardKey.keyD) {
            ref.read(developerEngineProvider.notifier).toggleOverlay();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: Stack(
        children: [
          child,
          const _DeveloperOverlayWidget(),
        ],
      ),
    );
  }
}

class _DeveloperOverlayWidget extends ConsumerWidget {
  const _DeveloperOverlayWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devState = ref.watch(developerEngineProvider);

    if (!devState.isOverlayVisible) return const SizedBox.shrink();

    return Positioned(
      bottom: 40,
      right: 20,
      width: 480,
      height: 380,
      child: Material(
        elevation: 16,
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFA0A0D12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF00E5FF), width: 1.5),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.bug_report, size: 16, color: Color(0xFF00E5FF)),
                      const SizedBox(width: 8),
                      const Text(
                        'PYROSYNC DEVELOPER ENGINE (CTRL+SHIFT+D)',
                        style: TextStyle(fontFamily: 'RobotoMono', fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF00E5FF)),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 16, color: Colors.white),
                    onPressed: () => ref.read(developerEngineProvider.notifier).toggleOverlay(),
                  ),
                ],
              ),
              const Divider(color: Color(0xFF1E293B)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text('RAM: ${devState.memoryUsageMb.toStringAsFixed(1)} MB', style: const TextStyle(fontFamily: 'RobotoMono', fontSize: 10, color: Color(0xFF00E676))),
                  Text('FPS: ${devState.fps.toStringAsFixed(0)} Hz', style: const TextStyle(fontFamily: 'RobotoMono', fontSize: 10, color: Color(0xFF00E676))),
                  Text('LOGS: ${devState.logs.length}', style: const TextStyle(fontFamily: 'RobotoMono', fontSize: 10, color: Color(0xFF94A3B8))),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: const Color(0xFF05070A), borderRadius: BorderRadius.circular(6)),
                  child: ListView.builder(
                    itemCount: devState.logs.length,
                    itemBuilder: (context, index) {
                      final log = devState.logs[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Text(
                          '[${log.type.name.toUpperCase()}] ${log.message}',
                          style: TextStyle(
                            fontFamily: 'RobotoMono',
                            fontSize: 10,
                            color: log.type == LogType.error ? Colors.red : (log.type == LogType.ai ? Colors.purpleAccent : const Color(0xFF94A3B8)),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
