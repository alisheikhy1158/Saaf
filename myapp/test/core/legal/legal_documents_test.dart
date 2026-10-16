// Covers: store-compliance §1 (privacy policy: what is collected, how used, who
// gets it, retention, deletion; face-data promises of screen 04 are contractual),
// §3 (account deletion route), §4 (subscription terms), §5 (cosmetic, not
// medical), design.md §9.6 (Terms/Privacy pages)
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/core/config/legal_config.dart';
import 'package:saaf/core/config/policy_version.dart';
import 'package:saaf/core/legal/legal_documents.dart';

String allText(LegalDocument d) => [
  d.intro,
  for (final s in d.sections) ...[s.heading, ...s.paragraphs, ...s.bullets],
].join('\n').toLowerCase();

void main() {
  const config = LegalConfig(
    operatorName: 'Saaf',
    contactEmail: 'help@example.test',
    deletionUrl: 'https://example.test/delete',
    isReviewed: false,
  );
  final terms = LegalDocuments.terms(config);
  final privacy = LegalDocuments.privacy(config);

  group('both documents', () {
    for (final (name, doc) in [('terms', terms), ('privacy', privacy)]) {
      test('$name has a title, an update date and numbered sections', () {
        expect(doc.title, isNotEmpty);
        expect(doc.lastUpdated, currentPolicyVersion);
        expect(doc.sections.length, greaterThanOrEqualTo(10));
        for (final s in doc.sections) {
          expect(s.heading, isNotEmpty);
          expect(
            s.paragraphs.isNotEmpty || s.bullets.isNotEmpty,
            isTrue,
            reason: s.heading,
          );
        }
      });

      test('$name has no leftover placeholder text', () {
        final text = allText(doc);
        for (final bad in ['lorem', 'todo', 'tbd', 'xxx', '[', '{']) {
          expect(text.contains(bad), isFalse, reason: '$name contains "$bad"');
        }
      });

      test('$name shows the contact details it was given', () {
        expect(allText(doc), contains('help@example.test'));
      });
    }
  });

  group('privacy policy states what the app really does', () {
    final text = allText(privacy);

    test('face photos stay on the phone and are analysed on the device', () {
      expect(text, contains('on your phone'));
      expect(text, contains('on your device'));
      expect(text, contains('never uploaded unless you turn on backup'));
    });

    test('health-related quiz answers never leave the phone', () {
      expect(text, contains('pregnan'));
      expect(text, contains('never uploaded'));
    });

    test('no sale, no advertising, no tracking', () {
      expect(text, contains('never sold'));
      expect(text, contains('advertis'));
      expect(text, contains('advertising id'));
    });

    test('names every service provider that receives data', () {
      for (final provider in ['firebase', 'apple', 'google', 'revenuecat']) {
        expect(text, contains(provider), reason: provider);
      }
    });

    test('explains retention and how to delete the account', () {
      expect(text, contains('delete my account'));
      expect(text, contains('https://example.test/delete'));
      expect(text, contains('does not cancel'));
      expect(text, contains('retain'));
    });

    test('is for people aged 16 and over', () {
      expect(text, contains('16'));
    });

    test('lists the rights users have', () {
      for (final right in ['access', 'correct', 'delete', 'withdraw']) {
        expect(text, contains(right), reason: right);
      }
    });
  });

  group('terms of use', () {
    final text = allText(terms);

    test('say Saaf is cosmetic, not medical advice', () {
      expect(text, contains('not medical advice'));
      expect(text, contains('dermatologist'));
    });

    test('set the minimum age at 16', () {
      expect(text, contains('16'));
    });

    test('cover subscriptions the way the stores require', () {
      expect(text, contains('automatically renew'));
      expect(text, contains('24 hours'));
      expect(text, contains('apple id'));
      expect(text, contains('google play'));
    });

    test('do not promise skin results', () {
      expect(text, contains('no guarantee'));
    });

    test('name the governing law and link the privacy policy', () {
      expect(text, contains('laws of pakistan'));
      expect(text, contains('privacy policy'));
    });
  });

  group('LegalConfig', () {
    test('without a contact email the documents still read correctly', () {
      const noEmail = LegalConfig(operatorName: 'Saaf', isReviewed: false);
      final text = allText(LegalDocuments.privacy(noEmail));
      expect(text, isNot(contains('null')));
      expect(text, contains('contact'));
    });

    test('the shipped config says it is still a draft', () {
      expect(LegalConfig.current.isReviewed, isFalse);
    });
  });
}
