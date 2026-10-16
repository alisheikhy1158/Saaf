import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:saaf/core/l10n/app_localizations.dart';
import 'package:saaf/core/router/saaf_route.dart';
import 'package:saaf/presentation/widgets/common/saaf_adaptive_nav.dart';

/// The four main tabs of the app, in navigation order.
enum SaafMainTab {
  home(SaafRoute.home, Icons.home_outlined),
  scan(SaafRoute.selfieCapture, Icons.crop_free),
  progress(SaafRoute.monthlyProgress, Icons.trending_up),
  profile(SaafRoute.profile, Icons.person_outline);

  const SaafMainTab(this.route, this.icon);

  final SaafRoute route;
  final IconData icon;
}

/// The app's bottom pill / navigation rail with Home, Scan, Progress and
/// Profile, wrapped around a tab screen. Picking another tab replaces the
/// screen (the tabs are siblings, not a stack).
class SaafMainNav extends StatelessWidget {
  const SaafMainNav({required this.current, required this.child, super.key});

  final SaafMainTab current;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final labels = {
      SaafMainTab.home: l10n.navHome,
      SaafMainTab.scan: l10n.navScan,
      SaafMainTab.progress: l10n.navProgress,
      SaafMainTab.profile: l10n.navProfile,
    };

    return SaafAdaptiveNav(
      destinations: [
        for (final tab in SaafMainTab.values)
          SaafNavDestination(icon: tab.icon, label: labels[tab]!),
      ],
      selectedIndex: current.index,
      onSelected: (index) {
        final tab = SaafMainTab.values[index];
        if (tab != current) context.go(tab.route.path);
      },
      child: child,
    );
  }
}
