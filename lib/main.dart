import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:get/get.dart';
import 'package:getx_reactive_ble_demo/ble/ble_device_connector.dart';
import 'package:getx_reactive_ble_demo/routes/app_routes.dart';

import 'package:getx_reactive_ble_demo/ui/pages/splash_page.dart';
import 'ble/ble_logger.dart';
import 'ble/ble_scanner.dart';
import 'ble/ble_status_monitor.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final ble = FlutterReactiveBle();
  final bleLogger = Get.put(BleLogger(ble: ble));
  // final _scanner = BleScanner(ble: _ble, logMessage: _bleLogger.addToLog);
  Get.put(BleStatusMonitor(ble));
  Get.put(BleScanner(ble: ble, logMessage: bleLogger.addToLog));
  Get.put(BleDeviceConnector(ble: ble, logMessage: bleLogger.addToLog));
  runApp(MyApp(
    ble: ble,
    bleLogger: bleLogger,
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({required this.ble, required this.bleLogger, Key? key})
      : super(key: key);

  final FlutterReactiveBle ble;

  final BleLogger bleLogger;

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: true,
      home: SplashPage(
        ble: ble,
        bleLogger: bleLogger,
      ),
      getPages: AppRoutes.routes,
    );
  }
}
