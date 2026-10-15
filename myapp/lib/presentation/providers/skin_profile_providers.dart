import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:saaf/data/repositories/in_memory_skin_profile_repository.dart';
import 'package:saaf/domain/repositories/skin_profile_repository.dart';
import 'package:saaf/domain/usecases/save_skin_concerns.dart';

part 'skin_profile_providers.g.dart';

/// Swapped for the drift-backed repository in Phase 7.
@Riverpod(keepAlive: true)
SkinProfileRepository skinProfileRepository(Ref ref) =>
    InMemorySkinProfileRepository();

@riverpod
SaveSkinConcerns saveSkinConcerns(Ref ref) =>
    SaveSkinConcerns(ref.watch(skinProfileRepositoryProvider));
