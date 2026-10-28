import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saaf/presentation/providers/skin_profile_providers.dart';
import 'package:saaf/presentation/providers/consent_providers.dart';
import 'package:saaf/presentation/providers/life_providers.dart';
import 'package:saaf/domain/entities/owned_product.dart';
import 'package:intl/intl.dart' show DateFormat, NumberFormat;
import 'package:go_router/go_router.dart';
import 'package:saaf/core/l10n/app_localizations.dart';
import 'package:saaf/core/router/saaf_route.dart';
import 'package:saaf/core/theme/saaf_tokens_extension.dart';
import 'package:saaf/domain/entities/product.dart';
import 'package:saaf/presentation/providers/ai_routine_providers.dart';
import 'package:saaf/presentation/widgets/common/saaf_button.dart';
import 'package:saaf/presentation/widgets/common/saaf_scaffold.dart';
import 'package:saaf/presentation/widgets/common/saaf_text_field.dart';
import 'package:saaf/presentation/widgets/common/saaf_top_bar.dart';

/// The skin care products the user uses now, so Saaf AI can say which to keep
/// and which to change. Asked once right after the skin quiz ([setup]: then
/// Continue or Skip goes on to the face scan) and editable from Profile. The
/// names stay on the phone unless Saaf AI is turned on.
class MyProductsScreen extends ConsumerStatefulWidget {
  const MyProductsScreen({super.key, this.setup = false});

  final bool setup;

  @override
  ConsumerState<MyProductsScreen> createState() => _MyProductsScreenState();
}

/// The kinds a product can be: the four routine steps, or something else.
enum _Kind {
  cleanser(ProductCategory.cleanser),
  treatment(ProductCategory.treatment),
  moisturiser(ProductCategory.moisturiser),
  sunscreen(ProductCategory.sunscreen),
  other(null);

  const _Kind(this.step);
  final ProductCategory? step;

  static _Kind of(ProductCategory? step) =>
      values.firstWhere((k) => k.step == step);
}

class _MyProductsScreenState extends ConsumerState<MyProductsScreen> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _price = TextEditingController();
  bool _full = false;
  _Kind? _kind;
  bool _needsKind = false;

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    final text = _name.text;
    if (text.trim().isEmpty) return;
    final kind = _kind;
    if (kind == null) {
      setState(() => _needsKind = true);
      return;
    }
    final now = await ref.read(currentProductsProvider.future);
    final added = await ref
        .read(currentProductsProvider.notifier)
        .add(text, kind.step, pricePkr: _rupees(_price.text));
    if (!mounted) return;
    setState(() {
      _full = !added && now.length >= CurrentProducts.max;
      _needsKind = false;
      if (added) _kind = null;
    });
    if (added) {
      _name.clear();
      _price.clear();
    }
  }

  /// "Rs 1,200".
  String _rs(AppLocalizations l10n, int amount) => l10n.priceRs(
    NumberFormat.decimalPattern(
      Localizations.localeOf(context).toString(),
    ).format(amount),
  );

  /// What they spend a month on their products, against their budget.
  String? _spendLine(AppLocalizations l10n, List<OwnedProduct> products) {
    final spent = products.fold(0, (sum, p) => sum + (p.pricePkr ?? 0));
    if (spent == 0) return null;
    final limit = ref
        .watch(skinProfileControllerProvider)
        .budget
        ?.maxMonthlyPkr;
    if (limit == null) return l10n.myProductsSpend(_rs(l10n, spent));
    if (spent > limit) {
      return l10n.myProductsSpendOver(_rs(l10n, spent), _rs(l10n, limit));
    }
    return l10n.myProductsSpendLeft(
      _rs(l10n, spent),
      _rs(l10n, limit - spent),
      _rs(l10n, limit),
    );
  }

  /// "Moisturiser · Use by 18 Oct 2027 · runs out around 13 Dec".
  String _caption(AppLocalizations l10n, OwnedProduct product) {
    final locale = Localizations.localeOf(context).toString();
    return [
      _kindLabel(l10n, _Kind.of(product.step)),
      if (product.pricePkr case final price?) _rs(l10n, price),
      if (product.useBy case final d?)
        l10n.shelfUseBy(DateFormat('d MMM y', locale).format(d)),
      if (product.runsOutAround case final d?)
        l10n.shelfRunsOut(DateFormat('d MMM', locale).format(d)),
    ].join(' · ');
  }

  Future<void> _openShelf(OwnedProduct product) async {
    final result = await showModalBottomSheet<_ShelfResult>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _ShelfSheet(product: product),
    );
    if (!mounted || result == null) return;
    if (result.introduce) {
      await ref
          .read(introductionControllerProvider.notifier)
          .start(product.name);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).introStarted(product.name),
          ),
        ),
      );
      return;
    }
    if (result.findCheaper) {
      await context.push(
        Uri(
          path: SaafRoute.productAi.path,
          queryParameters: {'dupe': product.name},
        ).toString(),
      );
      return;
    }
    await ref
        .read(currentProductsProvider.notifier)
        .updateShelf(
          product.name,
          pricePkr: result.pricePkr,
          openedOn: result.openedOn,
          paoMonths: result.paoMonths,
          lastsWeeks: result.lastsWeeks,
        );
  }

  String _kindLabel(AppLocalizations l10n, _Kind kind) => switch (kind) {
    _Kind.cleanser => l10n.stepCleanser,
    _Kind.treatment => l10n.stepTreatment,
    _Kind.moisturiser => l10n.stepMoisturiser,
    _Kind.sunscreen => l10n.stepSunscreen,
    _Kind.other => l10n.myProductsStepOther,
  };

  void _next() => context.go(SaafRoute.chooseCity.path);

  void _leave() => widget.setup
      ? context.go(SaafRoute.skinQuiz.path)
      : context.canPop()
      ? context.pop()
      : context.go(SaafRoute.profile.path);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.saaf;
    final space = tokens.space;
    final products = ref.watch(currentProductsProvider).value ?? const [];

    return SaafScaffold(
      key: ValueKey('screen-${SaafRoute.myProducts.name}'),
      topBar: SaafTopBar(
        leading: SaafTopBar.backButton(tooltip: l10n.back, onBack: _leave),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: space.x16,
        children: [
          Semantics(
            header: true,
            child: Text(l10n.myProductsTitle, style: tokens.styles.screenTitle),
          ),
          Text(
            l10n.myProductsBody,
            style: context.text.bodyMedium?.copyWith(
              color: tokens.textSecondary,
            ),
          ),
          SaafTextField(
            key: const ValueKey('product-name'),
            label: l10n.myProductsFieldLabel,
            controller: _name,
            hintText: l10n.myProductsFieldHint,
            textInputAction: TextInputAction.done,
            errorText: _full ? l10n.myProductsFull : null,
          ),
          SaafTextField(
            key: const ValueKey('product-price'),
            label: l10n.myProductsPriceLabel,
            controller: _price,
            hintText: l10n.myProductsPriceHint,
            prefixText: l10n.myProductsPricePrefix,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            textInputAction: TextInputAction.done,
          ),
          Semantics(
            header: true,
            child: Text(
              l10n.myProductsStepLabel,
              style: context.text.titleSmall,
            ),
          ),
          Wrap(
            spacing: space.x8,
            runSpacing: space.x8,
            children: [
              for (final kind in _Kind.values)
                ChoiceChip(
                  label: Text(_kindLabel(l10n, kind)),
                  selected: _kind == kind,
                  onSelected: (_) => setState(() {
                    _kind = kind;
                    _needsKind = false;
                  }),
                ),
            ],
          ),
          if (_needsKind)
            Text(
              l10n.myProductsChooseStep,
              style: context.text.bodySmall?.copyWith(
                color: context.colors.error,
              ),
            ),
          SaafButton.outline(
            label: l10n.myProductsAdd,
            leadingIcon: Icons.add,
            onPressed: _add,
          ),
          if (products.isEmpty)
            Text(
              l10n.myProductsEmpty,
              style: context.text.bodyMedium?.copyWith(color: tokens.textMeta),
            )
          else
            DecoratedBox(
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(tokens.radius.r18),
                border: Border.all(
                  color: tokens.borderCard,
                  width: tokens.size.borderThin,
                ),
              ),
              child: Column(
                children: [
                  for (final product in products)
                    Padding(
                      padding: EdgeInsetsDirectional.only(start: space.x16),
                      child: Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => _openShelf(product),
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minHeight: tokens.size.minTouchTarget,
                                ),
                                child: MergeSemantics(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        product.name,
                                        style: tokens.styles.listTitle,
                                      ),
                                      Text(
                                        _caption(l10n, product),
                                        style: context.text.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: l10n.myProductsRemove(product.name),
                            icon: const Icon(Icons.close),
                            onPressed: () => ref
                                .read(currentProductsProvider.notifier)
                                .remove(product.name),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          if (_spendLine(l10n, products) case final line?)
            Text(line, style: context.text.bodyMedium),
          Text(
            l10n.myProductsPrivacy,
            style: tokens.styles.legal.copyWith(color: tokens.textMeta),
          ),
        ],
      ),
      bottom: widget.setup
          ? Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: space.x8,
              children: [
                SaafButton.primary(label: l10n.scanContinue, onPressed: _next),
                SaafButton.text(label: l10n.quizSkip, onPressed: _next),
              ],
            )
          : SaafButton.primary(label: l10n.commonDone, onPressed: _leave),
    );
  }
}

/// A whole number of rupees from what was typed, or null (none, or 0).
int? _rupees(String text) {
  final value = int.tryParse(text.trim());
  return value == null || value <= 0 ? null : value;
}

class _ShelfResult {
  const _ShelfResult({
    this.pricePkr,
    this.openedOn,
    this.paoMonths,
    this.lastsWeeks,
    this.findCheaper = false,
    this.introduce = false,
  });

  final int? pricePkr;
  final DateTime? openedOn;
  final int? paoMonths;
  final int? lastsWeeks;
  final bool findCheaper;
  final bool introduce;
}

/// One product's shelf details: when it was opened, how long it keeps once
/// open, how long it lasts; and a way to find a cheaper alternative.
class _ShelfSheet extends ConsumerStatefulWidget {
  const _ShelfSheet({required this.product});

  final OwnedProduct product;

  @override
  ConsumerState<_ShelfSheet> createState() => _ShelfSheetState();
}

class _ShelfSheetState extends ConsumerState<_ShelfSheet> {
  static const _months = [3, 6, 12, 24];
  static const _weeks = [4, 8, 12];

  late final TextEditingController _price = TextEditingController(
    text: widget.product.pricePkr?.toString() ?? '',
  );
  late DateTime? _opened = widget.product.openedOn;

  @override
  void dispose() {
    _price.dispose();
    super.dispose();
  }

  late int? _pao = widget.product.paoMonths;
  late int? _lasts = widget.product.lastsWeeks;

  Future<void> _pickDate() async {
    final today = ref.read(clockProvider).now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _opened ?? today,
      firstDate: DateTime(today.year - 3),
      lastDate: today,
    );
    if (picked != null) setState(() => _opened = picked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.saaf;
    final space = tokens.space;
    final locale = Localizations.localeOf(context).toString();

    Widget heading(String text) => Semantics(
      header: true,
      child: Text(text, style: context.text.titleSmall),
    );

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsetsDirectional.all(space.x16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: space.x12,
          children: [
            Semantics(
              header: true,
              child: Text(widget.product.name, style: context.text.titleMedium),
            ),
            SaafTextField(
              key: const ValueKey('shelf-price'),
              label: l10n.myProductsPriceLabel,
              controller: _price,
              hintText: l10n.myProductsPriceHint,
              prefixText: l10n.myProductsPricePrefix,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              textInputAction: TextInputAction.done,
            ),
            heading(l10n.shelfOpenedQuestion),
            Text(
              _opened == null
                  ? l10n.shelfNotSet
                  : l10n.shelfOpenedOn(
                      DateFormat('d MMM y', locale).format(_opened!),
                    ),
              style: context.text.bodyMedium,
            ),
            Wrap(
              spacing: space.x8,
              runSpacing: space.x8,
              children: [
                SaafButton.outline(
                  label: l10n.shelfOpenedToday,
                  onPressed: () =>
                      setState(() => _opened = ref.read(clockProvider).now()),
                ),
                SaafButton.text(
                  label: l10n.shelfChooseDate,
                  onPressed: _pickDate,
                ),
              ],
            ),
            heading(l10n.shelfKeepsQuestion),
            Text(l10n.shelfKeepsHint, style: context.text.bodySmall),
            Wrap(
              spacing: space.x8,
              runSpacing: space.x8,
              children: [
                for (final months in _months)
                  ChoiceChip(
                    label: Text(l10n.shelfMonths(months)),
                    selected: _pao == months,
                    onSelected: (on) =>
                        setState(() => _pao = on ? months : null),
                  ),
              ],
            ),
            heading(l10n.shelfLastsQuestion),
            Wrap(
              spacing: space.x8,
              runSpacing: space.x8,
              children: [
                for (final weeks in _weeks)
                  ChoiceChip(
                    label: Text(l10n.shelfWeeks(weeks)),
                    selected: _lasts == weeks,
                    onSelected: (on) =>
                        setState(() => _lasts = on ? weeks : null),
                  ),
              ],
            ),
            SaafButton.primary(
              label: l10n.shelfSave,
              onPressed: () => Navigator.of(context).pop(
                _ShelfResult(
                  pricePkr: _rupees(_price.text),
                  openedOn: _opened,
                  paoMonths: _pao,
                  lastsWeeks: _lasts,
                ),
              ),
            ),
            if (ref.watch(lifeEventControllerProvider).value case final event?
                when event.tooCloseForNewProduct(ref.read(clockProvider).now()))
              Text(
                l10n.introTooClose(event.name),
                style: context.text.bodySmall?.copyWith(
                  color: context.colors.error,
                ),
              ),
            SaafButton.outline(
              label: l10n.introStart,
              leadingIcon: Icons.science_outlined,
              onPressed: () => Navigator.of(
                context,
              ).pop(const _ShelfResult(introduce: true)),
            ),
            SaafButton.text(
              label: l10n.shelfFindCheaper,
              leadingIcon: Icons.savings_outlined,
              onPressed: () => Navigator.of(
                context,
              ).pop(const _ShelfResult(findCheaper: true)),
            ),
          ],
        ),
      ),
    );
  }
}
