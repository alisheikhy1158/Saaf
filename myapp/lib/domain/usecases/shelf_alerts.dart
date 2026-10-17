import 'package:saaf/domain/entities/owned_product.dart';

enum ShelfAlertKind { expired, expiresSoon, probablyFinished, runsOutSoon }

class ShelfAlert {
  const ShelfAlert({required this.product, required this.kind, this.date});

  final OwnedProduct product;
  final ShelfAlertKind kind;

  /// The use-by or run-out day the alert is about.
  final DateTime? date;
}

/// What to tell the user about their shelf today: past its use-by date or
/// within two weeks of it, probably finished or within a week of running out.
/// One alert per product, the most important first.
class ShelfAlerts {
  const ShelfAlerts();

  static const int expiresSoonDays = 14;
  static const int runsOutSoonDays = 7;

  List<ShelfAlert> call(List<OwnedProduct> products, DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    int daysTo(DateTime day) => day.difference(today).inDays;

    final alerts = <ShelfAlert>[];
    for (final product in products) {
      final useBy = product.useBy;
      final runsOut = product.runsOutAround;
      if (useBy != null && daysTo(useBy) <= 0) {
        alerts.add(
          ShelfAlert(
            product: product,
            kind: ShelfAlertKind.expired,
            date: useBy,
          ),
        );
      } else if (useBy != null && daysTo(useBy) <= expiresSoonDays) {
        alerts.add(
          ShelfAlert(
            product: product,
            kind: ShelfAlertKind.expiresSoon,
            date: useBy,
          ),
        );
      } else if (runsOut != null && daysTo(runsOut) <= 0) {
        alerts.add(
          ShelfAlert(
            product: product,
            kind: ShelfAlertKind.probablyFinished,
            date: runsOut,
          ),
        );
      } else if (runsOut != null && daysTo(runsOut) <= runsOutSoonDays) {
        alerts.add(
          ShelfAlert(
            product: product,
            kind: ShelfAlertKind.runsOutSoon,
            date: runsOut,
          ),
        );
      }
    }
    alerts.sort((a, b) => a.kind.index.compareTo(b.kind.index));
    return alerts;
  }
}
