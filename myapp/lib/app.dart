import 'package:flutter/material.dart';
import 'package:saaf/core/theme/saaf_theme.dart';

/// Root widget. Router and localisation are added in 2.5.
class SaafApp extends StatelessWidget {
  const SaafApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Saaf',
      theme: SaafTheme.light(),
      darkTheme: SaafTheme.dark(),
      highContrastTheme: SaafTheme.highContrastLight(),
      highContrastDarkTheme: SaafTheme.highContrastDark(),
      themeMode: ThemeMode.system,
      home: const Scaffold(body: SizedBox.shrink()),
    );
  }
}
