import 'package:flutter/material.dart';
import 'package:saaf/core/router/saaf_route.dart';
import 'package:saaf/core/theme/saaf_theme.dart';
import 'package:saaf/core/theme/saaf_tokens_extension.dart';
import 'package:saaf/presentation/widgets/common/saaf_adaptive_nav.dart';
import 'package:saaf/presentation/widgets/common/saaf_button.dart';
import 'package:saaf/presentation/widgets/common/saaf_card.dart';
import 'package:saaf/presentation/widgets/common/saaf_chip.dart';
import 'package:saaf/presentation/widgets/common/saaf_icon_button.dart';
import 'package:saaf/presentation/widgets/common/saaf_scaffold.dart';
import 'package:saaf/presentation/widgets/common/saaf_text_field.dart';

/// Dev-only (debug builds) page showing every common widget, with switches for
/// dark mode and RTL, to compare against Figma in Chrome. English literals are
/// fine here: the route does not exist in release builds.
class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  // Purely visual dev-tool state, so setState is allowed here (architecture §3).
  bool _dark = false;
  bool _rtl = false;
  int _navIndex = 0;

  static const _destinations = [
    SaafNavDestination(icon: Icons.home_outlined, label: 'Home'),
    SaafNavDestination(icon: Icons.photo_camera_outlined, label: 'Scan'),
    SaafNavDestination(icon: Icons.show_chart, label: 'Progress'),
    SaafNavDestination(icon: Icons.person_outline, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _dark ? SaafTheme.dark() : SaafTheme.light(),
      child: Directionality(
        textDirection: _rtl ? TextDirection.rtl : TextDirection.ltr,
        child: SaafAdaptiveNav(
          destinations: _destinations,
          selectedIndex: _navIndex,
          onSelected: (i) => setState(() => _navIndex = i),
          child: SaafScaffold(
            key: ValueKey('screen-${SaafRoute.gallery.name}'),
            body: _GalleryContent(
              dark: _dark,
              rtl: _rtl,
              onDark: (v) => setState(() => _dark = v),
              onRtl: (v) => setState(() => _rtl = v),
            ),
          ),
        ),
      ),
    );
  }
}

class _GalleryContent extends StatelessWidget {
  const _GalleryContent({
    required this.dark,
    required this.rtl,
    required this.onDark,
    required this.onRtl,
  });

  final bool dark;
  final bool rtl;
  final ValueChanged<bool> onDark;
  final ValueChanged<bool> onRtl;

  @override
  Widget build(BuildContext context) {
    final space = context.saaf.space;
    return Column(
      key: const ValueKey('gallery-content'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: space.sectionGapLarge,
      children: [
        Padding(
          padding: EdgeInsetsDirectional.only(top: space.x16),
          child: Text('Gallery', style: context.text.headlineMedium),
        ),
        _Section(
          title: 'Preview',
          children: [
            _SwitchRow(
              switchKey: const ValueKey('gallery-dark'),
              label: 'Dark mode',
              value: dark,
              onChanged: onDark,
            ),
            _SwitchRow(
              switchKey: const ValueKey('gallery-rtl'),
              label: 'Right-to-left (Urdu)',
              value: rtl,
              onChanged: onRtl,
            ),
          ],
        ),
        _Section(
          title: 'Typography (Nunito 400 / 700 / 800, Noto Naskh)',
          children: [
            Text('Clear skin, made simple.', style: context.text.headlineSmall),
            Text('Routine step title', style: context.saaf.styles.rowTitle),
            Text(
              'Subtitle text in regular weight.',
              style: context.text.bodyLarge,
            ),
            Text('صاف جلد، آسان انداز میں۔', style: context.text.titleLarge),
          ],
        ),
        _Section(
          title: 'SaafButton',
          children: [
            SaafButton.primary(
              label: 'Continue',
              trailingIcon: Icons.arrow_forward,
              onPressed: () {},
            ),
            SaafButton.primary(
              label: 'Saving',
              isLoading: true,
              onPressed: () {},
            ),
            const SaafButton.primary(label: 'Disabled', onPressed: null),
            SaafButton.outline(
              label: 'Continue with Google',
              leadingIcon: Icons.g_mobiledata,
              onPressed: () {},
            ),
            SaafButton.text(label: 'Skip', onPressed: () {}),
          ],
        ),
        _Section(
          title: 'SaafIconButton',
          children: [
            Row(
              spacing: space.x16,
              children: [
                SaafIconButton(
                  icon: Icons.arrow_back,
                  tooltip: 'Back',
                  onPressed: () {},
                ),
                SaafIconButton(
                  icon: Icons.notifications_none,
                  tooltip: 'Notifications',
                  onPressed: () {},
                ),
                ColoredBox(
                  color: context.colors.inverseSurface,
                  child: Padding(
                    padding: EdgeInsetsDirectional.all(space.x8),
                    child: SaafIconButton(
                      icon: Icons.close,
                      tooltip: 'Close',
                      onDark: true,
                      onPressed: () {},
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        _Section(
          title: 'SaafChip',
          children: [
            Wrap(
              spacing: space.x8,
              runSpacing: space.x8,
              children: const [
                SaafChip(label: 'Sage'),
                SaafChip(
                  label: 'For South Asian skin',
                  tone: SaafChipTone.papaya,
                ),
                SaafChip(label: 'Saaf Pro', tone: SaafChipTone.ink),
                SaafChip(label: 'Cornsilk', tone: SaafChipTone.cornsilk),
                SaafChip(
                  label: 'Good match',
                  icon: Icons.check,
                  tone: SaafChipTone.sage,
                ),
                SaafChip(
                  label: 'Save 44%',
                  small: true,
                  tone: SaafChipTone.sageTint,
                ),
              ],
            ),
          ],
        ),
        _Section(
          title: 'SaafCard',
          children: [
            const SaafCard(
              child: Text('A plain card with the Figma hairline.'),
            ),
            SaafCard(
              onTap: () {},
              semanticLabel: 'Tappable card',
              child: const Text('A tappable card.'),
            ),
          ],
        ),
        const _Section(
          title: 'SaafTextField',
          children: [
            SaafTextField(label: 'Mobile number', hintText: '300 1234567'),
            SaafTextField(
              label: 'Mobile number',
              prefixText: '+92',
              hintText: '300 1234567',
              keyboardType: TextInputType.phone,
              isValid: true,
              helperText: "We'll text you a code",
              helperIcon: Icons.lock_outline,
            ),
            SaafTextField(
              label: 'Mobile number',
              prefixText: '+92',
              errorText: 'Enter a valid mobile number',
            ),
          ],
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: context.saaf.space.x12,
      children: [
        Text(title.toUpperCase(), style: context.text.labelSmall),
        ...children,
      ],
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.switchKey,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final Key switchKey;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label, style: context.text.bodyLarge)),
        Switch.adaptive(key: switchKey, value: value, onChanged: onChanged),
      ],
    );
  }
}
