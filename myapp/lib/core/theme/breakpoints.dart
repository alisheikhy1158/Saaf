import 'package:saaf/core/theme/tokens.dart';

/// Adaptive layout classes (design.md §7).
enum SaafBreakpoint {
  /// < 600 dp: phones, open flip phones, fold cover screens.
  compact,

  /// 600–839 dp: iPad portrait, unfolded foldables.
  medium,

  /// >= 840 dp: iPad landscape, tablets.
  expanded;

  static const double mediumStart = 600;
  static const double expandedStart = 840;

  /// Figma's 350 dp column scaled up for medium/expanded windows.
  static const double maxContentWidth = 560;

  static const double _narrowPhone = 360;

  static SaafBreakpoint fromWidth(double width) {
    if (width >= expandedStart) return expanded;
    if (width >= mediumStart) return medium;
    return compact;
  }

  /// Page gutter: 20 dp, or 16 dp on screens narrower than 360 dp.
  static double gutterFor(double width) {
    const space = SaafSpace();
    return width < _narrowPhone ? space.gutterNarrow : space.gutter;
  }
}
