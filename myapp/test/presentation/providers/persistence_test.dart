// Covers: Phase 7 — what the user said and did survives a restart, and account
// deletion wipes the database (store requirement A-1)
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/data/local/app_database.dart';
import 'package:saaf/data/repositories/fake_auth_repository.dart';
import 'package:saaf/data/services/web/in_memory_photo_store.dart';
import 'package:saaf/domain/entities/completed_scan.dart';
import 'package:saaf/domain/entities/consent_record.dart';
import 'package:saaf/domain/entities/face_pose.dart';
import 'package:saaf/domain/entities/skin_profile.dart';
import 'package:saaf/domain/entities/skin_type.dart';
import 'package:saaf/domain/entities/stored_photo.dart';
import 'package:saaf/presentation/providers/auth_providers.dart';
import 'package:saaf/presentation/providers/consent_providers.dart';
import 'package:saaf/presentation/providers/database_providers.dart';
import 'package:saaf/presentation/providers/onboarding_status.dart';
import 'package:saaf/presentation/providers/profile_providers.dart';
import 'package:saaf/presentation/providers/progress_providers.dart';
import 'package:saaf/presentation/providers/scan_providers.dart';
import 'package:saaf/presentation/providers/skin_profile_providers.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  /// A fresh app start on the same database.
  ProviderContainer start() {
    final c = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
        photoStoreProvider.overrideWithValue(InMemoryPhotoStore()),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  Future<void> settle() =>
      Future<void>.delayed(const Duration(milliseconds: 50));

  test('the quiz being done is remembered', () async {
    final first = start();
    first.read(quizDoneProvider.notifier).markDone();
    await settle();

    final second = start();
    second.listen(quizDoneProvider, (_, _) {});
    await settle();
    expect(second.read(quizDoneProvider), isTrue);
  });

  test('consent is remembered', () async {
    final first = start();
    await first
        .read(consentRepositoryProvider)
        .save(ConsentRecord(acceptedAt: DateTime(2026), policyVersion: 'v'));

    final second = start();
    second.listen(consentStatusProvider, (_, _) {});
    expect(second.read(consentStatusProvider), isNull); // still reading
    await settle();
    expect(second.read(consentStatusProvider), isTrue);
  });

  test('no consent saved: false, not true', () async {
    final c = start();
    c.listen(consentStatusProvider, (_, _) {});
    await settle();
    expect(c.read(consentStatusProvider), isFalse);
  });

  test('the quiz answers are remembered', () async {
    final first = start();
    await first
        .read(skinProfileRepositoryProvider)
        .save(const SkinProfile(skinType: SkinType.oily));

    final second = start();
    second.listen(skinProfileControllerProvider, (_, _) {});
    await settle();
    expect(second.read(skinProfileControllerProvider).skinType, SkinType.oily);
  });

  test('finished scans are remembered', () async {
    final scan = CompletedScan(
      id: 'scan-1',
      takenAt: DateTime(2026, 10, 1),
      photos: const [
        StoredPhoto(
          scanId: 'scan-1',
          pose: FacePose.front,
          reference: 'scans/scan-1/front.jpg',
        ),
      ],
    );
    final first = start();
    first.read(scanHistoryProvider.notifier).add(scan);
    await settle();

    final second = start();
    second.listen(scanHistoryProvider, (_, _) {});
    await settle();
    expect(second.read(scanHistoryProvider).map((s) => s.id), ['scan-1']);
  });

  test(
    'deleting the account empties the database and resets the app',
    () async {
      final c = start();
      c.listen(quizDoneProvider, (_, _) {});
      c.listen(skinProfileControllerProvider, (_, _) {});
      c.listen(scanHistoryProvider, (_, _) {});
      await c
          .read(consentRepositoryProvider)
          .save(ConsentRecord(acceptedAt: DateTime(2026), policyVersion: 'v'));
      await c
          .read(skinProfileRepositoryProvider)
          .save(const SkinProfile(skinType: SkinType.dry));
      c.read(quizDoneProvider.notifier).markDone();
      c
          .read(scanHistoryProvider.notifier)
          .add(
            CompletedScan(
              id: 's',
              takenAt: DateTime(2026, 10, 1),
              photos: const [],
            ),
          );
      await settle();

      final result = await c
          .read(accountControllerProvider.notifier)
          .deleteAccount();
      expect(result.isOk, isTrue);
      await settle();

      expect(await db.select(db.consentRows).get(), isEmpty);
      expect(await db.select(db.skinProfileRows).get(), isEmpty);
      expect(await db.select(db.scanRows).get(), isEmpty);
      expect(await db.select(db.flagRows).get(), isEmpty);
      expect(c.read(quizDoneProvider), isFalse);
      expect(c.read(scanHistoryProvider), isEmpty);

      // And a restart afterwards finds nothing.
      final again = start();
      again.listen(quizDoneProvider, (_, _) {});
      await settle();
      expect(again.read(quizDoneProvider), isFalse);
    },
  );
}
