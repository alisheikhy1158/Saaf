import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:saaf/core/config/env.dart';
import 'package:saaf/data/services/plugin_external_link_service.dart';
import 'package:saaf/data/services/seed_product_lookup.dart';
import 'package:saaf/data/services/web/fake_external_link_service.dart';
import 'package:saaf/domain/entities/scanned_product.dart';
import 'package:saaf/domain/services/external_link_service.dart';
import 'package:saaf/domain/services/product_lookup.dart';
import 'package:saaf/presentation/providers/no_auto_retry.dart';

part 'product_providers.g.dart';

/// PLACEHOLDER: one demo product. Barcode scanning and the real product and
/// price service come in Phase 8 (see handoff.md).
@Riverpod(keepAlive: true)
ProductLookup productLookup(Ref ref) => SeedProductLookup();

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
