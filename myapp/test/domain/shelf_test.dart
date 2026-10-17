// Covers: the product shelf — when a product was opened, how long it keeps
// (the "12M" open-jar symbol) and how long it lasts, and the reminders that
// follow (use by, runs out), all on the phone
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/domain/entities/owned_product.dart';
import 'package:saaf/domain/entities/product.dart';
import 'package:saaf/domain/usecases/shelf_alerts.dart';

void main() {
  final opened = DateTime(2026, 9, 1);

  test('use-by and run-out dates come from the opened date', () {
    final p = OwnedProduct(
      name: 'Nivea Soft',
      step: ProductCategory.moisturiser,
      openedOn: opened,
      paoMonths: 12,
      lastsWeeks: 8,
    );
    expect(p.useBy, DateTime(2027, 9, 1));
    expect(p.runsOutAround, DateTime(2026, 10, 27));
    expect(const OwnedProduct(name: 'x').useBy, isNull);
  });

  test('the shelf details survive saving and reading', () {
    final list = [
      OwnedProduct(
        name: 'Nivea Soft',
        step: ProductCategory.moisturiser,
        openedOn: opened,
        paoMonths: 12,
        lastsWeeks: 8,
      ),
    ];
    final back = OwnedProduct.decodeList(OwnedProduct.encodeList(list)).single;
    expect(back.openedOn, opened);
    expect(back.paoMonths, 12);
    expect(back.lastsWeeks, 8);
  });

  group('reminders', () {
    List<(String, ShelfAlertKind)> alerts(
      List<OwnedProduct> list,
      DateTime today,
    ) => [
      for (final a in const ShelfAlerts()(list, today))
        (a.product.name, a.kind),
    ];

    test('past its use-by date, or close to it', () {
      final old = OwnedProduct(name: 'Old', openedOn: opened, paoMonths: 1);
      expect(alerts([old], DateTime(2026, 10, 5)), [
        ('Old', ShelfAlertKind.expired),
      ]);
      expect(alerts([old], DateTime(2026, 9, 20)), [
        ('Old', ShelfAlertKind.expiresSoon),
      ]);
    });

    test('running out soon, or probably finished', () {
      final cream = OwnedProduct(
        name: 'Cream',
        openedOn: opened,
        lastsWeeks: 4,
      );
      expect(alerts([cream], DateTime(2026, 9, 25)), [
        ('Cream', ShelfAlertKind.runsOutSoon),
      ]);
      expect(alerts([cream], DateTime(2026, 10, 10)), [
        ('Cream', ShelfAlertKind.probablyFinished),
      ]);
    });

    test('nothing to say without dates, or when far off', () {
      expect(alerts([const OwnedProduct(name: 'x')], opened), isEmpty);
      final fresh = OwnedProduct(
        name: 'Fresh',
        openedOn: opened,
        paoMonths: 12,
        lastsWeeks: 12,
      );
      expect(alerts([fresh], DateTime(2026, 9, 5)), isEmpty);
    });

    test('expired comes before running out', () {
      final both = OwnedProduct(
        name: 'Both',
        openedOn: opened,
        paoMonths: 1,
        lastsWeeks: 2,
      );
      expect(alerts([both], DateTime(2026, 10, 5)), [
        ('Both', ShelfAlertKind.expired),
      ]);
    });
  });
}
