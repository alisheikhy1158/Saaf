// Covers: scanning a product barcode — our own camera explanation before the
// system dialog (store-compliance §1), typing the number instead, and moving on
// to the product result
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/core/error/result.dart';
import 'package:saaf/data/services/web/fake_external_link_service.dart';
import 'package:saaf/data/services/web/fake_permission_service.dart';
import 'package:saaf/domain/entities/camera_permission.dart';
import 'package:saaf/domain/entities/scanned_product.dart';
import 'package:saaf/domain/services/product_lookup.dart';
import 'package:saaf/presentation/features/products/screens/product_scan_result_screen.dart';
import 'package:saaf/presentation/features/products/screens/scan_product_screen.dart';
import 'package:saaf/presentation/providers/product_providers.dart';
import 'package:saaf/presentation/providers/scan_providers.dart';

import '../../../helpers/pump_app.dart';

class _Permissions extends FakePermissionService {
  _Permissions(super.initial, {super.grantsOnRequest});
  int settingsOpened = 0;

  @override
  Future<bool> openSettings() async {
    settingsOpened++;
    return true;
  }
}

class _Lookup implements ProductLookup {
  final List<String> asked = [];

  @override
  Future<Result<ScannedProduct?>> byBarcode(String barcode) async {
    asked.add(barcode);
    return const Ok<ScannedProduct?>(null);
  }
}

late _Lookup _lookup;

/// A stand-in for the live camera: one button that "reads" a barcode.
Widget _fakeScanner(BuildContext context, ValueChanged<String> onCode) =>
    Center(
      child: FilledButton(
        onPressed: () => onCode('3337875743563'),
        child: const Text('simulate barcode'),
      ),
    );

List<Override> _overrides(_Permissions permissions) => [
  permissionServiceProvider.overrideWithValue(permissions),
  barcodeScannerViewProvider.overrideWithValue(_fakeScanner),
  productLookupProvider.overrideWithValue(_lookup),
  externalLinkServiceProvider.overrideWithValue(FakeExternalLinkService()),
];

Future<void> _open(
  WidgetTester tester, {
  CameraPermission permission = CameraPermission.granted,
  bool grantsOnRequest = true,
  _Permissions? service,
}) async {
  await pumpSaafApp(
    tester,
    location: '/scan-product',
    overrides: _overrides(
      service ?? _Permissions(permission, grantsOnRequest: grantsOnRequest),
    ),
  );
  await tester.pump();
  await tester.pump();
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.tap(finder, warnIfMissed: false);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

void main() {
  setUp(() => _lookup = _Lookup());

  group('camera allowed', () {
    testWidgets('shows the scanner, a hint and the typing option', (
      tester,
    ) async {
      await _open(tester);
      expect(find.text('Scan a product'), findsWidgets);
      expect(find.text('simulate barcode'), findsOneWidget);
      expect(find.textContaining('Point the camera'), findsOneWidget);
      expect(find.text('Or type the barcode number'), findsOneWidget);
    });

    testWidgets('a scanned barcode opens the product result', (tester) async {
      await _open(tester);
      await _tap(tester, find.text('simulate barcode'));
      expect(find.byType(ProductScanResultScreen), findsOneWidget);
      expect(_lookup.asked, ['3337875743563']);
    });

    testWidgets('only the first reading counts', (tester) async {
      await _open(tester);
      final button = find.text('simulate barcode');
      await tester.tap(button, warnIfMissed: false);
      await tester.tap(button, warnIfMissed: false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(_lookup.asked, hasLength(1));
    });
  });

  group('our explanation comes first', () {
    testWidgets('not asked yet: explains before the system dialog', (
      tester,
    ) async {
      final permissions = _Permissions(CameraPermission.denied);
      await _open(tester, service: permissions);
      expect(find.text('Allow camera access'), findsOneWidget);
      expect(find.textContaining('read a product’s barcode'), findsOneWidget);
      expect(find.text('simulate barcode'), findsNothing);
      expect(await permissions.cameraStatus(), CameraPermission.denied);
    });

    testWidgets('Continue asks, and allowing opens the scanner', (
      tester,
    ) async {
      await _open(tester, permission: CameraPermission.denied);
      await _tap(tester, find.text('Continue'));
      expect(find.text('simulate barcode'), findsOneWidget);
    });

    testWidgets('Not now keeps the typing option and a way to try again', (
      tester,
    ) async {
      await _open(tester, permission: CameraPermission.denied);
      await _tap(tester, find.text('Not now'));
      expect(find.text('simulate barcode'), findsNothing);
      expect(find.text('Camera access is off'), findsOneWidget);
      expect(find.text('Or type the barcode number'), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
    });

    testWidgets('refused in the system dialog: offers Settings', (
      tester,
    ) async {
      await _open(
        tester,
        permission: CameraPermission.denied,
        grantsOnRequest: false,
      );
      await _tap(tester, find.text('Continue'));
      expect(find.text('Open Settings'), findsOneWidget);
      expect(find.text('Or type the barcode number'), findsOneWidget);
    });

    testWidgets('blocked earlier: no dialog, Open Settings works', (
      tester,
    ) async {
      final permissions = _Permissions(CameraPermission.permanentlyDenied);
      await _open(tester, service: permissions);
      expect(find.text('Allow camera access'), findsNothing);
      await _tap(tester, find.text('Open Settings'));
      expect(permissions.settingsOpened, 1);
    });
  });

  group('typing the number instead', () {
    testWidgets('a good number opens the result', (tester) async {
      await _open(tester, permission: CameraPermission.permanentlyDenied);
      await tester.enterText(
        find.byKey(const ValueKey('barcode-field')),
        '3337875743563',
      );
      await _tap(tester, find.text('Look up'));
      expect(find.byType(ProductScanResultScreen), findsOneWidget);
      expect(_lookup.asked, ['3337875743563']);
    });

    testWidgets('a number that is too short is refused with a message', (
      tester,
    ) async {
      await _open(tester, permission: CameraPermission.permanentlyDenied);
      await tester.enterText(
        find.byKey(const ValueKey('barcode-field')),
        '123',
      );
      await _tap(tester, find.text('Look up'));
      expect(
        find.text('Enter the 8 to 14 digits printed under the barcode.'),
        findsOneWidget,
      );
      expect(_lookup.asked, isEmpty);
    });

    testWidgets('only digits can be typed', (tester) async {
      await _open(tester, permission: CameraPermission.permanentlyDenied);
      await tester.enterText(
        find.byKey(const ValueKey('barcode-field')),
        '33a37 87x5',
      );
      final field = tester.widget<EditableText>(
        find.descendant(
          of: find.byKey(const ValueKey('barcode-field')),
          matching: find.byType(EditableText),
        ),
      );
      expect(field.controller.text, '3337875');
    });
  });

  group('layout', () {
    testWidgets('is robust and accessible', (tester) async {
      for (final size in matrixSizes) {
        await pumpSaafApp(
          tester,
          location: '/scan-product',
          size: size,
          overrides: _overrides(_Permissions(CameraPermission.granted)),
        );
        await tester.pump();
        await tester.pump();
        expect(tester.takeException(), isNull, reason: '$size');
      }
      await expectTapTargetsAccessible(tester);
    });

    testWidgets('the explanation fits at 200 % text in Urdu', (tester) async {
      await pumpSaaf(
        tester,
        const ScanProductScreen(),
        scaffold: false,
        textScale: 2,
        locale: const Locale('ur'),
        overrides: _overrides(_Permissions(CameraPermission.denied)),
      );
      await tester.pump();
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });
}
