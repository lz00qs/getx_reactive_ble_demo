import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:getx_reactive_ble_demo/ble/ble_logger.dart';

class DeviceLogTab extends StatelessWidget {
  DeviceLogTab({Key? key}) : super(key: key);

  final logger = Get.find<BleLogger>();

  @override
  Widget build(BuildContext context) {
    return Obx(() => Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView.builder(
            itemBuilder: (context, index) =>
                Text(logger.rxMessages.value[index]),
            itemCount: logger.rxMessages.value.length,
          ),
        ));
  }
}
