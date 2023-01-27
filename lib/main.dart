import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:get/get.dart';
import 'package:getx_reactive_ble_demo/routes/app_routes.dart';
import 'package:getx_reactive_ble_demo/ui/pages/splash_page.dart';
import 'ble/ble_logger.dart';
import 'ble/ble_status_monitor.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final ble = FlutterReactiveBle();
  final _bleLogger = BleLogger(ble: ble);
  // final _scanner = BleScanner(ble: _ble, logMessage: _bleLogger.addToLog);
  final monitor = BleStatusMonitor(ble);
  runApp(MyApp(ble: ble,monitor: monitor,));
}

class MyApp extends StatelessWidget{
  const MyApp({required this.ble, required this.monitor,Key? key}) : super(key: key);

  final FlutterReactiveBle ble;

  final BleStatusMonitor monitor;

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: true,
      home: SplashPage(ble: ble,monitor: monitor),
      getPages: AppRoutes.routes,
    );
  }

}
