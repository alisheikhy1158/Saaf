// Covers: PLAN Phase 5 (English/Urdu language switch), design.md §11
import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/presentation/providers/locale_controller.dart';

void main() {
  test('follows the system language until the user picks one', () {
    final container = ProviderContainer.test();
    expect(container.read(localeControllerProvider), isNull);
  });

  test('setLocale stores the chosen language', () {
    final container = ProviderContainer.test();
    container
        .read(localeControllerProvider.notifier)
        .setLocale(const Locale('ur'));
    expect(container.read(localeControllerProvider), const Locale('ur'));
  });

  test('setLocale(null) goes back to the system language', () {
    final container = ProviderContainer.test();
    final notifier = container.read(localeControllerProvider.notifier)
      ..setLocale(const Locale('ur'))
      ..setLocale(null);
    expect(container.read(localeControllerProvider), isNull);
    expect(notifier, isNotNull);
  });

  test('only supported languages are accepted', () {
    final container = ProviderContainer.test();
    final notifier = container.read(localeControllerProvider.notifier);
    expect(() => notifier.setLocale(const Locale('fr')), throwsArgumentError);
  });
}
