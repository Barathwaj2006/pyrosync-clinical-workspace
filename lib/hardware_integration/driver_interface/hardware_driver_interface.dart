import 'dart:async';
import 'dart:typed_data';
import '../../device_connectivity/models/device_models.dart';

abstract class IHardwareDriver {
  String get driverId;
  String get driverName;
  
  Future<bool> connect();
  Future<bool> disconnect();
  
  Future<bool> startStreaming();
  Future<bool> stopStreaming();
  
  Stream<Uint8List> readPacketStream();
  Future<bool> writeCommand(Uint8List commandBytes);
  
  DeviceInfo getDeviceInfo();
  String getFirmwareVersion();
  double getSamplingRateHz();
  int getChannelCount();
}
