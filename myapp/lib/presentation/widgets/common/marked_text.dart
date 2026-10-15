import 'package:flutter/widgets.dart';

/// Splits a translated sentence at marker characters and puts [byMarker]'s spans
/// in their place, so each language keeps its own word order around inline
/// links or bold text. Build the sentence by passing the markers as the ARB
/// placeholder values, e.g. `l10n.consentAgree('', '')`.
List<InlineSpan> spansFromTemplate(
  String template,
  Map<String, InlineSpan> byMarker,
) {
  final spans = <InlineSpan>[];
  final plain = StringBuffer();
  void flush() {
    if (plain.isEmpty) return;
    spans.add(TextSpan(text: plain.toString()));
    plain.clear();
  }

  for (final unit in template.codeUnits) {
    final replacement = byMarker[String.fromCharCode(unit)];
    if (replacement == null) {
      plain.writeCharCode(unit);
    } else {
      flush();
      spans.add(replacement);
    }
  }
  flush();
  return spans;
}
