import 'package:flutter/material.dart';
import 'package:saaf/core/theme/breakpoints.dart';
import 'package:saaf/core/theme/saaf_tokens_extension.dart';

/// Screen frame (design.md §6, §7): safe area, 20 dp page gutter (16 dp on
/// narrow screens), content column capped at 560 dp and centred.
///
/// [bottom] (the primary CTA) is pinned 28 dp above the bottom edge when the
/// content fits, and scrolls with the content when it does not. [topBar] stays
/// fixed above the scrolling area; [offlineBanner] spans the full width on top.
/// Wrap in `SaafAdaptiveNav` for tab screens.
class SaafScaffold extends StatelessWidget {
  const SaafScaffold({
    required this.body,
    super.key,
    this.topBar,
    this.bottom,
    this.offlineBanner,
  });

  final Widget body;
  final Widget? topBar;
  final Widget? bottom;
  final Widget? offlineBanner;

  @override
  Widget build(BuildContext context) {
    final space = context.saaf.space;
    final gutter = SaafBreakpoint.gutterFor(MediaQuery.sizeOf(context).width);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ?offlineBanner,
            Expanded(
              child: Align(
                alignment: AlignmentDirectional.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: SaafBreakpoint.maxContentWidth,
                  ),
                  child: Padding(
                    padding: EdgeInsetsDirectional.symmetric(
                      horizontal: gutter,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ?topBar,
                        Expanded(
                          child: CustomScrollView(
                            slivers: [
                              SliverFillRemaining(
                                hasScrollBody: false,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    body,
                                    Expanded(
                                      child: Align(
                                        alignment:
                                            AlignmentDirectional.bottomCenter,
                                        child: Padding(
                                          padding: EdgeInsetsDirectional.only(
                                            top: space.x16,
                                            bottom: space.pageBottom,
                                          ),
                                          child: bottom,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
