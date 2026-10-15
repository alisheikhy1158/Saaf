import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:saaf/core/l10n/app_localizations.dart';
import 'package:saaf/core/theme/saaf_tokens_extension.dart';
import 'package:saaf/presentation/widgets/common/marked_text.dart';

/// "Sent to +92 312 456 7890 · Edit", with Edit as a bold link back to Sign up.
class SentToLine extends StatefulWidget {
  const SentToLine({required this.phone, required this.onEdit, super.key});

  /// The number as shown ("+92 312 456 7890").
  final String phone;
  final VoidCallback onEdit;

  @override
  State<SentToLine> createState() => _SentToLineState();
}

class _SentToLineState extends State<SentToLine> {
  static const _editMarker = '';

  late final TapGestureRecognizer _edit = TapGestureRecognizer()
    ..onTap = () => widget.onEdit();

  @override
  void dispose() {
    _edit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.saaf;

    return Text.rich(
      TextSpan(
        children:
            spansFromTemplate(l10n.verifySentTo(widget.phone, _editMarker), {
              _editMarker: TextSpan(
                text: l10n.verifyEdit,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: context.colors.onSurface,
                ),
                recognizer: _edit,
              ),
            }),
      ),
      style: context.text.bodyLarge?.copyWith(color: tokens.textSecondary),
    );
  }
}
