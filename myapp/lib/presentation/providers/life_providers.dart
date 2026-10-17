import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:saaf/domain/entities/introduction.dart';
import 'package:saaf/domain/entities/life_event.dart';
import 'package:saaf/presentation/providers/consent_providers.dart';
import 'package:saaf/presentation/providers/settings_providers.dart';

part 'life_providers.g.dart';

/// The new product being brought in slowly, if any (kept on the phone).
@Riverpod(keepAlive: true)
class IntroductionController extends _$IntroductionController {
  @override
  Future<Introduction?> build() async {
    final json = await ref
        .read(settingsRepositoryProvider)
        .read(SettingNames.introduction);
    return json == null ? null : Introduction.decode(json);
  }

  Future<void> start(String productName) => _save(
    Introduction(
      productName: productName,
      startedOn: ref.read(clockProvider).now(),
    ),
  );

  /// Today's answer to "any reaction?".
  Future<void> answer(Reaction reaction) async {
    final now = await future;
    if (now == null) return;
    await _save(now.withReaction(ref.read(clockProvider).now(), reaction));
  }

  Future<void> clear() => _save(null);

  Future<void> _save(Introduction? value) async {
    await ref
        .read(settingsRepositoryProvider)
        .write(SettingNames.introduction, value?.encode());
    state = AsyncData(value);
  }
}

/// The big day the user is getting ready for, if any (kept on the phone).
@Riverpod(keepAlive: true)
class LifeEventController extends _$LifeEventController {
  @override
  Future<LifeEvent?> build() async {
    final json = await ref
        .read(settingsRepositoryProvider)
        .read(SettingNames.lifeEvent);
    return json == null ? null : LifeEvent.decode(json);
  }

  Future<void> set(LifeEvent? event) async {
    await ref
        .read(settingsRepositoryProvider)
        .write(SettingNames.lifeEvent, event?.encode());
    state = AsyncData(event);
  }
}

/// Ramadan mode: the routine says "after sehri" / "after iftar" and Home
/// shows fasting-friendly tips.
@Riverpod(keepAlive: true)
class RamadanMode extends _$RamadanMode {
  @override
  Future<bool> build() async =>
      await ref
          .read(settingsRepositoryProvider)
          .read(SettingNames.ramadanMode) ==
      'on';

  Future<void> set({required bool on}) async {
    await ref
        .read(settingsRepositoryProvider)
        .write(SettingNames.ramadanMode, on ? 'on' : null);
    state = AsyncData(on);
  }
}
