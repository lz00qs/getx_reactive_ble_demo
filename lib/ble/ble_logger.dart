import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class BleLogger extends GetxController {
  BleLogger({
    required FlutterReactiveBle ble,
  }) : _ble = ble;

  final FlutterReactiveBle _ble;
  final Rx<List<String>> rxMessages = Rx<List<String>>([]);
  final DateFormat formatter = DateFormat('HH:mm:ss.SSS');

  // List<String> get messages => _logMessages;


  void addToLog(String message) {
    final now = DateTime.now();
    rxMessages.value.add('${formatter.format(now)} - $message');
  }

  void clearLogs() => rxMessages.value.clear();

  bool get verboseLogging => _ble.logLevel == LogLevel.verbose;

  void toggleVerboseLogging() =>
      _ble.logLevel = verboseLogging ? LogLevel.none : LogLevel.verbose;
}
