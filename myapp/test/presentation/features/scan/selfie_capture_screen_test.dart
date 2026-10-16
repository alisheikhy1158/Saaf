// Covers: Figma 06 Selfie capture (node 3:2) extended to three photos (front,
// left, right), design.md §9, store-compliance §1 (own explanation before the
// system dialog, usable without the camera), A11Y-1/2/3/5/6/8
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/data/services/web/fake_camera_service.dart';
import 'package:saaf/data/services/web/fake_permission_service.dart';
import 'package:saaf/data/services/web/fake_photo_picker.dart';
import 'package:saaf/data/services/web/in_memory_photo_store.dart';
import 'package:saaf/domain/entities/camera_permission.dart';
import 'package:saaf/domain/entities/capture_quality.dart';
import 'package:saaf/domain/entities/face_pose.dart';
import 'package:saaf/domain/services/capture_quality_monitor.dart';
import 'package:saaf/presentation/features/scan/screens/selfie_capture_screen.dart';
import 'package:saaf/presentation/providers/scan_providers.dart';
import 'package:saaf/presentation/widgets/common/saaf_camera_controls.dart';

import '../../../helpers/pump_app.dart';

/// Says what it is told; never starts a timer.
class _Monitor implements CaptureQualityMonitor {
  _Monitor([this.quality = CaptureQuality.initial]);
  final CaptureQuality quality;

  @override
  Stream<CaptureQuality> watch(FacePose pose) => Stream.value(quality);
}

const _ready = CaptureQuality(lightOk: true, centred: true, steady: true);

List<Override> _overrides({
  CameraPermission permission = CameraPermission.granted,
  CaptureQualityMonitor? monitor,
}) {
  final camera = FakeCameraService();
  return [
    permissionServiceProvider.overrideWithValue(
      FakePermissionService(permission),
    ),
    cameraDeviceProvider.overrideWithValue((service: camera, preview: camera)),
    captureQualityMonitorProvider.overrideWithValue(monitor ?? _Monitor()),
    photoPickerProvider.overrideWithValue(FakePhotoPicker()),
    photoStoreProvider.overrideWithValue(InMemoryPhotoStore()),
  ];
}

Future<void> _open(
  WidgetTester tester, {
  CameraPermission permission = CameraPermission.granted,
  CaptureQualityMonitor? monitor,
  Size size = const Size(390, 844),
}) async {
  await pumpSaaf(
    tester,
    const SelfieCaptureScreen(),
    scaffold: false,
    size: size,
    overrides: _overrides(permission: permission, monitor: monitor),
  );
  await tester.pump();
  await tester.pump();
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pump();
  await tester.pump();
}

void main() {
  group('live camera', () {
    testWidgets('shows the top bar, the three steps and the controls', (
      tester,
    ) async {
      await _open(tester);
      expect(find.text('Face scan'), findsOneWidget);
      for (final label in ['Front', 'Left', 'Right']) {
        expect(find.text(label), findsOneWidget);
      }
      expect(find.byTooltip('Close'), findsOneWidget);
      expect(find.byTooltip('Screen light'), findsOneWidget);
      expect(find.byTooltip('Choose from gallery'), findsOneWidget);
      expect(find.byTooltip('Switch camera'), findsOneWidget);
      expect(find.bySemanticsLabel('Take photo'), findsOneWidget);
    });

    testWidgets('asks for the front pose first', (tester) async {
      await _open(tester);
      expect(find.text('Look straight at the camera'), findsOneWidget);
    });

    testWidgets('shows the three quality chips', (tester) async {
      await _open(tester, monitor: _Monitor(_ready));
      expect(find.text('Good light'), findsOneWidget);
      expect(find.text('Centred'), findsOneWidget);
      expect(find.text('Hold still'), findsOneWidget);
    });

    testWidgets('the advice chip replaces the instruction when light is bad', (
      tester,
    ) async {
      await _open(
        tester,
        monitor: _Monitor(
          const CaptureQuality(
            lightOk: false,
            centred: true,
            steady: true,
            advice: LightAdvice.tooBright,
          ),
        ),
      );
      expect(find.text('Move to softer light'), findsOneWidget);
      expect(find.text('Look straight at the camera'), findsNothing);
    });

    testWidgets('shows the countdown once everything is ready', (tester) async {
      await _open(tester, monitor: _Monitor(_ready));
      expect(find.text('Hold still — capturing in 2s'), findsOneWidget);
      // Leave the screen so the countdown timer is cancelled.
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('the light button adds a frame and can be switched off', (
      tester,
    ) async {
      await _open(tester);
      expect(find.byKey(const ValueKey('scan-light-frame')), findsNothing);
      await _tap(tester, find.byTooltip('Screen light'));
      expect(find.byKey(const ValueKey('scan-light-frame')), findsOneWidget);
      await _tap(tester, find.byTooltip('Screen light'));
      expect(find.byKey(const ValueKey('scan-light-frame')), findsNothing);
    });
  });

  group('three photos', () {
    testWidgets('shutter, keep, then the left cheek is asked for', (
      tester,
    ) async {
      await _open(tester);
      await _tap(tester, find.bySemanticsLabel('Take photo'));
      expect(find.text('Is your face clear and well lit?'), findsOneWidget);
      expect(find.text('Retake'), findsOneWidget);
      expect(find.text('Use this photo'), findsOneWidget);

      await _tap(tester, find.text('Use this photo'));
      expect(find.text('Show your left cheek'), findsOneWidget);
      expect(find.bySemanticsLabel('Take photo'), findsOneWidget);
    });

    testWidgets('retake goes back to the camera for the same pose', (
      tester,
    ) async {
      await _open(tester);
      await _tap(tester, find.bySemanticsLabel('Take photo'));
      await _tap(tester, find.text('Retake'));
      expect(find.text('Look straight at the camera'), findsOneWidget);
      expect(find.text('Retake'), findsNothing);
    });

    testWidgets('the last photo offers "Analyse my skin"', (tester) async {
      await _open(tester);
      for (var i = 0; i < 2; i++) {
        await _tap(tester, find.bySemanticsLabel('Take photo'));
        await _tap(tester, find.text('Use this photo'));
      }
      expect(find.text('Show your right cheek'), findsOneWidget);
      await _tap(tester, find.bySemanticsLabel('Take photo'));
      expect(find.text('Analyse my skin'), findsOneWidget);
      expect(find.text('Use this photo'), findsNothing);
    });

    testWidgets('a finished step can be tapped to look at it again', (
      tester,
    ) async {
      await _open(tester);
      await _tap(tester, find.bySemanticsLabel('Take photo'));
      await _tap(tester, find.text('Use this photo'));
      await _tap(tester, find.text('Front'));
      expect(find.text('Retake'), findsOneWidget);
    });

    testWidgets('a gallery photo can be used instead of the camera', (
      tester,
    ) async {
      await _open(tester);
      await _tap(tester, find.byTooltip('Choose from gallery'));
      expect(find.text('Use this photo'), findsOneWidget);
    });
  });

  group('finishing', () {
    testWidgets('three photos, then "Analyse my skin" opens the results', (
      tester,
    ) async {
      await pumpSaafApp(
        tester,
        location: '/selfie-capture',
        overrides: _overrides(),
      );
      await tester.pump();
      await tester.pump();
      for (var i = 0; i < 2; i++) {
        await _tap(tester, find.bySemanticsLabel('Take photo'));
        await _tap(tester, find.text('Use this photo'));
      }
      await _tap(tester, find.bySemanticsLabel('Take photo'));
      await _tap(tester, find.text('Analyse my skin'));
      await tester.pump(const Duration(seconds: 1));
      expect(
        find.byKey(const ValueKey('screen-analysisResults')),
        findsOneWidget,
      );
      // The results are worked out from the saved scan.
      expect(find.text('Here’s your skin today'), findsOneWidget);
    });

    testWidgets('the X leaves the scan for Home', (tester) async {
      await pumpSaafApp(
        tester,
        location: '/selfie-capture',
        overrides: _overrides(),
      );
      await tester.pump();
      await tester.tap(find.byTooltip('Close'));
      await tester.pump(const Duration(seconds: 1));
      expect(find.byKey(const ValueKey('screen-home')), findsOneWidget);
    });

    testWidgets('"Not now" on the camera explanation leaves for Home', (
      tester,
    ) async {
      await pumpSaafApp(
        tester,
        location: '/selfie-capture',
        overrides: _overrides(permission: CameraPermission.denied),
      );
      await tester.pump();
      await tester.pump();
      await _tap(tester, find.text('Not now'));
      await tester.pump(const Duration(seconds: 1));
      expect(find.byKey(const ValueKey('screen-home')), findsOneWidget);
    });
  });

  group('permission', () {
    testWidgets('explains before the system asks, then opens the camera', (
      tester,
    ) async {
      await _open(tester, permission: CameraPermission.denied);
      expect(find.text('Allow camera access'), findsOneWidget);
      expect(
        find.text(
          'Photos stay on your phone unless you choose to send them to the AI coach.',
        ),
        findsOneWidget,
      );
      expect(find.bySemanticsLabel('Take photo'), findsNothing);

      await _tap(tester, find.text('Continue'));
      expect(find.text('Allow camera access'), findsNothing);
      expect(find.bySemanticsLabel('Take photo'), findsOneWidget);
    });

    testWidgets('blocked for good: offers Settings and the gallery', (
      tester,
    ) async {
      await _open(tester, permission: CameraPermission.permanentlyDenied);
      expect(find.text('Turn on the camera in Settings'), findsOneWidget);
      expect(find.text('Open Settings'), findsOneWidget);
      expect(find.text('Choose from gallery'), findsOneWidget);
      expect(find.bySemanticsLabel('Take photo'), findsNothing);
    });

    testWidgets('the gallery works without the camera', (tester) async {
      await _open(tester, permission: CameraPermission.permanentlyDenied);
      await _tap(tester, find.text('Choose from gallery'));
      expect(find.text('Use this photo'), findsOneWidget);
    });
  });

  group('layout', () {
    /// Like `expectRobustLayout`, but waits until the camera has started (or the
    /// panel is up) so the real screen is measured, and can move on to a state.
    Future<void> robust(
      WidgetTester tester, {
      CameraPermission permission = CameraPermission.granted,
      Future<void> Function()? advance,
    }) async {
      final configs = <(String, Size, ThemeMode, double, Locale, bool)>[
        for (final size in matrixSizes)
          ('$size', size, ThemeMode.light, 1, const Locale('en'), false),
        ('dark', matrixSizes[1], ThemeMode.dark, 1, const Locale('en'), false),
        (
          'text 200%',
          matrixSizes[1],
          ThemeMode.light,
          2,
          const Locale('en'),
          false,
        ),
        ('Urdu', matrixSizes[1], ThemeMode.light, 1, const Locale('ur'), false),
        (
          'contrast',
          matrixSizes[1],
          ThemeMode.light,
          1,
          const Locale('en'),
          true,
        ),
      ];
      for (final (name, size, mode, scale, locale, contrast) in configs) {
        // Drop the previous screen and its state first.
        await tester.pumpWidget(const SizedBox());
        await pumpSaaf(
          tester,
          const SelfieCaptureScreen(),
          scaffold: false,
          size: size,
          themeMode: mode,
          textScale: scale,
          locale: locale,
          highContrast: contrast,
          overrides: _overrides(permission: permission),
        );
        await tester.pump();
        await tester.pump();
        await advance?.call();
        expect(tester.takeException(), isNull, reason: name);
      }
    }

    Future<void> shoot(WidgetTester tester) async {
      final shutter = find.byKey(SaafCameraControls.shutterKey);
      await tester.ensureVisible(shutter);
      await tester.tap(shutter);
      await tester.pump();
      await tester.pump();
    }

    testWidgets('live camera is robust', (tester) async {
      await robust(tester);
    });

    testWidgets('reviewing a photo is robust', (tester) async {
      await robust(tester, advance: () => shoot(tester));
    });

    testWidgets('permission panel is robust', (tester) async {
      await robust(tester, permission: CameraPermission.denied);
    });

    testWidgets('live camera is accessible', (tester) async {
      await _open(tester);
      await expectTapTargetsAccessible(tester);
    });

    testWidgets('review is accessible', (tester) async {
      await _open(tester);
      await shoot(tester);
      await expectTapTargetsAccessible(tester);
    });

    testWidgets('permission panel is accessible', (tester) async {
      await _open(tester, permission: CameraPermission.denied);
      await expectTapTargetsAccessible(tester);
    });

    testWidgets('the shutter is reachable on a small phone', (tester) async {
      await _open(tester, size: const Size(320, 568));
      await tester.ensureVisible(find.bySemanticsLabel('Take photo'));
      expect(tester.takeException(), isNull);
    });
  });
}
