// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Saaf';

  @override
  String get welcomeTitle => 'Clear skin, made simple.';

  @override
  String get welcomeSubtitle =>
      'A skincare coach for South Asian skin. Routines built from products you can actually buy in Pakistan.';

  @override
  String get welcomeChip => 'For South Asian skin';

  @override
  String get welcomeStatCaption => 'Example: dark spots';

  @override
  String get welcomeStatValue => '−32% in 8 weeks';

  @override
  String get getStarted => 'Get started';

  @override
  String get alreadyHaveAccount => 'I already have an account';

  @override
  String get language => 'Language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageUrdu => 'Urdu';

  @override
  String get back => 'Back';

  @override
  String get consentTitle => 'Your photos stay\non your phone';

  @override
  String get consentSubtitle =>
      'Saaf checks your skin, not your identity. Here’s how we look after your data.';

  @override
  String get consentPointDeviceTitle => 'Saved on your device';

  @override
  String get consentPointDeviceBody =>
      'Photos stay on your phone unless you turn on backup.';

  @override
  String get consentPointNeverSoldTitle => 'Never sold or shared';

  @override
  String get consentPointNeverSoldBody =>
      'Brands and advertisers never see your face data.';

  @override
  String get consentPointDeleteTitle => 'Delete anytime';

  @override
  String get consentPointDeleteBody =>
      'Remove your account and every photo in one tap.';

  @override
  String consentAgree(String terms, String privacy) {
    return 'I agree to the $terms and $privacy';
  }

  @override
  String get consentAge => 'I am 16 or older';

  @override
  String get consentContinue => 'Agree and continue';

  @override
  String get termsTitle => 'Terms of Use';

  @override
  String get privacyPolicyTitle => 'Privacy Policy';

  @override
  String openDocumentAction(String name) {
    return 'Open $name';
  }

  @override
  String get legalDraftBanner => 'Draft: pending legal review';

  @override
  String legalLastUpdated(String date) {
    return 'Last updated $date';
  }

  @override
  String get legalEnglishOnlyNote =>
      'This document is currently available in English only.';

  @override
  String quizStepLabel(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get quizSkip => 'Skip';

  @override
  String get quizNext => 'Next';

  @override
  String get quizConcernsTitle => 'What bothers you most about your skin?';

  @override
  String get quizConcernsHint => 'Pick up to two. You can change this later.';

  @override
  String get quizSkinTypeTitle => 'How does your skin feel by midday?';

  @override
  String get quizSkinTypeHint =>
      'Pick the closest match. Not sure? That’s fine.';

  @override
  String get skinTypeOilyTitle => 'Oily';

  @override
  String get skinTypeOilyCaption =>
      'Shiny, especially on the forehead and nose';

  @override
  String get skinTypeDryTitle => 'Dry';

  @override
  String get skinTypeDryCaption => 'Tight or flaky, even after moisturiser';

  @override
  String get skinTypeCombinationTitle => 'Combination';

  @override
  String get skinTypeCombinationCaption => 'Oily T-zone, drier cheeks';

  @override
  String get skinTypeNormalTitle => 'Balanced';

  @override
  String get skinTypeNormalCaption => 'Comfortable, neither shiny nor tight';

  @override
  String get skinTypeNotSureTitle => 'Not sure';

  @override
  String get skinTypeNotSureCaption => 'We’ll start gentle and learn with you';

  @override
  String get quizSensitivityTitle =>
      'How does your skin react to new products?';

  @override
  String get quizSensitivityHint =>
      'Pick one. Strong ingredients stay away from sensitive skin.';

  @override
  String get sensitivityLowTitle => 'Rarely reacts';

  @override
  String get sensitivityLowCaption => 'New products usually feel fine';

  @override
  String get sensitivitySometimesTitle => 'Sometimes reacts';

  @override
  String get sensitivitySometimesCaption =>
      'Occasional stinging, redness or breakouts';

  @override
  String get sensitivityHighTitle => 'Often reacts';

  @override
  String get sensitivityHighCaption => 'Many products sting or irritate';

  @override
  String get quizSafetyTitle => 'Anything we should keep in mind?';

  @override
  String get quizSafetyHint =>
      'Optional. This stays on your phone and only helps us avoid ingredients that may not suit you.';

  @override
  String get safetyPregnantTitle => 'Pregnant or breastfeeding';

  @override
  String get safetyPregnantCaption =>
      'We’ll leave out ingredients usually avoided';

  @override
  String get safetyPrescriptionTitle => 'On a prescription skin treatment';

  @override
  String get safetyPrescriptionCaption =>
      'We’ll keep things gentle and suggest checking with your doctor';

  @override
  String get safetyAllergyTitle => 'A known ingredient allergy';

  @override
  String get safetyAllergyCaption =>
      'For example fragrance or a specific ingredient';

  @override
  String get safetyNoneTitle => 'None of these';

  @override
  String get safetyNoneCaption => 'Nothing to add';

  @override
  String get quizBudgetTitle => 'What can you spend on skincare each month?';

  @override
  String get quizBudgetHint =>
      'Pick a range. Your routine is built from products that fit it.';

  @override
  String get budgetEssentialTitle => 'Under Rs 3,000';

  @override
  String get budgetEssentialCaption => 'Simple, effective basics';

  @override
  String get budgetBalancedTitle => 'Rs 3,000 – 6,000';

  @override
  String get budgetBalancedCaption => 'A solid routine with a few extras';

  @override
  String get budgetComfortableTitle => 'Rs 6,000 – 10,000';

  @override
  String get budgetComfortableCaption => 'More choice, including treatments';

  @override
  String get budgetPremiumTitle => 'Over Rs 10,000';

  @override
  String get budgetPremiumCaption => 'Anything that suits your skin';

  @override
  String get concernDarkSpotsTitle => 'Dark spots & pigmentation';

  @override
  String get concernDarkSpotsCaption => 'Marks left by acne or the sun';

  @override
  String get concernAcneTitle => 'Acne & breakouts';

  @override
  String get concernAcneCaption => 'Pimples, blackheads, bumps';

  @override
  String get concernOilinessTitle => 'Oiliness & large pores';

  @override
  String get concernOilinessCaption => 'Shiny by midday';

  @override
  String get concernDrynessTitle => 'Dryness & dullness';

  @override
  String get concernDrynessCaption => 'Tight, flaky or tired-looking';

  @override
  String get concernUnevenToneTitle => 'Uneven skin tone';

  @override
  String get concernUnevenToneCaption => 'Patchy colour, dark circles';

  @override
  String get signUpTitle => 'Let’s get you started';

  @override
  String get signUpSubtitle =>
      'Use your mobile number. No passwords to remember.';

  @override
  String get phoneLabel => 'Mobile number';

  @override
  String get phoneHint => '3XX XXX XXXX';

  @override
  String get phoneHelper => 'We’ll text you a 6-digit code.';

  @override
  String get sendCode => 'Send code';

  @override
  String get orDivider => 'or';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get continueWithApple => 'Continue with Apple';

  @override
  String signUpLegal(String terms, String privacy) {
    return 'By continuing you agree to Saaf’s $terms and $privacy.';
  }

  @override
  String get signUpSendFailed =>
      'We couldn’t send the code. Check your connection and try again.';

  @override
  String get socialSignInFailed => 'We couldn’t sign you in. Please try again.';

  @override
  String get verifyTitle => 'Enter the code';

  @override
  String verifySentTo(String phone, String edit) {
    return 'Sent to $phone  ·  $edit';
  }

  @override
  String get verifyEdit => 'Edit';

  @override
  String get verifyCodeLabel => 'Verification code';

  @override
  String verifyResendIn(String time) {
    return 'Resend code in $time';
  }

  @override
  String get verifyResend => 'Resend code';

  @override
  String get verifyButton => 'Verify';

  @override
  String get verifyWrongCode =>
      'That code doesn’t match. Check it and try again.';

  @override
  String get verifyFailed =>
      'We couldn’t verify the code. Check your connection and try again.';

  @override
  String get keypadDelete => 'Delete';

  @override
  String get notFoundTitle => 'Page not found';

  @override
  String get notFoundBody => 'We couldn\'t find that page.';

  @override
  String get goToStart => 'Go to start';

  @override
  String get fieldValid => 'Valid';

  @override
  String get scanTitle => 'Face scan';

  @override
  String get scanClose => 'Close';

  @override
  String get scanLightToggle => 'Screen light';

  @override
  String get scanPoseFront => 'Front';

  @override
  String get scanPoseLeft => 'Left';

  @override
  String get scanPoseRight => 'Right';

  @override
  String scanStepSemantics(int number, int total, String pose) {
    return 'Photo $number of $total: $pose';
  }

  @override
  String get scanStepDone => 'taken';

  @override
  String get scanInstructionFront => 'Look straight at the camera';

  @override
  String get scanInstructionLeft => 'Show your left cheek';

  @override
  String get scanInstructionRight => 'Show your right cheek';

  @override
  String get scanAdviceTooBright => 'Move to softer light';

  @override
  String get scanAdviceTooDark => 'Find brighter light';

  @override
  String get scanChipLight => 'Good light';

  @override
  String get scanChipCentred => 'Centred';

  @override
  String get scanChipSteady => 'Hold still';

  @override
  String get scanChipNotYet => 'not yet';

  @override
  String scanStatusCountdown(int seconds) {
    return 'Hold still — capturing in ${seconds}s';
  }

  @override
  String get scanStatusManual => 'Or tap the button to take it now';

  @override
  String get scanGallery => 'Choose from gallery';

  @override
  String get scanShutter => 'Take photo';

  @override
  String get scanFlip => 'Switch camera';

  @override
  String get scanCameraPreview => 'Camera view';

  @override
  String scanPhotoOf(String pose) {
    return '$pose photo';
  }

  @override
  String get scanReviewQuestion => 'Is your face clear and well lit?';

  @override
  String get scanRetake => 'Retake';

  @override
  String get scanUsePhoto => 'Use this photo';

  @override
  String get scanAnalyse => 'Analyse my skin';

  @override
  String get scanSaving => 'Saving your photos…';

  @override
  String get scanSaveFailed =>
      'We couldn’t save your photos. Please try again.';

  @override
  String get scanPickFailed =>
      'We couldn’t open that photo. Please try another.';

  @override
  String get scanCaptureFailed => 'The photo didn’t work. Please try again.';

  @override
  String get scanPrivacyNote =>
      'Photos stay on your phone and are never uploaded.';

  @override
  String get scanRationaleTitle => 'Allow camera access';

  @override
  String get scanRationaleBody =>
      'Saaf uses your camera only to take the three photos of your face scan: front, left and right.';

  @override
  String get scanContinue => 'Continue';

  @override
  String get scanNotNow => 'Not now';

  @override
  String get scanDeniedTitle => 'Camera access is off';

  @override
  String get scanDeniedBody =>
      'You can try again, or choose photos from your gallery instead.';

  @override
  String get scanSettingsTitle => 'Turn on the camera in Settings';

  @override
  String get scanSettingsBody =>
      'Camera access is blocked for Saaf. You can allow it in your phone’s Settings, or choose photos from your gallery.';

  @override
  String get scanOpenSettings => 'Open Settings';

  @override
  String get scanTryAgain => 'Try again';

  @override
  String get scanFailedTitle => 'The camera didn’t start';

  @override
  String get scanFailedBody =>
      'Close other apps that use the camera and try again, or choose photos from your gallery.';

  @override
  String resultsOverline(String date) {
    return 'SCAN · $date';
  }

  @override
  String get resultsTitle => 'Here’s your skin today';

  @override
  String get resultsShare => 'Share your result';

  @override
  String get resultsScoreLabel => 'Skin score';

  @override
  String resultsScoreSemantics(int score) {
    return 'Skin score $score out of 100';
  }

  @override
  String get resultsHeadlineGood => 'Good base, two things to work on';

  @override
  String get resultsHeadlineFair => 'A fair start, two things to work on';

  @override
  String get resultsHeadlineNeedsCare =>
      'Your skin needs some care. Start with two things';

  @override
  String resultsFocus(String first, String second) {
    return '$first and $second are your main focus.';
  }

  @override
  String get resultsConcerns => 'Concerns';

  @override
  String get resultsHowWeScore => 'How we score';

  @override
  String get metricDarkSpots => 'Dark spots';

  @override
  String get metricBreakouts => 'Breakouts';

  @override
  String get metricOiliness => 'Oiliness';

  @override
  String get metricHydration => 'Hydration';

  @override
  String get ratingMild => 'Mild';

  @override
  String get ratingModerate => 'Moderate';

  @override
  String get ratingHigh => 'High';

  @override
  String get ratingLow => 'Low';

  @override
  String get ratingFair => 'Fair';

  @override
  String get ratingGood => 'Good';

  @override
  String metricSemantics(String name, String rating) {
    return '$name: $rating';
  }

  @override
  String get resultsDisclaimer =>
      'A cosmetic screening, not a medical diagnosis. See a dermatologist for anything that worries you.';

  @override
  String get resultsSeeRoutine => 'See my routine';

  @override
  String get resultsEmptyTitle => 'No scan yet';

  @override
  String get resultsEmptyBody =>
      'Take your three face photos to see how your skin looks today.';

  @override
  String get resultsEmptyAction => 'Start a scan';

  @override
  String get resultsErrorTitle => 'We couldn’t read your results';

  @override
  String get resultsErrorAction => 'Try again';

  @override
  String resultsShareText(int score, String focus) {
    return 'My Saaf skin score: $score/100. Main focus: $focus. A cosmetic screening, not medical advice.';
  }

  @override
  String get howWeScoreTitle => 'How we score';

  @override
  String get howWeScoreIntro =>
      'Your Saaf skin score is a number from 40 to 100 that sums up how your skin looks today. It is a guide for choosing a routine, not a medical measurement.';

  @override
  String get howWeScoreLooksTitle => 'What we look at';

  @override
  String get howWeScoreSpots =>
      'Dark spots: uneven colour and marks left by the sun or by acne.';

  @override
  String get howWeScoreBreakouts => 'Breakouts: pimples, blackheads and bumps.';

  @override
  String get howWeScoreOil =>
      'Oiliness: shine and visible pores, mostly on the forehead and nose.';

  @override
  String get howWeScoreHydration =>
      'Hydration: how comfortable and smooth your skin looks. This is the only measure where more is better.';

  @override
  String get howWeScoreMathTitle => 'How the number is made';

  @override
  String get howWeScoreMath =>
      'Dark spots, breakouts and oiliness can take up to 40 points off between them. Low hydration can take off up to 20 more. A skin with none of these scores 100.';

  @override
  String get howWeScorePhotosTitle => 'Your photos';

  @override
  String get howWeScorePhotos =>
      'The three photos stay on your phone. They are never uploaded to work out your score.';

  @override
  String get howWeScoreMedicalTitle => 'Not medical advice';

  @override
  String get howWeScoreMedical =>
      'Saaf cannot diagnose skin conditions. If a spot changes, bleeds, itches or worries you, please see a dermatologist.';
}
