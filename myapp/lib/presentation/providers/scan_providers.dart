import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:saaf/core/config/env.dart';
import 'package:saaf/core/platform/camera_preview_source.dart';
import 'package:saaf/data/services/file_photo_store.dart';
import 'package:saaf/data/services/plugin_camera_service.dart';
import 'package:saaf/data/services/plugin_permission_service.dart';
import 'package:saaf/data/services/plugin_photo_picker.dart';
import 'package:saaf/data/services/web/fake_camera_service.dart';
import 'package:saaf/data/services/web/fake_capture_quality_monitor.dart';
import 'package:saaf/data/services/web/fake_permission_service.dart';
import 'package:saaf/data/services/web/fake_photo_picker.dart';
import 'package:saaf/data/services/web/in_memory_photo_store.dart';
import 'package:saaf/domain/entities/camera_permission.dart';
import 'package:saaf/domain/services/camera_service.dart';
import 'package:saaf/domain/services/capture_quality_monitor.dart';
import 'package:saaf/domain/services/permission_service.dart';
import 'package:saaf/domain/services/photo_picker.dart';
import 'package:saaf/domain/services/photo_store.dart';
import 'package:saaf/domain/usecases/camera_access.dart';
import 'package:saaf/domain/usecases/capture_photo.dart';
import 'package:saaf/domain/usecases/finish_scan.dart';
import 'package:saaf/domain/usecases/pick_photo.dart';
import 'package:saaf/presentation/providers/consent_providers.dart';

part 'scan_providers.g.dart';

/// The camera as the scan screen needs it: taking photos and drawing the live
/// picture. One object behind both views.
typedef CameraDevice = ({CameraService service, CameraPreviewSource preview});

/// With `--dart-define=FAKE_CAMERA=true` everything is pretend (Chrome demos).
/// Otherwise phones use the real plugins; Chrome uses the real camera (the
/// browser asks for permission itself) with photos kept in memory.
@Riverpod(keepAlive: true)
PermissionService permissionService(Ref ref) {
  if (Env.fakeCamera) return FakePermissionService(CameraPermission.denied);
  if (kIsWeb) return FakePermissionService(CameraPermission.granted);
  return const PluginPermissionService();
}

@Riverpod(keepAlive: true)
CameraDevice cameraDevice(Ref ref) {
  if (Env.fakeCamera) {
    final fake = FakeCameraService();
    return (service: fake, preview: fake);
  }
  final real = PluginCameraService();
  return (service: real, preview: real);
}

@Riverpod(keepAlive: true)
CameraService cameraService(Ref ref) => ref.watch(cameraDeviceProvider).service;

@Riverpod(keepAlive: true)
CameraPreviewSource cameraPreviewSource(Ref ref) =>
    ref.watch(cameraDeviceProvider).preview;

@Riverpod(keepAlive: true)
PhotoPicker photoPicker(Ref ref) =>
    Env.fakeCamera ? FakePhotoPicker() : PluginPhotoPicker();

/// Photos live in the app's private folder on phones, in memory in Chrome.
@Riverpod(keepAlive: true)
PhotoStore photoStore(Ref ref) =>
    (Env.fakeCamera || kIsWeb) ? InMemoryPhotoStore() : FilePhotoStore();

/// Pretend until real on-device image analysis exists (see handoff.md).
@Riverpod(keepAlive: true)
CaptureQualityMonitor captureQualityMonitor(Ref ref) =>
    const FakeCaptureQualityMonitor();

@Riverpod(keepAlive: true)
CameraAccess cameraAccess(Ref ref) =>
    CameraAccess(ref.watch(permissionServiceProvider));

@Riverpod(keepAlive: true)
CapturePhoto capturePhoto(Ref ref) => CapturePhoto(
  camera: ref.watch(cameraServiceProvider),
  clock: ref.watch(clockProvider),
);

@Riverpod(keepAlive: true)
PickPhoto pickPhoto(Ref ref) => PickPhoto(
  picker: ref.watch(photoPickerProvider),
  clock: ref.watch(clockProvider),
);

@Riverpod(keepAlive: true)
FinishScan finishScan(Ref ref) => FinishScan(ref.watch(photoStoreProvider));
