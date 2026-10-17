import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  bool _full = false;
  _Kind? _kind;
  bool _needsKind = false;

  @override
  void dispose() {
    _name.dispose();
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
        .add(text, kind.step);
    if (!mounted) return;
    setState(() {
      _full = !added && now.length >= CurrentProducts.max;
      _needsKind = false;
      if (added) _kind = null;
    });
    if (added) _name.clear();
  }

  String _kindLabel(AppLocalizations l10n, _Kind kind) => switch (kind) {
    _Kind.cleanser => l10n.stepCleanser,
    _Kind.treatment => l10n.stepTreatment,
    _Kind.moisturiser => l10n.stepMoisturiser,
    _Kind.sunscreen => l10n.stepSunscreen,
    _Kind.other => l10n.myProductsStepOther,
  };

  void _next() => context.go(SaafRoute.selfieCapture.path);

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
                            child: MergeSemantics(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    style: tokens.styles.listTitle,
                                  ),
                                  Text(
                                    _kindLabel(l10n, _Kind.of(product.step)),
                                    style: context.text.bodySmall,
                                  ),
                                ],
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
