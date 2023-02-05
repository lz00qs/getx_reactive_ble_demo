import 'dart:async';

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:get/get.dart';
import 'package:meta/meta.dart';

import 'ble_logger.dart';

/// 这个类负责开启和关闭蓝牙扫描器并输出扫描结果
class BleScanner extends GetxController {
  BleScanner({
    required FlutterReactiveBle ble,
  }) : _ble = ble {
    rxBleScannerState.bindStream(_stateStreamController.stream);
  }


  final FlutterReactiveBle _ble; /// 输入 FlutterReactiveBle 来获取结果及功能
  final void Function(String message) _logMessage =
      Get.find<BleLogger>().addToLog;
  final StreamController<BleScannerState> _stateStreamController =
      StreamController();

  StreamSubscription? _subscription;

  /// 使用 Getx 的 Rx 来监听扫描结果
  final rxBleScannerState = Rx<BleScannerState>(
      const BleScannerState(discoveredDevices: [], scanIsInProgress: false));

  final _devices = <DiscoveredDevice>[];

  /// 开始扫描蓝牙设备
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

  /// 更新扫描结果
  void _pushState() {
    _stateStreamController.add(
      BleScannerState(
        discoveredDevices: _devices,
        scanIsInProgress: _subscription != null,
      ),
    );
  }

  /// 停止扫描蓝牙设备
  Future<void> stopScan() async {
    _logMessage('Stop ble discovery');

    await _subscription?.cancel();
    _subscription = null;
    _pushState();
  }

  /// GetxController 的生命周期函数，当页面关闭时，关闭扫描器
  @override
  Future<void> onClose() async {
    rxBleScannerState.close();
    await _stateStreamController.close();
    super.onClose();
  }
}

/// 这个类用来存储扫描到的蓝牙设备以及扫描器状态
@immutable
class BleScannerState {
  const BleScannerState({
    required this.discoveredDevices,
    required this.scanIsInProgress,
  });

  final List<DiscoveredDevice> discoveredDevices;
  final bool scanIsInProgress;
}

/// 这个类用来存储扫描器的过滤器
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
