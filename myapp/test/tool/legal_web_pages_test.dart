// Covers: store-compliance §1/§3/§7 — the Privacy Policy, Terms of Use and the
// account deletion page must also be on the web (store listings, Google Play's
// deletion URL). The server serves them from backend/ai-proxy/src/legal_pages.js,
// which is made from the same text the app shows. This test fails when the two
// differ; to write the file again run (in myapp):
//
//   flutter test test/tool/legal_web_pages_test.dart --dart-define=UPDATE_LEGAL_PAGES=true
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/core/config/legal_config.dart';
import 'package:saaf/core/legal/legal_documents.dart';

/// Replaced by the server with the support address (SUPPORT_EMAIL).
const contactToken = '__SUPPORT_EMAIL__';

const _update = bool.fromEnvironment('UPDATE_LEGAL_PAGES');
const _target = '../backend/ai-proxy/src/legal_pages.js';

String _escape(String text) => const HtmlEscape().convert(text);

String renderDocument(LegalDocument doc) {
  final out = StringBuffer()
    ..writeln('<h1>${_escape(doc.title)}</h1>')
    ..writeln('<p class="meta">Last updated: ${_escape(doc.lastUpdated)}</p>')
    ..writeln('<p>${_escape(doc.intro)}</p>');
  for (final section in doc.sections) {
    out.writeln('<h2>${_escape(section.heading)}</h2>');
    for (final p in section.paragraphs) {
      out.writeln('<p>${_escape(p)}</p>');
    }
    if (section.bullets.isNotEmpty) {
      out.writeln('<ul>');
      for (final b in section.bullets) {
        out.writeln('<li>${_escape(b)}</li>');
      }
      out.writeln('</ul>');
    }
  }
  return out.toString();
}

String renderModule() {
  const config = LegalConfig(
    operatorName: 'Saaf',
    contactEmail: contactToken,
    deletionUrl: 'https://saaf-ai.saafai.workers.dev/delete-account',
  );
  final pages = {
    'privacy': renderDocument(LegalDocuments.privacy(config)),
    'terms': renderDocument(LegalDocuments.terms(config)),
  };
  return [
    '// GENERATED from myapp/lib/core/legal/legal_documents.dart by',
    '// myapp/test/tool/legal_web_pages_test.dart. Do not edit by hand.',
    '',
    'export const LEGAL_PAGES = ${const JsonEncoder.withIndent('  ').convert(pages)};',
    '',
  ].join('\n');
}

void main() {
  test('the web pages match the Terms and Privacy Policy in the app', () {
    final module = renderModule();
    final file = File(_target);
    if (_update) {
      file.writeAsStringSync(module);
      return;
    }
    expect(
      file.existsSync() && file.readAsStringSync() == module,
      isTrue,
      reason:
          '$_target is out of date. Run: flutter test '
          'test/tool/legal_web_pages_test.dart '
          '--dart-define=UPDATE_LEGAL_PAGES=true',
    );
  });

  test('the pages are escaped HTML with every section', () {
    final html = renderDocument(
      LegalDocuments.terms(const LegalConfig(operatorName: 'A & B')),
    );
    expect(html, contains('A &amp; B'));
    expect(html, contains('<h2>7. Refunds</h2>'));
    expect(html, isNot(contains('<script')));
  });
}
