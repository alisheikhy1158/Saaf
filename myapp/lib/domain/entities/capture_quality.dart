enum LightAdvice { none, tooDark, tooBright }

/// How good the current camera view is for a skin photo: the three chips on the
/// scan screen ("Good light", "Centred", "Hold still").
class CaptureQuality {
  const CaptureQuality({
    required this.lightOk,
    required this.centred,
    required this.steady,
    this.advice = LightAdvice.none,
  });

  /// Nothing known yet.
  static const CaptureQuality initial = CaptureQuality(
    lightOk: false,
    centred: false,
    steady: false,
  );

  final bool lightOk;
  final bool centred;
  final bool steady;

  /// What to tell the user when the light is not ok ("Move to softer light").
  final LightAdvice advice;

  /// Everything is fine: the photo can be taken.
  bool get isReady => lightOk && centred && steady;

  CaptureQuality copyWith({
    bool? lightOk,
    bool? centred,
    bool? steady,
    LightAdvice? advice,
  }) => CaptureQuality(
    lightOk: lightOk ?? this.lightOk,
    centred: centred ?? this.centred,
    steady: steady ?? this.steady,
    advice: advice ?? this.advice,
  );

  @override
  bool operator ==(Object other) =>
      other is CaptureQuality &&
      other.lightOk == lightOk &&
      other.centred == centred &&
      other.steady == steady &&
      other.advice == advice;

  @override
  int get hashCode => Object.hash(lightOk, centred, steady, advice);
}
