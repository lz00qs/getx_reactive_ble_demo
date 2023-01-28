import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:get/get.dart';
import '../../ble/ble_device_connector.dart';
import '../widgets/ble/device_log_tab.dart';

class BleDeviceDetailPage extends StatelessWidget {
  BleDeviceDetailPage({Key? key}) : super(key: key);
  final DiscoveredDevice device = Get.arguments;
  final BleDeviceConnector connector = Get.find<BleDeviceConnector>();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        connector.disconnect(device.id);
        return true;
      },
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text(device.name),
            bottom: const TabBar(
              tabs: [
                Tab(
                  icon: Icon(
                    Icons.bluetooth_connected,
                  ),
                ),
                Tab(
                  icon: Icon(
                    Icons.find_in_page_sharp,
                  ),
                ),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              // DeviceInteractionTab(
              //   device: device,
              // ),
              const Text("DeviceInteractionTab"),
              // Text("DeviceLogTab"),
              DeviceLogTab(),
            ],
          ),
        ),
      ),
    );
  }
}
