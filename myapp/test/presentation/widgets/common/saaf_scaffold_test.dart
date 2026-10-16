// Covers: design.md §6 SaafScaffold (gutter 20 / 16, bottom 28, SafeArea),
// §7 (max content width 560, CTA pinned only when content fits, 320×480 no
// overflow), A11Y-6
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/presentation/widgets/common/saaf_scaffold.dart';

import '../../../helpers/pump_app.dart';

void main() {
  const bodyKey = ValueKey('body');
  const ctaKey = ValueKey('cta');

  Widget scaffold({double bodyHeight = 100, Widget? topBar, Widget? banner}) =>
      SaafScaffold(
        topBar: topBar,
        offlineBanner: banner,
        body: SizedBox(
          key: bodyKey,
          height: bodyHeight,
          width: double.infinity,
        ),
        bottom: const SizedBox(key: ctaKey, height: 56, width: double.infinity),
      );

  testWidgets('uses the 20 dp gutter on a 390 dp phone', (tester) async {
    await pumpSaaf(tester, scaffold(), scaffold: false);
    final body = tester.getRect(find.byKey(bodyKey));
    expect(body.left, 20);
    expect(body.right, 390 - 20);
  });

  testWidgets('uses the 16 dp gutter below 360 dp', (tester) async {
    await pumpSaaf(
      tester,
      scaffold(),
      size: const Size(320, 568),
      scaffold: false,
    );
    final body = tester.getRect(find.byKey(bodyKey));
    expect(body.left, 16);
    expect(body.right, 320 - 16);
  });

  testWidgets('limits content to 560 dp and centres it on wide screens', (
    tester,
  ) async {
    await pumpSaaf(
      tester,
      scaffold(),
      size: const Size(1280, 800),
      scaffold: false,
    );
    final body = tester.getRect(find.byKey(bodyKey));
    expect(body.width, lessThanOrEqualTo(560));
    expect(body.center.dx, closeTo(640, 0.5));
  });

  testWidgets('pins the bottom action 28 dp above the edge when content fits', (
    tester,
  ) async {
    await pumpSaaf(tester, scaffold(), scaffold: false);
    final cta = tester.getRect(find.byKey(ctaKey));
    expect(cta.bottom, 844 - 28);
  });

  testWidgets('scrolls the bottom action with the content when it is tall', (
    tester,
  ) async {
    await pumpSaaf(tester, scaffold(bodyHeight: 2000), scaffold: false);
    expect(tester.getRect(find.byKey(ctaKey)).top, greaterThan(844));
    // (scrollUntilVisible stops at once: the CTA is already in the tree.)
    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -2000),
    );
    await tester.pump();
    expect(tester.getRect(find.byKey(ctaKey)).bottom, lessThanOrEqualTo(844));
  });

  testWidgets(
    'shows the top bar above the content and the offline banner on top',
    (tester) async {
      await pumpSaaf(
        tester,
        scaffold(
          topBar: const SizedBox(key: ValueKey('top'), height: 40),
          banner: const SizedBox(key: ValueKey('banner'), height: 32),
        ),
        scaffold: false,
      );
      final banner = tester.getRect(find.byKey(const ValueKey('banner')));
      final top = tester.getRect(find.byKey(const ValueKey('top')));
      final body = tester.getRect(find.byKey(bodyKey));
      expect(banner.bottom, lessThanOrEqualTo(top.top));
      expect(top.bottom, lessThanOrEqualTo(body.top));
    },
  );

  testWidgets('accepts a body that contains a LayoutBuilder', (tester) async {
    await pumpSaaf(
      tester,
      SaafScaffold(
        body: LayoutBuilder(
          builder: (context, constraints) =>
              SizedBox(key: bodyKey, height: 100, width: constraints.maxWidth),
        ),
        bottom: const SizedBox(key: ctaKey, height: 56),
      ),
      scaffold: false,
    );
    expect(tester.takeException(), isNull);
    expect(tester.getRect(find.byKey(ctaKey)).bottom, 844 - 28);
  });

  testWidgets('has no overflow at 320×480 with 200 % text', (tester) async {
    await pumpSaaf(
      tester,
      const SaafScaffold(
        body: Text(
          'Clear skin, made simple. '
          'A long body that wraps and scrolls',
        ),
        bottom: SizedBox(height: 56),
      ),
      size: const Size(320, 480),
      textScale: 2.0,
      scaffold: false,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('survives the responsive / dark / 200 % / RTL matrix', (
    tester,
  ) async {
    await expectRobustLayout(tester, scaffold, scaffold: false);
  });

  group('fixedBody (a chat: the body scrolls by itself)', () {
    Widget chat() => SaafScaffold(
      fixedBody: true,
      body: ListView(
        key: bodyKey,
        children: [for (var i = 0; i < 60; i++) Text('line $i')],
      ),
      bottom: const SizedBox(key: ctaKey, height: 56, width: double.infinity),
    );

    testWidgets('the body takes the space and the bottom stays pinned', (
      tester,
    ) async {
      await pumpSaaf(tester, chat(), scaffold: false);
      expect(tester.takeException(), isNull);
      final body = tester.getRect(find.byKey(bodyKey));
      final cta = tester.getRect(find.byKey(ctaKey));
      expect(cta.bottom, lessThanOrEqualTo(844));
      expect(body.bottom, lessThanOrEqualTo(cta.top));
      // Scrolling the list does not move the pinned bottom.
      await tester.drag(find.byKey(bodyKey), const Offset(0, -400));
      await tester.pump();
      expect(tester.getRect(find.byKey(ctaKey)), cta);
    });

    testWidgets('survives the smallest phone', (tester) async {
      await pumpSaaf(
        tester,
        chat(),
        size: const Size(320, 480),
        scaffold: false,
      );
      expect(tester.takeException(), isNull);
    });
  });
}
