/// Turns an AI answer (light Markdown) into simple blocks the app can show
/// tidily: headings, paragraphs and bullets with bold parts. Tables, which do
/// not fit a phone, become one bullet per row; links, code marks, rules and
/// web-citation marks are removed. Pure Dart, so it is easy to test.
library;

/// A run of text, bold or not.
class AiSpan {
  const AiSpan(this.text, {this.bold = false});

  final String text;
  final bool bold;

  @override
  bool operator ==(Object other) =>
      other is AiSpan && other.text == text && other.bold == bold;

  @override
  int get hashCode => Object.hash(text, bold);
}

sealed class AiBlock {
  const AiBlock();
}

final class AiHeading extends AiBlock {
  const AiHeading(this.text);
  final String text;
}

final class AiParagraph extends AiBlock {
  const AiParagraph(this.spans);
  final List<AiSpan> spans;
}

/// A bullet point; [number] is set for a numbered step.
final class AiBullet extends AiBlock {
  const AiBullet(this.spans, {this.number});
  final List<AiSpan> spans;
  final int? number;
}

final _hashHeading = RegExp(r'^#{1,6}\s+(.+)$');
final _boldHeading = RegExp(r'^\*\*([^*]+?)\*\*:?$');
final _bullet = RegExp(r'^[-*•]\s+(.+)$');
final _numbered = RegExp(r'^(\d{1,2})[.)]\s+(.+)$');
final _rule = RegExp(r'^([-*_])\s*(\1\s*){2,}$');
final _tableSeparator = RegExp(r'^\|?[\s:|-]+\|?$');
final _citation = RegExp(r'【[^】]*】');
final _link = RegExp(r'\[([^\]]+)\]\([^)]*\)');
final _italic = RegExp(r'(?<![*\w])\*(?!\*)([^*\n]+?)\*(?![*\w])');
final _emptyCell = RegExp(r'^[\s\-–—]*$');

List<AiBlock> parseAiText(String text) {
  final blocks = <AiBlock>[];
  final paragraph = <String>[];
  List<String>? tableHeader;

  void endParagraph() {
    if (paragraph.isEmpty) return;
    final spans = _spans(paragraph.join(' '));
    if (spans.isNotEmpty) blocks.add(AiParagraph(spans));
    paragraph.clear();
  }

  final lines = text.replaceAll('\r\n', '\n').split('\n');
  for (var i = 0; i < lines.length; i++) {
    final line = _tidy(lines[i]).trim();

    if (line.startsWith('|') || (line.contains('|') && tableHeader != null)) {
      endParagraph();
      if (_tableSeparator.hasMatch(line)) continue;
      final cells = _cells(line);
      final next = i + 1 < lines.length ? lines[i + 1].trim() : '';
      if (tableHeader == null &&
          next.contains('|') &&
          _tableSeparator.hasMatch(next)) {
        tableHeader = cells; // the header row is not shown
        continue;
      }
      final kept = cells.where((c) => !_emptyCell.hasMatch(c)).toList();
      if (kept.isEmpty) continue;
      final first = kept.first.replaceAll('**', '').trim();
      final rest = kept.skip(1).join(' · ');
      blocks.add(
        AiBullet([
          AiSpan(first, bold: true),
          if (rest.isNotEmpty) ...[const AiSpan(' – '), ..._spans(rest)],
        ]),
      );
      continue;
    }
    tableHeader = null;

    if (line.isEmpty || _rule.hasMatch(line)) {
      endParagraph();
      continue;
    }

    final hash = _hashHeading.firstMatch(line);
    final bold = _boldHeading.firstMatch(line);
    if (hash != null || bold != null) {
      endParagraph();
      final title = (hash?.group(1) ?? bold!.group(1)!)
          .replaceAll('**', '')
          .replaceAll(RegExp(r':$'), '')
          .trim();
      if (title.isNotEmpty) blocks.add(AiHeading(title));
      continue;
    }

    final numbered = _numbered.firstMatch(line);
    if (numbered != null) {
      endParagraph();
      blocks.add(
        AiBullet(
          _spans(numbered.group(2)!),
          number: int.parse(numbered.group(1)!),
        ),
      );
      continue;
    }

    final bullet = _bullet.firstMatch(line);
    if (bullet != null) {
      endParagraph();
      final spans = _spans(bullet.group(1)!);
      if (spans.isNotEmpty) blocks.add(AiBullet(spans));
      continue;
    }

    paragraph.add(line);
  }
  endParagraph();
  return blocks;
}

/// Removes what never shows well: citations, links, code marks, single stars.
String _tidy(String line) => line
    .replaceAll(_citation, '')
    .replaceAllMapped(_link, (m) => m.group(1)!)
    .replaceAll('`', '')
    .replaceAllMapped(_italic, (m) => m.group(1)!);

List<String> _cells(String line) {
  var row = line.trim();
  if (row.startsWith('|')) row = row.substring(1);
  if (row.endsWith('|')) row = row.substring(0, row.length - 1);
  return [for (final cell in row.split('|')) cell.trim()];
}

/// Splits on "**" into plain and bold runs. An unclosed "**" is dropped.
List<AiSpan> _spans(String text) {
  final parts = text.split('**');
  final closed = parts.length.isOdd;
  final spans = <AiSpan>[];
  for (var i = 0; i < parts.length; i++) {
    final bold = closed && i.isOdd;
    final part = parts[i];
    if (part.isEmpty) continue;
    if (spans.isNotEmpty && spans.last.bold == bold) {
      spans[spans.length - 1] = AiSpan(spans.last.text + part, bold: bold);
    } else {
      spans.add(AiSpan(part, bold: bold));
    }
  }
  if (spans.isEmpty) return spans;
  // Trim the outer spaces of the whole line.
  spans[0] = AiSpan(spans.first.text.trimLeft(), bold: spans.first.bold);
  spans[spans.length - 1] = AiSpan(
    spans.last.text.trimRight(),
    bold: spans.last.bold,
  );
  return [
    for (final s in spans)
      if (s.text.isNotEmpty) s,
  ];
}
