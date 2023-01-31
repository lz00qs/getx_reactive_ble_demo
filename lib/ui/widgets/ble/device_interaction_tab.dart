import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:get/get.dart';
import '../../../ble/ble_device_connector.dart';
import '../../../ble/ble_device_interactor.dart';

class DeviceInteractionTab extends StatefulWidget {
  DeviceInteractionTab({
    required this.discoveredDevice,
    Key? key,
  }) : super(key: key) {
    bleDevice = BleDevice(
      id: discoveredDevice.id,
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
  void initState() {
    super.initState();
  }

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
                    "ID: ${widget.discoveredDevice.id}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 16.0),
                  child: Text(
                    "Status: ${widget.bleDevice.deviceConnector.rxBleConnectionState.value?.connectionState ?? DeviceConnectionState.disconnected}",
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
                                        ?.connectionState ??
                                    DeviceConnectionState.disconnected) ==
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
                                        ?.connectionState ??
                                    DeviceConnectionState.disconnected) ==
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
                                        ?.connectionState ??
                                    DeviceConnectionState.disconnected) ==
                                DeviceConnectionState.connected
                            ? widget.bleDevice.discoverServices
                            : null,
                        child: const Text("Discover Services"),
                      ),
                    ],
                  ),
                ),
                if ((widget.bleDevice.deviceConnector.rxBleConnectionState.value
                            ?.connectionState ??
                        DeviceConnectionState.disconnected) ==
                    DeviceConnectionState.connected)
                  _ServiceDiscoveryList(
                    deviceId: widget.bleDevice.id,
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
    required this.id,
    required this.deviceConnector,
    required this.fDiscoverServices,
  });

  final String id;
  final RxList<DiscoveredService> rxDiscoveredServices =
      <DiscoveredService>[].obs;

  final BleDeviceConnector deviceConnector;
  final Future<List<DiscoveredService>> Function() fDiscoverServices;

  void discoverServices() async {
    final result = await fDiscoverServices();
    rxDiscoveredServices.value = result;
  }

  void connect() {
    deviceConnector.connect(id);
  }

  void disconnect() {
    deviceConnector.disconnect(id);
  }
}

class _ServiceDiscoveryList extends StatefulWidget {
  const _ServiceDiscoveryList({
    required this.deviceId,
    required this.discoveredServices,
    Key? key,
  }) : super(key: key);

  final String deviceId;
  final RxList<DiscoveredService> discoveredServices;

  @override
  _ServiceDiscoveryListState createState() => _ServiceDiscoveryListState();
}

class _ServiceDiscoveryListState extends State<_ServiceDiscoveryList> {
  late final List<int> _expandedItems;

  @override
  void initState() {
    _expandedItems = [];
    super.initState();
  }

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
          DiscoveredCharacteristic characteristic, String deviceId) =>
      ListTile(
        // onTap: () => showDialog<void>(
        //     context: context,
        //     builder: (context) => CharacteristicInteractionDialog(
        //       characteristic: QualifiedCharacteristic(
        //           characteristicId: characteristic.characteristicId,
        //           serviceId: characteristic.serviceId,
        //           deviceId: deviceId),
        //     )),
        title: Text(
          '${characteristic.characteristicId}\n(${_characteristicsSummary(characteristic)})',
          style: const TextStyle(
            fontSize: 14,
          ),
        ),
      );

  List<ExpansionPanel> buildPanels() {
    final panels = <ExpansionPanel>[];

    widget.discoveredServices.asMap().forEach(
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
                    shrinkWrap: true,
                    itemBuilder: (context, index) => _characteristicTile(
                      service.characteristics[index],
                      widget.deviceId,
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
  Widget build(BuildContext context) =>
      Obx(() => widget.discoveredServices.isEmpty
          ? const SizedBox()
          : Padding(
              padding: const EdgeInsetsDirectional.only(
                top: 20.0,
                start: 20.0,
                end: 20.0,
              ),
              child: ExpansionPanelList(
                expansionCallback: (int index, bool isExpanded) {
                  setState(() {
                    setState(() {
                      if (isExpanded) {
                        _expandedItems.remove(index);
                      } else {
                        _expandedItems.add(index);
                      }
                    });
                  });
                },
                children: [
                  ...buildPanels(),
                ],
              ),
            ));
}
