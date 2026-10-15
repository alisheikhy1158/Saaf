import 'package:flutter/material.dart';
import 'package:saaf/core/theme/saaf_tokens_extension.dart';

/// One option of a [SaafSegmentedControl]. The optional [icon] is shown only
/// while the segment is selected (Figma 01: globe next to "English").
@immutable
class SaafSegment {
  const SaafSegment({required this.label, this.icon});

  final String label;
  final IconData? icon;
}

/// Segmented control (design.md §6): ink@4 % track (r26, padding 4, gap 4),
/// equal-width segments (r22, 12×10), selected = sage fill + ink text.
///
/// The drawn control is 46 dp tall like Figma; the tappable row behind it is
/// 48 dp tall so hit areas meet §9.1.
class SaafSegmentedControl extends StatelessWidget {
  const SaafSegmentedControl({
    required this.segments,
    required this.selectedIndex,
    required this.onChanged,
    required this.semanticLabel,
    super.key,
  });

  final List<SaafSegment> segments;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  /// Names the group for screen readers (e.g. "Language").
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final tokens = context.saaf;
    final space = tokens.space;

    final visual = DecoratedBox(
      key: const ValueKey('saaf-segmented-track'),
      decoration: BoxDecoration(
        color: tokens.trackSegmented,
        borderRadius: BorderRadius.circular(tokens.radius.r26),
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.all(space.x4),
        child: Row(
          spacing: space.x4,
          children: [
            for (var i = 0; i < segments.length; i++)
              Expanded(
                child: _SegmentVisual(
                  key: ValueKey('saaf-segment-$i'),
                  segment: segments[i],
                  selected: i == selectedIndex,
                ),
              ),
          ],
        ),
      ),
    );

    return Semantics(
      container: true,
      label: semanticLabel,
      child: Stack(
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(minHeight: tokens.size.minTouchTarget),
            child: Center(child: ExcludeSemantics(child: visual)),
          ),
          Positioned.fill(
            child: Padding(
              padding: EdgeInsetsDirectional.symmetric(horizontal: space.x4),
              child: Row(
                spacing: space.x4,
                children: [
                  for (var i = 0; i < segments.length; i++)
                    Expanded(
                      child: Semantics(
                        button: true,
                        selected: i == selectedIndex,
                        label: segments[i].label,
                        onTap: () => onChanged(i),
                        excludeSemantics: true,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => onChanged(i),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentVisual extends StatelessWidget {
  const _SegmentVisual({
    required this.segment,
    required this.selected,
    super.key,
  });

  final SaafSegment segment;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final tokens = context.saaf;
    final colors = context.colors;
    final color = selected ? colors.onPrimary : tokens.textSecondary;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: selected ? colors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(tokens.radius.r22),
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.symmetric(
          horizontal: tokens.space.x12,
          vertical: tokens.space.x10,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: tokens.space.x6,
          children: [
            if (selected && segment.icon != null)
              Icon(segment.icon, size: tokens.size.iconSmall, color: color),
            Flexible(
              child: Text(
                segment.label,
                textAlign: TextAlign.center,
                style: tokens.styles.segment.copyWith(color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
