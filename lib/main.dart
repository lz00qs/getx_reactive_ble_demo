import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getx_ble/getx_ble.dart';
import 'package:getx_reactive_ble_demo/routes/app_routes.dart';
import 'package:getx_reactive_ble_demo/tools/logs.dart';

import 'package:getx_reactive_ble_demo/ui/pages/splash_page.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(Logs());
  Get.put(GetxBle());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: true,
      home: SplashPage(),
      getPages: AppRoutes.routes,
    );
  }
}
