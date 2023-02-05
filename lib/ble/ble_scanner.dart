import 'dart:async';

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:get/get.dart';
import 'package:meta/meta.dart';

import 'ble_logger.dart';

/// 这个类负责开启和关闭蓝牙扫描器并输出扫描结果
/// This class is responsible for starting and stopping the BLE scanner and outputting the scan results.
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

  final rxBleScannerState = Rx<BleScannerState>(
      const BleScannerState(discoveredDevices: [], scanIsInProgress: false));

  final _devices = <DiscoveredDevice>[];

  void startScan(BleScannerFilter filter) {
    _logMessage('Start ble discovery');
    _devices.clear();
    _subscription?.cancel();
    _subscription = _ble
        .scanForDevices(withServices: filter.serviceId ?? [])
        .listen((device) {
      final knownDeviceIndex = _devices.indexWhere((d) => d.id == device.id);

      if (knownDeviceIndex >= 0) {
        _devices[knownDeviceIndex] = device;
      } else {
        if (device.name
            .toLowerCase()
            .contains((filter.name ?? "".toLowerCase()))) {
          if(device.id
              .contains((filter.mac ?? ""))) {
            if (device.rssi >= (filter.rssi ?? -100)) {
              _devices.add(device);
            }
          }
        }
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

  @override
  Future<void> onClose() async {
    rxBleScannerState.close();
    await _stateStreamController.close();
    super.onClose();
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

class BleScannerFilter {
  String? name;
  String? mac;
  List<Uuid>? serviceId;
  int? rssi;

  BleScannerFilter({
    this.name,
    this.mac,
    this.serviceId,
    this.rssi,
  });
}
