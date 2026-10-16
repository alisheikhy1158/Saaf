import 'package:flutter/foundation.dart' show ValueChanged, kIsWeb;
import 'package:flutter/widgets.dart' show BuildContext, Widget;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:saaf/core/config/env.dart';
import 'package:saaf/data/services/plugin_external_link_service.dart';
import 'package:saaf/data/services/open_beauty_facts_lookup.dart';
import 'package:saaf/data/services/plugin_barcode_scanner_view.dart';
import 'package:saaf/data/services/seed_product_lookup.dart';
import 'package:saaf/data/services/web/fake_barcode_scanner_view.dart';
import 'package:saaf/data/services/web/fake_external_link_service.dart';
import 'package:saaf/domain/entities/scanned_product.dart';
import 'package:saaf/domain/services/external_link_service.dart';
import 'package:saaf/domain/services/product_lookup.dart';
import 'package:saaf/presentation/providers/no_auto_retry.dart';

part 'product_providers.g.dart';

/// Real products from Open Beauty Facts (open data, any barcode). With
/// `FAKE_CAMERA=true` (Chrome demos) one demo product answers instead.
@Riverpod(keepAlive: true)
ProductLookup productLookup(Ref ref) =>
    Env.fakeCamera ? SeedProductLookup() : OpenBeautyFactsLookup();

/// Builds the live barcode camera: the real reader on phones, a pretend one
/// (a single "scan" button) in Chrome and for `FAKE_CAMERA` demos.
typedef BarcodeScannerViewBuilder =
    Widget Function(BuildContext context, ValueChanged<String> onCode);

@Riverpod(keepAlive: true)
BarcodeScannerViewBuilder barcodeScannerView(Ref ref) =>
    (Env.fakeCamera || kIsWeb)
    ? fakeBarcodeScannerView
    : pluginBarcodeScannerView;

@Riverpod(keepAlive: true)
ExternalLinkService externalLinkService(Ref ref) =>
    Env.fakeCamera ? FakeExternalLinkService() : PluginExternalLinkService();

/// The product behind [barcode]; null when the barcode is not known. A failure
/// surfaces as an error state the screen can retry.
@Riverpod(retry: noAutoRetry)
Future<ScannedProduct?> scannedProduct(Ref ref, String barcode) async {
  final result = await ref.watch(productLookupProvider).byBarcode(barcode);
  return result.when(ok: (product) => product, err: (failure) => throw failure);
}
