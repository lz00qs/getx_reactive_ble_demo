import 'package:getx_reactive_ble_demo/ble/profiles/ble_sig_gatt_uuids.dart';

import 'ble_gatt_uuid.dart';

class BleGattDevice {
  final String name;
  final String macAddress;
  final List<BleGattService> services;

  BleGattDevice(
      {required this.services, required this.name, required this.macAddress});
}

class BleGattService {
  BleGattUuid uuid;
  late String name;
  final List<BleGattCharacteristic> characteristics;

  BleGattService({required this.uuid, required this.characteristics}) {
    if (uuid.uuid128.substring(9) !=
        '0000-1000-8000-00805f9b34fb'.toUpperCase()) {
      name = 'Unknown';
    } else {
      name = BleSigGattUuids.serviceUuids[uuid.uuid16] ?? 'Unknown';
    }
  }
}

class BleGattCharacteristic {
  BleGattUuid uuid;
  late String name;
  final List<BleGattProperty> properties = [];

  void addProperty(BleGattProperty property) {
    properties.add(property);
    properties.sort((a, b) => a.index.compareTo(b.index));
  }

  BleGattCharacteristic({required this.uuid}) {
    if (uuid.uuid128.substring(9) !=
        '0000-1000-8000-00805f9b34fb'.toUpperCase()) {
      name = 'Unknown';
    } else {
      name = BleSigGattUuids.characteristicUuids[uuid.uuid16] ?? 'Unknown';
    }
  }
}

enum BleGattProperty { read, writeAck, writeUnack, notify, indicate }
