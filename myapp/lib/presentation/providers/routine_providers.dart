import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:saaf/data/repositories/real_product_catalog.dart';
import 'package:saaf/domain/entities/routine.dart';
import 'package:saaf/domain/repositories/product_catalog.dart';
import 'package:saaf/domain/usecases/build_routine.dart';
import 'package:saaf/presentation/providers/no_auto_retry.dart';
import 'package:saaf/presentation/providers/skin_profile_providers.dart';

part 'routine_providers.g.dart';

/// Real products sold in Pakistan, shipped with the app (prices are a guide).
/// A backend feed to keep prices fresh can replace this later (OFF-4).
@Riverpod(keepAlive: true)
ProductCatalog productCatalog(Ref ref) => const RealProductCatalog();

/// The user's routine, rebuilt whenever the quiz answers change.
@Riverpod(retry: noAutoRetry)
Future<Routine> routine(Ref ref) async {
  final products = await ref.watch(productCatalogProvider).all();
  final profile = ref.watch(skinProfileControllerProvider);
  return BuildRoutine(products)(profile);
}
