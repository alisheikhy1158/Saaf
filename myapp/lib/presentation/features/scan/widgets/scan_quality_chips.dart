import 'package:flutter/material.dart';
import 'package:saaf/core/l10n/app_localizations.dart';
import 'package:saaf/core/theme/saaf_tokens_extension.dart';
import 'package:saaf/domain/entities/capture_quality.dart';
import 'package:saaf/presentation/widgets/common/saaf_chip.dart';

/// "Good light · Centred · Hold still": a tick when the check passes, a clock
/// while it is still waiting. Spoken with "not yet" so colour and icon are not
/// the only signal (A11Y-7).
class ScanQualityChips extends StatelessWidget {
  const ScanQualityChips({required this.quality, super.key});

  final CaptureQuality quality;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: context.saaf.space.x8,
      runSpacing: context.saaf.space.x8,
      children: [
        _chip(l10n, l10n.scanChipLight, quality.lightOk),
        _chip(l10n, l10n.scanChipCentred, quality.centred),
        _chip(l10n, l10n.scanChipSteady, quality.steady),
      ],
    );
  }

  Widget _chip(AppLocalizations l10n, String label, bool ok) => Semantics(
    label: ok ? label : '$label, ${l10n.scanChipNotYet}',
    excludeSemantics: true,
    child: SaafChip(
      label: label,
      icon: ok ? Icons.check : Icons.schedule,
      tone: SaafChipTone.onDark,
    ),
  );
}
