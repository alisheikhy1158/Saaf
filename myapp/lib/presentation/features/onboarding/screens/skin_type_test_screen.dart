import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:saaf/core/l10n/app_localizations.dart';
import 'package:saaf/core/router/saaf_route.dart';
import 'package:saaf/core/theme/saaf_tokens_extension.dart';
import 'package:saaf/domain/entities/skin_type.dart';
import 'package:saaf/domain/usecases/classify_tissue_test.dart';
import 'package:saaf/presentation/widgets/common/saaf_button.dart';
import 'package:saaf/presentation/widgets/common/saaf_chip.dart';
import 'package:saaf/presentation/widgets/common/saaf_option_tile.dart';
import 'package:saaf/presentation/widgets/common/saaf_scaffold.dart';
import 'package:saaf/presentation/widgets/common/saaf_top_bar.dart';

/// The tissue (blotting) test for the skin type, opened from the "skin type"
/// quiz step. First the four steps, then what the tissue showed; "Use this
/// result" closes the screen and hands the [SkinType] back to the quiz.
class SkinTypeTestScreen extends StatefulWidget {
  const SkinTypeTestScreen({super.key});

  @override
  State<SkinTypeTestScreen> createState() => _SkinTypeTestScreenState();
}

class _SkinTypeTestScreenState extends State<SkinTypeTestScreen> {
  bool _questions = false;
  bool _forehead = false;
  bool _nose = false;
  bool _cheeks = false;
  bool _tight = false;

  SkinType get _result => classifyTissueTest(
    foreheadOil: _forehead,
    noseOil: _nose,
    cheeksOil: _cheeks,
    feelsTight: _tight,
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.saaf;
    final space = tokens.space;
    final result = _result;
    final readable = _questions && result != SkinType.notSure;

    return SaafScaffold(
      key: ValueKey('screen-${SaafRoute.skinTypeTest.name}'),
      topBar: SaafTopBar(
        title: l10n.tissueTitle,
        leading: SaafTopBar.backButton(
          tooltip: l10n.back,
          onBack: () => context.canPop()
              ? context.pop()
              : context.go(SaafRoute.skinQuiz.path),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: space.x16,
        children: _questions
            ? _questionChildren(context, l10n, result)
            : _stepChildren(context, l10n),
      ),
      bottom: _questions
          ? (readable
                ? SaafButton.primary(
                    key: const ValueKey('tissue-use'),
                    label: l10n.tissueUse,
                    onPressed: () => context.pop(result),
                  )
                : null)
          : SaafButton.primary(
              key: const ValueKey('tissue-done'),
              label: l10n.tissueDone,
              onPressed: () => setState(() => _questions = true),
            ),
    );
  }

  List<Widget> _stepChildren(BuildContext context, AppLocalizations l10n) {
    final tokens = context.saaf;
    final steps = [
      l10n.tissueStep1,
      l10n.tissueStep2,
      l10n.tissueStep3,
      l10n.tissueStep4,
    ];
    return [
      Text(
        l10n.tissueIntro,
        style: context.text.bodyMedium?.copyWith(color: tokens.textSecondary),
      ),
      for (final (i, step) in steps.indexed)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: tokens.space.rowGap,
          children: [
            SaafChip(label: '${i + 1}', tone: SaafChipTone.sageTint),
            Expanded(child: Text(step, style: context.text.bodyLarge)),
          ],
        ),
    ];
  }

  List<Widget> _questionChildren(
    BuildContext context,
    AppLocalizations l10n,
    SkinType result,
  ) {
    final tokens = context.saaf;

    Widget option(IconData icon, String title, bool on, VoidCallback toggle) =>
        SaafOptionTile(
          icon: icon,
          title: title,
          caption: l10n.tissueOptionCaption,
          selected: on,
          onTap: () => setState(toggle),
        );

    final (String title, String body) = switch (result) {
      SkinType.oily => (_named(l10n, result), l10n.tissueResultOily),
      SkinType.combination => (
        _named(l10n, result),
        l10n.tissueResultCombination,
      ),
      SkinType.normal => (_named(l10n, result), l10n.tissueResultNormal),
      SkinType.dry => (_named(l10n, result), l10n.tissueResultDry),
      SkinType.notSure => (l10n.tissueUnclearTitle, l10n.tissueResultUnclear),
    };

    return [
      Semantics(
        header: true,
        child: Text(l10n.tissueQuestionTitle, style: context.text.titleLarge),
      ),
      Text(
        l10n.tissueQuestionHint,
        style: context.text.bodyMedium?.copyWith(color: tokens.textSecondary),
      ),
      option(
        Icons.face_retouching_natural,
        l10n.tissueForehead,
        _forehead,
        () => _forehead = !_forehead,
      ),
      option(Icons.face, l10n.tissueNose, _nose, () => _nose = !_nose),
      option(
        Icons.face_3,
        l10n.tissueCheeks,
        _cheeks,
        () => _cheeks = !_cheeks,
      ),
      option(Icons.air, l10n.tissueTight, _tight, () => _tight = !_tight),
      Semantics(
        liveRegion: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: tokens.space.x6,
          children: [
            Text(title, style: context.text.titleMedium),
            Text(body, style: context.text.bodyMedium),
          ],
        ),
      ),
      Text(
        l10n.tissueCaveat,
        style: tokens.styles.legal.copyWith(color: tokens.textMeta),
      ),
    ];
  }

  /// "Your skin looks combination" (the type name in lower case).
  static String _named(AppLocalizations l10n, SkinType type) {
    final name = switch (type) {
      SkinType.oily => l10n.skinTypeOilyTitle,
      SkinType.dry => l10n.skinTypeDryTitle,
      SkinType.combination => l10n.skinTypeCombinationTitle,
      SkinType.normal => l10n.skinTypeNormalTitle,
      SkinType.notSure => l10n.skinTypeNotSureTitle,
    };
    return l10n.tissueResultTitle(name.toLowerCase());
  }
}
