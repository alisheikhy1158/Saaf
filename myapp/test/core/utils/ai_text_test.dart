// Covers: AI answers shown tidily on a phone — headings, bullets and bold
// instead of raw "**" marks, and tables turned into readable bullet lines
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/core/utils/ai_text.dart';

/// A short, readable form of the blocks: "h:" heading, "p:" paragraph,
/// "b:" bullet, "1." numbered; bold parts in [brackets].
List<String> shape(String text) => [
  for (final block in parseAiText(text))
    switch (block) {
      AiHeading(:final text) => 'h:$text',
      AiParagraph(:final spans) => 'p:${_spans(spans)}',
      AiBullet(:final spans, :final number) =>
        '${number == null ? 'b' : '$number.'}:${_spans(spans)}',
    },
];

String _spans(List<AiSpan> spans) =>
    spans.map((s) => s.bold ? '[${s.text}]' : s.text).join();

void main() {
  test('plain text is one paragraph', () {
    expect(shape('Use sunscreen every morning.'), [
      'p:Use sunscreen every morning.',
    ]);
  });

  test(
    'lines next to each other join; a blank line starts a new paragraph',
    () {
      expect(shape('First line\nstill first.\n\nSecond.'), [
        'p:First line still first.',
        'p:Second.',
      ]);
    },
  );

  test('a bold line on its own is a heading', () {
    expect(shape('**What’s working well**\nGood habits.'), [
      'h:What’s working well',
      'p:Good habits.',
    ]);
    expect(shape('**Where you can improve:**'), ['h:Where you can improve']);
  });

  test('# headings become headings too', () {
    expect(shape('## Your routine\n### Morning'), [
      'h:Your routine',
      'h:Morning',
    ]);
  });

  test('bullets with -, * or •, and bold inside them', () {
    expect(
      shape('- **Neem face wash** – good for oily skin\n* SPF 60\n• Water'),
      ['b:[Neem face wash] – good for oily skin', 'b:SPF 60', 'b:Water'],
    );
  });

  test('numbered steps keep their number', () {
    expect(shape('1. Cleanse\n2) Moisturise'), ['1.:Cleanse', '2.:Moisturise']);
  });

  test('a table becomes one bullet per row, without the pipes', () {
    const table =
        '| Step | Current product | Suggested tweak |\n'
        '|------|-----------------|-----------------|\n'
        '| **Cleanser** | Himalaya Neem | Keep it |\n'
        '| Moisturiser | Nivea Soft | Try a gel |';
    final lines = shape(table);
    expect(lines, [
      'b:[Cleanser] – Himalaya Neem · Keep it',
      'b:[Moisturiser] – Nivea Soft · Try a gel',
    ]);
    expect(lines.join(), isNot(contains('|')));
  });

  test('table cells left empty are skipped', () {
    expect(shape('| A | B |\n|---|---|\n| Treatments | – |'), [
      'b:[Treatments]',
    ]);
  });

  test('lines, links, code marks, single stars and citations are tidied', () {
    expect(
      shape(
        'Use *gentle* `niacinamide` [like this](https://x.example).【2†L1-L3】\n'
        '---\n'
        '***',
      ),
      ['p:Use gentle niacinamide like this.'],
    );
  });

  test('a stray, unclosed ** is not left on screen', () {
    expect(shape('Try **this'), ['p:Try this']);
  });

  test('Urdu text is kept as it is', () {
    expect(shape('**اہم بات**\n- سن اسکرین لگائیں'), [
      'h:اہم بات',
      'b:سن اسکرین لگائیں',
    ]);
  });

  test('nothing in, nothing out', () {
    expect(shape('  \n\n '), isEmpty);
  });
}
