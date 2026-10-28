# Design System — Saaf (UI/UX rules)

> Source of truth: Figma file **"Saaf"** — https://www.figma.com/design/cEIPg8dDgUiw9QZQra6r5L
> (Page 1, 14 screens, 390 × 844 frames). Every value in this file was extracted from the Figma screens.
> Read this file AND `store-compliance.md` before writing UI code.

## 0. Precedence rule (owner's decision, 2026-10-15)

1. **The Figma screens win.** If this doc, a generic guideline (8-pt grid, Material defaults, "best practice"), or
   your own taste conflicts with what the Figma screens show, build what the screens show.
2. The Figma header strip ("Paper White #FAFAF7 / Ink Black #141414 / Mehndi Clay #B84F27") is a stale label —
   ignore it. The colours actually used on the 14 screens (below) are the truth.
3. The prototype is a prototype. Things it does not show but the app legally/technically needs (Restore purchases,
   Sign in with Apple, real data, empty/error states, dark mode, tablet layouts, 48 dp hit areas…) are **added** using the
   Figma tokens and component styles so they look native to the design — see §9 "Build-time additions".
   Additions never restyle or remove what Figma shows.
4. If Figma is ambiguous or silent and §9 doesn't cover it, ask the owner.

---

## 1. Theme architecture (STRICT)

**Rule T-1: ALL colours, text styles, spacing, radii and sizes come from `ThemeData` (`ColorScheme`, `TextTheme`) or our
`ThemeExtension` `SaafTokens`. No hardcoded hex codes (`Color(0xFF...)`), no `Colors.*` (except `Colors.transparent`),
no literal `TextStyle(fontSize: …)`, no numeric literals in `EdgeInsets`/`SizedBox`/`BorderRadius` inside UI widgets.**

- Raw Figma values exist in exactly ONE file: `lib/core/theme/tokens.dart`.
- `lib/core/theme/saaf_theme.dart` builds `ThemeData light()`, `dark()` and `highContrastLight()/highContrastDark()`
  (`useMaterial3: true`).
- `lib/core/theme/saaf_tokens_extension.dart`: `SaafTokens extends ThemeExtension<SaafTokens>` — brand colours with no
  `ColorScheme` slot, the ink-opacity text ladder, spacing, radii, sizes, motion. Implements `copyWith` + `lerp`.
- Access through one extension:
  ```dart
  extension SaafContext on BuildContext {
    ColorScheme get colors => Theme.of(this).colorScheme;
    TextTheme get text => Theme.of(this).textTheme;
    SaafTokens get saaf => Theme.of(this).extension<SaafTokens>()!;
  }
  // usage
  Padding(padding: EdgeInsetsDirectional.symmetric(horizontal: context.saaf.space.gutter), ...)
  ```
- Component defaults (buttons, inputs, chips, cards, checkbox, dialogs, sheets) are set ONCE in `ThemeData`, so screens
  rarely pass styles.
- Enforced by `test/architecture/no_hardcoded_values_test.dart` (test-strategy.md §5).

## 2. Colour

### 2.1 Palette (from the screens)

| Token (`tokens.dart`) | Hex | Name | Where in Figma |
|---|---|---|---|
| `cornsilk` | `#FEFAE0` | background | every light screen bg, cards, plan tiles |
| `ink` | `#3D3120` | primary text / dark surfaces | all text, ink cards, bottom nav, today pill, 06 camera bg |
| `sage` | `#CCD5AE` | primary accent | primary buttons, selected segment, checks, progress fill, avatar, Saaf Pro chip |
| `lightSage` | `#E9EDC9` | soft accent | 01 hero card |
| `papaya` | `#FAEDCD` | warm accent | "For South Asian skin" chip, 10 product page background |
| `tan` | `#D4A373` | highlight | 01 trend icon circle |

### 2.2 Ink-opacity ladder (Figma uses ink/cornsilk with alpha, not grey hex codes)

| SaafTokens name | On light (ink @ α) | On ink / dark (cornsilk @ α) | Figma usage |
|---|---|---|---|
| `textPrimary` | ink 1.0 | cornsilk 1.0 | titles, list titles, buttons |
| `textLabel` | ink 0.70 | cornsilk 0.70 | field label "Mobile number"; 06 helper text |
| `textSecondary` | ink 0.60 | cornsilk 0.60 | subtitles under titles, unselected segment, ink-card captions |
| `textCaption` | ink 0.55 | — | list subtitles, dates, helper text, plan sub-lines |
| `textMeta` | ink 0.50 | cornsilk 0.50 | settings values, legal text, "or", day letters |
| `textOverline` | ink 0.45 | — | "ROUTINE", "PRIVACY" |
| `checkBorder` | ink 0.25 | — | unchecked circle checks |
| `divider` / `trackOnInk` | ink 0.15 | cornsilk 0.15 | phone-field divider, progress track on ink card |
| `borderStrong` | ink 0.14 | — | OTP boxes |
| `borderControl` | ink 0.12 | cornsilk 0.12 (fill) | icon buttons, monthly plan tile; 06 icon-button & chip fill |
| `borderOption` | ink 0.10 | — | quiz options, "or" divider |
| `borderCard` | ink 0.09 | — | list groups (09 checklist, 14 settings), week-strip days |
| `borderSubtle` | ink 0.08 | — | 01 stat card, quiz progress track |
| `rowDivider` | ink 0.07 | — | dividers between list rows |
| `trackSegmented` | ink 0.04 | cornsilk 0.05 | segmented control track; 06 viewfinder |
| `sageTint` | sage 0.10 | — | inactive icon circles, "Save 44%" chip |
| `papayaTint` | papaya 0.10 | — | product thumbnail background |
| `borderFocus` | ink 1.0, 1.5 dp | — | focused input, current OTP box, selected option (1.5), selected plan (2) |

### 2.3 ColorScheme mapping

| ColorScheme role | Light | Dark (derived from Figma 06 dark screen) |
|---|---|---|
| `surface` | cornsilk | ink `#3D3120` |
| `onSurface` | ink | cornsilk |
| `onSurfaceVariant` | ink @ 0.60 | cornsilk @ 0.70 |
| `primary` / `onPrimary` | sage / ink | sage / ink |
| `primaryContainer` / `onPrimaryContainer` | lightSage / ink | cornsilk @ 0.12 / cornsilk |
| `secondaryContainer` / `onSecondaryContainer` | papaya / ink | papaya / ink |
| `tertiary` / `onTertiary` | tan / ink | tan / ink |
| `inverseSurface` / `onInverseSurface` (ink cards, nav, selected day) | ink / cornsilk | cornsilk @ 0.08 + 1 dp cornsilk @ 0.12 border / cornsilk |
| `surfaceContainer` (list groups, plans) | cornsilk + `borderCard` | cornsilk @ 0.05 + cornsilk @ 0.12 border |
| `outline` / `outlineVariant` | ink @ 0.12 / ink @ 0.07 | cornsilk @ 0.12 / cornsilk @ 0.07 |
| `error` / `onError` | not in Figma — add `#B3261E` / cornsilk (§9) | `#F2B8B5` / ink |

**No dark mode** (owner's decision, 2026-10-29): the app is always light (`ThemeMode.light`), whatever the phone uses,
and Profile has no Appearance setting. Only the camera screens are dark, by design (06 Selfie-capture: ink background,
cornsilk text with the same alpha ladder, sage accent), through `SaafDarkScope` and `SaafTheme.dark()`.

### 2.4 Contrast note
Figma's lighter text (`textCaption` 0.55 ≈ 3.9:1, `textMeta` 0.50, `textOverline` 0.45) is below WCAG AA 4.5:1 for small
text. **We keep the Figma values** in the default theme. When the OS requests more contrast
(`MediaQuery.highContrastOf(context)` — iOS "Increase Contrast", Android high-contrast text), switch to
`highContrastLight/Dark()`, where every ladder step below 0.70 becomes 0.70 (≈ 5.6:1). Nothing else changes.

## 3. Typography

Font: **Nunito** (confirmed in Figma — weights used: Regular 400, Bold 700, ExtraBold 800). Bundle the `.ttf` files in
`assets/fonts/` (no runtime font download). Urdu: `fontFamilyFallback: ['NotoNaskhArabic']` (bundled) because Nunito has no
Urdu glyphs.

| Style token (TextTheme role) | Size / line height | Weight | Figma usage |
|---|---|---|---|
| `display` (`displaySmall`) | 46 / 48 | 800 | 01 "Clear skin, made simple." |
| `headlineLarge` | 34 / 44 | 800 | 02, 03, 13 screen titles |
| `screenTitle` (SaafTokens) | 32 / 42 | 800 | 04 "Your photos stay / on your phone" (Figma node 2:227; was wrongly listed as 34/44) |
| `headlineMedium` | 30 / 40 | 800 | 14 "Profile", 07/08 titles; 01 "Saaf" wordmark (30 / 33) |
| `headlineSmall` | 29 / 38 | 800 | 09 "Salam, Ayesha", 05 quiz question |
| `avatarInitial` (SaafTokens) | 27 / 34 | 800 | 14 avatar |
| `titleLarge` | 24 / 32 | 800 | 09 "2 of 4 steps done" |
| `ringValue` (SaafTokens) | 21 / 24 | 800 | 09 "50%" (07 score is larger — read from Figma when building 07) |
| `otpDigit` / `keypadKey` (SaafTokens) | 22 / 1.4 · 24 / 24 | 800 · 700 | 03 |
| `titleMedium` | 18 / 24 | 800 | 14 name |
| `sectionTitle` (`titleSmall`) | 17 / 1.4 (≈24) | 800 | "Today's routine", "Concerns", plan prices |
| `button` (`labelLarge`) | 16 / 20 | 800 | all buttons, plan names, top-bar title (16 / 1.4) |
| `inputText` (`bodyLarge`) | 16 / 1.4 | 700 (number) · 800 (+92 prefix) | 02 phone field |
| `listTitle` (`titleSmall` variant) | 15 / 20 | 800 | routine/checklist/option titles, ink-card titles |
| `rowTitle` (`bodyMedium` strong) | 15 / 20 | 700 | settings rows, paywall benefits |
| `subtitle` (`bodyLarge` variant) | 15 / 22 | 400 | subtitles under screen titles |
| `body` (`bodyMedium`) | 14 / 1.4 | 400 | 05 helper line, 06 status text |
| `segment` / `skip` | 14 / 18 · 14 / 1.4 | 800 | segmented control, "Skip" |
| `chip` (`labelMedium`) | 13 / 18 | 800 | all pill chips |
| `fieldLabel` | 13 / 1.4 | 800 @ `textLabel` | "Mobile number" |
| `meta` (`bodySmall` large) | 13 / 1.4 | 400 | dates, settings values, resend timer |
| `caption` (`bodySmall`) | 12 / 16 | 400 | list subtitles, plan sub-lines |
| `legal` | 12 / 18, centered | 400 @ `textMeta` | terms lines (02, 13) |
| `overline` (`labelSmall`) | 12 / 1.4, letterSpacing 0.96 (8 %), UPPERCASE | 800 | "STEP 2 OF 5", "ROUTINE", "SCAN · 15 OCT 2026" |
| `micro` | 11 / 14 | 800 | week-strip day letters, "Save 44%" |

The status bar ("9:41", 15 / 800) in the mockups is a device mock — use the real system status bar.
Never set `maxLines: 1` on titles without `overflow: TextOverflow.ellipsis` and a 200 % text-scale check.

## 4. Spacing, radii & sizes (Figma scale)

**Rule G-1 (replaces the earlier 8-point-grid rule): use only values on the Figma scale below, through tokens.**
No arbitrary numbers. For new elements not in Figma, pick from this scale, preferring 8 / 16 / 24.

```dart
// SaafTokens.space — every value that appears in the Figma screens
x2 = 2, x4 = 4, x6 = 6, x8 = 8, x10 = 10, x12 = 12, x14 = 14, x16 = 16,
x18 = 18, x20 = 20, x22 = 22, x24 = 24, x28 = 28, x36 = 36
// semantic aliases (what screens should use)
gutter = 20            // page left/right padding (compact phones)
pageBottom = 28        // bottom padding under the last CTA
topBarTop = 4, topBarBottom = 12
titleToSubtitle = 10   // (8 on 03, 6 on 05 — follow the screen)
sectionGap = 20–24     // follow the screen: 20, 22 or 24
inkCardPadding = 20, groupPaddingH = 16, settingsGroupPaddingV = 2, checklistPaddingV = 4
rowPaddingV = 12 (checklist) / 14 (settings), rowGap = 12, optionPadding = 14, optionGap = 10
planPadding = EdgeInsets.symmetric(h: 18, v: 16), benefitGap = 14
chipPadding = EdgeInsets.symmetric(h: 14, v: 8), chipIconGap = 6, smallChipPadding = (h: 10, v: 4)
buttonPadding = EdgeInsets.symmetric(h: 24, v: 18)   // → 56 dp tall
navPaddingH = 36

// SaafTokens.radius
r3 = 3 (progress bars), r12 = 12 (thumbnails, 24-dp checks), r14 = 14 (inputs, OTP boxes, gallery button),
r18 = 18 (chips, quiz options, 01 stat card), r20 = 20 (settings groups, plans, Pro promo),
r22 = 22 (09 checklist group, week-strip days, segments), r24 = 24 (ink progress card),
r26 = 26 (segmented track), r28 = 28 (buttons, viewfinder), r32 = 32 (01 hero, bottom nav),
circle = half the size (icon buttons, icon circles, avatar, checks)

// SaafTokens.size
button = 56, input = 56, otpBox = 50 × 58, iconButton = 40, iconButtonOnDark = 40,
iconCircle = 40 (05) / 36 (13) / 38 (01) / 64 (04), avatar = 64, thumbnail = 48,
check = 26 (09) / 24 (05, 13) / 22 (02), day = 44 × 68, dayDot = 5,
bottomNav = 64 (floating, full width minus gutters), shutter = 78, cameraControl = 48,
icon = 20, iconSmall = 16 (chevrons, segment globe), iconChip = 14, iconCamera = 22, keypadIcon = 24,
progressBar = 6 high, borderThin = 1, borderFocus = 1.5, borderSelectedPlan = 2
minTouchTarget = 48   // hit area, see §9.1 — NOT a visual size
```

Prefer `Column(spacing: …)` / `Row(spacing: …)` or `SizedBox(height: context.saaf.space.x16)` — never `SizedBox(height: 16)`.
Fixed heights from Figma (e.g. 144 dp score card, 118 dp progress card) are **content heights at default text size**:
build them with padding + content, not a fixed `height`, so 200 % text scale still fits.

## 5. Platform adaptation

**Decision: one unified Material 3 implementation styled exactly like Figma on both platforms.** The mockups are a
single custom brand language, not stock iOS or Android. We do NOT render Cupertino widgets via `Platform.isIOS` — that
duplicates screens, and `dart:io`'s `Platform` throws on web (our dev target).

Platform-specific *behaviour* only (via `defaultTargetPlatform` / `Theme.of(context).platform`, in `core/platform/`):
- Page transitions: `CupertinoPageTransitionsBuilder` on iOS (swipe-back), default on Android; keep Android predictive back.
- `.adaptive` where the visual isn't specified by Figma: `Switch.adaptive`, `showAdaptiveDialog`, `CircularProgressIndicator.adaptive`.
- Reminder time picker: Cupertino wheel in a bottom sheet on iOS, Material time picker on Android.
- Haptics: `HapticFeedback.selectionClick()` on selection.
- Store-specific copy & buttons (Sign in with Apple, cancellation text) — see §9 and store-compliance.md.
- Scroll physics stay platform default.

## 6. Component reusability

**Rule C-1: Repeated UI is extracted into `lib/presentation/widgets/common/` — never rewritten per screen.** If a pattern
appears on 2+ screens and isn't here, extract it and add it to this table.

| Widget | Figma component | Exact spec |
|---|---|---|
| `SaafScaffold` | screen frame | cornsilk bg, gutter 20, bottom 28, SafeArea, max content width, nav slot, offline banner |
| `SaafTopBar` | "Top bar" / "Quiz top" | 40-dp icon buttons left/right (empty 40-dp slot keeps title centred), title 16/800, pad top 4 bottom 12; quiz variant has progress bar (6 high, r3, track ink@0.08, fill sage) + "Skip" |
| `SaafIconButton` | "icon-btn" | 40 circle, 1 dp ink@0.12 border, 20-dp icon; on dark: fill cornsilk@0.12, no border; hit area 48; `tooltip` required |
| `SaafButton.primary` | Button/primary | sage fill, ink text 16/20/800, padding 24×18 (56 tall), r28, optional trailing 20-dp arrow, gap 8 |
| `SaafButton.outline` | Button/outline | transparent, 1.5 dp ink border, same text/padding/radius, optional leading icon |
| `SaafButton.text` | Button/text | no fill/border, padding 24×10, text 16/20/800 |
| `SaafChip` | "Chip" | pill r18, padding 14×8, optional 14-dp icon gap 6, text 13/18/800; fills: sage / papaya / ink (cornsilk text) / cornsilk / cornsilk@0.12 on dark / sageTint small variant (10×4, 11/14) |
| `SaafSegmentedControl` | "Segmented" | track ink@0.04, r26, padding 4, gap 4; segment r22, padding 12×10, text 14/18/800; selected = sage + ink text (+16-dp icon); unselected text ink@0.6 |
| `SaafPhoneField` / `SaafTextField` | Input/phone | label 13/800 @0.7 above (gap 8); 56 tall, r14, padding h16, gap 12; unfocused 1 dp ink@0.12 border, focused 1.5 dp ink; "+92" 16/800 + 1×24 divider ink@0.15; valid state 22-dp sage check; helper row 14-dp icon + 12/400 @0.55 |
| `SaafOtpField` | "OTP boxes" + "Keypad" | 6 boxes 50×58 r14, 1 dp ink@0.14 border, digit 22/800; active box 1.5 dp ink + 2×24 sage caret; keypad 3×4, keys 24/24/700, padding v14, row gap 4, 24-dp delete icon (see §9.4 for autofill) |
| `SaafOptionTile` | "Option" (05), "Plan" (13) | cornsilk, r18, padding 14, gap 14, 40-dp icon circle, title 15/20/800 + caption 12/16, trailing 24-dp check; unselected border 1 dp ink@0.1 + icon circle sageTint; selected border 1.5 dp ink + icon circle sage. Plan variant: r20, padding 18×16, selected border 2 dp, trailing price 17/800 |
| `SaafCheck` | "Check" | circle 22/24/26, checked = sage fill + ink check icon (13/14/16), unchecked = 1.5 dp ink@0.25 border |
| `SaafCheckRow` | 04 checkbox rows | Figma row (36 visual) + whole row tappable, `MergeSemantics` |
| `SaafListGroup` + `SaafListRowProduct` | 09 "Checklist", 08 routine list | group: cornsilk, 1 dp ink@0.09, r22, padding h16 v4; row: padding v12, gap 12, 48-dp thumb (r12, papayaTint), title 15/20/800 + caption 12/16 @0.55, trailing check 26; row divider 1 dp ink@0.07 (not after last) |
| `SaafSettingsGroup` + `SaafSettingsRow` | 14 settings | group r20, padding h16 v2; row padding v14, gap 12, 20-dp leading icon, title 15/20/700, value 13/400 @0.5, 16-dp chevron (directional) |
| `SaafSectionHeader` | "Section" | title 17/800 + spacer + trailing chip/link |
| `SaafOverline` | "ROUTINE", "STEP 2 OF 5" | 12/800, letterSpacing 0.96, uppercase, ink@0.45 (ink 1.0 on 05) |
| `SaafInkCard` | 09 "Today progress", 07 score card, 14 "Pro promo" | ink fill; r24 padding 20 (progress) or r20 padding 16 (promo); cornsilk text ladder |
| `SaafProgressRing` | "Score ring" | 76 dp (09), track + sage arc, value text inside; `Semantics(value:)` |
| `SaafProgressBar` | "Progress" | 6 high, r3, track ink@0.08 (light) / cornsilk@0.15 (on ink), fill sage |
| `SaafWeekStrip` / `SaafDayPill` | "Week strip" / "Day" | 7 pills 44×68 r22 space-between; normal: 1 dp ink@0.09, letter 11/14/800 @0.5, number 15/18/800, 5-dp dot; today: ink fill, cornsilk text (letter @0.7) |
| `SaafIconCircle` | "icon-circle" | circle 36–64, fill sage / sageTint / tan / lightSage per screen, centred icon at ~½ size |
| `SaafAvatar` | "Avatar" | 64 circle sage, initial 27/34/800 |
| `SaafBottomNav` / `SaafAdaptiveNav` | "Bottom nav" | floating ink pill, 64 tall, r32, padding h36, 4 icons (Home, Scan, Progress, Profile) 24 wide + active dot; becomes `NavigationRail` on medium/expanded (§7) |
| `SaafChatBubble` | 11 "Bubble" | coach/me variants — read exact spec from 11 when building |
| `SaafBeforeAfterSlider` | 12 slider | read exact spec from 12 when building |
| `SaafCameraControls` | 06 "Camera controls" | 48-dp gallery (r14) + 78-dp shutter + 48-dp flip (circle), fills cornsilk@0.12 on ink |
| `SaafDisclaimer` | 07 "Disclaimer" | info icon + caption text |
| `PermissionRationaleSheet`, `SaafEmptyState`, `SaafErrorState`, `SaafOfflineBanner`, `SaafSkeleton` | (not in Figma — §9) | built from the tokens above |

Each common widget: `const` constructor, documented params, widget test incl. a11y guidelines, works in light/dark and RTL.
**Before building any screen, call Figma `get_design_context` for that node** and match it exactly using these widgets.

## 7. Responsive & adaptive layout (phones, iPad, foldables, flip phones)

Figma only shows 390 × 844. The design must stretch from a flip-phone cover screen to an iPad Pro **while keeping the
Figma look** (same components, tokens and proportions — just reflowed). Breakpoints in `core/theme/breakpoints.dart`,
read only in `SaafScaffold` / layout widgets via `LayoutBuilder` / `MediaQuery.sizeOf`:

| Class | Width (dp) | Devices | Layout |
|---|---|---|---|
| compact | < 600 | phones, open flip phones, Fold cover screen | exactly the Figma layout; gutter 20 (16 if width < 360); floating bottom nav |
| medium | 600–839 | iPad mini / portrait, unfolded foldables, Surface Duo single screen | `NavigationRail` styled like the Figma nav (ink, sage active); content max width 560 centred (Figma 350-dp column scaled up); grids 2 → 3 columns |
| expanded | ≥ 840 | iPad landscape, tablets, Duo spanned | `NavigationRail` with labels; **two-pane**: Home + Routine, Progress + Coach, Routine list + Product; each pane max 560 |

Rules:
1. **Minimum 320 × 480 dp with no overflow.** Everything scrolls; the bottom CTA (Figma pins it with a spacer) stays
   pinned only when content fits, otherwise it scrolls with the content.
2. **Foldables / dual-screen:** read `MediaQuery.displayFeaturesOf(context)`; with a vertical hinge, put the two panes on
   either side — never place text or buttons across the hinge. Horizontal fold ("tabletop"): on 06, viewfinder top half,
   camera controls bottom half.
3. **Flip phones:** open = tall compact (test 360 × 880); cover screen = tiny compact. Don't assume 19.5:9.
4. **iPad:** support all orientations, Split View, Slide Over (window can be 320 dp wide). Bottom sheets become dialogs
   or side sheets on medium/expanded. Hover states for trackpads.
5. **No orientation lock** (Android 16+ ignores locks on large screens anyway).
6. Respect safe areas, cutouts, keyboard insets, the Android gesture bar.
7. Fixed-size Figma graphics (hero 350 × 372, viewfinder 350 × 440) become `AspectRatio` boxes constrained by width/height.
8. Test matrix: 320×568, 360×640, 360×880, 390×844, 768×1024, 1024×768, 884×1104, 1280×800.

## 8. Interaction & motion
- `SaafTokens.motion`: fast 150 ms, medium 250 ms, slow 400 ms, `Curves.easeOutCubic`; respect `MediaQuery.disableAnimationsOf`.
- Pressed/hover/focus states: M3 ink ripple tinted ink@0.08 on light, cornsilk@0.12 on dark (Figma shows no pressed states).
- Disabled primary button: sage @ 0.5 fill, ink @ 0.5 text (not in Figma — §9).
- Destructive actions (Delete account): `error` colour + confirmation.
- Loading: skeletons (ink@0.04 blocks, Figma radii) for content, spinner inside the button for actions.

## 9. Build-time additions (not in the prototype — required when building)

These keep the Figma look but add what the stores, accessibility or real data require. Details in store-compliance.md.

### 9.1 Touch targets
Figma visuals stay as drawn (40-dp icon buttons, 36-dp checkbox rows, 40-dp text button, 44-dp days, 22–26-dp checks).
**Hit areas are expanded invisibly to ≥ 48 × 48 dp** (`MaterialTapTargetSize.padded`, `ConstrainedBox(minWidth/minHeight: 48)`
around the visual, or making the whole row tappable). Layout spacing must not change visibly.

### 9.2 Paywall (13)
Keep the Figma layout. Additions, all styled with existing tokens:
- Prices, "Rs 333/month", "Save 44%", trial length and the legal sentence are **built from store data** (RevenueCat),
  never the Figma literals.
- Legal line is platform-aware: "Cancel anytime in Google Play" (Android) / "Cancel anytime in your Apple ID settings" (iOS).
- Add one row of `legal`-style text links under the legal line: **Restore purchases · Terms of Use · Privacy Policy**
  (12/18, ink@0.5, underlined on press, each with a 48-dp hit area).

### 9.3 Sign up (02)
- Add a **"Continue with Apple"** button using `SaafButton.outline` (same size, Apple logo as leading icon),
  placed above "Continue with Google", equal prominence. Required on iOS (App Store 4.8); since 2026-10-29 also shown
  on Android (owner's request; Firebase signs in with Apple in a browser there).
- "Terms of Use" and "Privacy Policy" in the legal line become real tappable links.

### 9.4 Verify code (03)
Keep Figma's boxes + on-screen keypad as the default UI, and add autofill:
- Android: use the SMS User Consent / Retriever API to fill the code automatically.
- iOS: tapping an OTP box switches to the system number pad on a field with `AutofillHints.oneTimeCode`
  (iOS only offers SMS-code autofill above the system keyboard). Paste of a 6-digit code works everywhere.
- Each key and box has a semantic label; the keypad isn't the only way to enter the code.

### 9.5 Welcome (01)
The "Dark spots −32% in 8 weeks" stat card keeps its design, but the text must be real aggregated data, or labelled
"Example" (e.g. caption "Example result"). Never a made-up claim.

### 9.6 Content & states
- No mockup data in builds ("Ayesha", "Rs 1,450", "+92 312 456 7890", "LUMÉ"…). Real data or empty states.
- Add per screen: loading, empty, error, offline states and an `error` colour (`#B3261E` light / `#F2B8B5` dark) for validation.
- Add: splash, Delete-account confirmation, permission rationale sheet, "How we score" page, Terms/Privacy pages,
  report-AI-reply action on 11, theme override row in 14. Design each from §6 components.

### 9.7 Privacy promise
04 says "Your photos stay on your phone" → analysis runs on-device (architecture.md PRV-2). If that ever changes, the
04 copy changes first.

## 10. Screen inventory

| # | Screen | Figma node | Feature folder | Build-time additions (§9) |
|---|---|---|---|---|
| 01 | Welcome | 2:15 | onboarding | real/“Example” stat; hit area on text button |
| 02 | Sign up | 2:76 | auth | Sign in with Apple (iOS); real legal links |
| 03 | Verify code | 2:140 | auth | OTP autofill path |
| 04 | Privacy consent | 2:227 | onboarding | 48-dp row hit areas; promises true in code |
| 05 | Skin quiz | 2:305 | onboarding | max-2 selection logic, "Skip" hit area |
| 06 | Selfie capture | 3:2 | scan | permission rationale; tabletop layout |
| 07 | Analysis results | 3:97 | scan | "How we score" page |
| 08 | Routine | 3:185 | routine | real budget/products |
| 09 | Home | 3:292 | home | bell tooltip; empty state |
| 10 | Product scan result | 3:446 | products | external Buy links; price "as of" |
| 11 | Weekly check-in | 3:537 | coach | AI report action; consent if third-party AI |
| 12 | Monthly progress | 3:613 | progress | Pro gate |
| 13 | Saaf Pro paywall | 3:712 | paywall | §9.2 |
| 14 | Profile & privacy | 3:801 | profile | Delete-account flow; theme row |

## 11. Copy & localisation
- All strings in `lib/core/l10n/app_en.arb` / `app_ur.arb` — copy the Figma text exactly for English.
- Numbers/currency via `intl` `NumberFormat` ("Rs 1,450" style), dates via `DateFormat` ("Thursday, 15 October").
- Tone (Figma): warm, short, plain words, "Salam" greeting, no medical jargon.
