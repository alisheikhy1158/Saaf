import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:saaf/data/repositories/real_product_catalog.dart';
import 'package:saaf/domain/entities/owned_product.dart';
import 'package:saaf/domain/entities/routine.dart';
import 'package:saaf/domain/repositories/product_catalog.dart';
import 'package:saaf/domain/usecases/build_routine.dart';
import 'package:saaf/presentation/providers/no_auto_retry.dart';
import 'package:saaf/presentation/providers/ai_routine_providers.dart';
import 'package:saaf/presentation/providers/skin_profile_providers.dart';

part 'routine_providers.g.dart';

/// Real products sold in Pakistan, shipped with the app (prices are a guide).
/// A backend feed to keep prices fresh can replace this later (OFF-4).
@Riverpod(keepAlive: true)
ProductCatalog productCatalog(Ref ref) => const RealProductCatalog();

/// The user's routine, rebuilt whenever the quiz answers change. The products
/// the user already uses take their steps first (unless Saaf AI says to
/// replace or stop them). When the user has turned Saaf AI on, the products it
/// found on the web fill the other steps, but the safety answers and the
/// budget still decide, here on the phone. Until the plan arrives, or if it
/// fails, the app's own catalogue and rules fill them.
@Riverpod(retry: noAutoRetry)
Future<Routine> routine(Ref ref) async {
  final products = await ref.watch(productCatalogProvider).all();
  final profile = ref.watch(skinProfileControllerProvider);
  final plan = ref.watch(aiRoutinePlanControllerProvider).value;
  final owned = await ref.watch(currentProductsProvider.future);
  final mine = OwnedProduct.productsFor(owned, plan);
  return BuildRoutine(
    [...products, ...?plan?.products, ...mine],
    preferred: plan?.productIds ?? const {},
    owned: {for (final p in mine) p.id},
  )(profile);
}
