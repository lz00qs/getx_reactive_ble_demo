import 'package:get/get.dart';
import 'package:getx_reactive_ble_demo/ui/pages/splash_page.dart';
import '../ui/pages/ble_dev_page.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

/// getx name routes

import '../ui/pages/ble_status_page.dart';

class AppRoutes {
  static final routes = [
    // GetPage(
    //   name: "/bleStatusPage",
    //   page: () => BleStatusPage(),
    // ),
    GetPage(
      name: "/bleDevPage",
      page: () => const BleDevPage(),
    ),
    // GetPage(name: "/splashPage", page: () => const SplashPage()),
  ];
}
