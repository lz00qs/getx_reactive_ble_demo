import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:get/get.dart';
import 'package:getx_reactive_ble_demo/ble/ble_logger.dart';
import '../../ble/ble_scanner.dart';


/// 蓝牙设备列表页面
class BleDevPage extends StatefulWidget {
  BleDevPage({
    super.key,
  });

  final BleScanner scanner = Get.find<BleScanner>();
  final BleLogger bleLogger = Get.find<BleLogger>();

  @override
  BleDevPageState createState() => BleDevPageState();
}

class _BleScanFilterController extends GetxController {
  final nameController = TextEditingController();
  final macController = TextEditingController();
  final serviceUuidController = TextEditingController();

  final RxInt rssi = (-100).obs;
  final rxNameText = "".obs;
  final rxMacText = "".obs;
  final rxServiceUuidText = "".obs;

  @override
  void onClose() {
    nameController.dispose();
    macController.dispose();
    serviceUuidController.dispose();
    super.onClose();
  }
}

/// 蓝牙设备列表页面状态
class BleDevPageState extends State<BleDevPage> {
  final _BleScanFilterController _filter = Get.put(_BleScanFilterController());

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    widget.scanner.stopScan();
    _filter.dispose();
    super.dispose();
  }

  bool _isValidUuidInput() {
    final uuidText = _filter.rxServiceUuidText.value;
    if (uuidText.isEmpty) {
      return true;
    } else {
      try {
        Uuid.parse(uuidText);
        return true;
      } on Exception {
        return false;
      }
    }
  }

  bool _isValidMacInput() {
    if (_filter.rxMacText.value.isEmpty) return true;
    RegExp macText = RegExp(r"[0-9a-fA-F]{2}(:[0-9a-fA-F]{2}){5}");
    return macText.hasMatch(_filter.rxMacText.value);
  }

  void _startScanning() {
    final BleScannerFilter filter = BleScannerFilter();
    filter.name = _filter.rxNameText.value;
    filter.mac = _filter.rxMacText.value.toUpperCase();
    filter.serviceId = _filter.rxServiceUuidText.value.isEmpty
        ? []
        : [Uuid.parse(_filter.rxServiceUuidText.value)];
    filter.rssi = _filter.rssi.value;
    widget.scanner.startScan(filter);
  }

  @override
  Widget build(BuildContext context) {
    RxDouble rssiSliderTemp = (100.0).obs;
    RxBool filterExpanded = false.obs;
    return Obx(() {
      List<DiscoveredDevice> discoveredDevices = [];

      for (var element
          in widget.scanner.rxBleScannerState.value.discoveredDevices) {
        discoveredDevices.add(element);
      }

      discoveredDevices.sort((left, right) => right.rssi.compareTo(left.rssi));

      return Scaffold(
        // 防止键盘打开时页面内容报 bottom space not enough 错误
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: const Text('Scan for devices'),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ExpansionPanelList(
                        expansionCallback: (int index, bool isExpanded) {
                          filterExpanded.value = !filterExpanded.value &&
                              !widget.scanner.rxBleScannerState.value
                                  .scanIsInProgress;
                        },
                        children: [
                          ExpansionPanel(
                            headerBuilder:
                                (BuildContext context, bool isExpanded) {
                              return ListTile(
                                title: const Text("Filter",
                                    style: TextStyle(fontSize: 20)),
                                subtitle: !(widget.scanner.rxBleScannerState
                                        .value.scanIsInProgress)
                                    ? null
                                    : Text(
                                        'Stop scanning to change filter.\nDevice count: ${discoveredDevices.length}'),
                              );
                            },
                            body: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Filter by name',
                                        style: TextStyle(fontSize: 16)),
                                    TextField(
                                      controller: _filter.nameController,
                                      enabled: !(widget
                                          .scanner
                                          .rxBleScannerState
                                          .value
                                          .scanIsInProgress),
                                      onChanged: (value) {
                                        _filter.rxNameText.value =
                                            _filter.nameController.text;
                                      },
                                      autocorrect: false,
                                    ),
                                    const SizedBox(height: 16),
                                    const Text('Filter by MAC address',
                                        style: TextStyle(fontSize: 16)),
                                    TextField(
                                      controller: _filter.macController,
                                      enabled: !(widget
                                          .scanner
                                          .rxBleScannerState
                                          .value
                                          .scanIsInProgress),
                                      onChanged: (value) {
                                        _filter.rxMacText.value =
                                            _filter.macController.text;
                                      },
                                      decoration: InputDecoration(
                                          errorText: _filter.rxMacText.value
                                                      .isEmpty ||
                                                  _isValidMacInput()
                                              ? null
                                              : 'Invalid MAC address format'),
                                      autocorrect: false,
                                    ),
                                    const SizedBox(height: 16),
                                    const Text('Filter by service UUID',
                                        style: TextStyle(fontSize: 16)),
                                    TextField(
                                      controller: _filter.serviceUuidController,
                                      enabled: !(widget
                                          .scanner
                                          .rxBleScannerState
                                          .value
                                          .scanIsInProgress),
                                      onChanged: (value) {
                                        _filter.rxServiceUuidText.value =
                                            _filter.serviceUuidController.text;
                                      },
                                      decoration: InputDecoration(
                                          errorText: _filter.rxServiceUuidText
                                                      .value.isEmpty ||
                                                  _isValidUuidInput()
                                              ? null
                                              : 'Invalid service UUID format'),
                                      autocorrect: false,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Filter by RSSI: ${-rssiSliderTemp.toInt()} dBm',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    Slider(
                                      value: rssiSliderTemp.value,
                                      onChanged: (data) {
                                        if (!widget.scanner.rxBleScannerState
                                            .value.scanIsInProgress) {
                                          rssiSliderTemp.value = data;
                                        }
                                      },
                                      onChangeStart: (data) {},
                                      onChangeEnd: (data) {
                                        if (!widget.scanner.rxBleScannerState
                                            .value.scanIsInProgress) {
                                          _filter.rssi.value = -data.toInt();
                                        }
                                      },
                                      min: 40.0,
                                      max: 100.0,
                                      divisions: 60,
                                      label: '${-rssiSliderTemp.toInt()}',
                                    ),
                                  ],
                                )),
                            isExpanded: filterExpanded.value &&
                                !widget.scanner.rxBleScannerState.value
                                    .scanIsInProgress,
                          ),
                        ]),
                    Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              onPressed: !(widget.scanner.rxBleScannerState
                                          .value.scanIsInProgress) &&
                                      _isValidUuidInput() &&
                                      _isValidMacInput()
                                  ? _startScanning
                                  : null,
                              child: const Text('Scan'),
                            ),
                            ElevatedButton(
                              onPressed: (widget.scanner.rxBleScannerState.value
                                      .scanIsInProgress)
                                  ? widget.scanner.stopScan
                                  : null,
                              child: const Text('Stop'),
                            ),
                          ],
                        )),
                    SizedBox(
                      child: SwitchListTile(
                          title: const Text("Verbose logging"),
                          value: widget.bleLogger.rxVerboseLogging.value,
                          onChanged: (_) {
                            widget.bleLogger.rxVerboseLogging.value =
                                !widget.bleLogger.rxVerboseLogging.value;
                            widget.bleLogger.verboseLoggingUpdate();
                          }),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: ListView(
                    children: [
                      ...(discoveredDevices)
                          .map(
                            (device) => ListTile(
                              title: Text(device.name),
                              subtitle:
                                  Text("${device.id}\nRSSI: ${device.rssi}"),
                              // leading: const BluetoothIcon(),
                              onTap: () async {
                                widget.scanner.stopScan();
                                await Get.toNamed('/bleDeviceDetailPage',
                                    arguments: device);
                              },
                            ),
                          )
                          .toList(),
                    ],
                  ),
                ),
              ],
            ),
          ));
    });
  }
}
