import 'package:get/get.dart';
import 'package:getx_reactive_ble_demo/ui/pages/ble_device_detail_page.dart';

class AppRoutes {
  static final routes = [
    // GetPage(
    //   name: "/bleStatusPage",
    //   page: () => BleStatusPage(),
    // ),
    // GetPage(
    //   name: "/bleDevPage",
    //   page: () => BleDevPage(bleLogger: BleLogger(),),
    // ),
    // GetPage(name: "/splashPage", page: () => const SplashPage()),
    GetPage(name: "/bleDeviceDetailPage", page: () => BleDeviceDetailPage()),
  ];
}
