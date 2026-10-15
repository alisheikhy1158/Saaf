import 'package:flutter/material.dart';
import 'package:saaf/core/theme/breakpoints.dart';
import 'package:saaf/core/theme/saaf_tokens_extension.dart';

/// One tab of [SaafAdaptiveNav].
@immutable
class SaafNavDestination {
  const SaafNavDestination({
    required this.icon,
    required this.label,
    this.selectedIcon,
  });

  final IconData icon;
  final IconData? selectedIcon;

  /// Screen-reader label and tooltip (the pill shows icons only, as in Figma).
  final String label;
}

/// Navigation that adapts to the window (design.md §7): the floating ink pill
/// from Figma on compact widths, a `NavigationRail` on medium (icons) and
/// expanded (icons + labels). The pill sits below [child] rather than over it
/// so content is never hidden.
class SaafAdaptiveNav extends StatelessWidget {
  const SaafAdaptiveNav({
    required this.destinations,
    required this.selectedIndex,
    required this.onSelected,
    required this.child,
    super.key,
  });

  final List<SaafNavDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final breakpoint = SaafBreakpoint.fromWidth(width);

    // The nav wraps whole screens, so it paints the page background itself
    // (the strip around the pill / rail would otherwise show the host colour).
    return ColoredBox(
      key: const ValueKey('saaf-nav-background'),
      color: context.colors.surface,
      child: breakpoint == SaafBreakpoint.compact
          ? _compact(context, width)
          : _rail(breakpoint),
    );
  }

  Widget _compact(BuildContext context, double width) {
    final space = context.saaf.space;
    return Column(
      children: [
        Expanded(child: child),
        SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsetsDirectional.only(
              start: SaafBreakpoint.gutterFor(width),
              end: SaafBreakpoint.gutterFor(width),
              bottom: space.x16,
            ),
            child: _BottomPill(
              destinations: destinations,
              selectedIndex: selectedIndex,
              onSelected: onSelected,
            ),
          ),
        ),
      ],
    );
  }

  Widget _rail(SaafBreakpoint breakpoint) {
    return Row(
      children: [
        SafeArea(
          right: false,
          child: NavigationRail(
            key: const ValueKey('saaf-nav-rail'),
            selectedIndex: selectedIndex,
            onDestinationSelected: onSelected,
            labelType: breakpoint == SaafBreakpoint.expanded
                ? NavigationRailLabelType.all
                : NavigationRailLabelType.none,
            destinations: [
              for (final d in destinations)
                NavigationRailDestination(
                  icon: Icon(d.icon),
                  selectedIcon: Icon(d.selectedIcon ?? d.icon),
                  label: Text(d.label),
                ),
            ],
          ),
        ),
        Expanded(child: child),
      ],
    );
  }
}

class _BottomPill extends StatelessWidget {
  const _BottomPill({
    required this.destinations,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<SaafNavDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final tokens = context.saaf;
    final colors = context.colors;
    final isDark = colors.brightness == Brightness.dark;

    // The pill is its own Material so ink ripples work even when the nav wraps
    // a whole screen (no Scaffold above it) and paint over the ink fill.
    return Material(
      key: const ValueKey('saaf-bottom-nav'),
      color: colors.inverseSurface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radius.r32),
        side: isDark
            ? BorderSide(color: colors.outline, width: tokens.size.borderThin)
            : BorderSide.none,
      ),
      child: SizedBox(
        height: tokens.size.bottomNav,
        child: Padding(
          padding: EdgeInsetsDirectional.symmetric(
            horizontal: tokens.space.navPaddingH,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var i = 0; i < destinations.length; i++)
                _NavItem(
                  destination: destinations[i],
                  selected: i == selectedIndex,
                  onTap: () => onSelected(i),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final SaafNavDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.saaf;
    final color = selected ? tokens.sage : tokens.onInkSecondary;

    return Tooltip(
      message: destination.label,
      excludeFromSemantics: true,
      child: Semantics(
        button: true,
        selected: selected,
        label: destination.label,
        onTap: onTap,
        excludeSemantics: true,
        child: InkResponse(
          onTap: onTap,
          radius: tokens.size.minTouchTarget / 2,
          child: SizedBox.square(
            dimension: tokens.size.minTouchTarget,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: tokens.space.x4,
              children: [
                Icon(
                  selected
                      ? (destination.selectedIcon ?? destination.icon)
                      : destination.icon,
                  size: tokens.size.keypadIcon,
                  color: color,
                ),
                selected
                    ? SizedBox.square(
                        key: const ValueKey('nav-dot'),
                        dimension: tokens.size.dayDot,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: tokens.sage,
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                    : SizedBox.square(dimension: tokens.size.dayDot),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
