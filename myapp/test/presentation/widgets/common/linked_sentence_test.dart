// Covers: store-compliance §1 (Terms/Privacy linked in-app: 02, 04, 13, 14),
// design.md §11 (sentences come from ARB, link order is the language's)
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/presentation/widgets/common/linked_sentence.dart';

import '../../../helpers/pump_app.dart';

/// The sentence's leaf spans (Text.rich wraps them in an outer span).
List<TextSpan> spansOf(WidgetTester tester) {
  final rich = tester.widget<RichText>(
    find.descendant(
      of: find.byType(LinkedSentence),
      matching: find.byType(RichText),
    ),
  );
  final leaves = <TextSpan>[];
  void collect(InlineSpan span) {
    if (span is! TextSpan) return;
    if (span.text != null) leaves.add(span);
    span.children?.forEach(collect);
  }

  collect(rich.text);
  return leaves;
}

void main() {
  testWidgets('turns the two document names into underlined links', (
    tester,
  ) async {
    var terms = 0;
    var privacy = 0;
    await pumpSaaf(
      tester,
      LinkedSentence(
        sentence: (terms, privacy) =>
            'By continuing you agree to the $terms and $privacy.',
        onOpenTerms: () => terms++,
        onOpenPrivacy: () => privacy++,
      ),
    );
    final spans = spansOf(tester);
    expect(spans.map((s) => s.text), [
      'By continuing you agree to the ',
      'Terms of Use',
      ' and ',
      'Privacy Policy',
      '.',
    ]);
    final termsSpan = spans[1];
    expect(termsSpan.style?.decoration, TextDecoration.underline);
    (termsSpan.recognizer! as TapGestureRecognizer).onTap!();
    (spans[3].recognizer! as TapGestureRecognizer).onTap!();
    expect(terms, 1);
    expect(privacy, 1);
  });

  testWidgets('supports a language that puts the privacy link first', (
    tester,
  ) async {
    var privacy = 0;
    await pumpSaaf(
      tester,
      LinkedSentence(
        sentence: (terms, privacy) => '$privacy aur $terms',
        onOpenTerms: () {},
        onOpenPrivacy: () => privacy++,
      ),
    );
    final spans = spansOf(tester);
    expect(spans.first.text, 'Privacy Policy');
    (spans.first.recognizer! as TapGestureRecognizer).onTap!();
    expect(privacy, 1);
  });

  testWidgets('applies the given style and alignment', (tester) async {
    await pumpSaaf(
      tester,
      LinkedSentence(
        sentence: (terms, privacy) => 'x $terms y $privacy',
        onOpenTerms: () {},
        onOpenPrivacy: () {},
        textAlign: TextAlign.center,
      ),
    );
    final rich = tester.widget<RichText>(
      find.descendant(
        of: find.byType(LinkedSentence),
        matching: find.byType(RichText),
      ),
    );
    expect(rich.textAlign, TextAlign.center);
  });

  testWidgets('disposes its recognizers with no errors', (tester) async {
    await pumpSaaf(
      tester,
      LinkedSentence(
        sentence: (terms, privacy) => '$terms $privacy',
        onOpenTerms: () {},
        onOpenPrivacy: () {},
      ),
    );
    await pumpSaaf(tester, const SizedBox.shrink());
    expect(tester.takeException(), isNull);
  });
}
