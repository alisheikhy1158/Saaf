import 'package:flutter/material.dart';
import 'package:saaf/core/router/saaf_route.dart';
import 'package:saaf/presentation/widgets/common/screen_placeholder.dart';

/// Figma screen `signUp` — placeholder until this screen is built.
class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ScreenPlaceholder(route: SaafRoute.signUp);
  }
}
