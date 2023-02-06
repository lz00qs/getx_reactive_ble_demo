import 'package:logger/logger.dart';
import 'package:get/get.dart';

class _SimplePrinter extends LogPrinter {
  @override
  List<String> log(LogEvent event) {
    return ['${event.level}: ${event.message}'];
  }
}

class Logs extends GetxController {
  final logger = Logger(
    printer: _SimplePrinter()
  );

  get v => logger.v;

  get d => logger.d;

  get i => logger.i;

  get w => logger.w;

  get e => logger.e;

  get wtf => logger.wtf;

  set level(Level level) => Logger.level = level;
}
