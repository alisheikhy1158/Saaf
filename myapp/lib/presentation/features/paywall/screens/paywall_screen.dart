import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:saaf/core/error/failure.dart';
import 'package:saaf/core/l10n/app_localizations.dart';
import 'package:saaf/core/router/saaf_route.dart';
import 'package:saaf/core/theme/saaf_tokens_extension.dart';
import 'package:saaf/domain/entities/subscription_plan.dart';
import 'package:saaf/presentation/providers/subscription_providers.dart';
import 'package:saaf/presentation/widgets/common/linked_sentence.dart';
import 'package:saaf/presentation/widgets/common/saaf_button.dart';
import 'package:saaf/presentation/widgets/common/saaf_chip.dart';
import 'package:saaf/presentation/widgets/common/saaf_icon_button.dart';
import 'package:saaf/presentation/widgets/common/saaf_icon_circle.dart';
import 'package:saaf/presentation/widgets/common/saaf_plan_tile.dart';
import 'package:saaf/presentation/widgets/common/saaf_scaffold.dart';
import 'package:saaf/presentation/widgets/common/saaf_status_message.dart';
import 'package:saaf/presentation/widgets/common/saaf_top_bar.dart';

/// Figma 13 Saaf Pro paywall. Prices and the free trial come from the store
/// (never typed in), the fine print says what happens after the trial and where
/// to cancel for this platform, and Restore, Terms and Privacy are one tap away
/// (store-compliance §4).
class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  /// The plan picked in the list (the yearly plan comes first).
  int _selected = 0;
  bool _busy = false;

  void _close() =>
      context.canPop() ? context.pop() : context.go(SaafRoute.home.path);

  void _say(String message) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message)));

  Future<void> _buy(SubscriptionPlan plan) async {
    final l10n = AppLocalizations.of(context);
    setState(() => _busy = true);
    final result = await ref.read(purchasePlanProvider)(plan);
    if (!mounted) return;
    setState(() => _busy = false);

    final failure = result.failureOrNull;
    if (failure == null) {
      _close();
    } else if (failure is! PurchaseCancelled) {
      // Cancelling the store sheet is a choice, not an error: say nothing.
      _say(l10n.paywallPurchaseFailed);
    }
  }

  Future<void> _restore() async {
    final l10n = AppLocalizations.of(context);
    final result = await ref.read(restorePurchasesProvider)();
    if (!mounted) return;
    final found = result.valueOrNull;
    if (found == null) {
      _say(l10n.paywallRestoreFailed);
    } else if (found) {
      _say(l10n.paywallRestored);
      _close();
    } else {
      _say(l10n.paywallNothingToRestore);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final plans = ref.watch(subscriptionPlansProvider);
    final isPro = ref.watch(proStatusProvider);
    final list = plans.value;

    final Widget body;
    Widget? bottom;
    if (isPro) {
      body = SaafStatusMessage(
        icon: Icons.auto_awesome,
        title: l10n.paywallAlreadyProTitle,
        body: l10n.paywallAlreadyProBody(_storeName(l10n)),
        actionLabel: l10n.paywallClose,
        onAction: _close,
      );
    } else if (plans.hasError && !plans.hasValue ||
        (list != null && list.isEmpty)) {
      body = SaafStatusMessage(
        icon: Icons.storefront_outlined,
        title: l10n.paywallUnavailableTitle,
        body: l10n.paywallUnavailableBody,
        actionLabel: l10n.paywallRetry,
        onAction: () => ref.invalidate(subscriptionPlansProvider),
      );
    } else if (list == null) {
      body = Padding(
        padding: EdgeInsetsDirectional.only(top: context.saaf.space.x36),
        child: const Center(child: CircularProgressIndicator()),
      );
    } else {
      final plan = list[_selected.clamp(0, list.length - 1)];
      body = _Offer(
        plans: list,
        selected: _selected,
        onSelect: (i) => setState(() => _selected = i),
      );
      bottom = _Purchase(
        plan: plan,
        busy: _busy,
        storeName: _storeName(l10n),
        onBuy: () => _buy(plan),
        onRestore: _restore,
      );
    }

    return SaafScaffold(
      key: ValueKey('screen-${SaafRoute.paywall.name}'),
      topBar: SaafTopBar(
        trailing: SaafIconButton(
          icon: Icons.close,
          tooltip: l10n.paywallClose,
          onPressed: _close,
        ),
      ),
      body: body,
      bottom: bottom,
    );
  }

  /// Where the user manages a subscription on this phone.
  String _storeName(AppLocalizations l10n) =>
      switch (Theme.of(context).platform) {
        TargetPlatform.iOS || TargetPlatform.macOS => l10n.paywallStoreApple,
        TargetPlatform.android => l10n.paywallStoreGoogle,
        _ => l10n.paywallStoreOther,
      };
}

class _Offer extends StatelessWidget {
  const _Offer({
    required this.plans,
    required this.selected,
    required this.onSelect,
  });

  final List<SubscriptionPlan> plans;
  final int selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.saaf;
    final space = tokens.space;

    final yearly = plans
        .where((p) => p.period == PlanPeriod.yearly)
        .firstOrNull;
    final monthly = plans
        .where((p) => p.period == PlanPeriod.monthly)
        .firstOrNull;
    final saving = yearly != null && monthly != null
        ? savePercent(yearly: yearly, monthly: monthly)
        : null;

    final benefits = [
      (Icons.photo_camera_outlined, l10n.paywallBenefitPhotos),
      (Icons.auto_awesome, l10n.paywallBenefitScans),
      (Icons.notifications_none, l10n.paywallBenefitAlerts),
      (Icons.trending_up, l10n.paywallBenefitCoach),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: SaafChip(label: l10n.paywallProChip, icon: Icons.auto_awesome),
        ),
        SizedBox(height: space.x14),
        Semantics(
          header: true,
          child: Text(l10n.paywallTitle, style: context.text.headlineLarge),
        ),
        SizedBox(height: space.sectionGapMedium),
        Column(
          spacing: space.benefitGap,
          children: [
            for (final (icon, text) in benefits)
              Row(
                spacing: space.benefitGap,
                children: [
                  SaafIconCircle(
                    icon: icon,
                    size: SaafIconCircleSize.small,
                    tone: SaafIconCircleTone.sageTint,
                  ),
                  Expanded(child: Text(text, style: tokens.styles.rowTitle)),
                ],
              ),
          ],
        ),
        SizedBox(height: space.sectionGapLarge),
        Column(
          spacing: space.optionGap,
          children: [
            for (final (i, plan) in plans.indexed)
              SaafPlanTile(
                title: plan.period == PlanPeriod.yearly
                    ? l10n.planYearly
                    : l10n.planMonthly,
                caption: plan.period == PlanPeriod.yearly
                    ? l10n.planPerMonthBilledYearly(
                        plan.pricePerMonthText ?? plan.priceText,
                      )
                    : l10n.planCancelAnytime,
                price: plan.priceText,
                badge: plan.period == PlanPeriod.yearly && saving != null
                    ? l10n.planSave(saving)
                    : null,
                selected: i == selected,
                onTap: () => onSelect(i),
                semanticLabel: l10n.planSemantics(
                  plan.period == PlanPeriod.yearly
                      ? l10n.planYearly
                      : l10n.planMonthly,
                  plan.priceText,
                  plan.period == PlanPeriod.yearly
                      ? l10n.planPerMonthBilledYearly(
                          plan.pricePerMonthText ?? plan.priceText,
                        )
                      : l10n.planCancelAnytime,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// The button, the fine print, Restore and the legal links.
class _Purchase extends StatelessWidget {
  const _Purchase({
    required this.plan,
    required this.busy,
    required this.storeName,
    required this.onBuy,
    required this.onRestore,
  });

  final SubscriptionPlan plan;
  final bool busy;
  final String storeName;
  final VoidCallback onBuy;
  final VoidCallback onRestore;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.saaf;
    final period = plan.period == PlanPeriod.yearly
        ? l10n.paywallPeriodYear
        : l10n.paywallPeriodMonth;
    final finePrint = plan.hasTrial
        ? l10n.paywallFinePrintTrial(
            plan.trialDays,
            plan.priceText,
            period,
            storeName,
          )
        : l10n.paywallFinePrint(plan.priceText, period, storeName);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SaafButton.primary(
          label: plan.hasTrial
              ? l10n.paywallStartTrial(plan.trialDays)
              : l10n.paywallSubscribe,
          isLoading: busy,
          onPressed: busy ? null : onBuy,
        ),
        SizedBox(height: tokens.space.x10),
        Text(
          finePrint,
          textAlign: TextAlign.center,
          style: tokens.styles.legal.copyWith(color: tokens.textMeta),
        ),
        // How payment works: the store's own sheet, never in Saaf.
        if (switch (Theme.of(context).platform) {
              TargetPlatform.iOS ||
              TargetPlatform.macOS => l10n.paywallPayApple,
              TargetPlatform.android => l10n.paywallPayGoogle,
              _ => null,
            }
            case final howToPay?)
          Text(
            howToPay,
            textAlign: TextAlign.center,
            style: tokens.styles.legal.copyWith(color: tokens.textMeta),
          ),
        SaafButton.text(
          label: l10n.paywallRestore,
          onPressed: busy ? null : onRestore,
        ),
        LinkedSentence(
          sentence: l10n.signUpLegal,
          style: tokens.styles.legal,
          textAlign: TextAlign.center,
          onOpenTerms: () => context.push(SaafRoute.terms.path),
          onOpenPrivacy: () => context.push(SaafRoute.privacyPolicy.path),
        ),
      ],
    );
  }
}
