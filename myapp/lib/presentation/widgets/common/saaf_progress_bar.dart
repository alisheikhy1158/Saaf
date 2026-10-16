import 'package:flutter/material.dart';
import 'package:saaf/core/theme/saaf_tokens_extension.dart';

/// Thin progress bar (design.md §6): 6 dp, r3 (8 dp, r4 when [thick], the 07
/// concern bars), sage fill on a faint track
/// (cornsilk @ 15 % when [onInk]). [value] is 0–1 and the fill starts at the
/// reading-direction start (right in RTL).
class SaafProgressBar extends StatelessWidget {
  const SaafProgressBar({
    required this.value,
    super.key,
    this.onInk = false,
    this.thick = false,
  });

  final double value;
  final bool onInk;
  final bool thick;

  @override
  Widget build(BuildContext context) {
    final tokens = context.saaf;
    final clamped = value.clamp(0.0, 1.0);
    final height = thick
        ? tokens.size.progressBarThick
        : tokens.size.progressBar;
    final radius = BorderRadius.circular(
      thick ? tokens.radius.r4 : tokens.radius.r3,
    );

    return Semantics(
      value: '${(clamped * 100).round()}%',
      child: SizedBox(
        height: height,
        child: DecoratedBox(
          key: const ValueKey('saaf-progress-track'),
          decoration: BoxDecoration(
            color: onInk ? tokens.trackOnInk : tokens.borderSubtle,
            borderRadius: radius,
          ),
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: FractionallySizedBox(
              widthFactor: clamped,
              child: DecoratedBox(
                key: const ValueKey('saaf-progress-fill'),
                decoration: BoxDecoration(
                  color: tokens.sage,
                  borderRadius: radius,
                ),
                child: SizedBox(height: height),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
