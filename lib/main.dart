import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:get/get.dart';
import 'package:getx_reactive_ble_demo/ble/ble_device_connector.dart';
import 'package:getx_reactive_ble_demo/ble/ble_device_interactor.dart';
import 'package:getx_reactive_ble_demo/routes/app_routes.dart';

import 'package:getx_reactive_ble_demo/ui/pages/splash_page.dart';
import 'ble/ble_logger.dart';
import 'ble/ble_scanner.dart';
import 'ble/ble_status_monitor.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final ble = FlutterReactiveBle();
  Get.put(BleLogger(ble: ble));
  Get.put(BleStatusMonitor(ble));
  Get.put(BleScanner(ble: ble));
  Get.put(BleDeviceConnector(ble: ble));
  Get.put(BleDeviceInteractor(
      bleDiscoverServices: ble.discoverServices,
      readCharacteristic: ble.readCharacteristic,
      writeWithResponse: ble.writeCharacteristicWithResponse,
      writeWithOutResponse: ble.writeCharacteristicWithoutResponse,
      subscribeToCharacteristic: ble.subscribeToCharacteristic));
  runApp(MyApp(
    ble: ble,
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({required this.ble, Key? key}) : super(key: key);

  final FlutterReactiveBle ble;

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: true,
      home: SplashPage(
        ble: ble,
      ),
      getPages: AppRoutes.routes,
    );
  }
}
