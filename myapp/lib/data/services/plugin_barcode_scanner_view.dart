import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// The live barcode reader (phones), through the `mobile_scanner` plugin. It
/// only reports numbers of 8 to 14 digits (EAN and UPC product codes); the
/// picture is never saved or sent anywhere.
Widget pluginBarcodeScannerView(
  BuildContext context,
  ValueChanged<String> onCode,
) => _PluginBarcodeScanner(onCode: onCode);

class _PluginBarcodeScanner extends StatefulWidget {
  const _PluginBarcodeScanner({required this.onCode});

  final ValueChanged<String> onCode;

  @override
  State<_PluginBarcodeScanner> createState() => _PluginBarcodeScannerState();
}

class _PluginBarcodeScannerState extends State<_PluginBarcodeScanner> {
  static final _digits = RegExp(r'^\d{8,14}$');

  final MobileScannerController _controller = MobileScannerController(
    // Product barcodes only: faster, and no QR codes from strangers.
    formats: const [
      BarcodeFormat.ean13,
      BarcodeFormat.ean8,
      BarcodeFormat.upcA,
      BarcodeFormat.upcE,
    ],
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    for (final barcode in capture.barcodes) {
      final value = barcode.rawValue?.trim();
      if (value != null && _digits.hasMatch(value)) {
        widget.onCode(value);
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) =>
      MobileScanner(controller: _controller, onDetect: _onDetect);
}
