import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// The live code reader (phones), through the `mobile_scanner` plugin. It
/// reports product barcodes (EAN, UPC) and the text of QR and DataMatrix codes
/// (which may carry the product number); the screen decides what they mean.
/// The picture is never saved or sent anywhere, and a QR link is never opened.
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
  final MobileScannerController _controller = MobileScannerController(
    // Product codes only: barcodes, and the QR / DataMatrix codes packs carry.
    formats: const [
      BarcodeFormat.ean13,
      BarcodeFormat.ean8,
      BarcodeFormat.upcA,
      BarcodeFormat.upcE,
      BarcodeFormat.qrCode,
      BarcodeFormat.dataMatrix,
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
      final value = barcode.rawValue;
      if (value != null && value.trim().isNotEmpty) {
        widget.onCode(value);
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) =>
      MobileScanner(controller: _controller, onDetect: _onDetect);
}
