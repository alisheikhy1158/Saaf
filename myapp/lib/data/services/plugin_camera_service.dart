import 'dart:async';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;
import 'package:flutter/widgets.dart';
import 'package:saaf/core/error/failure.dart';
import 'package:saaf/core/error/result.dart';
import 'package:saaf/core/platform/camera_preview_source.dart';
import 'package:saaf/data/services/live_frame_source.dart';
import 'package:saaf/domain/entities/camera_facing.dart';
import 'package:saaf/domain/services/camera_service.dart';

/// Maps the camera plugin's error code to the app's failure.
Failure cameraFailureFromCode(String code) => switch (code) {
  'CameraAccessDenied' ||
  'CameraAccessDeniedWithoutPrompt' ||
  'CameraAccessRestricted' => const PermissionDenied(),
  _ => UnknownFailure(code),
};

/// The real camera through the `camera` plugin (phones and Chrome). Photos are
/// taken at "high" resolution (about 720p), enough for skin analysis and small.
class PluginCameraService
    implements CameraService, CameraPreviewSource, LiveFrameSource {
  CameraController? _controller;
  List<CameraDescription> _cameras = const [];

  @override
  bool get canFlip => _cameras.length > 1;

  @override
  Future<Result<void>> open(CameraFacing facing) async {
    await close();
    try {
      if (_cameras.isEmpty) _cameras = await availableCameras();
      if (_cameras.isEmpty) return const Err(UnknownFailure('no-camera'));

      final wanted = facing == CameraFacing.front
          ? CameraLensDirection.front
          : CameraLensDirection.back;
      final description = _cameras.firstWhere(
        (c) => c.lensDirection == wanted,
        orElse: () => _cameras.first,
      );
      final controller = CameraController(
        description,
        ResolutionPreset.high,
        enableAudio: false,
        // The format the face detector reads (not used in Chrome).
        imageFormatGroup: kIsWeb
            ? null
            : defaultTargetPlatform == TargetPlatform.android
            ? ImageFormatGroup.nv21
            : ImageFormatGroup.bgra8888,
      );
      await controller.initialize();
      _controller = controller;
      return const Ok<void>(null);
    } on CameraException catch (e) {
      return Err(cameraFailureFromCode(e.code));
    } on Object {
      return const Err(UnknownFailure('camera-open'));
    }
  }

  @override
  Future<Result<Uint8List>> capture() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return const Err(UnknownFailure('camera-closed'));
    }
    try {
      final file = await controller.takePicture();
      return Ok(await file.readAsBytes());
    } on CameraException catch (e) {
      return Err(cameraFailureFromCode(e.code));
    } on Object {
      return const Err(UnknownFailure('camera-capture'));
    }
  }

  @override
  Future<void> close() async {
    final controller = _controller;
    _controller = null;
    try {
      await controller?.dispose();
    } on Object {
      // Already gone.
    }
  }

  @override
  Stream<LiveFrame> liveFrames() {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return Stream.error(StateError('camera-closed'));
    }
    late final StreamController<LiveFrame> out;
    out = StreamController<LiveFrame>(
      onListen: () async {
        try {
          await controller.startImageStream((image) {
            if (out.isClosed) return;
            out.add(
              LiveFrame(
                image: image,
                sensorOrientation: controller.description.sensorOrientation,
                front:
                    controller.description.lensDirection ==
                    CameraLensDirection.front,
                deviceOrientation: controller.value.deviceOrientation,
              ),
            );
          });
        } on Object catch (error, stack) {
          if (!out.isClosed) out.addError(error, stack);
        }
      },
      onCancel: () async {
        try {
          if (controller.value.isStreamingImages) {
            await controller.stopImageStream();
          }
        } on Object {
          // The camera is already closed.
        }
      },
    );
    return out.stream;
  }

  @override
  Widget buildPreview(BuildContext context) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return const SizedBox.shrink();
    }
    return CameraPreview(controller);
  }
}
