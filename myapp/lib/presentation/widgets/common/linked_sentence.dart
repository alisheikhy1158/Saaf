import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:saaf/core/l10n/app_localizations.dart';
import 'package:saaf/presentation/widgets/common/marked_text.dart';

/// A sentence that links to the Terms of Use and the Privacy Policy (required on
/// sign-up, consent, paywall and profile). [sentence] receives the two document
/// names and returns the translated sentence, so each language can order them as
/// it needs.
class LinkedSentence extends StatefulWidget {
  const LinkedSentence({
    required this.sentence,
    required this.onOpenTerms,
    required this.onOpenPrivacy,
    super.key,
    this.style,
    this.textAlign,
  });

  final String Function(String terms, String privacy) sentence;
  final VoidCallback onOpenTerms;
  final VoidCallback onOpenPrivacy;
  final TextStyle? style;
  final TextAlign? textAlign;

  @override
  State<LinkedSentence> createState() => _LinkedSentenceState();
}

class _LinkedSentenceState extends State<LinkedSentence> {
  static const _termsMarker = '';
  static const _privacyMarker = '';

  late final TapGestureRecognizer _terms = TapGestureRecognizer()
    ..onTap = () => widget.onOpenTerms();
  late final TapGestureRecognizer _privacy = TapGestureRecognizer()
    ..onTap = () => widget.onOpenPrivacy();

  @override
  void dispose() {
    _terms.dispose();
    _privacy.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final linkStyle = TextStyle(
      decoration: TextDecoration.underline,
      decorationColor:
          widget.style?.color ?? Theme.of(context).colorScheme.onSurface,
    );

    return Text.rich(
      TextSpan(
        children:
            spansFromTemplate(widget.sentence(_termsMarker, _privacyMarker), {
              _termsMarker: TextSpan(
                text: l10n.termsTitle,
                style: linkStyle,
                recognizer: _terms,
              ),
              _privacyMarker: TextSpan(
                text: l10n.privacyPolicyTitle,
                style: linkStyle,
                recognizer: _privacy,
              ),
            }),
      ),
      style: widget.style,
      textAlign: widget.textAlign,
    );
  }
}
