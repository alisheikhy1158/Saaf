import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:saaf/core/config/env.dart';
import 'package:saaf/core/error/failure.dart';
import 'package:saaf/core/error/failure_detail.dart';
import 'package:saaf/core/l10n/app_localizations.dart';
import 'package:saaf/core/router/saaf_route.dart';
import 'package:saaf/core/theme/saaf_tokens_extension.dart';
import 'package:saaf/domain/entities/ai_photo_source.dart';
import 'package:saaf/domain/entities/safety_check.dart';
import 'package:saaf/presentation/providers/ai_providers.dart';
import 'package:saaf/presentation/providers/cream_safety_controller.dart';
import 'package:saaf/core/utils/dermatologist_search.dart';
import 'package:saaf/presentation/providers/product_providers.dart';
import 'package:saaf/presentation/providers/weather_providers.dart';
import 'package:saaf/presentation/widgets/common/saaf_button.dart';
import 'package:saaf/presentation/widgets/common/saaf_chip.dart';
import 'package:saaf/presentation/widgets/common/saaf_icon_circle.dart';
import 'package:saaf/presentation/widgets/common/saaf_message_row.dart';
import 'package:saaf/presentation/widgets/common/saaf_scaffold.dart';
import 'package:saaf/presentation/widgets/common/saaf_text_field.dart';
import 'package:saaf/presentation/widgets/common/saaf_top_bar.dart';

/// "Is this cream safe?" Fairness and "formula" creams are often found to
/// contain mercury, hydroquinone or strong steroids. The user types the name
/// or photographs the label; Saaf AI reads it and searches for warnings, and
/// the phone's fixed ingredient rules add to it. Sent only on a tap, after
/// Saaf AI is turned on; the verdict never says "safe"; it can be reported.
class CreamSafetyScreen extends ConsumerStatefulWidget {
  const CreamSafetyScreen({super.key});

  @override
  ConsumerState<CreamSafetyScreen> createState() => _CreamSafetyScreenState();
}

enum _ReportReason { harmful, wrong, offensive, other }

class _CreamSafetyScreenState extends ConsumerState<CreamSafetyScreen> {
  final TextEditingController _name = TextEditingController();

  @override
  void initState() {
    super.initState();
    _name.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _leave() =>
      context.canPop() ? context.pop() : context.go(SaafRoute.home.path);

  Future<void> _check() async {
    final state = ref.read(creamSafetyControllerProvider);
    final photo = state.photo;
    final name = _name.text.trim();
    final query = photo != null
        ? CreamPhotoQuery(photo)
        : name.isNotEmpty
        ? CreamNameQuery(name)
        : null;
    if (query != null) {
      await ref.read(creamSafetyControllerProvider.notifier).check(query);
    }
  }

  Future<void> _report() async {
    final l10n = AppLocalizations.of(context);
    final reason = await showModalBottomSheet<_ReportReason>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsetsDirectional.all(context.saaf.space.x16),
              child: Semantics(
                header: true,
                child: Text(
                  l10n.aiReportTitle,
                  style: context.text.titleMedium,
                ),
              ),
            ),
            for (final (reason, label) in [
              (_ReportReason.harmful, l10n.aiReportHarmful),
              (_ReportReason.wrong, l10n.aiReportWrong),
              (_ReportReason.offensive, l10n.aiReportOffensive),
              (_ReportReason.other, l10n.aiReportOther),
            ])
              ListTile(
                title: Text(label),
                onTap: () => Navigator.of(context).pop(reason),
              ),
          ],
        ),
      ),
    );
    if (reason == null || !mounted) return;
    final sent = await ref
        .read(creamSafetyControllerProvider.notifier)
        .report(reason.name);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(sent ? l10n.aiReportThanks : l10n.aiReportFailed)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.saaf;
    final space = tokens.space;
    final consent = ref.watch(aiConsentStateProvider);
    final state = ref.watch(creamSafetyControllerProvider);
    final controller = ref.read(creamSafetyControllerProvider.notifier);

    final Widget body;
    if (consent == null) {
      body = const Center(child: CircularProgressIndicator());
    } else if (state.checking) {
      body = Padding(
        padding: EdgeInsetsDirectional.only(top: space.x36),
        child: Column(
          spacing: space.x16,
          children: [
            const CircularProgressIndicator(),
            Text(
              l10n.creamChecking,
              textAlign: TextAlign.center,
              style: context.text.bodyMedium,
            ),
          ],
        ),
      );
    } else if (state.check case final check? when check.found) {
      body = _Verdict(
        check: check,
        reported: state.reported,
        onReport: _report,
      );
    } else {
      final notFound = state.check != null;
      final canCheck = state.photo != null || _name.text.trim().isNotEmpty;
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: space.x16,
        children: [
          const Center(
            child: SaafIconCircle(
              icon: Icons.health_and_safety_outlined,
              size: SaafIconCircleSize.large,
            ),
          ),
          Semantics(
            header: true,
            child: Text(
              notFound ? l10n.productAiNotFoundTitle : l10n.creamTitle,
              textAlign: TextAlign.center,
              style: context.text.titleLarge,
            ),
          ),
          Text(
            notFound ? l10n.creamNotFoundBody : l10n.creamIntro,
            textAlign: TextAlign.center,
            style: context.text.bodyMedium?.copyWith(color: tokens.textLabel),
          ),
          if (consent == false) ...[
            Text(
              l10n.productAiNeedsConsent,
              textAlign: TextAlign.center,
              style: context.text.bodyMedium?.copyWith(color: tokens.textLabel),
            ),
            SaafButton.primary(
              label: l10n.aiPicksTurnOn,
              onPressed: () => context.push(SaafRoute.aiCoach.path),
            ),
          ] else ...[
            SaafTextField(
              key: const ValueKey('cream-name'),
              label: l10n.creamNameLabel,
              controller: _name,
              hintText: l10n.creamNameHint,
            ),
            if (state.photo case final Uint8List photo)
              Center(
                child: Semantics(
                  image: true,
                  label: l10n.productAiPhotoLabel,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(tokens.radius.r18),
                    child: Image.memory(
                      photo,
                      height: tokens.size.productPhoto,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stack) =>
                          const Icon(Icons.image_outlined),
                    ),
                  ),
                ),
              ),
            SaafButton.outline(
              label: state.photo == null
                  ? l10n.creamTakePhoto
                  : l10n.productAiRetake,
              leadingIcon: Icons.photo_camera_outlined,
              onPressed: () => controller.pickPhoto(AiPhotoSource.camera),
            ),
            SaafButton.text(
              label: l10n.productAiChoosePhoto,
              onPressed: () => controller.pickPhoto(AiPhotoSource.gallery),
            ),
            if (state.failure case final failure?)
              SaafMessageRow(
                icon: Icons.error_outline,
                text: withDetail(
                  switch (failure) {
                    NetworkFailure() => l10n.aiErrorNetwork,
                    RateLimited() => l10n.aiErrorLimit,
                    ServiceUnavailable() => l10n.aiErrorUnavailable,
                    Unauthorised() => l10n.aiErrorSignIn,
                    _ => l10n.aiErrorGeneric,
                  },
                  failure,
                  show: Env.diagnostics,
                ),
                color: context.colors.error,
              ),
            if (state.photoFailed)
              Text(
                l10n.aiPhotoFailed,
                style: context.text.bodySmall?.copyWith(
                  color: context.colors.error,
                ),
              ),
            Text(
              l10n.creamWhatIsSent,
              style: tokens.styles.legal.copyWith(color: tokens.textMeta),
            ),
            SaafButton.primary(
              label: l10n.creamCheck,
              onPressed: canCheck ? _check : null,
            ),
          ],
        ],
      );
    }

    return SaafScaffold(
      key: ValueKey('screen-${SaafRoute.creamCheck.name}'),
      topBar: SaafTopBar(
        title: l10n.creamTitle,
        leading: SaafTopBar.backButton(tooltip: l10n.back, onBack: _leave),
      ),
      body: body,
    );
  }
}

/// The verdict: a clear banner, what the phone flagged on the label, what
/// Saaf AI found (with sources), and the limits of the check.
class _Verdict extends ConsumerWidget {
  const _Verdict({
    required this.check,
    required this.reported,
    required this.onReport,
  });

  final SafetyCheck check;
  final bool reported;
  final VoidCallback onReport;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.saaf;
    final space = tokens.space;
    final colors = context.colors;

    final (title, advice, fill, ink, icon) = switch (check.level) {
      SafetyLevel.danger => (
        l10n.creamDangerTitle,
        l10n.creamDangerBody,
        colors.errorContainer,
        colors.onErrorContainer,
        Icons.dangerous_outlined,
      ),
      SafetyLevel.caution => (
        l10n.creamCautionTitle,
        l10n.creamCautionBody,
        colors.secondaryContainer,
        colors.onSecondaryContainer,
        Icons.warning_amber_outlined,
      ),
      SafetyLevel.noKnownProblem => (
        l10n.creamNoKnownTitle,
        l10n.creamNoKnownBody,
        tokens.sageTint,
        colors.onSurface,
        Icons.info_outline,
      ),
    };

    String flagText(IngredientFlag flag) => switch (flag.risk) {
      IngredientRisk.mercury => l10n.creamFlagMercury(flag.ingredient),
      IngredientRisk.hydroquinone => l10n.creamFlagHydroquinone(
        flag.ingredient,
      ),
      IngredientRisk.strongSteroid => l10n.creamFlagStrongSteroid(
        flag.ingredient,
      ),
      IngredientRisk.steroid => l10n.creamFlagSteroid(flag.ingredient),
      IngredientRisk.prescriptionRetinoid => l10n.creamFlagRetinoid(
        flag.ingredient,
      ),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: space.x12,
      children: [
        Row(
          spacing: space.x8,
          children: [
            Expanded(
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: SaafChip(
                  label: l10n.aiAnswerLabel,
                  tone: SaafChipTone.sageTint,
                  small: true,
                ),
              ),
            ),
            if (reported)
              Flexible(
                child: Text(
                  l10n.aiReported,
                  style: tokens.styles.legal.copyWith(color: tokens.textMeta),
                ),
              )
            else
              IconButton(
                tooltip: l10n.aiReport,
                icon: const Icon(Icons.flag_outlined),
                onPressed: onReport,
              ),
          ],
        ),
        if (check.title.isNotEmpty)
          Semantics(
            header: true,
            child: Text(
              check.title,
              textDirection: TextDirection.ltr,
              style: tokens.styles.productTitle,
            ),
          ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(tokens.radius.r20),
          ),
          child: Padding(
            padding: EdgeInsetsDirectional.all(space.x16),
            child: MergeSemantics(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: space.x6,
                children: [
                  Row(
                    spacing: space.x8,
                    children: [
                      ExcludeSemantics(child: Icon(icon, color: ink)),
                      Expanded(
                        child: Text(
                          title,
                          style: tokens.styles.listTitle.copyWith(color: ink),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    advice,
                    style: tokens.styles.pointCaption.copyWith(color: ink),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (check.summary.isNotEmpty)
          Text(check.summary, style: context.text.bodyMedium),
        if (check.flags.isNotEmpty) ...[
          Semantics(
            header: true,
            child: Text(l10n.creamOnLabel, style: context.text.titleSmall),
          ),
          for (final flag in check.flags)
            SaafMessageRow(
              icon: Icons.warning_amber_outlined,
              text: flagText(flag),
              color: colors.onSurface,
            ),
        ],
        if (check.ingredientsPrinted == false)
          SaafMessageRow(
            icon: Icons.help_outline,
            text: l10n.creamNoIngredients,
            color: colors.onSurface,
          ),
        if (check.findings.isNotEmpty) ...[
          Semantics(
            header: true,
            child: Text(l10n.creamFound, style: context.text.titleSmall),
          ),
          for (final finding in check.findings)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• ${finding.text}', style: context.text.bodyMedium),
                if (finding.source case final url?)
                  SaafButton.text(
                    label: Uri.tryParse(url)?.host ?? url,
                    leadingIcon: Icons.open_in_new,
                    onPressed: () =>
                        ref.read(externalLinkServiceProvider).open(url),
                  ),
              ],
            ),
        ],
        if (check.level == SafetyLevel.danger)
          SaafButton.outline(
            label: l10n.dermFind,
            leadingIcon: Icons.local_hospital_outlined,
            onPressed: () async {
              final city = await ref.read(weatherCityProvider.future);
              await ref
                  .read(externalLinkServiceProvider)
                  .open(dermatologistSearchUrl(city?.englishName));
            },
          ),
        Text(
          l10n.creamDisclaimer,
          style: tokens.styles.legal.copyWith(color: tokens.textMeta),
        ),
        SaafButton.outline(
          label: l10n.creamCheckAnother,
          onPressed: () =>
              ref.read(creamSafetyControllerProvider.notifier).reset(),
        ),
      ],
    );
  }
}
