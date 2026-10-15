import 'package:flutter/material.dart';
import 'package:saaf/core/router/saaf_route.dart';
import 'package:saaf/core/theme/saaf_tokens_extension.dart';

/// Stand-in for a Figma screen that has not been built yet (dev builds only).
/// Each feature screen replaces its use of this widget when it is implemented.
class ScreenPlaceholder extends StatelessWidget {
  const ScreenPlaceholder({required this.route, super.key});

  final SaafRoute route;

  @override
  Widget build(BuildContext context) {
    final number = route.number.toString().padLeft(2, '0');
    return Scaffold(
      key: ValueKey('screen-${route.name}'),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsetsDirectional.symmetric(
              horizontal: context.saaf.space.gutter,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: context.saaf.space.x8,
              children: [
                Text(number, style: context.text.labelSmall),
                Text(
                  route.title,
                  style: context.text.headlineMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
