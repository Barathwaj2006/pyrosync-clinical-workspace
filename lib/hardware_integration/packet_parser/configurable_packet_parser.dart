import 'dart:typed_data';

class PacketHeaderConfig {
  final List<int> headerBytes;
  final List<int> footerBytes;
  final int payloadLength;
  final int channelCount;

  PacketHeaderConfig({
    required this.headerBytes,
    required this.footerBytes,
    required this.payloadLength,
    required this.channelCount,
  });
}

class ParsedHardwarePacket {
  final int sequenceNumber;
  final int timestampMs;
  final List<double> channelMicrovolts;
  final bool isValidChecksum;

  ParsedHardwarePacket({
    required this.sequenceNumber,
    required this.timestampMs,
    required this.channelMicrovolts,
    required this.isValidChecksum,
  });
}

class ConfigurablePacketParser {
  final PacketHeaderConfig config;

  ConfigurablePacketParser({required this.config});

  ParsedHardwarePacket parseRawBytes(Uint8List rawBytes) {
    if (rawBytes.length < config.payloadLength) {
      return ParsedHardwarePacket(
        sequenceNumber: -1,
        timestampMs: DateTime.now().millisecondsSinceEpoch,
        channelMicrovolts: List.filled(config.channelCount, 0.0),
        isValidChecksum: false,
      );
    }

    final byteData = ByteData.sublistView(rawBytes);
    final seqNum = byteData.getUint16(2, Endian.big);
    final timestampMs = byteData.getUint32(4, Endian.big);

    final channels = <double>[];
    for (int i = 0; i < config.channelCount; i++) {
      final sampleInt24 = byteData.getInt16(8 + (i * 2), Endian.big);
      channels.add(sampleInt24 * 0.0223);
    }

    return ParsedHardwarePacket(
      sequenceNumber: seqNum,
      timestampMs: timestampMs,
      channelMicrovolts: channels,
      isValidChecksum: true,
    );
  }
}
