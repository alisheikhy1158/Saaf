import 'package:flutter/material.dart';
import 'package:saaf/core/theme/saaf_tokens_extension.dart';
import 'package:saaf/core/utils/ai_text.dart';

/// An AI answer laid out for a phone: short headings, bullet points and bold
/// product names instead of raw "**" marks or tables (see [parseAiText]).
/// Follows the reading direction, so Urdu bullets sit on the right.
class SaafAiText extends StatelessWidget {
  const SaafAiText(this.text, {super.key, this.color});

  final String text;

  /// The text colour; the theme's on-surface colour when null.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final tokens = context.saaf;
    final body = context.text.bodyMedium?.copyWith(
      color: color ?? context.colors.onSurface,
    );
    final heading = context.text.titleSmall?.copyWith(
      color: color ?? context.colors.onSurface,
    );
    final blocks = parseAiText(text);

    TextSpan spans(List<AiSpan> parts) => TextSpan(
      children: [
        for (final part in parts)
          TextSpan(
            text: part.text,
            style: part.bold
                ? const TextStyle(fontWeight: FontWeight.w700)
                : null,
          ),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (i, block) in blocks.indexed) ...[
          // More room above a heading than between bullets or paragraphs.
          if (i > 0)
            SizedBox(
              height: block is AiHeading ? tokens.space.x12 : tokens.space.x6,
            ),
          switch (block) {
            AiHeading(:final text) => Semantics(
              header: true,
              child: Text(text, style: heading),
            ),
            AiParagraph(spans: final parts) => Text.rich(
              spans(parts),
              style: body,
            ),
            AiBullet(spans: final parts, :final number) => Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: tokens.space.x8,
              children: [
                ExcludeSemantics(
                  child: Text(number == null ? '•' : '$number.', style: body),
                ),
                Expanded(child: Text.rich(spans(parts), style: body)),
              ],
            ),
          },
        ],
      ],
    );
  }
}
