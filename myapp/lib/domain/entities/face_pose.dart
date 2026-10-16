/// The three photos of a face scan, in the order they are taken: straight on,
/// then each side profile.
enum FacePose {
  front,
  left,
  right;

  /// 1-based position, as shown in the step indicator.
  int get number => index + 1;

  static int get count => values.length;

  FacePose? get next => number < count ? values[number] : null;
  FacePose? get previous => index > 0 ? values[index - 1] : null;

  /// A side view (left or right), as opposed to the front view.
  bool get isProfile => this != front;
}
