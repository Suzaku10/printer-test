import 'dart:async';
import 'dart:typed_data';

import 'package:drago_usb_printer/drago_usb_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';

class PrinterUtils {
  PrinterUtils._();

  static DragoUsbPrinter? flutterUsbPrinter;

  static Future printReceipt(Map<String, dynamic> device) async {
    try {
      final bytes = await PrinterUtils._createReceipt();
      await printReceiptViaUsbAndroid(bytes, device);
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<dynamic>> getUSBList() async {
    try {
      flutterUsbPrinter ??= DragoUsbPrinter();
      final devices = [];
      devices.addAll(await DragoUsbPrinter.getUSBDeviceList());
      return devices;
    } catch (e) {
      rethrow;
    }
  }

  static Future printReceiptViaUsbAndroid(List<int>? bytes, Map<String, dynamic> device) async {
    try {
      flutterUsbPrinter ??= DragoUsbPrinter();
      var isConnected = await flutterUsbPrinter!.connect(int.parse(device['vendorId']), int.parse(device['productId']));
      if (isConnected == true) {
        await flutterUsbPrinter!.write(Uint8List.fromList(bytes!));
        await flutterUsbPrinter!.close();
      }
    } catch (exception) {
      rethrow;
    }
  }

  static Future<List<int>?> _createReceipt() async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);

    List<int> bytes = [];

    bytes += generator.reset();
    //Header
    bytes += generator.emptyLines(1);
    bytes += generator.text('Customer Care:',
        styles: const PosStyles(align: PosAlign.center));
    bytes += generator.text('Facebook: ',
        styles: const PosStyles(align: PosAlign.center));
    bytes += generator.hr();
    bytes += generator.text('Sales included PB1',
        styles: const PosStyles(align: PosAlign.center));
    bytes += generator.emptyLines(1);
    bytes += generator.text('Join us for more exciting surprises!',
        styles: const PosStyles(align: PosAlign.center));
    bytes += generator.text('Scan this QR Code for more information',
        styles: const PosStyles(align: PosAlign.center));
    bytes += generator.emptyLines(1);

    return bytes;
  }
}