// Covers: PLAN 2.6 (hidden /gallery route to view the common widgets in Chrome,
// light + dark, LTR + RTL), design.md §6
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/app.dart';
import 'package:saaf/core/router/app_router.dart';
import 'package:saaf/core/router/saaf_route.dart';
import 'package:saaf/presentation/providers/app_router_provider.dart';
import 'package:saaf/presentation/widgets/common/saaf_adaptive_nav.dart';
import 'package:saaf/presentation/widgets/common/saaf_button.dart';
import 'package:saaf/presentation/widgets/common/saaf_card.dart';
import 'package:saaf/presentation/widgets/common/saaf_chip.dart';
import 'package:saaf/presentation/widgets/common/saaf_icon_button.dart';
import 'package:saaf/presentation/widgets/common/saaf_text_field.dart';

import '../../../helpers/pump_app.dart';

Future<void> pumpGallery(
  WidgetTester tester, {
  bool enableGallery = true,
  Size size = const Size(390, 844),
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appRouterProvider.overrideWithValue(
          buildAppRouter(
            initialLocation: SaafRoute.gallery.path,
            enableGallery: enableGallery,
          ),
        ),
      ],
      child: const SaafApp(),
    ),
  );
  await tester.pump(const Duration(milliseconds: 400));
}

void main() {
  test('the gallery is not one of the 14 Figma screens', () {
    expect(SaafRoute.all, isNot(contains(SaafRoute.gallery)));
    expect(SaafRoute.gallery.path, '/gallery');
  });

  testWidgets('/gallery shows every common widget', (tester) async {
    await pumpGallery(tester);
    expect(find.byKey(const ValueKey('screen-gallery')), findsOneWidget);
    // Scroll through the page so lazily built content is realised.
    for (final type in <Type>[
      SaafButton,
      SaafIconButton,
      SaafChip,
      SaafCard,
      SaafTextField,
    ]) {
      await tester.scrollUntilVisible(
        find.byType(type).first,
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.byType(type), findsWidgets, reason: '$type');
    }
    expect(find.byType(SaafAdaptiveNav), findsOneWidget);
  });

  testWidgets('the dark switch re-themes the gallery', (tester) async {
    await pumpGallery(tester);
    BuildContext content() =>
        tester.element(find.byKey(const ValueKey('gallery-content')));
    expect(Theme.of(content()).brightness, Brightness.light);
    await tester.tap(find.byKey(const ValueKey('gallery-dark')));
    await tester.pump(const Duration(milliseconds: 400));
    expect(Theme.of(content()).brightness, Brightness.dark);
  });

  testWidgets('the RTL switch mirrors the gallery', (tester) async {
    await pumpGallery(tester);
    BuildContext content() =>
        tester.element(find.byKey(const ValueKey('gallery-content')));
    expect(Directionality.of(content()), TextDirection.ltr);
    await tester.tap(find.byKey(const ValueKey('gallery-rtl')));
    await tester.pump(const Duration(milliseconds: 400));
    expect(Directionality.of(content()), TextDirection.rtl);
  });

  testWidgets('the gallery does not exist when disabled (release builds)', (
    tester,
  ) async {
    await pumpGallery(tester, enableGallery: false);
    expect(find.byKey(const ValueKey('screen-gallery')), findsNothing);
    expect(find.byKey(const ValueKey('screen-not-found')), findsOneWidget);
  });

  testWidgets('renders without overflow at phone, tablet and desktop sizes', (
    tester,
  ) async {
    for (final size in matrixSizes) {
      await pumpGallery(tester, size: size);
      expect(tester.takeException(), isNull, reason: '$size');
    }
  });
}
