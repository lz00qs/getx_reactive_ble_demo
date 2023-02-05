import 'dart:async';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:get/get.dart';
import 'ble_logger.dart';

class BleDeviceConnector extends GetxController {
  BleDeviceConnector({
    required FlutterReactiveBle ble,
  }) : _ble = ble {
    rxBleConnectionState.bindStream(_deviceConnectionController.stream);
  }

  final FlutterReactiveBle _ble;
  final void Function(String message) _logMessage =
      Get.find<BleLogger>().addToLog;

  final rxBleConnectionState = Rx<ConnectionStateUpdate>(
      const ConnectionStateUpdate(
          deviceId: "",
          connectionState: DeviceConnectionState.disconnected,
          failure: null));

  final _deviceConnectionController = StreamController<ConnectionStateUpdate>();

  // ignore: cancel_subscriptions
  late StreamSubscription<ConnectionStateUpdate> _connection;

  Future<void> connect(String deviceId) async {
    _logMessage('Start connecting to $deviceId');
    _connection = _ble.connectToDevice(id: deviceId).listen(
      (update) {
        _logMessage(
            'ConnectionState for device $deviceId : ${update.connectionState}');
        _deviceConnectionController.add(update);
      },
      onError: (Object e) =>
          _logMessage('Connecting to device $deviceId resulted in error $e'),
    );
  }

  Future<void> disconnect(String deviceId) async {
    try {
      _logMessage('disconnecting to device: $deviceId');
      await _connection.cancel();
    } on Exception catch (e, _) {
      _logMessage("Error disconnecting from a device: $e");
    } finally {
      // Since [_connection] subscription is terminated, the "disconnected" state cannot be received and propagated
      _deviceConnectionController.add(
        ConnectionStateUpdate(
          deviceId: deviceId,
          connectionState: DeviceConnectionState.disconnected,
          failure: null,
        ),
      );
    }
  }

  Future<void> streamDispose() async {
    await _deviceConnectionController.close();
  }
}
