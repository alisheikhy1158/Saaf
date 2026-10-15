import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:saaf/core/l10n/app_localizations.dart';
import 'package:saaf/core/theme/saaf_tokens_extension.dart';

/// "I agree to the Terms of Use and Privacy Policy" with both document names as
/// tappable links. The sentence comes from the ARB file with two placeholders,
/// so each language can put the links wherever its grammar needs them.
class ConsentAgreeLabel extends StatefulWidget {
  const ConsentAgreeLabel({
    required this.onOpenTerms,
    required this.onOpenPrivacy,
    super.key,
  });

  final VoidCallback onOpenTerms;
  final VoidCallback onOpenPrivacy;

  @override
  State<ConsentAgreeLabel> createState() => _ConsentAgreeLabelState();
}

class _ConsentAgreeLabelState extends State<ConsentAgreeLabel> {
  // Private-use characters stand in for the two placeholders while the
  // sentence is split into plain text and links.
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
    final sentence = l10n.consentAgree(_termsMarker, _privacyMarker);
    final linkStyle = TextStyle(
      decoration: TextDecoration.underline,
      decorationColor: context.colors.onSurface,
    );

    final spans = <InlineSpan>[];
    final plain = StringBuffer();
    void flush() {
      if (plain.isEmpty) return;
      spans.add(TextSpan(text: plain.toString()));
      plain.clear();
    }

    for (final char in sentence.characters) {
      if (char == _termsMarker) {
        flush();
        spans.add(
          TextSpan(text: l10n.termsTitle, style: linkStyle, recognizer: _terms),
        );
      } else if (char == _privacyMarker) {
        flush();
        spans.add(
          TextSpan(
            text: l10n.privacyPolicyTitle,
            style: linkStyle,
            recognizer: _privacy,
          ),
        );
      } else {
        plain.write(char);
      }
    }
    flush();

    return Text.rich(TextSpan(children: spans));
  }
}
