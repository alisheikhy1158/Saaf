import 'package:flutter/material.dart';
import 'package:saaf/core/l10n/app_localizations.dart';
import 'package:saaf/core/theme/saaf_tokens_extension.dart';
import 'package:saaf/core/theme/tokens.dart';
import 'package:saaf/presentation/widgets/common/saaf_chip.dart';
import 'package:saaf/presentation/widgets/common/saaf_icon_circle.dart';

/// The 01 Welcome hero (Figma node 2:37): a light-sage card with decorative
/// circles, the wordmark, a "For South Asian skin" chip and an example stat.
/// Scales uniformly with its width (design frame 350 × 372).
class WelcomeHero extends StatelessWidget {
  const WelcomeHero({super.key});

  @override
  Widget build(BuildContext context) {
    const geometry = SaafHeroGeometry();
    final tokens = context.saaf;
    final space = tokens.space;
    final l10n = AppLocalizations.of(context);

    // Figma's 350 × 372 is the height at default text size: the hero is at
    // least that tall (scaled with its width) and grows if the text needs more.
    return LayoutBuilder(
      key: const ValueKey('welcome-hero'),
      builder: (context, constraints) {
        final scale = constraints.maxWidth / geometry.designWidth;
        return ClipRRect(
          borderRadius: BorderRadius.circular(tokens.radius.r32),
          child: ColoredBox(
            color: context.colors.primaryContainer,
            child: Stack(
              children: [
                Positioned.fill(
                  child: ExcludeSemantics(
                    child: _HeroArt(geometry: geometry, scale: scale),
                  ),
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: geometry.designHeight * scale,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: EdgeInsetsDirectional.only(
                            start: space.x24,
                            end: space.x16,
                            top: space.x20,
                          ),
                          child: Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: space.x8,
                            runSpacing: space.x8,
                            children: [
                              Text(l10n.appName, style: tokens.styles.wordmark),
                              SaafChip(
                                label: l10n.welcomeChip,
                                tone: SaafChipTone.papaya,
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Align(
                            alignment: AlignmentDirectional.bottomStart,
                            child: Padding(
                              padding: EdgeInsetsDirectional.all(space.x20),
                              child: const _StatCard(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// The decorative circles, oval and glow, positioned from the design frame.
class _HeroArt extends StatelessWidget {
  const _HeroArt({required this.geometry, required this.scale});

  final SaafHeroGeometry geometry;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final size = context.saaf.size;
    final g = geometry;

    Widget circle(double left, double top, double diameter, Color color) =>
        Positioned(
          left: left * scale,
          top: top * scale,
          width: diameter * scale,
          height: diameter * scale,
          child: DecoratedBox(
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        circle(
          g.bigCircleLeft,
          g.bigCircleTop,
          g.bigCircleSize,
          colors.surface.withValues(alpha: SaafAlpha.heroLightCircle),
        ),
        circle(
          g.cornerCircleLeft,
          g.cornerCircleTop,
          g.cornerCircleSize,
          colors.onSurface.withValues(alpha: SaafAlpha.heroInkCircle),
        ),
        Positioned(
          left: g.ovalLeft * scale,
          top: g.ovalTop * scale,
          width: g.ovalWidth * scale,
          height: g.ovalHeight * scale,
          child: CustomPaint(
            painter: _OvalPainter(
              fill: colors.surface.withValues(alpha: SaafAlpha.heroOvalFill),
              stroke: colors.surface.withValues(
                alpha: SaafAlpha.heroOvalStroke,
              ),
              strokeWidth: size.borderFocus,
            ),
          ),
        ),
        Positioned(
          left: g.glowLeft * scale,
          top: g.glowTop * scale,
          width: g.glowWidth * scale,
          height: g.glowHeight * scale,
          child: Image.asset(
            'assets/images/welcome_hero_glow.png',
            fit: BoxFit.fill,
          ),
        ),
      ],
    );
  }
}

class _OvalPainter extends CustomPainter {
  const _OvalPainter({
    required this.fill,
    required this.stroke,
    required this.strokeWidth,
  });

  final Color fill;
  final Color stroke;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawOval(rect, Paint()..color = fill);
    // Figma strokes the ellipse inside its edge.
    canvas.drawOval(
      rect.deflate(strokeWidth / 2),
      Paint()
        ..color = stroke
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );
  }

  @override
  bool shouldRepaint(_OvalPainter old) =>
      old.fill != fill ||
      old.stroke != stroke ||
      old.strokeWidth != strokeWidth;
}

/// "Example: dark spots / −32% in 8 weeks". Labelled as an example because
/// the claim is not yet backed by real data (design.md §9.5).
class _StatCard extends StatelessWidget {
  const _StatCard();

  @override
  Widget build(BuildContext context) {
    final tokens = context.saaf;
    final space = tokens.space;
    final l10n = AppLocalizations.of(context);

    return MergeSemantics(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(tokens.radius.r18),
          border: Border.all(
            color: tokens.borderSubtle,
            width: tokens.size.borderThin,
          ),
        ),
        child: Padding(
          padding: EdgeInsetsDirectional.only(
            start: space.x12,
            end: space.x18,
            top: space.x12,
            bottom: space.x12,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: space.x12,
            children: [
              const SaafIconCircle(
                icon: Icons.trending_up,
                size: SaafIconCircleSize.welcome,
                tone: SaafIconCircleTone.tan,
              ),
              Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.welcomeStatCaption,
                      style: context.text.bodySmall,
                    ),
                    Text(l10n.welcomeStatValue, style: tokens.styles.listTitle),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
