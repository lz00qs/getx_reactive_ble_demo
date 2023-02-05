import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:get/get.dart';
import '../../../ble/ble_device_connector.dart';
import '../../../ble/ble_device_interactor.dart';
import 'characteristic_interaction_dialog.dart';

class DeviceInteractionTab extends StatefulWidget {
  DeviceInteractionTab({
    required this.discoveredDevice,
    Key? key,
  }) : super(key: key) {
    bleDevice = BleDevice(
      deviceMAC: discoveredDevice.id,
      deviceConnector: connector,
      fDiscoverServices: () => interactor.discoverServices(discoveredDevice.id),
    );
  }

  final DiscoveredDevice discoveredDevice;
  final BleDeviceInteractor interactor = Get.find<BleDeviceInteractor>();
  final BleDeviceConnector connector = Get.find<BleDeviceConnector>();
  late final BleDevice bleDevice;

  @override
  DeviceInteractionTabState createState() => DeviceInteractionTabState();
}

class DeviceInteractionTabState extends State<DeviceInteractionTab> {
  @override
  Widget build(BuildContext context) => Obx(() => CustomScrollView(
        slivers: [
          SliverList(
            delegate: SliverChildListDelegate.fixed(
              [
                Padding(
                  padding: const EdgeInsetsDirectional.only(
                      top: 8.0, bottom: 16.0, start: 16.0),
                  child: Text(
                    "MAC: ${widget.discoveredDevice.id}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 16.0),
                  child: Text(
                    "Status: ${widget.bleDevice.deviceConnector.rxBleConnectionState.value.connectionState}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      ElevatedButton(
                        onPressed: !((widget
                                    .bleDevice
                                    .deviceConnector
                                    .rxBleConnectionState
                                    .value
                                    .connectionState) ==
                                DeviceConnectionState.connected)
                            ? widget.bleDevice.connect
                            : null,
                        child: const Text("Connect"),
                      ),
                      ElevatedButton(
                        onPressed: (widget
                                    .bleDevice
                                    .deviceConnector
                                    .rxBleConnectionState
                                    .value
                                    .connectionState) ==
                                DeviceConnectionState.connected
                            ? widget.bleDevice.disconnect
                            : null,
                        child: const Text("Disconnect"),
                      ),
                      ElevatedButton(
                        onPressed: (widget
                                    .bleDevice
                                    .deviceConnector
                                    .rxBleConnectionState
                                    .value
                                    .connectionState) ==
                                DeviceConnectionState.connected
                            ? widget.bleDevice.discoverServices
                            : null,
                        child: const Text("Discover Services"),
                      ),
                    ],
                  ),
                ),
                if ((widget.bleDevice.deviceConnector.rxBleConnectionState.value
                        .connectionState) ==
                    DeviceConnectionState.connected)
                  _ServiceDiscoveryList(
                    deviceMAC: widget.bleDevice.deviceMAC,
                    discoveredServices: widget.bleDevice.rxDiscoveredServices,
                  )
              ],
            ),
          ),
        ],
      ));
}

class BleDevice extends GetxController {
  BleDevice({
    required this.deviceMAC,
    required this.deviceConnector,
    required this.fDiscoverServices,
  });

  final String deviceMAC;
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
    deviceConnector.connect(deviceMAC);
  }

  void disconnect() {
    rxDiscoveredServices.value = [];
    deviceConnector.disconnect(deviceMAC);
  }
}

class _ServiceDiscoveryList extends StatelessWidget {
  _ServiceDiscoveryList({
    required this.deviceMAC,
    required this.discoveredServices,
    Key? key,
  }) : super(key: key);

  final String deviceMAC;
  final RxList<DiscoveredService> discoveredServices;

  // class _ServiceDiscoveryListState extends State<_ServiceDiscoveryList> {
  // late final List<int> _expandedItems;
  final RxList<int> _expandedItems = <int>[].obs;

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
          DiscoveredCharacteristic characteristic, String deviceMAC) =>
      ListTile(
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

  List<ExpansionPanel> buildPanels() {
    final panels = <ExpansionPanel>[];

    discoveredServices.asMap().forEach(
          (index, service) => panels.add(
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
                      deviceMAC,
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
          ),
        );
    return panels;
  }

  @override
  Widget build(BuildContext context) => Obx(() => discoveredServices.isEmpty
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
        ));
}
