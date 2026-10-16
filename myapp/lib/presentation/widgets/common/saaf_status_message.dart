import 'package:flutter/material.dart';
import 'package:saaf/core/theme/saaf_tokens_extension.dart';
import 'package:saaf/presentation/widgets/common/saaf_button.dart';
import 'package:saaf/presentation/widgets/common/saaf_icon_circle.dart';

/// An empty or error state (design.md §9.6): a big icon, a title, optional
/// explanation and exactly one way forward.
class SaafStatusMessage extends StatelessWidget {
  const SaafStatusMessage({
    required this.icon,
    required this.title,
    required this.actionLabel,
    required this.onAction,
    super.key,
    this.body,
  });

  final IconData icon;
  final String title;
  final String? body;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final tokens = context.saaf;
    return Padding(
      padding: EdgeInsetsDirectional.only(top: tokens.space.x36),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: tokens.space.x12,
        children: [
          Center(
            child: SaafIconCircle(icon: icon, size: SaafIconCircleSize.large),
          ),
          Semantics(
            header: true,
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: context.text.titleLarge,
            ),
          ),
          if (body != null)
            Text(
              body!,
              textAlign: TextAlign.center,
              style: context.text.bodyMedium?.copyWith(color: tokens.textLabel),
            ),
          SizedBox(height: tokens.space.x8),
          SaafButton.primary(label: actionLabel, onPressed: onAction),
        ],
      ),
    );
  }
}
