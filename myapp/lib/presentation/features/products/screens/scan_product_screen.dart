import 'package:flutter/material.dart';
import 'package:flutter/services.dart'
    show FilteringTextInputFormatter, LengthLimitingTextInputFormatter;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:saaf/core/l10n/app_localizations.dart';
import 'package:saaf/core/router/saaf_route.dart';
import 'package:saaf/core/theme/saaf_tokens_extension.dart';
import 'package:saaf/domain/usecases/camera_access.dart';
import 'package:saaf/presentation/providers/product_providers.dart';
import 'package:saaf/presentation/providers/scan_providers.dart';
import 'package:saaf/presentation/widgets/common/saaf_button.dart';
import 'package:saaf/presentation/widgets/common/saaf_icon_circle.dart';
import 'package:saaf/presentation/widgets/common/saaf_scaffold.dart';
import 'package:saaf/presentation/widgets/common/saaf_text_field.dart';
import 'package:saaf/presentation/widgets/common/saaf_top_bar.dart';

/// Scan a product's barcode (or type its number) to see what is in it and how
/// it fits the user's skin. Our own camera explanation comes before the system
/// dialog (store-compliance §1); without the camera the number can be typed, so
/// the feature never depends on the camera.
class ScanProductScreen extends ConsumerStatefulWidget {
  const ScanProductScreen({super.key});

  @override
  ConsumerState<ScanProductScreen> createState() => _ScanProductScreenState();
}

enum _Camera { checking, ready, denied, needsSettings }

class _ScanProductScreenState extends ConsumerState<ScanProductScreen> {
  static final _barcode = RegExp(r'^\d{8,14}$');

  final TextEditingController _typed = TextEditingController();
  _Camera _camera = _Camera.checking;
  bool _typedError = false;
  bool _handled = false;

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void dispose() {
    _typed.dispose();
    super.dispose();
  }

  CameraAccess get _access => ref.read(cameraAccessProvider);

  Future<void> _start() async {
    final outcome = await _access.check();
    if (!mounted) return;
    if (outcome == CameraAccessOutcome.needsRationale) {
      final go = await _explain();
      if (!mounted) return;
      if (go != true) {
        setState(() => _camera = _Camera.denied);
        return;
      }
      _apply(await _access.request());
    } else {
      _apply(outcome);
    }
  }

  void _apply(CameraAccessOutcome outcome) {
    if (!mounted) return;
    setState(
      () => _camera = switch (outcome) {
        CameraAccessOutcome.granted => _Camera.ready,
        CameraAccessOutcome.needsSettings => _Camera.needsSettings,
        CameraAccessOutcome.denied ||
        CameraAccessOutcome.needsRationale => _Camera.denied,
      },
    );
  }

  Future<bool?> _explain() {
    final l10n = AppLocalizations.of(context);
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.scanRationaleTitle),
        content: Text(l10n.scanProductRationaleBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.scanNotNow),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.scanContinue),
          ),
        ],
      ),
    );
  }

  /// A barcode was read or typed: show the product (only the first one counts).
  void _open(String code) {
    if (_handled) return;
    _handled = true;
    context.pushReplacement(
      Uri(
        path: SaafRoute.productScanResult.path,
        queryParameters: {'barcode': code},
      ).toString(),
    );
  }

  void _lookUp() {
    final code = _typed.text.trim();
    final ok = _barcode.hasMatch(code);
    setState(() => _typedError = !ok);
    if (ok) _open(code);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.saaf;
    final space = tokens.space;

    return SaafScaffold(
      key: ValueKey('screen-${SaafRoute.scanProduct.name}'),
      topBar: SaafTopBar(
        title: l10n.scanProductTitle,
        leading: SaafTopBar.backButton(
          tooltip: l10n.back,
          onBack: () => context.canPop()
              ? context.pop()
              : context.go(SaafRoute.home.path),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: space.x16,
        children: [
          _camera == _Camera.ready
              ? _Viewfinder(onCode: _open)
              : _CameraNotice(
                  camera: _camera,
                  onTryAgain: _start,
                  onSettings: _access.openSettings,
                ),
          Semantics(
            header: true,
            child: Text(
              l10n.scanProductManualTitle,
              style: context.text.titleSmall,
            ),
          ),
          SaafTextField(
            key: const ValueKey('barcode-field'),
            label: l10n.scanProductManualLabel,
            controller: _typed,
            hintText: l10n.scanProductManualHint,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.search,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(14),
            ],
            errorText: _typedError ? l10n.scanProductInvalid : null,
          ),
          SaafButton.outline(label: l10n.scanProductLookUp, onPressed: _lookUp),
        ],
      ),
    );
  }
}

/// The live camera in a rounded frame, with a hint under it.
class _Viewfinder extends ConsumerWidget {
  const _Viewfinder({required this.onCode});

  final ValueChanged<String> onCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.saaf;
    final view = ref.watch(barcodeScannerViewProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: tokens.space.x12,
      children: [
        SizedBox(
          height: tokens.size.productPhoto,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(tokens.radius.r24),
            child: ColoredBox(
              color: context.colors.inverseSurface,
              child: view(context, onCode),
            ),
          ),
        ),
        Text(
          l10n.scanProductHint,
          textAlign: TextAlign.center,
          style: context.text.bodyMedium?.copyWith(color: tokens.textLabel),
        ),
      ],
    );
  }
}

/// What to show instead of the camera: still looking, refused, or blocked.
class _CameraNotice extends StatelessWidget {
  const _CameraNotice({
    required this.camera,
    required this.onTryAgain,
    required this.onSettings,
  });

  final _Camera camera;
  final VoidCallback onTryAgain;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.saaf;

    if (camera == _Camera.checking) {
      return SizedBox(
        height: tokens.size.productPhoto,
        child: const Center(child: CircularProgressIndicator()),
      );
    }
    final blocked = camera == _Camera.needsSettings;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: tokens.space.x12,
      children: [
        Center(
          child: SaafIconCircle(
            icon: blocked ? Icons.lock_outline : Icons.no_photography_outlined,
            size: SaafIconCircleSize.large,
          ),
        ),
        Semantics(
          header: true,
          child: Text(
            l10n.scanDeniedTitle,
            textAlign: TextAlign.center,
            style: context.text.titleLarge,
          ),
        ),
        Text(
          blocked ? l10n.scanProductSettingsBody : l10n.scanProductDeniedBody,
          textAlign: TextAlign.center,
          style: context.text.bodyMedium?.copyWith(color: tokens.textLabel),
        ),
        SaafButton.primary(
          label: blocked ? l10n.scanOpenSettings : l10n.scanTryAgain,
          onPressed: blocked ? onSettings : onTryAgain,
        ),
      ],
    );
  }
}
