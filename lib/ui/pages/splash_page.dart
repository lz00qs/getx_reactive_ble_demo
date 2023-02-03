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
    Key? key,
  }) : super(key: key);

  final FlutterReactiveBle ble;

  final monitor = Get.find<BleStatusMonitor>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (monitor.rxBleStatus.value == BleStatus.ready) {
        return BleDevPage();
      } else {
        return BleStatusPage(status: monitor.rxBleStatus.value);
      }
    });
  }
}
