import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:get/get.dart';
import '../../../ble/ble_device_interactor.dart';

class CharacteristicInteractionDialog extends StatefulWidget {
  CharacteristicInteractionDialog({
    required this.deviceMAC,
    required this.dCharacteristic,
    Key? key,
  }) : super(key: key) {
    qCharacteristic = QualifiedCharacteristic(
      characteristicId: dCharacteristic.characteristicId,
      serviceId: dCharacteristic.serviceId,
      deviceId: deviceMAC,
    );
  }

  late final QualifiedCharacteristic qCharacteristic;

  final DiscoveredCharacteristic dCharacteristic;

  final String deviceMAC;

  final BleDeviceInteractor interactor = Get.find<BleDeviceInteractor>();

  @override
  CharacteristicInteractionDialogState createState() =>
      CharacteristicInteractionDialogState();
}

class CharacteristicInteractionDialogState
    extends State<CharacteristicInteractionDialog> {
  final RxString readOutput = ''.obs;
  final RxString writeOutput = ''.obs;
  final RxString subscribeOutput = ''.obs;
  final TextEditingController textEditingController = TextEditingController();

  final subscribeStream = Rx<List<int>>([]);

  @override
  void initState() {
    super.initState();
  }

  Future<void> subscribeCharacteristic() async {
    subscribeStream.bindStream(
        widget.interactor.subScribeToCharacteristic(widget.qCharacteristic));
    subscribeOutput.value = subscribeStream.value.toString();
  }

  Future<void> readCharacteristic() async {
    readOutput.value =
        (await widget.interactor.readCharacteristic(widget.qCharacteristic))
            .toString();
  }

  List<int> _parseInput() => textEditingController.text
      .split(',')
      .map(
        int.parse,
      )
      .toList();

  Future<void> writeCharacteristicWithResponse() async {
    await widget.interactor.writeCharacteristicWithResponse(
        widget.qCharacteristic, _parseInput());
    writeOutput.value = 'Ok';
  }

  Future<void> writeCharacteristicWithoutResponse() async {
    await widget.interactor.writeCharacteristicWithoutResponse(
        widget.qCharacteristic, _parseInput());

    writeOutput.value = 'Done';
  }

  Widget get divider => const Padding(
        padding: EdgeInsets.symmetric(vertical: 12.0),
        child: Divider(thickness: 2.0),
      );

  Widget sectionHeader(String text) => Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      );

  List<Widget> get readSection => [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            sectionHeader('Read characteristic'),
            ElevatedButton(
              onPressed: readCharacteristic,
              child: const Text('Read'),
            ),
          ],
        ),
        Obx(() => Text('Output: ${readOutput.value}')),
        divider,
      ];

  List<Widget> get writeSection => [
        sectionHeader('Write characteristic'),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: TextField(
            controller: textEditingController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Value',
            ),
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
              signed: false,
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              onPressed: writeCharacteristicWithResponse,
              child: const Text('ACK'),
            ),
            ElevatedButton(
              onPressed: writeCharacteristicWithoutResponse,
              child: const Text('UnACK'),
            ),
          ],
        ),
        Padding(
            padding: const EdgeInsetsDirectional.only(top: 8.0),
            child: Obx(() => Text('Output: $writeOutput'))),
        divider,
      ];

  List<Widget> get subscribeSection => [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            sectionHeader('Subscribe / notify'),
            ElevatedButton(
              onPressed: subscribeCharacteristic,
              child: const Text('Subscribe'),
            ),
          ],
        ),
        Obx(() => Text('Output: $subscribeOutput')),
        divider,
      ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          shrinkWrap: true,
          children: [
            const Text(
              'Select an operation',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                widget.qCharacteristic.characteristicId.toString(),
              ),
            ),
            divider,
            if (widget.dCharacteristic.isReadable) ...readSection,
            if (widget.dCharacteristic.isWritableWithResponse ||
                widget.dCharacteristic.isWritableWithoutResponse)
              ...writeSection,
            if (widget.dCharacteristic.isNotifiable) ...subscribeSection,
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: ElevatedButton(
                    onPressed: () => Get.back(), child: const Text('close')),
              ),
            )
          ],
        ),
      ),
    );
  }
}
