// Covers: Figma 05 ("Pick up to two"), design.md §10 (max-2 selection),
// SEC-8 (validate at the boundary), architecture §3.10 (Result, no throws)
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/core/error/failure.dart';
import 'package:saaf/domain/entities/skin_concern.dart';
import 'package:saaf/domain/entities/skin_profile.dart';
import 'package:saaf/domain/repositories/skin_profile_repository.dart';
import 'package:saaf/domain/usecases/save_skin_concerns.dart';

class FakeSkinProfileRepository implements SkinProfileRepository {
  SkinProfile? saved;
  int saveCalls = 0;
  Object? throwOnSave;

  @override
  Future<SkinProfile?> current() async => saved;

  @override
  Future<void> save(SkinProfile profile) async {
    saveCalls++;
    if (throwOnSave != null) throw throwOnSave!;
    saved = profile;
  }

  @override
  Future<void> clear() async => saved = null;
}

void main() {
  late FakeSkinProfileRepository repository;
  late SaveSkinConcerns saveSkinConcerns;

  setUp(() {
    repository = FakeSkinProfileRepository();
    saveSkinConcerns = SaveSkinConcerns(repository);
  });

  test('the five concerns match the Figma options, in order', () {
    expect(SkinConcern.values.map((c) => c.name), [
      'darkSpots',
      'acne',
      'oiliness',
      'dryness',
      'unevenTone',
    ]);
  });

  test('saves one concern', () async {
    final result = await saveSkinConcerns({SkinConcern.acne});
    expect(result.isOk, isTrue);
    expect(repository.saved?.concerns, {SkinConcern.acne});
  });

  test('saves two concerns', () async {
    final result = await saveSkinConcerns({
      SkinConcern.darkSpots,
      SkinConcern.oiliness,
    });
    expect(result.valueOrNull?.concerns.length, 2);
  });

  test('rejects three concerns without saving', () async {
    final result = await saveSkinConcerns({
      SkinConcern.darkSpots,
      SkinConcern.acne,
      SkinConcern.dryness,
    });
    expect(result.failureOrNull, const ValidationFailure('concerns'));
    expect(repository.saveCalls, 0);
  });

  test('rejects an empty selection without saving', () async {
    final result = await saveSkinConcerns({});
    expect(result.failureOrNull, const ValidationFailure('concerns'));
    expect(repository.saveCalls, 0);
  });

  test('a storage error becomes StorageFailure', () async {
    repository.throwOnSave = StateError('disk full');
    final result = await saveSkinConcerns({SkinConcern.acne});
    expect(result.failureOrNull, const StorageFailure());
  });

  test('SkinProfile has value equality', () {
    expect(
      const SkinProfile(concerns: {SkinConcern.acne}),
      const SkinProfile(concerns: {SkinConcern.acne}),
    );
  });
}
