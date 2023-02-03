import 'dart:async';

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:get/get.dart';
import 'package:meta/meta.dart';

import 'ble_logger.dart';

class BleScanner extends GetxController {
  BleScanner({
    required FlutterReactiveBle ble,
  }) : _ble = ble {
    rxBleScannerState.bindStream(_stateStreamController.stream);
  }

  final FlutterReactiveBle _ble;
  final void Function(String message) _logMessage =
      Get.find<BleLogger>().addToLog;
  final StreamController<BleScannerState> _stateStreamController =
      StreamController();

  StreamSubscription? _subscription;

  final rxBleScannerState = Rx<BleScannerState?>(null);

  final _devices = <DiscoveredDevice>[];

  void startScan(List<Uuid> serviceIds) {
    _logMessage('Start ble discovery');
    _devices.clear();
    _subscription?.cancel();
    _subscription =
        _ble.scanForDevices(withServices: serviceIds).listen((device) {
      final knownDeviceIndex = _devices.indexWhere((d) => d.id == device.id);
      if (knownDeviceIndex >= 0) {
        _devices[knownDeviceIndex] = device;
      } else {
        _devices.add(device);
      }
      _pushState();
    }, onError: (Object e) => _logMessage('Device scan fails with error: $e'));
    _pushState();
  }

  void _pushState() {
    _stateStreamController.add(
      BleScannerState(
        discoveredDevices: _devices,
        scanIsInProgress: _subscription != null,
      ),
    );
  }

  Future<void> stopScan() async {
    _logMessage('Stop ble discovery');

    await _subscription?.cancel();
    _subscription = null;
    _pushState();
  }

  Future<void> streamDispose() async {
    rxBleScannerState.close();
    await _stateStreamController.close();
  }

}

@immutable
class BleScannerState {
  const BleScannerState({
    required this.discoveredDevices,
    required this.scanIsInProgress,
  });

  final List<DiscoveredDevice> discoveredDevices;
  final bool scanIsInProgress;
}
