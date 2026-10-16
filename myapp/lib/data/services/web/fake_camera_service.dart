import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:saaf/core/error/failure.dart';
import 'package:saaf/core/error/result.dart';
import 'package:saaf/core/platform/camera_preview_source.dart';
import 'package:saaf/core/theme/saaf_tokens_extension.dart';
import 'package:saaf/core/utils/solid_png.dart';
import 'package:saaf/domain/entities/camera_facing.dart';
import 'package:saaf/domain/services/camera_service.dart';

/// A pretend camera for Chrome demos and tests: "photos" are small coloured
/// PNGs, a different colour each shot, so you can tell retakes apart.
class FakeCameraService implements CameraService, CameraPreviewSource {
  CameraFacing? _facing;
  int _shots = 0;

  /// The side the camera was last opened on.
  CameraFacing? get facing => _facing;

  @override
  bool get canFlip => true;

  @override
  Future<Result<void>> open(CameraFacing facing) async {
    _facing = facing;
    return const Ok<void>(null);
  }

  @override
  Future<Result<Uint8List>> capture() async {
    if (_facing == null) return const Err(UnknownFailure('camera-closed'));
    _shots++;
    return Ok(
      solidPng(
        width: 24,
        height: 32,
        red: (60 + _shots * 47) % 256,
        green: (120 + _shots * 31) % 256,
        blue: (90 + _shots * 23) % 256,
      ),
    );
  }

  @override
  Future<void> close() async => _facing = null;

  @override
  Widget buildPreview(BuildContext context) =>
      _isOpen ? const _FakePreview() : const SizedBox.shrink();

  bool get _isOpen => _facing != null;
}

/// A head-and-shoulders outline standing in for the live picture, drawn in the
/// theme's faint on-ink colour so it follows light, dark and high contrast.
class _FakePreview extends StatelessWidget {
  const _FakePreview();

  @override
  Widget build(BuildContext context) => SizedBox.expand(
    child: CustomPaint(painter: _SilhouettePainter(context.saaf.controlOnInk)),
  );
}

class _SilhouettePainter extends CustomPainter {
  const _SilhouettePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()..color = color;
    canvas
      ..drawOval(
        Rect.fromCenter(
          center: Offset(size.width / 2, size.height * 0.42),
          width: size.width * 0.46,
          height: size.height * 0.34,
        ),
        fill,
      )
      ..drawOval(
        Rect.fromCenter(
          center: Offset(size.width / 2, size.height * 0.92),
          width: size.width * 0.9,
          height: size.height * 0.4,
        ),
        fill,
      );
  }

  @override
  bool shouldRepaint(_SilhouettePainter oldDelegate) =>
      oldDelegate.color != color;
}
