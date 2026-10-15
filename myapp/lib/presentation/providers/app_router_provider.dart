import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:saaf/core/router/app_router.dart';

part 'app_router_provider.g.dart';

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final router = buildAppRouter();
  ref.onDispose(router.dispose);
  return router;
}
