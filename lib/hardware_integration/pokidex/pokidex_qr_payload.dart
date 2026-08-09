import 'dart:convert';
import 'dart:math';

class PokidexQrPayload {
  final String protocol;
  final int version;
  final String sessionId;
  final String host;
  final int port;
  final String transport;
  final String token;
  final int expiresAt;

  PokidexQrPayload({
    this.protocol = 'pyrosync-pokidex',
    this.version = 1,
    required this.sessionId,
    required this.host,
    this.port = 8765,
    this.transport = 'websocket',
    required this.token,
    required this.expiresAt,
  });

  bool get isExpired => DateTime.now().millisecondsSinceEpoch ~/ 1000 > expiresAt;

  Map<String, dynamic> toJson() {
    return {
      'protocol': protocol,
      'version': version,
      'session_id': sessionId,
      'host': host,
      'port': port,
      'transport': transport,
      'token': token,
      'expires_at': expiresAt,
    };
  }

  String toJsonString() => jsonEncode(toJson());

  factory PokidexQrPayload.fromJsonString(String rawJson) {
    final Map<String, dynamic> map = jsonDecode(rawJson);
    return PokidexQrPayload(
      protocol: map['protocol'] ?? 'pyrosync-pokidex',
      version: map['version'] ?? 1,
      sessionId: map['session_id'] ?? '',
      host: map['host'] ?? '127.0.0.1',
      port: map['port'] ?? 8765,
      transport: map['transport'] ?? 'websocket',
      token: map['token'] ?? '',
      expiresAt: map['expires_at'] ?? 0,
    );
  }

  static String generateRandomToken() {
    final rand = Random.secure();
    final values = List<int>.generate(8, (i) => rand.nextInt(256));
    return values.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  static String generateSessionId() {
    final rand = Random.secure();
    final val = rand.nextInt(90000) + 10000;
    return 'PX-$val';
  }
}
