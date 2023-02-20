import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:get/get.dart';
import 'package:getx_ble/getx_ble.dart';
import '../../../tools/logs.dart';
import 'characteristic_interaction_dialog.dart';

class DeviceInteractionTab extends StatelessWidget {
  DeviceInteractionTab({
    required this.discoveredDevice,
    Key? key,
  }) : super(key: key) {
    _bleDeviceController = Get.put(_BleDeviceController(
      discoveredDevice: discoveredDevice,
      deviceConnector: connector,
      fDiscoverServices: () => interactor.discoverServices(discoveredDevice.id),
    ));
  }

  final DiscoveredDevice discoveredDevice;
  final BleDeviceInteractor interactor = Get.find<GetxBle>().interactor;
  final BleDeviceConnector connector = Get.find<GetxBle>().connector;
  late final _BleDeviceController _bleDeviceController;

  @override
  Widget build(BuildContext context) => Obx(() {
        return CustomScrollView(
          slivers: [
            SliverList(
              delegate: SliverChildListDelegate.fixed(
                [
                  Padding(
                    padding: const EdgeInsetsDirectional.only(
                        top: 8.0, bottom: 16.0, start: 16.0),
                    child: Text(
                      "MAC: ${discoveredDevice.id}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.only(start: 16.0),
                    child: Text(
                      "Status: ${_bleDeviceController.deviceConnector.rxBleConnectionState.value.connectionState}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        ElevatedButton(
                          onPressed: !((_bleDeviceController
                                      .deviceConnector
                                      .rxBleConnectionState
                                      .value
                                      .connectionState) ==
                                  DeviceConnectionState.connected)
                              ? _bleDeviceController.connect
                              : null,
                          child: const Text("Connect"),
                        ),
                        ElevatedButton(
                          onPressed: (_bleDeviceController
                                      .deviceConnector
                                      .rxBleConnectionState
                                      .value
                                      .connectionState) ==
                                  DeviceConnectionState.connected
                              ? _bleDeviceController.disconnect
                              : null,
                          child: const Text("Disconnect"),
                        ),
                        ElevatedButton(
                          onPressed: (_bleDeviceController
                                      .deviceConnector
                                      .rxBleConnectionState
                                      .value
                                      .connectionState) ==
                                  DeviceConnectionState.connected
                              ? _bleDeviceController.discoverServices
                              : null,
                          child: const Text("Discover Services"),
                        ),
                      ],
                    ),
                  ),
                  if ((_bleDeviceController.deviceConnector.rxBleConnectionState
                          .value.connectionState) ==
                      DeviceConnectionState.connected)
                    _ServiceDiscoveryList(
                      discoveredDevice: _bleDeviceController.discoveredDevice,
                      discoveredServices:
                          _bleDeviceController.rxDiscoveredServices,
                    )
                ],
              ),
            ),
          ],
        );
      });
}

class _BleDeviceController extends GetxController {
  _BleDeviceController({
    required this.discoveredDevice,
    required this.deviceConnector,
    required this.fDiscoverServices,
  });

  final DiscoveredDevice discoveredDevice;
  final RxList<DiscoveredService> rxDiscoveredServices =
      <DiscoveredService>[].obs;
  final BleDeviceConnector deviceConnector;
  final Future<List<DiscoveredService>> Function() fDiscoverServices;

  void discoverServices() async {
    rxDiscoveredServices.value = [];
    final result = await fDiscoverServices();
    rxDiscoveredServices.value = result;
  }

  void connect() {
    deviceConnector.connect(discoveredDevice.id);
  }

  void disconnect() {
    rxDiscoveredServices.value = [];
    deviceConnector.disconnect(discoveredDevice.id);
  }
}

class _ServiceDiscoveryList extends StatelessWidget {
  _ServiceDiscoveryList({
    required this.discoveredDevice,
    required this.discoveredServices,
    Key? key,
  }) : super(key: key);

  final DiscoveredDevice discoveredDevice;
  final RxList<DiscoveredService> discoveredServices;
  final RxList<int> _expandedItems = <int>[].obs;
  final logs = Get.find<Logs>();

  String _characteristicsSummary(DiscoveredCharacteristic c) {
    final props = <String>[];
    if (c.isReadable) {
      props.add("read");
    }
    if (c.isWritableWithoutResponse) {
      props.add("write without response");
    }
    if (c.isWritableWithResponse) {
      props.add("write with response");
    }
    if (c.isNotifiable) {
      props.add("notify");
    }
    if (c.isIndicatable) {
      props.add("indicate");
    }

    return props.join("\n");
  }

  Widget _characteristicTile(
      DiscoveredCharacteristic characteristic, String deviceMAC) {
    return ListTile(
      onTap: () => Get.dialog(
        CharacteristicInteractionDialog(
          deviceMAC: deviceMAC,
          dCharacteristic: characteristic,
        ),
      ),
      title: Text(
        '${characteristic.characteristicId}\n(${_characteristicsSummary(characteristic)})',
        style: const TextStyle(
          fontSize: 14,
        ),
      ),
    );
  }

  List<ExpansionPanel> buildPanels() {
    final panels = <ExpansionPanel>[];
    discoveredServices.asMap().forEach((index, service) {
      return panels.add(
        ExpansionPanel(
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsetsDirectional.only(start: 16.0),
                child: Text(
                  'Characteristics',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                // disable scroll in ListView
                shrinkWrap: true,
                itemBuilder: (context, index) => _characteristicTile(
                  service.characteristics[index],
                  discoveredDevice.id,
                ),
                itemCount: service.characteristicIds.length,
              ),
            ],
          ),
          headerBuilder: (context, isExpanded) => ListTile(
            title: Text(
              '${service.serviceId}',
              style: const TextStyle(fontSize: 14),
            ),
          ),
          isExpanded: _expandedItems.contains(index),
        ),
      );
    });
    return panels;
  }

  @override
  Widget build(BuildContext context) => Obx(() {
        return discoveredServices.isEmpty
            ? const SizedBox()
            : Padding(
                padding: const EdgeInsetsDirectional.only(
                  top: 20.0,
                  start: 20.0,
                  end: 20.0,
                ),
                child: ExpansionPanelList(
                  expansionCallback: (int index, bool isExpanded) {
                    if (isExpanded) {
                      _expandedItems.remove(index);
                    } else {
                      _expandedItems.add(index);
                    }
                  },
                  children: [
                    ...buildPanels(),
                  ],
                ),
              );
      });
}
