import 'package:flutter_riverpod/flutter_riverpod.dart';

enum NotificationSeverity {
  success,
  warning,
  critical,
  info,
}

class PyroNotification {
  final String id;
  final String title;
  final String message;
  final NotificationSeverity severity;
  final DateTime timestamp;
  final bool isRead;

  PyroNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.severity,
    required this.timestamp,
    this.isRead = false,
  });

  PyroNotification markRead() => PyroNotification(
        id: id,
        title: title,
        message: message,
        severity: severity,
        timestamp: timestamp,
        isRead: true,
      );
}

final notificationEngineProvider = StateNotifierProvider<NotificationEngineNotifier, List<PyroNotification>>((ref) {
  return NotificationEngineNotifier();
});

class NotificationEngineNotifier extends StateNotifier<List<PyroNotification>> {
  NotificationEngineNotifier()
      : super([
          PyroNotification(
            id: 'NOTIF-101',
            title: 'Unilateral VEP Delay Detected',
            message: 'Right eye P100 latency (114.8 ms) exceeds normal range.',
            severity: NotificationSeverity.warning,
            timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
          ),
          PyroNotification(
            id: 'NOTIF-102',
            title: 'System Initialized',
            message: 'PyroSync workspace ready. Hardware state: Disconnected.',
            severity: NotificationSeverity.info,
            timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
          ),
        ]);

  void pushNotification({
    required String title,
    required String message,
    required NotificationSeverity severity,
  }) {
    final notif = PyroNotification(
      id: 'NOTIF-${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      message: message,
      severity: severity,
      timestamp: DateTime.now(),
    );
    state = [notif, ...state];
  }

  void markAllRead() {
    state = state.map((n) => n.markRead()).toList();
  }
}
