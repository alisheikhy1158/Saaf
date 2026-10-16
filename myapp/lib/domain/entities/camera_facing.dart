/// Which camera is used. Face scans start on the front (selfie) camera.
enum CameraFacing {
  front,
  back;

  CameraFacing get flipped => this == front ? back : front;
}
