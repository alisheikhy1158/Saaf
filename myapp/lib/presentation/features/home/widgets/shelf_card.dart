import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:saaf/core/l10n/app_localizations.dart';
import 'package:saaf/core/router/saaf_route.dart';
import 'package:saaf/core/theme/saaf_tokens_extension.dart';
import 'package:saaf/domain/usecases/shelf_alerts.dart';
import 'package:saaf/presentation/providers/ai_routine_providers.dart';
import 'package:saaf/presentation/providers/consent_providers.dart';
import 'package:saaf/presentation/widgets/common/saaf_button.dart';
import 'package:saaf/presentation/widgets/common/saaf_message_row.dart';

/// Home: products that are running out or past their use-by date (from the
/// shelf, worked out on the phone). Nothing when there is nothing to say.
class ShelfCard extends ConsumerWidget {
  const ShelfCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.saaf;
    final locale = Localizations.localeOf(context).toString();
    final products = ref.watch(currentProductsProvider).value ?? const [];
    final alerts = const ShelfAlerts()(
      products,
      ref.watch(clockProvider).now(),
    );
    if (alerts.isEmpty) return const SizedBox.shrink();

    String text(ShelfAlert a) {
      final day = a.date == null
          ? ''
          : DateFormat('d MMM', locale).format(a.date!);
      return switch (a.kind) {
        ShelfAlertKind.expired => l10n.shelfAlertExpired(a.product.name),
        ShelfAlertKind.expiresSoon => l10n.shelfAlertExpiresSoon(
          a.product.name,
          day,
        ),
        ShelfAlertKind.probablyFinished => l10n.shelfAlertFinished(
          a.product.name,
        ),
        ShelfAlertKind.runsOutSoon => l10n.shelfAlertRunsOut(
          a.product.name,
          day,
        ),
      };
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(tokens.radius.r20),
        border: Border.all(
          color: tokens.borderCard,
          width: tokens.size.borderThin,
        ),
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.all(tokens.space.x16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: tokens.space.x8,
          children: [
            Semantics(
              header: true,
              child: Text(l10n.shelfTitle, style: tokens.styles.listTitle),
            ),
            for (final alert in alerts)
              SaafMessageRow(
                icon:
                    alert.kind == ShelfAlertKind.expired ||
                        alert.kind == ShelfAlertKind.expiresSoon
                    ? Icons.event_busy_outlined
                    : Icons.hourglass_bottom,
                text: text(alert),
                color: context.colors.onSurface,
              ),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: SaafButton.text(
                label: l10n.shelfOpen,
                onPressed: () => context.push(SaafRoute.myProducts.path),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
