// Covers: architecture.md §2 (app.dart is the MaterialApp.router root)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/app.dart';

void main() {
  testWidgets('SaafApp builds a MaterialApp inside a ProviderScope', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: SaafApp()));
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
