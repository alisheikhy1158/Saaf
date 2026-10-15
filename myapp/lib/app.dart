import 'package:flutter/material.dart';

/// Root widget. Placeholder until the theme (2.3) and router (2.5) exist.
class SaafApp extends StatelessWidget {
  const SaafApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Saaf',
      home: Scaffold(body: SizedBox.shrink()),
    );
  }
}
