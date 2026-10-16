import 'package:flutter/material.dart';
import 'package:saaf/core/l10n/app_localizations.dart';
import 'package:saaf/data/services/seed_product_lookup.dart';

/// A pretend camera for Chrome and `FAKE_CAMERA` demos: one button that "reads"
/// the demo product's barcode.
Widget fakeBarcodeScannerView(
  BuildContext context,
  ValueChanged<String> onCode,
) => Center(
  child: FilledButton.icon(
    onPressed: () => onCode(SeedProductLookup.demoBarcode),
    icon: const Icon(Icons.qr_code_scanner),
    label: Text(AppLocalizations.of(context).scanProductPretend),
  ),
);
