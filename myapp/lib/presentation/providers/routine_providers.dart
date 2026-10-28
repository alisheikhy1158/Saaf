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

/// The user's routine: empty until Saaf AI has read a face scan and researched
/// products for it (the app never fills it with products nobody checked for
/// this user). Then the products the user already uses take their steps first
/// (unless Saaf AI says to replace or stop them), and Saaf AI's reviewed
/// options fill the others: the one the user chose, or the best one. The
/// safety answers and the budget still decide, here on the phone.
@Riverpod(retry: noAutoRetry)
Future<Routine> routine(Ref ref) async {
  final profile = ref.watch(skinProfileControllerProvider);
  final plan = ref.watch(aiRoutinePlanControllerProvider).value;
  if (plan == null) {
    return Routine(
      morning: const [],
      night: const [],
      concerns: profile.concerns.toList(),
      budget: profile.budget,
    );
  }
  final owned = await ref.watch(currentProductsProvider.future);
  final choices = await ref.watch(routineChoicesProvider.future);
  final mine = OwnedProduct.productsFor(owned, plan);
  return BuildRoutine(
    [...plan.products, ...mine],
    preferred: plan.chosenIds(choices),
    owned: {for (final p in mine) p.id},
    rank: [for (final p in plan.picks) p.product.id],
  )(profile);
}
