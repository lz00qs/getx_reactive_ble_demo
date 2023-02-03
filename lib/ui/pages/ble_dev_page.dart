import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:get/get.dart';
import 'package:getx_reactive_ble_demo/ble/ble_logger.dart';

import '../../ble/ble_scanner.dart';

class BleDevPage extends StatefulWidget {
  BleDevPage({
    super.key,
  });

  final BleScanner scanner = Get.find<BleScanner>();
  final BleLogger bleLogger = Get.find<BleLogger>();

  @override
  BleDevPageState createState() => BleDevPageState();
}

class BleDevPageState extends State<BleDevPage> {
  late TextEditingController _uuidController;

  @override
  void initState() {
    super.initState();

    _uuidController = TextEditingController()
      ..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    widget.scanner.stopScan();
    _uuidController.dispose();
    super.dispose();
  }

  bool _isValidUuidInput() {
    final uuidText = _uuidController.text;
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

  void _startScanning() {
    final text = _uuidController.text;
    widget.scanner
        .startScan(text.isEmpty ? [] : [Uuid.parse(_uuidController.text)]);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Scan for devices'),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  const Text('Service UUID (2, 4, 16 bytes):'),
                  TextField(
                    controller: _uuidController,
                    enabled: !(widget.scanner.rxBleScannerState.value
                            ?.scanIsInProgress ??
                        false),
                    decoration: InputDecoration(
                        errorText:
                            _uuidController.text.isEmpty || _isValidUuidInput()
                                ? null
                                : 'Invalid UUID format'),
                    autocorrect: false,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: !(widget.scanner.rxBleScannerState.value
                                        ?.scanIsInProgress ??
                                    false) &&
                                _isValidUuidInput()
                            ? _startScanning
                            : null,
                        child: const Text('Scan'),
                      ),
                      ElevatedButton(
                        onPressed: (widget.scanner.rxBleScannerState.value
                                    ?.scanIsInProgress ??
                                false)
                            ? widget.scanner.stopScan
                            : null,
                        child: const Text('Stop'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: ListView(
                children: [
                  SwitchListTile(
                    title: const Text("Verbose logging"),
                    value: widget.bleLogger.verboseLogging,
                    onChanged: (_) =>
                        setState(widget.bleLogger.toggleVerboseLogging),
                  ),
                  ListTile(
                    title: Text(
                      !(widget.scanner.rxBleScannerState.value
                                  ?.scanIsInProgress ??
                              false)
                          ? 'Enter a UUID above and tap start to begin scanning'
                          : 'Tap a device to connect to it',
                    ),
                    trailing: ((widget.scanner.rxBleScannerState.value
                                    ?.scanIsInProgress ??
                                false) ||
                            (widget.scanner.rxBleScannerState.value
                                        ?.discoveredDevices ??
                                    [])
                                .isNotEmpty)
                        ? Text(
                            'count: ${(widget.scanner.rxBleScannerState.value?.discoveredDevices ?? []).length}',
                          )
                        : null,
                  ),
                  ...(widget.scanner.rxBleScannerState.value
                              ?.discoveredDevices ??
                          [])
                      .map(
                        (device) => ListTile(
                          title: Text(device.name),
                          subtitle: Text("${device.id}\nRSSI: ${device.rssi}"),
                          // leading: const BluetoothIcon(),
                          onTap: () async {
                            widget.scanner.stopScan();
                            await Get.toNamed('/bleDeviceDetailPage',
                                arguments: device);
                            // await Navigator.push<void>(
                            //     context,
                            //     MaterialPageRoute(
                            //         builder: (_) =>
                            //             DeviceDetailScreen(device: device)));
                          },
                        ),
                      )
                      .toList(),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
