// Covers: design.md §11 (all strings in ARB, English + Urdu), A11Y-8 (RTL)
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/core/l10n/app_localizations.dart';

Map<String, dynamic> readArb(String name) =>
    jsonDecode(File('lib/core/l10n/$name').readAsStringSync())
        as Map<String, dynamic>;

Set<String> messageKeys(Map<String, dynamic> arb) =>
    arb.keys.where((k) => !k.startsWith('@')).toSet();

void main() {
  group('ARB files', () {
    final en = readArb('app_en.arb');
    final ur = readArb('app_ur.arb');

    test('English is the template locale', () {
      expect(en['@@locale'], 'en');
      expect(ur['@@locale'], 'ur');
    });

    test('Urdu has exactly the same message keys as English', () {
      expect(messageKeys(ur), messageKeys(en));
    });

    test('no message is empty in either language', () {
      for (final arb in [en, ur]) {
        for (final key in messageKeys(arb)) {
          expect((arb[key] as String).trim(), isNotEmpty, reason: key);
        }
      }
    });

    test('English copy matches Figma (01 Welcome)', () {
      expect(en['appName'], 'Saaf');
      expect(en['welcomeTitle'], 'Clear skin, made simple.');
      expect(en['fieldValid'], 'Valid');
    });
  });

  test('supports English and Urdu', () {
    expect(
      AppLocalizations.supportedLocales,
      containsAll([const Locale('en'), const Locale('ur')]),
    );
  });

  for (final (locale, direction) in [
    (const Locale('en'), TextDirection.ltr),
    (const Locale('ur'), TextDirection.rtl),
  ]) {
    testWidgets('${locale.languageCode} resolves strings and $direction', (
      tester,
    ) async {
      late AppLocalizations l10n;
      late TextDirection dir;
      await tester.pumpWidget(
        MaterialApp(
          locale: locale,
          localizationsDelegates: const [
            ...AppLocalizations.localizationsDelegates,
            GlobalMaterialLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              l10n = AppLocalizations.of(context);
              dir = Directionality.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(l10n.appName, isNotEmpty);
      expect(dir, direction);
    });
  }
}
