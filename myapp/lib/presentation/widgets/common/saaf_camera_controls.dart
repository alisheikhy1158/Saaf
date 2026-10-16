import 'package:flutter/material.dart';
import 'package:saaf/core/theme/saaf_tokens_extension.dart';

/// Figma 06 "Camera controls": a 48 dp gallery button (r14), the 78 dp shutter
/// and a 48 dp flip button (circle). Meant for dark surfaces (cornsilk @ 12 %
/// fills). [onFlip] null hides the flip button but keeps its space, so the
/// shutter stays centred. [onShutter] null disables the shutter.
class SaafCameraControls extends StatelessWidget {
  const SaafCameraControls({
    required this.onGallery,
    required this.onShutter,
    required this.onFlip,
    required this.galleryLabel,
    required this.shutterLabel,
    required this.flipLabel,
    super.key,
  });

  final VoidCallback? onGallery;
  final VoidCallback? onShutter;
  final VoidCallback? onFlip;
  final String galleryLabel;
  final String shutterLabel;
  final String flipLabel;

  /// Lets tests find the shutter whatever the language.
  static const Key shutterKey = ValueKey('saaf-shutter');

  @override
  Widget build(BuildContext context) {
    final tokens = context.saaf;
    return Padding(
      padding: EdgeInsetsDirectional.symmetric(
        horizontal: tokens.space.gutterNarrow,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _ControlButton(
            icon: Icons.image_outlined,
            label: galleryLabel,
            radius: tokens.radius.r14,
            onPressed: onGallery,
          ),
          _Shutter(label: shutterLabel, onPressed: onShutter),
          onFlip == null
              ? SizedBox.square(dimension: tokens.size.cameraControl)
              : _ControlButton(
                  icon: Icons.cameraswitch_outlined,
                  label: flipLabel,
                  radius: tokens.size.cameraControl / 2,
                  onPressed: onFlip,
                ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.label,
    required this.radius,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final double radius;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final tokens = context.saaf;
    return IconButton(
      onPressed: onPressed,
      tooltip: label,
      icon: Icon(icon, size: tokens.size.iconCamera),
      style: IconButton.styleFrom(
        backgroundColor: tokens.controlOnInk,
        foregroundColor: context.colors.onSurface,
        fixedSize: Size.square(tokens.size.cameraControl),
        minimumSize: Size.square(tokens.size.cameraControl),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

class _Shutter extends StatelessWidget {
  const _Shutter({required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final tokens = context.saaf;
    final colour = context.colors.onSurface;
    return Semantics(
      key: SaafCameraControls.shutterKey,
      button: true,
      enabled: onPressed != null,
      label: label,
      excludeSemantics: true,
      onTap: onPressed,
      child: Opacity(
        opacity: onPressed == null ? 0.4 : 1,
        child: InkResponse(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: SizedBox.square(
            dimension: tokens.size.shutter,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: colour,
                  width: tokens.size.shutterRing,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(tokens.size.shutterGap),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colour,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
