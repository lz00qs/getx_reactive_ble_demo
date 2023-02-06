class BleGattUuid {
  // static const String SERVICE = "00001800-0000-1000-8000-00805f9b34fb";
  // static const String CHARACTERISTIC = "00002a00-0000-1000-8000-00805f9b34fb";
  // static const String DESCRIPTOR = "00002902-0000-1000-8000-00805f9b34fb";
  final String rawUuid;

  get uuid16 => rawUuid.length == 4
      ? rawUuid.toUpperCase()
      : rawUuid.substring(4, 8).toUpperCase();

  get         uuid128 => rawUuid.length == 4
      ? "0000$rawUuid-0000-1000-8000-00805f9b34fb".toUpperCase()
      : rawUuid.toUpperCase();

  BleGattUuid(this.rawUuid) {
    if (rawUuid.length != 4) {
      if (rawUuid.length != 36 ||
          rawUuid[8] != "-" ||
          rawUuid[13] != "-" ||
          rawUuid[18] != "-" ||
          rawUuid[23] != "-") {
        print(rawUuid.length);
        // throw Exception("Invalid UUID");
      }
    }
  }
}
