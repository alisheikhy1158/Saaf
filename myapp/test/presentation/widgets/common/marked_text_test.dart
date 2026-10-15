// Covers: design.md §11 — sentences live in ARB with placeholders, so inline
// links/bold are built by splitting the translated sentence at marker characters.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/presentation/widgets/common/marked_text.dart';

void main() {
  const a = '';
  const b = '';

  List<String?> texts(List<InlineSpan> spans) =>
      spans.map((s) => (s as TextSpan).text).toList();

  test('replaces each marker with its span, in sentence order', () {
    final spans = spansFromTemplate('Hello $a and $b!', {
      a: const TextSpan(text: 'one'),
      b: const TextSpan(text: 'two'),
    });
    expect(texts(spans), ['Hello ', 'one', ' and ', 'two', '!']);
  });

  test('works when the sentence starts or ends with a marker', () {
    final spans = spansFromTemplate('$b-$a', {
      a: const TextSpan(text: 'A'),
      b: const TextSpan(text: 'B'),
    });
    expect(texts(spans), ['B', '-', 'A']);
  });

  test('a sentence without markers is one plain span', () {
    expect(texts(spansFromTemplate('plain', const {})), ['plain']);
  });

  test('an empty sentence gives no spans', () {
    expect(spansFromTemplate('', const {}), isEmpty);
  });

  test('keeps Urdu text and combining characters intact', () {
    final spans = spansFromTemplate('میں $a سے متفق ہوں', {
      a: const TextSpan(text: 'شرائط'),
    });
    expect(texts(spans), ['میں ', 'شرائط', ' سے متفق ہوں']);
  });
}
