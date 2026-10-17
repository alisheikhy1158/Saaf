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
import 'package:saaf/core/utils/price_search.dart';
import 'package:saaf/domain/entities/ai_photo_source.dart';
import 'package:saaf/domain/entities/product_insight.dart';
import 'package:saaf/presentation/providers/ai_providers.dart';
import 'package:saaf/presentation/providers/product_insight_controller.dart';
import 'package:saaf/presentation/providers/product_providers.dart';
import 'package:saaf/presentation/widgets/common/saaf_ai_text.dart';
import 'package:saaf/presentation/widgets/common/saaf_button.dart';
import 'package:saaf/presentation/widgets/common/saaf_chip.dart';
import 'package:saaf/presentation/widgets/common/saaf_icon_circle.dart';
import 'package:saaf/presentation/widgets/common/saaf_scaffold.dart';
import 'package:saaf/presentation/widgets/common/saaf_top_bar.dart';

/// Looks a product up with Saaf AI when its barcode is unknown, its QR code is
/// only a link, or nothing scans (a photo of the label). The user sees what
/// will be sent and taps to send it; Saaf AI must be turned on first (Apple
/// 5.1.2(i)); the answer is marked as AI and can be reported (Google Play's AI
/// content policy). Exactly one of [barcode], [qr] or [photo] is used.
class ProductAiScreen extends ConsumerWidget {
  const ProductAiScreen({super.key, this.barcode, this.qr, this.photo = false});

  final String? barcode;
  final String? qr;

  /// Look the product up from a photo of its label.
  final bool photo;

  ProductQuery? _codeQuery() {
    final digits = barcode?.trim();
    if (digits != null && digits.isNotEmpty) return ProductBarcodeQuery(digits);
    final text = qr?.trim();
    if (text != null && text.isNotEmpty) return ProductQrQuery(text);
    return null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final consent = ref.watch(aiConsentStateProvider);
    final state = ref.watch(productInsightControllerProvider);
    final controller = ref.read(productInsightControllerProvider.notifier);
    final code = photo ? null : _codeQuery();
    final usesPhoto = code == null;

    void leave() =>
        context.canPop() ? context.pop() : context.go(SaafRoute.home.path);

    Future<void> send() async {
      final photoBytes = state.photo;
      final query = usesPhoto
          ? (photoBytes == null ? null : ProductPhotoQuery(photoBytes))
          : code;
      if (query != null) await controller.lookUp(query);
    }

    // What will be sent, shown before anything is.
    final whatIsSent = switch (code) {
      ProductBarcodeQuery(:final digits) => l10n.productAiBarcodeBody(digits),
      ProductQrQuery(:final text) => l10n.productAiQrBody(text),
      _ => l10n.productAiPhotoBody,
    };

    final Widget body;
    if (consent == null) {
      body = const Center(child: CircularProgressIndicator());
    } else if (consent == false) {
      body = _Intro(
        title: usesPhoto ? l10n.productAiPhotoTitle : l10n.productAiCodeTitle,
        body: '$whatIsSent\n\n${l10n.productAiNeedsConsent}',
        actions: [
          SaafButton.primary(
            label: l10n.aiPicksTurnOn,
            onPressed: () => context.push(SaafRoute.aiCoach.path),
          ),
        ],
      );
    } else if (state.searching) {
      body = Padding(
        padding: EdgeInsetsDirectional.only(top: context.saaf.space.x36),
        child: Column(
          spacing: context.saaf.space.x16,
          children: [
            const CircularProgressIndicator(),
            Text(
              l10n.productAiSearching,
              textAlign: TextAlign.center,
              style: context.text.bodyMedium,
            ),
          ],
        ),
      );
    } else if (state.insight case final insight? when insight.found) {
      body = _Answer(insight: insight);
    } else if (state.insight != null) {
      body = _Intro(
        icon: Icons.search_off,
        title: l10n.productAiNotFoundTitle,
        body: usesPhoto
            ? l10n.productAiNotFoundPhoto
            : l10n.productAiNotFoundCode,
        actions: [
          SaafButton.primary(
            label: l10n.productAiTakePhoto,
            onPressed: () {
              controller.reset();
              if (usesPhoto) {
                controller.pickPhoto(AiPhotoSource.camera);
              } else {
                context.pushReplacement(
                  Uri(
                    path: SaafRoute.productAi.path,
                    queryParameters: {'photo': '1'},
                  ).toString(),
                );
              }
            },
          ),
        ],
      );
    } else {
      body = _Intro(
        title: usesPhoto ? l10n.productAiPhotoTitle : l10n.productAiCodeTitle,
        body: whatIsSent,
        photo: state.photo,
        error: state.failure == null
            ? (state.photoFailed ? l10n.aiPhotoFailed : null)
            : _failureText(l10n, state.failure!),
        actions: [
          if (!usesPhoto || state.photo != null)
            SaafButton.primary(
              label: state.failure == null
                  ? l10n.productAiLookUp
                  : l10n.scanTryAgain,
              onPressed: send,
            ),
          if (usesPhoto) ...[
            if (state.photo == null)
              SaafButton.primary(
                label: l10n.productAiTakePhoto,
                onPressed: () => controller.pickPhoto(AiPhotoSource.camera),
              )
            else
              SaafButton.outline(
                label: l10n.productAiRetake,
                onPressed: () => controller.pickPhoto(AiPhotoSource.camera),
              ),
            SaafButton.text(
              label: l10n.productAiChoosePhoto,
              onPressed: () => controller.pickPhoto(AiPhotoSource.gallery),
            ),
          ],
        ],
      );
    }

    return SaafScaffold(
      key: ValueKey('screen-${SaafRoute.productAi.name}'),
      topBar: SaafTopBar(
        title: l10n.productAiTitle,
        leading: SaafTopBar.backButton(tooltip: l10n.back, onBack: leave),
      ),
      body: body,
    );
  }

  static String _failureText(AppLocalizations l10n, Failure failure) =>
      withDetail(
        switch (failure) {
          NetworkFailure() => l10n.aiErrorNetwork,
          RateLimited() => l10n.aiErrorLimit,
          ServiceUnavailable() => l10n.aiErrorUnavailable,
          Unauthorised() => l10n.aiErrorSignIn,
          _ => l10n.aiErrorGeneric,
        },
        failure,
        show: Env.diagnostics,
      );
}

/// The starting view: what this does, what is sent, and the buttons.
class _Intro extends StatelessWidget {
  const _Intro({
    required this.title,
    required this.body,
    required this.actions,
    this.icon = Icons.auto_awesome,
    this.photo,
    this.error,
  });

  final IconData icon;
  final String title;
  final String body;
  final List<Widget> actions;
  final Uint8List? photo;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.saaf;
    final bytes = photo;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: tokens.space.x16,
      children: [
        Center(
          child: SaafIconCircle(icon: icon, size: SaafIconCircleSize.large),
        ),
        Semantics(
          header: true,
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: context.text.titleLarge,
          ),
        ),
        Text(
          body,
          textAlign: TextAlign.center,
          style: context.text.bodyMedium?.copyWith(color: tokens.textLabel),
        ),
        if (bytes != null)
          Center(
            child: Semantics(
              image: true,
              label: l10n.productAiPhotoLabel,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(tokens.radius.r18),
                child: Image.memory(
                  bytes,
                  height: tokens.size.productPhoto,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stack) => SizedBox.square(
                    dimension: tokens.size.avatar,
                    child: const Icon(Icons.image_outlined),
                  ),
                ),
              ),
            ),
          ),
        if (error != null)
          Text(
            error!,
            textAlign: TextAlign.center,
            style: context.text.bodyMedium?.copyWith(
              color: context.colors.error,
            ),
          ),
        ...actions,
      ],
    );
  }
}

enum _ReportReason { harmful, wrong, offensive, other }

/// Saaf AI's answer, marked as AI, with the report button and the reminder
/// that it can be wrong.
class _Answer extends ConsumerWidget {
  const _Answer({required this.insight});

  final ProductInsight insight;

  Future<void> _report(BuildContext context, WidgetRef ref) async {
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
    if (reason == null || !context.mounted) return;
    final sent = await ref
        .read(productInsightControllerProvider.notifier)
        .report(reason.name);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(sent ? l10n.aiReportThanks : l10n.aiReportFailed)),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.saaf;
    final reported = ref.watch(
      productInsightControllerProvider.select((s) => s.reported),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: tokens.space.x12,
      children: [
        Row(
          spacing: tokens.space.x8,
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
                onPressed: () => _report(context, ref),
              ),
          ],
        ),
        if (insight.title != null)
          Semantics(
            header: true,
            child: Text(insight.title!, style: tokens.styles.productTitle),
          ),
        if (!insight.webChecked)
          Text(
            l10n.productAiNotWebChecked,
            style: context.text.bodySmall?.copyWith(color: tokens.textLabel),
          ),
        SaafAiText(insight.text),
        if (insight.title != null)
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: SaafButton.text(
              label: l10n.checkPricesOnline,
              leadingIcon: Icons.open_in_new,
              onPressed: () => ref
                  .read(externalLinkServiceProvider)
                  .open(priceSearchUrl(insight.title!)),
            ),
          ),
        Text(
          l10n.aiDisclaimer,
          style: tokens.styles.legal.copyWith(color: tokens.textMeta),
        ),
        SaafButton.outline(
          label: l10n.productAiScanAnother,
          onPressed: () => context.pushReplacement(SaafRoute.scanProduct.path),
        ),
      ],
    );
  }
}
