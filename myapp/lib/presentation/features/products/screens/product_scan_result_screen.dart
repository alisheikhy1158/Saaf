import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' show DateFormat, NumberFormat;
import 'package:saaf/core/l10n/app_localizations.dart';
import 'package:saaf/core/router/saaf_route.dart';
import 'package:saaf/core/theme/saaf_tokens_extension.dart';
import 'package:saaf/core/utils/week.dart';
import 'package:saaf/domain/entities/ingredient_clash.dart';
import 'package:saaf/domain/entities/product.dart';
import 'package:saaf/domain/entities/scanned_product.dart';
import 'package:saaf/domain/entities/skin_concern.dart';
import 'package:saaf/domain/entities/skin_type.dart';
import 'package:saaf/domain/usecases/assess_product.dart';
import 'package:saaf/domain/usecases/find_ingredient_clashes.dart';
import 'package:saaf/presentation/providers/analysis_providers.dart';
import 'package:saaf/presentation/providers/consent_providers.dart';
import 'package:saaf/presentation/providers/product_providers.dart';
import 'package:saaf/presentation/providers/routine_providers.dart';
import 'package:saaf/presentation/providers/skin_profile_providers.dart';
import 'package:saaf/presentation/widgets/common/saaf_card.dart';
import 'package:saaf/presentation/widgets/common/saaf_chip.dart';
import 'package:saaf/presentation/widgets/common/saaf_disclaimer.dart';
import 'package:saaf/presentation/widgets/common/saaf_icon_button.dart';
import 'package:saaf/presentation/widgets/common/saaf_overline.dart';
import 'package:saaf/presentation/widgets/common/saaf_product_thumbnail.dart';
import 'package:saaf/presentation/widgets/common/saaf_scaffold.dart';
import 'package:saaf/presentation/widgets/common/saaf_status_message.dart';
import 'package:saaf/presentation/widgets/common/saaf_top_bar.dart';

/// Figma 10 Product scan result: the product behind a barcode, whether it suits
/// the user, ingredient clashes with their routine and where to buy it (Buy
/// opens the store in the browser). Also the empty, not-found, loading and
/// error states.
class ProductScanResultScreen extends ConsumerWidget {
  const ProductScanResultScreen({super.key, this.barcode});

  /// From the address (`?barcode=…`); null when opened without one.
  final String? barcode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.saaf;
    final code = barcode?.trim();
    final hasCode = code != null && code.isNotEmpty;
    final async = hasCode ? ref.watch(scannedProductProvider(code)) : null;
    final product = async?.value;

    void leave() =>
        context.canPop() ? context.pop() : context.go(SaafRoute.home.path);

    final Widget body;
    if (!hasCode) {
      body = SaafStatusMessage(
        icon: Icons.qr_code_scanner,
        title: l10n.productNoneTitle,
        body: l10n.productNoneBody,
        actionLabel: l10n.productNoneAction,
        onAction: () => context.go(SaafRoute.home.path),
      );
    } else if (async!.hasError && !async.hasValue) {
      body = SaafStatusMessage(
        icon: Icons.error_outline,
        title: l10n.productErrorTitle,
        actionLabel: l10n.productErrorAction,
        onAction: () => ref.invalidate(scannedProductProvider(code)),
      );
    } else if (async.isLoading && !async.hasValue) {
      body = Padding(
        padding: EdgeInsetsDirectional.only(top: tokens.space.x36),
        child: const Center(child: CircularProgressIndicator()),
      );
    } else if (product == null) {
      body = SaafStatusMessage(
        icon: Icons.search_off,
        title: l10n.productNotFoundTitle,
        body: l10n.productNotFoundBody,
        actionLabel: l10n.productNoneAction,
        onAction: () => context.go(SaafRoute.home.path),
      );
    } else {
      body = _Result(product: product);
    }

    return SaafScaffold(
      key: ValueKey('screen-${SaafRoute.productScanResult.name}'),
      // Papaya in the light theme (Figma 10); the dark theme keeps its ink.
      backgroundColor: Theme.of(context).brightness == Brightness.light
          ? tokens.papaya
          : null,
      topBar: SaafTopBar(
        title: l10n.productScanTitle,
        leading: SaafTopBar.backButton(tooltip: l10n.back, onBack: leave),
        trailing: product == null
            ? null
            : SaafIconButton(
                icon: Icons.ios_share,
                tooltip: l10n.productShare,
                onPressed: () => _share(context, ref, product),
              ),
      ),
      body: body,
    );
  }

  Future<void> _share(
    BuildContext context,
    WidgetRef ref,
    ScannedProduct product,
  ) async {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final lowest = product.lowestPricePkr;
    final text = lowest == null
        ? '${product.brand} ${product.name}'
        : l10n.productShareText(
            product.brand,
            product.name,
            l10n.priceRs(NumberFormat.decimalPattern(locale).format(lowest)),
          );
    await ref.read(shareServiceProvider).shareText(text);
  }
}

class _Result extends ConsumerWidget {
  const _Result({required this.product});

  final ScannedProduct product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.saaf;
    final space = tokens.space;
    final locale = Localizations.localeOf(context).toString();
    final profile = ref.watch(skinProfileControllerProvider);
    final routine = ref.watch(routineProvider).value;
    final today = ref.watch(clockProvider).now();

    final fit = const AssessProduct()(product.product, profile);
    final clashes = routine == null
        ? const <IngredientClash>[]
        : const FindIngredientClashes()(product.product, routine);

    final (fitLabel, fitIcon, fitTone) = switch (fit) {
      ProductFit.good => (l10n.productFitGood, Icons.check, SaafChipTone.sage),
      ProductFit.careful => (
        l10n.productFitCareful,
        Icons.warning_amber_outlined,
        SaafChipTone.strong,
      ),
      ProductFit.avoid => (
        l10n.productFitAvoid,
        Icons.block,
        SaafChipTone.strong,
      ),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Photo(),
        SizedBox(height: space.x16),
        SaafOverline(product.brand),
        SizedBox(height: space.x4),
        Semantics(
          header: true,
          child: Text(
            product.name,
            // Product names are English catalogue data.
            textDirection: TextDirection.ltr,
            style: tokens.styles.productTitle,
          ),
        ),
        SizedBox(height: space.x12),
        Wrap(
          spacing: space.x8,
          runSpacing: space.x8,
          children: [
            SaafChip(label: fitLabel, icon: fitIcon, tone: fitTone),
            SaafChip(
              label: _skinTypes(l10n, product.product),
              tone: SaafChipTone.outline,
            ),
          ],
        ),
        if (fit != ProductFit.good) ...[
          SizedBox(height: space.x14),
          _AdviceCard(
            title: fit == ProductFit.avoid
                ? l10n.productAvoidTitle
                : l10n.productCarefulTitle,
            body: fit == ProductFit.avoid
                ? l10n.productAvoidBody
                : l10n.productCarefulBody,
          ),
        ],
        for (final clash in clashes) ...[
          SizedBox(height: space.x14),
          _AdviceCard(
            title: _clashTitle(l10n, clash),
            body: _clashBody(l10n, clash),
          ),
        ],
        SizedBox(height: space.x18),
        Row(
          children: [
            Expanded(
              child: Semantics(
                header: true,
                child: Text(
                  l10n.productWhereToBuy,
                  style: context.text.titleSmall?.copyWith(
                    color: context.colors.onSurface,
                  ),
                ),
              ),
            ),
            Text(
              sameDay(product.pricesAsOf, today)
                  ? l10n.productPricesToday
                  : l10n.productPricesAsOf(
                      DateFormat('d MMM', locale).format(product.pricesAsOf),
                    ),
              style: tokens.styles.legal.copyWith(color: tokens.textMeta),
            ),
          ],
        ),
        SizedBox(height: space.x8),
        SaafCard(
          padding: EdgeInsetsDirectional.symmetric(
            horizontal: space.groupPaddingH,
            vertical: space.checklistPaddingV,
          ),
          child: Column(
            children: [
              for (final (i, offer) in product.offers.indexed)
                _OfferRow(offer: offer, isLast: i == product.offers.length - 1),
            ],
          ),
        ),
        SizedBox(height: space.x16),
        if (product.hasAffiliateLinks) ...[
          SaafDisclaimer(l10n.productAffiliate),
          SizedBox(height: space.x8),
        ],
        SaafDisclaimer(l10n.productDisclaimer),
      ],
    );
  }

  /// "Oily · Acne-prone".
  static String _skinTypes(AppLocalizations l10n, Product product) {
    final parts = [
      for (final type in product.skinTypes)
        switch (type) {
          SkinType.oily => l10n.skinTypeOilyTitle,
          SkinType.dry => l10n.skinTypeDryTitle,
          SkinType.combination => l10n.skinTypeCombinationTitle,
          SkinType.normal => l10n.skinTypeNormalTitle,
          SkinType.notSure => l10n.skinTypeNotSureTitle,
        },
      if (product.targets.contains(SkinConcern.acne)) l10n.productAcneProne,
    ];
    return parts.isEmpty ? l10n.productAllSkin : parts.join(' · ');
  }

  static String _clashTitle(AppLocalizations l10n, IngredientClash clash) =>
      switch (clash.rule) {
        ClashRule.niacinamideAndVitaminC => l10n.clashNiacinamideVitaminCTitle,
        ClashRule.retinolAndExfoliants => l10n.clashRetinolExfoliantsTitle,
        ClashRule.benzoylPeroxideAndRetinol => l10n.clashBenzoylRetinolTitle,
      };

  static String _clashBody(AppLocalizations l10n, IngredientClash clash) =>
      switch (clash.rule) {
        ClashRule.niacinamideAndVitaminC =>
          !clash.canMoveToOtherTime
              ? l10n.clashDifferentDays
              : clash.time == RoutineTime.morning
              ? l10n.clashMoveToNight
              : l10n.clashMoveToMorning,
        ClashRule.retinolAndExfoliants => l10n.clashRetinolExfoliants,
        ClashRule.benzoylPeroxideAndRetinol => l10n.clashBenzoylRetinol,
      };
}

/// The picture area: a big placeholder bottle and the "Barcode matched" chip.
class _Photo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.saaf;
    return SizedBox(
      height: tokens.size.productPhoto,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: tokens.papayaTint,
          borderRadius: BorderRadius.circular(tokens.radius.r24),
        ),
        child: Stack(
          children: [
            Align(
              alignment: AlignmentDirectional.topCenter,
              child: Padding(
                padding: EdgeInsetsDirectional.only(top: tokens.space.x18),
                child: SaafProductThumbnail(size: tokens.size.productImage),
              ),
            ),
            PositionedDirectional(
              top: tokens.space.x14,
              start: tokens.space.x14,
              child: SaafChip(
                label: l10n.productBarcodeMatched,
                icon: Icons.check,
                tone: SaafChipTone.cornsilk,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A warning with an icon, a title and a sentence (ingredient clash, fit).
class _AdviceCard extends StatelessWidget {
  const _AdviceCard({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final tokens = context.saaf;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: tokens.sageTint,
        borderRadius: BorderRadius.circular(tokens.radius.r18),
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.all(tokens.space.optionPadding),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: tokens.space.rowGap,
          children: [
            ExcludeSemantics(
              child: Icon(
                Icons.warning_amber_outlined,
                size: tokens.size.icon,
                color: tokens.textSecondary,
              ),
            ),
            Expanded(
              child: MergeSemantics(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: tokens.space.x2,
                  children: [
                    Text(title, style: tokens.styles.segment),
                    Text(body, style: tokens.styles.pointCaption),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OfferRow extends ConsumerWidget {
  const _OfferRow({required this.offer, required this.isLast});

  final ProductOffer offer;
  final bool isLast;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.saaf;
    final locale = Localizations.localeOf(context).toString();
    final price = l10n.priceRs(
      NumberFormat.decimalPattern(locale).format(offer.pricePkr),
    );

    Future<void> open() async {
      final result = await ref
          .read(externalLinkServiceProvider)
          .open(offer.url);
      if (result.isOk || !context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.productLinkFailed)));
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: tokens.rowDivider,
                  width: tokens.size.borderThin,
                ),
              ),
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.symmetric(
          vertical: tokens.space.rowPaddingV,
        ),
        child: Row(
          spacing: tokens.space.rowGap,
          children: [
            Expanded(
              flex: 3,
              child: MergeSemantics(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: tokens.space.x2,
                  children: [
                    Text(offer.store, style: tokens.styles.listTitle),
                    Text(
                      offer.note,
                      style: offer.isLowest
                          ? context.text.bodySmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: context.colors.onSurface,
                            )
                          : context.text.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            // Shrinks a little at very large text sizes instead of overflowing.
            Flexible(
              flex: 2,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.centerEnd,
                child: Text(price, style: tokens.styles.listTitle),
              ),
            ),
            Semantics(
              button: true,
              label: l10n.productBuySemantics(offer.store, price),
              excludeSemantics: true,
              onTap: open,
              child: InkWell(
                onTap: open,
                borderRadius: BorderRadius.circular(tokens.radius.r18),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: tokens.size.minTouchTarget,
                    minWidth: tokens.size.minTouchTarget,
                  ),
                  child: Center(
                    widthFactor: 1,
                    child: SaafChip(
                      label: l10n.productBuy,
                      tone: SaafChipTone.ink,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
