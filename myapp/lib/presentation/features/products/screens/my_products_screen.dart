import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:saaf/core/l10n/app_localizations.dart';
import 'package:saaf/core/router/saaf_route.dart';
import 'package:saaf/core/theme/saaf_tokens_extension.dart';
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

class _MyProductsScreenState extends ConsumerState<MyProductsScreen> {
  final TextEditingController _name = TextEditingController();
  bool _full = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    final text = _name.text;
    if (text.trim().isEmpty) return;
    final now = await ref.read(currentProductsProvider.future);
    final added = await ref.read(currentProductsProvider.notifier).add(text);
    if (!mounted) return;
    setState(() => _full = !added && now.length >= CurrentProducts.max);
    if (added) _name.clear();
  }

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
                  for (final name in products)
                    Padding(
                      padding: EdgeInsetsDirectional.only(start: space.x16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(name, style: tokens.styles.listTitle),
                          ),
                          IconButton(
                            tooltip: l10n.myProductsRemove(name),
                            icon: const Icon(Icons.close),
                            onPressed: () => ref
                                .read(currentProductsProvider.notifier)
                                .remove(name),
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
