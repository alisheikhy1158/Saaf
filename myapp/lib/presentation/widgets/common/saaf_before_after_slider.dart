import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:saaf/core/theme/saaf_tokens_extension.dart';
import 'package:saaf/presentation/widgets/common/saaf_chip.dart';

/// Before / after picture slider (Figma 12): [before] on the start side, [after]
/// on the other, a cornsilk line and a round handle to drag. Works with a finger,
/// arrow keys and screen-reader increase / decrease. [onChanged] gets the
/// divider position, 0 (all after) to 1 (all before).
class SaafBeforeAfterSlider extends StatefulWidget {
  const SaafBeforeAfterSlider({
    required this.before,
    required this.after,
    required this.beforeLabel,
    required this.afterLabel,
    required this.semanticLabel,
    super.key,
    this.onChanged,
  });

  final Widget before;
  final Widget after;
  final String beforeLabel;
  final String afterLabel;

  /// Names the slider for screen readers ("Compare before and after").
  final String semanticLabel;
  final ValueChanged<double>? onChanged;

  @override
  State<SaafBeforeAfterSlider> createState() => _SaafBeforeAfterSliderState();
}

class _SaafBeforeAfterSliderState extends State<SaafBeforeAfterSlider> {
  /// How far each arrow key / screen-reader step moves the divider.
  static const double _step = 0.1;

  double _position = 0.5;

  void _set(double value) {
    final clamped = value.clamp(0.0, 1.0);
    if (clamped == _position) return;
    setState(() => _position = clamped);
    widget.onChanged?.call(clamped);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.saaf;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final handle = tokens.size.compareHandle;

    return Semantics(
      slider: true,
      label: widget.semanticLabel,
      value: '${(_position * 100).round()}%',
      increasedValue: '${((_position + _step).clamp(0.0, 1.0) * 100).round()}%',
      decreasedValue: '${((_position - _step).clamp(0.0, 1.0) * 100).round()}%',
      onIncrease: () => _set(_position + _step),
      onDecrease: () => _set(_position - _step),
      child: SizedBox(
        height: tokens.size.compareHeight,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(tokens.radius.r24),
          child: ColoredBox(
            color: tokens.sageTint,
            child: LayoutBuilder(
              builder: (context, box) {
                final width = box.maxWidth;
                // Distance of the divider from the physical left edge.
                final x = (isRtl ? 1 - _position : _position) * width;

                return Stack(
                  children: [
                    Positioned.fill(child: widget.after),
                    Positioned.fill(
                      child: ClipRect(
                        clipper: _SideClipper(x: x, keepLeft: !isRtl),
                        child: widget.before,
                      ),
                    ),
                    PositionedDirectional(
                      top: tokens.space.x14,
                      start: tokens.space.x14,
                      child: SaafChip(
                        label: widget.beforeLabel,
                        small: true,
                        tone: SaafChipTone.cornsilk,
                      ),
                    ),
                    PositionedDirectional(
                      top: tokens.space.x14,
                      end: tokens.space.x14,
                      child: SaafChip(
                        label: widget.afterLabel,
                        small: true,
                        tone: SaafChipTone.cornsilk,
                      ),
                    ),
                    Positioned(
                      left: x - tokens.size.compareLine / 2,
                      top: 0,
                      bottom: 0,
                      width: tokens.size.compareLine,
                      child: ColoredBox(color: context.colors.surface),
                    ),
                    Positioned(
                      left: x - tokens.size.minTouchTarget / 2,
                      top:
                          (tokens.size.compareHeight -
                              tokens.size.minTouchTarget) /
                          2,
                      width: tokens.size.minTouchTarget,
                      height: tokens.size.minTouchTarget,
                      child: _Handle(
                        size: handle,
                        onDrag: (dx) =>
                            _set(_position + (isRtl ? -dx : dx) / width),
                        onKey: (direction) => _set(
                          _position + (isRtl ? -direction : direction) * _step,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _SideClipper extends CustomClipper<Rect> {
  const _SideClipper({required this.x, required this.keepLeft});

  final double x;
  final bool keepLeft;

  @override
  Rect getClip(Size size) => keepLeft
      ? Rect.fromLTRB(0, 0, x, size.height)
      : Rect.fromLTRB(x, 0, size.width, size.height);

  @override
  bool shouldReclip(_SideClipper old) => old.x != x || old.keepLeft != keepLeft;
}

class _Handle extends StatefulWidget {
  const _Handle({
    required this.size,
    required this.onDrag,
    required this.onKey,
  });

  final double size;
  final ValueChanged<double> onDrag;
  final ValueChanged<int> onKey;

  @override
  State<_Handle> createState() => _HandleState();
}

class _HandleState extends State<_Handle> {
  final FocusNode _focus = FocusNode(debugLabel: 'before-after handle');

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.saaf;
    return Focus(
      focusNode: _focus,
      onKeyEvent: (node, event) {
        if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
          return KeyEventResult.ignored;
        }
        if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
          widget.onKey(1);
          return KeyEventResult.handled;
        }
        if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
          widget.onKey(-1);
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        key: const ValueKey('saaf-compare-hit'),
        behavior: HitTestBehavior.opaque,
        onHorizontalDragUpdate: (d) => widget.onDrag(d.delta.dx),
        onTap: _focus.requestFocus,
        child: Center(
          child: DecoratedBox(
            key: const ValueKey('saaf-compare-handle'),
            decoration: BoxDecoration(
              color: context.colors.surface,
              shape: BoxShape.circle,
            ),
            child: SizedBox.square(
              dimension: widget.size,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chevron_left,
                    size: tokens.size.iconChip,
                    color: context.colors.onSurface,
                    textDirection: TextDirection.ltr,
                  ),
                  Icon(
                    Icons.chevron_right,
                    size: tokens.size.iconChip,
                    color: context.colors.onSurface,
                    textDirection: TextDirection.ltr,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
