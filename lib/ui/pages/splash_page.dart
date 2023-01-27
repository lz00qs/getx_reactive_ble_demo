import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:getx_reactive_ble_demo/ui/pages/ble_dev_page.dart';
import 'package:getx_reactive_ble_demo/ui/pages/ble_status_page.dart';
import 'package:get/get.dart';
import '../../ble/ble_status_monitor.dart';

/// Start-up page, it will do the permission check and navigate to the next page
class SplashPage extends StatelessWidget {
  SplashPage({
    required this.ble,
    required this.monitor,
    Key? key,
  }) : super(key: key) {
    // _myBleStatusController = Get.put(monitor);
  }

  final FlutterReactiveBle ble;

  final BleStatusMonitor monitor;

  // BleStatusMonitor _myBleStatusController;

  @override
  Widget build(BuildContext context) {
    // return Scaffold(
    //   body: Center(child: Obx(() => Text("test: ${monitor.rxBleStatus.value}"))),
    // );
    return Obx(() {
      if (monitor.rxBleStatus.value == BleStatus.ready) {
        return const BleDevPage();
      } else {
        return BleStatusPage(status: monitor.rxBleStatus.value);
      }
    });
  }
}
