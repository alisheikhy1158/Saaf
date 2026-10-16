/// The five questions of the skin quiz, in the order they are asked. Concerns is
/// step 2 because Figma 05 shows "STEP 2 OF 5".
enum QuizStep {
  skinType,
  concerns,
  sensitivity,
  safety,
  budget;

  /// 1-based position, as shown in "STEP 2 OF 5".
  int get number => index + 1;

  static int get count => values.length;

  /// The step with this 1-based [number]; out-of-range numbers are clamped.
  static QuizStep fromNumber(int number) =>
      values[(number - 1).clamp(0, values.length - 1)];

  /// The step after this one, or null after the last.
  QuizStep? get next => number < count ? values[number] : null;
}
