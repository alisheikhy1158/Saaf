// Covers: design.md §6 SaafCameraControls (06: 48 gallery r14, 78 shutter, 48
// flip), A11Y-1 (labels), 48 dp hit areas
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/presentation/widgets/common/saaf_camera_controls.dart';
import 'package:saaf/presentation/widgets/common/saaf_dark_scope.dart';

import '../../../helpers/pump_app.dart';

Widget controls({
  VoidCallback? onGallery,
  VoidCallback? onShutter,
  VoidCallback? onFlip,
}) => SaafDarkScope(
  child: Scaffold(
    body: Center(
      child: SaafCameraControls(
        onGallery: onGallery,
        onShutter: onShutter,
        onFlip: onFlip,
        galleryLabel: 'Choose from gallery',
        shutterLabel: 'Take photo',
        flipLabel: 'Switch camera',
      ),
    ),
  ),
);

void main() {
  testWidgets('has the three Figma sizes', (tester) async {
    await pumpSaaf(
      tester,
      controls(onGallery: () {}, onShutter: () {}, onFlip: () {}),
      scaffold: false,
    );
    expect(
      tester.getSize(find.byKey(SaafCameraControls.shutterKey)),
      const Size(78, 78),
    );
    expect(
      tester.getSize(find.byTooltip('Choose from gallery')),
      const Size(48, 48),
    );
    expect(tester.getSize(find.byTooltip('Switch camera')), const Size(48, 48));
  });

  testWidgets('each control calls its callback', (tester) async {
    final calls = <String>[];
    await pumpSaaf(
      tester,
      controls(
        onGallery: () => calls.add('gallery'),
        onShutter: () => calls.add('shutter'),
        onFlip: () => calls.add('flip'),
      ),
      scaffold: false,
    );
    await tester.tap(find.byTooltip('Choose from gallery'));
    await tester.tap(find.byKey(SaafCameraControls.shutterKey));
    await tester.tap(find.byTooltip('Switch camera'));
    expect(calls, ['gallery', 'shutter', 'flip']);
  });

  testWidgets('no onFlip hides the flip button but keeps the shutter centred', (
    tester,
  ) async {
    await pumpSaaf(
      tester,
      controls(onGallery: () {}, onShutter: () {}),
      scaffold: false,
    );
    expect(find.byTooltip('Switch camera'), findsNothing);
    final shutter = tester.getCenter(find.byKey(SaafCameraControls.shutterKey));
    expect(shutter.dx, closeTo(195, 1));
  });

  testWidgets('no onShutter: tapping the shutter does nothing', (tester) async {
    var taps = 0;
    await pumpSaaf(tester, controls(onGallery: () => taps++), scaffold: false);
    await tester.tap(find.byKey(SaafCameraControls.shutterKey));
    expect(taps, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('survives the responsive / dark / 200 % / RTL matrix', (
    tester,
  ) async {
    await expectRobustLayout(
      tester,
      () => controls(onGallery: () {}, onShutter: () {}, onFlip: () {}),
      scaffold: false,
    );
  });
}
