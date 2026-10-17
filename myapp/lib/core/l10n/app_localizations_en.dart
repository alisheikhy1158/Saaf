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
      'Your face-scan photos stay on your phone unless you turn on backup. The AI coach only gets photos you choose to send.';

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
  String get scanChipAngle => 'Right angle';

  @override
  String get scanStatusLocked => 'The button unlocks when everything is ready';

  @override
  String get scanFaceNoFace => 'We can’t see your face';

  @override
  String get scanFaceSeveral => 'Only one face, please';

  @override
  String get scanFaceCloser => 'Move a little closer';

  @override
  String get scanFaceBack => 'Move a little back';

  @override
  String get scanFaceCentre => 'Centre your face in the oval';

  @override
  String get scanFaceStraight => 'Look straight at the camera';

  @override
  String get scanFaceTurnLeft => 'Turn your head to your left';

  @override
  String get scanFaceTurnRight => 'Turn your head to your right';

  @override
  String get scanFaceTurnLess => 'Turn back a little';

  @override
  String get scanCheckNoFace =>
      'We couldn’t find a face in this photo. Please retake it.';

  @override
  String get scanCheckSeveral =>
      'There is more than one face in this photo. Please retake it with only you in it.';

  @override
  String get scanCheckPose =>
      'This is not the angle we need for this photo. Please retake it.';

  @override
  String get scanCheckSmall =>
      'Your face is too small in this photo. Move closer and retake it.';

  @override
  String get scanCheckDark =>
      'This photo is too dark. Find brighter light and retake it.';

  @override
  String get scanCheckBright =>
      'This photo is too bright. Move to softer light and retake it.';

  @override
  String get scanUseAnyway => 'Use it anyway';

  @override
  String get scanProductTitle => 'Scan a product';

  @override
  String get scanProductHint =>
      'Point the camera at the barcode or QR code on the pack. Hold it steady.';

  @override
  String get scanProductRationaleBody =>
      'Saaf uses your camera only to read a product’s barcode. Nothing is saved or uploaded.';

  @override
  String get scanProductDeniedBody =>
      'You can still type the barcode number below.';

  @override
  String get scanProductSettingsBody =>
      'Camera access is blocked for Saaf. Allow it in your phone’s Settings, or type the barcode number below.';

  @override
  String get scanProductManualTitle => 'Or type the barcode number';

  @override
  String get scanProductManualLabel => 'Barcode number';

  @override
  String get scanProductManualHint => 'e.g. 3337875743563';

  @override
  String get scanProductLookUp => 'Look up';

  @override
  String get scanProductInvalid =>
      'Enter the 8 to 14 digits printed under the barcode.';

  @override
  String get scanProductPretend => 'Pretend to scan (demo)';

  @override
  String get homeScanTooltip => 'Scan a product';

  @override
  String get aiTitle => 'Ask Saaf AI';

  @override
  String get aiMenuTooltip => 'More';

  @override
  String get aiMenuNewChat => 'New chat';

  @override
  String get aiMenuStop => 'Stop sharing with AI';

  @override
  String get aiDisclaimer =>
      'AI answers can be wrong and are not medical advice. See a dermatologist for painful, spreading or worrying skin changes.';

  @override
  String get aiConsentTitle => 'Before you chat with the AI coach';

  @override
  String get aiConsentIntro =>
      'Ask about your routine, ingredients or products, attach a photo of your skin, or let it review your progress photos. An AI model writes the answer.';

  @override
  String get aiConsentShareTitle => 'What is sent';

  @override
  String get aiConsentShareBody =>
      'Your message, any photo you attach or choose to send (a skin estimate or progress review, or a product label to look up), and a few facts: your skin type, concerns, sensitivity, budget, the names of your routine products and the products you use now, and, to choose products for you, your latest scan scores. Never your name, phone number, side photos, or your pregnancy, medication and allergy answers.';

  @override
  String get aiConsentWhoTitle => 'Who receives it';

  @override
  String get aiConsentWhoBody =>
      'Our server passes it to Groq, which runs an open-source AI model to write the reply. Groq handles it under its own privacy terms. Saaf does not keep your chats on its server.';

  @override
  String get aiConsentChoice => 'You can stop sharing at any time in Profile.';

  @override
  String get aiConsentAgree => 'I agree, start chatting';

  @override
  String get aiPolicyLink => 'Read the Privacy Policy';

  @override
  String get aiEmptyTitle => 'Ask me about your skin care';

  @override
  String get aiEmptyBody =>
      'I can explain ingredients, check your routine and look at photos you attach.';

  @override
  String get aiSuggestRoutine => 'Is my routine right for me?';

  @override
  String get aiSuggestDarkSpots => 'How do I fade dark spots safely?';

  @override
  String get aiSuggestClash => 'Can I use vitamin C and niacinamide together?';

  @override
  String get aiSuggestSunscreen => 'How do I choose a sunscreen?';

  @override
  String get aiInputHint => 'Ask about your skin or routine';

  @override
  String get aiSend => 'Send';

  @override
  String get aiAttach => 'Attach a photo';

  @override
  String get aiTakePhoto => 'Take a photo';

  @override
  String get aiChoosePhoto => 'Choose from gallery';

  @override
  String get aiRemovePhoto => 'Remove photo';

  @override
  String aiPhotosAttached(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count photos',
      one: '1 photo',
    );
    return '$_temp0';
  }

  @override
  String get aiPhotoFailed => 'We couldn’t get that photo. Please try again.';

  @override
  String get aiThinking => 'Thinking…';

  @override
  String get aiAnswerLabel => 'AI answer';

  @override
  String get aiReport => 'Report this answer';

  @override
  String get aiReportTitle => 'What is wrong with this answer?';

  @override
  String get aiReportHarmful => 'Harmful or unsafe';

  @override
  String get aiReportWrong => 'Wrong or misleading';

  @override
  String get aiReportOffensive => 'Offensive';

  @override
  String get aiReportOther => 'Something else';

  @override
  String get aiReported => 'Reported';

  @override
  String get aiReportThanks => 'Thank you. We will review this answer.';

  @override
  String get aiReportFailed =>
      'We couldn’t send your report. Please try again.';

  @override
  String get aiErrorNetwork =>
      'No connection. Check your internet and try again.';

  @override
  String get aiErrorLimit =>
      'You’ve reached today’s limit. Please try again tomorrow.';

  @override
  String get aiErrorUnavailable =>
      'The AI coach isn’t available right now. Please try again later.';

  @override
  String get aiErrorSignIn => 'Please sign in again to use the AI coach.';

  @override
  String get aiErrorGeneric => 'Something went wrong. Please try again.';

  @override
  String get homeAiTooltip => 'Ask the AI coach';

  @override
  String get profileRowAi => 'AI coach sharing';

  @override
  String get profileValueOn => 'On';

  @override
  String get aiSheetTitle => 'AI coach sharing';

  @override
  String get aiSheetBody =>
      'When on, your questions and the photos you attach are sent to the AI coach, as described in the Privacy Policy. Turning it off also clears the conversation.';

  @override
  String get aiSheetSwitch => 'Share with the AI coach';

  @override
  String progressNextScan(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: '1 day',
    );
    return 'Next scan in $_temp0';
  }

  @override
  String get progressScanDue => 'Your 2-week scan is due';

  @override
  String get progressScanNow => 'Scan now';

  @override
  String get progressAiTitle => 'AI progress review';

  @override
  String get progressAiBody =>
      'Let the AI coach look at your photos from the start until now and explain what has changed.';

  @override
  String get progressAiButton => 'Review my progress with AI';

  @override
  String get progressAiSetup => 'Set up the AI coach';

  @override
  String get progressAiConfirmTitle => 'Send these photos to the AI?';

  @override
  String get progressAiConfirmBody =>
      'Only the front photos below are sent, to the AI coach (Groq, through Saaf’s server), to describe what changed. Your side photos stay on your phone.';

  @override
  String get progressAiSend => 'Send';

  @override
  String get progressAiPhotoError =>
      'We couldn’t prepare your photos. Please try again.';

  @override
  String progressAiPhotoSemantics(String date) {
    return 'Photo from $date';
  }

  @override
  String get aiReviewQuestion =>
      'Please compare my face photos over time and tell me, in general terms, what has changed in my skin and what I should do next.';

  @override
  String aiReviewFirst(int n, String date) {
    return 'Photo $n is my first scan, taken $date.';
  }

  @override
  String aiReviewMiddle(int n, String date) {
    return 'Photo $n was taken $date.';
  }

  @override
  String aiReviewLatest(int n, String date) {
    return 'Photo $n is my latest scan, taken $date.';
  }

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
      'Photos stay on your phone unless you choose to send them to the AI coach.';

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
      'Your Saaf skin score is a number from 40 to 100 that sums up how your skin looks in your front photo, as Saaf AI sees it. It is a rough guide for choosing a routine, not a medical measurement.';

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
      'Saaf AI estimates the four measures from your front photo. It is sent only after you say yes (to Groq, through Saaf’s server) and is not kept there; your side photos stay on your phone. Each measure says how sure Saaf AI is, and there are no numbers until a photo is analysed.';

  @override
  String get howWeScoreMedicalTitle => 'Not medical advice';

  @override
  String get howWeScoreMedical =>
      'Saaf cannot diagnose skin conditions. If a spot changes, bleeds, itches or worries you, please see a dermatologist.';

  @override
  String get routineTitle => 'Your routine';

  @override
  String routineFor(String concerns) {
    return 'For $concerns';
  }

  @override
  String get routineForGeneral => 'For everyday skin health';

  @override
  String routineBudget(String amount) {
    return 'Budget $amount/month';
  }

  @override
  String get routineBudgetNoLimit => 'No budget limit';

  @override
  String routineSubtitle(String forText, String budgetText) {
    return '$forText · $budgetText';
  }

  @override
  String routineAnd(String first, String second) {
    return '$first & $second';
  }

  @override
  String get concernDarkSpots => 'dark spots';

  @override
  String get concernAcne => 'breakouts';

  @override
  String get concernOiliness => 'oiliness';

  @override
  String get concernDryness => 'dryness';

  @override
  String get concernUnevenTone => 'uneven tone';

  @override
  String priceRs(String amount) {
    return 'Rs $amount';
  }

  @override
  String get routineMorning => 'Morning';

  @override
  String get routineNight => 'Night';

  @override
  String get routineTabsLabel => 'Time of day';

  @override
  String routineSummary(int count, int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count steps',
      one: '1 step',
    );
    return '$_temp0 · about $minutes min';
  }

  @override
  String routineTotal(String price) {
    return '$price total';
  }

  @override
  String routineStepLine(int number, String category) {
    return 'Step $number · $category';
  }

  @override
  String get stepCleanser => 'Cleanser';

  @override
  String get stepTreatment => 'Treatment';

  @override
  String get stepMoisturiser => 'Moisturiser';

  @override
  String get stepSunscreen => 'Sun protection';

  @override
  String get routineResultsTitle => 'Results in 6–8 weeks';

  @override
  String routineResultsBody(String date) {
    return 'Use it every day. Your next progress photo is on $date.';
  }

  @override
  String get routineResultsBodyNoDate =>
      'Use it every day and check your progress every two weeks.';

  @override
  String get routineStart => 'Start my routine';

  @override
  String get routineOverBudget => 'This is a little over your monthly budget.';

  @override
  String get routinePriceNote => 'Prices are a guide and may differ in shops.';

  @override
  String get routineReminders => 'Reminders';

  @override
  String get routineEmptyTitle => 'We couldn’t build a routine yet';

  @override
  String get routineEmptyBody =>
      'Answer the skin quiz and we will pick products for you.';

  @override
  String get routineEmptyAction => 'Take the skin quiz';

  @override
  String get routineErrorTitle => 'We couldn’t load your routine';

  @override
  String get routineErrorAction => 'Try again';

  @override
  String get navHome => 'Home';

  @override
  String get navScan => 'Scan';

  @override
  String get navProgress => 'Progress';

  @override
  String get navProfile => 'Profile';

  @override
  String homeGreeting(String name) {
    return 'Salam, $name';
  }

  @override
  String get homeGreetingNoName => 'Salam';

  @override
  String get homeProgressLabel => 'Today’s progress';

  @override
  String homeStepsDone(int done, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$total steps',
      one: '1 step',
    );
    return '$done of $_temp0 done';
  }

  @override
  String homeProgressSemantics(int percent) {
    return '$percent percent of today’s routine done';
  }

  @override
  String get homeRoutineTitle => 'Today’s routine';

  @override
  String homeSwitchTime(String time) {
    return 'Show the $time routine';
  }

  @override
  String homeStepCaption(String category, String price) {
    return '$category · $price';
  }

  @override
  String homeStepDone(String name) {
    return '$name, done';
  }

  @override
  String homeStepNotDone(String name) {
    return '$name, not done yet';
  }

  @override
  String homeDayComplete(String day) {
    return '$day, all steps done';
  }

  @override
  String homeDayOpen(String day) {
    return '$day';
  }

  @override
  String homeToday(String day) {
    return '$day, today';
  }

  @override
  String get homeWeekLabel => 'This week';

  @override
  String get homeErrorTitle => 'We couldn’t load today’s routine';

  @override
  String get homeErrorAction => 'Try again';

  @override
  String get productScanTitle => 'Scan result';

  @override
  String get productShare => 'Share this product';

  @override
  String productShareText(String brand, String name, String price) {
    return '$brand $name: from $price on Saaf. Cosmetic guidance only.';
  }

  @override
  String get productBarcodeMatched => 'Barcode matched';

  @override
  String get productFitGood => 'Good match for you';

  @override
  String get productFitCareful => 'Use with care';

  @override
  String get productFitAvoid => 'Not recommended for you';

  @override
  String get productAllSkin => 'All skin types';

  @override
  String get productAcneProne => 'Acne-prone';

  @override
  String get clashNiacinamideVitaminCTitle => 'Don’t mix with Vitamin C';

  @override
  String get clashMoveToNight =>
      'Use this at night if your morning routine has Vitamin C.';

  @override
  String get clashMoveToMorning =>
      'Use this in the morning if your night routine has Vitamin C.';

  @override
  String get clashDifferentDays =>
      'Use it on different days from your Vitamin C.';

  @override
  String get clashRetinolExfoliantsTitle =>
      'Don’t layer with exfoliating acids';

  @override
  String get clashRetinolExfoliants =>
      'Use them on different nights to avoid irritation.';

  @override
  String get clashBenzoylRetinolTitle => 'Don’t layer with benzoyl peroxide';

  @override
  String get clashBenzoylRetinol =>
      'Use them at different times of day to avoid irritation.';

  @override
  String get productCarefulTitle => 'Check before you use it';

  @override
  String get productCarefulBody =>
      'It may not suit your skin type or sensitivity. Test a small patch first.';

  @override
  String get productAvoidTitle => 'Usually avoided for you';

  @override
  String get productAvoidBody =>
      'Your answers say products like this are best avoided. Ask a doctor or pharmacist first.';

  @override
  String get productWhereToBuy => 'Where to buy';

  @override
  String get productCheckPrice => 'Check price';

  @override
  String get productPricesVary => 'Prices vary by shop';

  @override
  String get productPricesToday => 'Prices today';

  @override
  String productPricesAsOf(String date) {
    return 'Prices as of $date';
  }

  @override
  String get productBuy => 'Buy';

  @override
  String productBuySemantics(String store, String price) {
    return 'Buy from $store for $price';
  }

  @override
  String get productAffiliate =>
      'Some Buy links may earn Saaf a small commission. It never changes your price.';

  @override
  String get productDisclaimer =>
      'Ingredient advice is general guidance, not medical advice.';

  @override
  String get productLinkFailed => 'We couldn’t open that link.';

  @override
  String get productNoneTitle => 'No product scanned yet';

  @override
  String get productNoneBody =>
      'Scan a product barcode to see if it suits your skin.';

  @override
  String get productNoneAction => 'Go to Home';

  @override
  String get productNotFoundTitle => 'We couldn’t find that product';

  @override
  String get productNotFoundBody =>
      'Saaf AI can search the web for it instead.';

  @override
  String get productErrorTitle => 'We couldn’t load this product';

  @override
  String get productErrorAction => 'Try again';

  @override
  String get checkInTitle => 'Weekly check-in';

  @override
  String get checkInInfo => 'About check-ins';

  @override
  String checkInWeek(int week) {
    return 'Week $week of your routine';
  }

  @override
  String checkInGreeting(String name) {
    return 'Salam $name! How has your skin felt this week?';
  }

  @override
  String get checkInGreetingNoName =>
      'Salam! How has your skin felt this week?';

  @override
  String get checkInFeelLessOily => 'Less oily than before';

  @override
  String get checkInFeelSame => 'About the same';

  @override
  String get checkInFeelDrier => 'Drier or tighter';

  @override
  String get checkInFeelIrritated => 'More irritated';

  @override
  String get checkInQ2Nice => 'Nice. Any new breakouts since last week?';

  @override
  String get checkInQ2Thanks => 'Thanks. Any new breakouts since last week?';

  @override
  String get checkInQ2Noted => 'Got it. Any new breakouts since last week?';

  @override
  String get checkInQ2Sorry =>
      'Sorry to hear that. Any new breakouts since last week?';

  @override
  String get checkInBreakNone => 'No new ones';

  @override
  String get checkInBreakFew => '1–2 small ones';

  @override
  String get checkInBreakMore => 'A few more than before';

  @override
  String get checkInBreakSevere => 'Many or painful';

  @override
  String get checkInOnTrack => 'Likely on track';

  @override
  String get checkInKeepGoing => 'Keep going';

  @override
  String get checkInAdjust => 'Let’s adjust a little';

  @override
  String get checkInSeePro => 'Please check with a professional';

  @override
  String get checkInSentenceLessOily => 'Oil control is improving.';

  @override
  String get checkInSentenceSame => 'Your skin feels about the same.';

  @override
  String get checkInSentenceDrier =>
      'Your skin feels drier, which is common with new products.';

  @override
  String get checkInSentenceIrritated => 'Your skin feels irritated.';

  @override
  String get checkInSentenceNone => 'No new breakouts is a good sign.';

  @override
  String checkInSentenceFew(int week) {
    return 'A few small breakouts are common in week $week.';
  }

  @override
  String get checkInSentenceMore =>
      'More breakouts than before can happen while skin adjusts.';

  @override
  String get checkInSentenceSevere =>
      'Many or painful breakouts need a professional look.';

  @override
  String get checkInAdviceOnTrack => 'Keep going and try not to pick.';

  @override
  String get checkInAdviceKeepGoing =>
      'Results usually take 6–8 weeks, so keep going.';

  @override
  String get checkInAdviceAdjust =>
      'Try a richer moisturiser and use strong products less often. If nothing changes in two weeks, ask a pharmacist.';

  @override
  String get checkInAdviceSeePro =>
      'Pause any new products and ask a dermatologist or pharmacist, especially if it is painful or keeps getting worse.';

  @override
  String checkInNextPhoto(String date) {
    return 'Next photo check · $date';
  }

  @override
  String get checkInHint => 'Reply in English or Urdu…';

  @override
  String get checkInSend => 'Send';

  @override
  String get checkInNoteSaved =>
      'Thanks, I’ve saved your note for your next check-in.';

  @override
  String get checkInCoachInitial => 'S';

  @override
  String checkInCoachSays(String text) {
    return 'Saaf says: $text';
  }

  @override
  String checkInYouSaid(String text) {
    return 'You said: $text';
  }

  @override
  String checkInResultSemantics(String title, String body) {
    return 'Result: $title. $body';
  }

  @override
  String get checkInInfoTitle => 'About check-ins';

  @override
  String get checkInInfoBody =>
      'Your check-in uses simple rules, not AI. Your answers are kept on your phone. It cannot diagnose skin conditions: if something worries you, please see a dermatologist.';

  @override
  String get checkInInfoClose => 'Got it';

  @override
  String get paywallProChip => 'Saaf Pro';

  @override
  String get paywallTitle => 'See real change,\nevery two weeks';

  @override
  String get paywallBenefitPhotos => 'Aligned photo comparisons every 2 weeks';

  @override
  String get paywallBenefitScans => 'Unlimited skin and product scans';

  @override
  String get paywallBenefitAlerts => 'Price-drop alerts on your products';

  @override
  String get paywallBenefitCoach => 'Weekly coach check-ins and reports';

  @override
  String get planYearly => 'Yearly';

  @override
  String get planMonthly => 'Monthly';

  @override
  String planSave(int percent) {
    return 'Save $percent%';
  }

  @override
  String planPerMonthBilledYearly(String price) {
    return '$price/month, billed yearly';
  }

  @override
  String get planCancelAnytime => 'Cancel anytime';

  @override
  String planSemantics(String title, String price, String caption) {
    return '$title. $price. $caption';
  }

  @override
  String paywallStartTrial(int days) {
    return 'Start $days-day free trial';
  }

  @override
  String get paywallSubscribe => 'Subscribe';

  @override
  String get paywallPeriodYear => 'year';

  @override
  String get paywallPeriodMonth => 'month';

  @override
  String get paywallStoreApple => 'the App Store';

  @override
  String get paywallStoreGoogle => 'Google Play';

  @override
  String get paywallStoreOther => 'your store settings';

  @override
  String paywallFinePrintTrial(
    int days,
    String price,
    String period,
    String store,
  ) {
    return 'Free for $days days, then $price/$period. Cancel anytime in $store.';
  }

  @override
  String paywallFinePrint(String price, String period, String store) {
    return '$price/$period. Renews automatically. Cancel anytime in $store.';
  }

  @override
  String get paywallRestore => 'Restore purchases';

  @override
  String get paywallRestored => 'Welcome back to Saaf Pro.';

  @override
  String get paywallNothingToRestore => 'No earlier purchase found.';

  @override
  String get paywallRestoreFailed =>
      'We couldn’t check your purchases. Please try again.';

  @override
  String get paywallPurchaseFailed =>
      'We couldn’t complete the purchase. You have not been charged.';

  @override
  String get paywallClose => 'Close';

  @override
  String get paywallUnavailableTitle =>
      'Subscriptions aren’t available right now';

  @override
  String get paywallUnavailableBody => 'Please try again later.';

  @override
  String get paywallRetry => 'Try again';

  @override
  String get paywallAlreadyProTitle => 'You’re on Saaf Pro';

  @override
  String paywallAlreadyProBody(String store) {
    return 'Thank you for supporting Saaf. You can manage your plan in $store.';
  }

  @override
  String progressWeek(int week) {
    return 'WEEK $week';
  }

  @override
  String get progressTitle => 'Your progress';

  @override
  String get progressShare => 'Share your progress';

  @override
  String progressShareText(int week, String first, String second) {
    return 'My Saaf progress, week $week: $first, $second. A cosmetic guide, not medical advice.';
  }

  @override
  String progressRange(String from, String to, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count aligned photos',
      one: '1 aligned photo',
    );
    return '$from → $to  ·  $_temp0';
  }

  @override
  String progressBefore(String date) {
    return 'Before · $date';
  }

  @override
  String progressAfter(String date) {
    return 'After · $date';
  }

  @override
  String get progressCompare => 'Compare before and after';

  @override
  String progressVs(String date) {
    return 'vs $date';
  }

  @override
  String progressChangeSemantics(String name, String change, String since) {
    return '$name: $change $since';
  }

  @override
  String get progressCoach => 'Coach summary';

  @override
  String progressSummaryImproving(String metric) {
    return 'Good news: $metric improved. Daily sun protection keeps the progress, so keep it up.';
  }

  @override
  String progressSummarySteady(String date) {
    return 'Your skin looks steady since $date. Results often take 6–8 weeks, so keep going.';
  }

  @override
  String get progressSummarySlipping =>
      'Some areas look a little worse than last time. Check your routine and sun protection, and see a dermatologist if you are worried.';

  @override
  String get progressLockedTitle => 'Progress tracking is part of Saaf Pro';

  @override
  String get progressLockedBody =>
      'Compare aligned photos every two weeks and see what is changing.';

  @override
  String get progressLockedAction => 'See Saaf Pro';

  @override
  String get progressEmptyTitle => 'Your first comparison is on its way';

  @override
  String get progressEmptyBody =>
      'Take another face scan in two weeks and Saaf will show what changed.';

  @override
  String get progressEmptyAction => 'Take a scan';

  @override
  String get progressErrorTitle => 'We couldn’t load your progress';

  @override
  String get progressErrorAction => 'Try again';

  @override
  String get progressCheckIn => 'Start your weekly check-in';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileNameFallback => 'Saaf member';

  @override
  String profilePhoneFallback(String digits) {
    return 'Phone ending $digits';
  }

  @override
  String profileSkinType(String type) {
    return '$type skin';
  }

  @override
  String get profilePlanFree => 'You’re on the free plan';

  @override
  String get profilePlanFreeBody => 'Unlock photo tracking every 2 weeks';

  @override
  String get profileGoPro => 'Go Pro';

  @override
  String get profilePlanPro => 'You’re on Saaf Pro';

  @override
  String get profilePlanProBody => 'Thank you for supporting Saaf';

  @override
  String get profileManage => 'Manage';

  @override
  String get profileSectionRoutine => 'Routine';

  @override
  String get profileSectionPrivacy => 'Privacy';

  @override
  String get profileSectionApp => 'App';

  @override
  String get profileRowSkin => 'Skin profile';

  @override
  String get profileRowBudget => 'Monthly budget';

  @override
  String get profileRowReminders => 'Reminders';

  @override
  String get profileRowLanguage => 'Language';

  @override
  String get profileRowAppearance => 'Appearance';

  @override
  String get profileRowBackup => 'Photo backup';

  @override
  String get profileRowDelete => 'Delete my account';

  @override
  String get profileRowLogout => 'Log out';

  @override
  String profileRowSemantics(String title, String value) {
    return '$title, $value';
  }

  @override
  String get profileValueNotSet => 'Not set';

  @override
  String get profileValueOff => 'Off';

  @override
  String get profileValueNoLimit => 'No limit';

  @override
  String get profileLangEnglish => 'English';

  @override
  String get profileLangUrdu => 'اردو';

  @override
  String get profileThemeSystem => 'System';

  @override
  String get profileThemeLight => 'Light';

  @override
  String get profileThemeDark => 'Dark';

  @override
  String get commonDone => 'Done';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get quizTissueEntry => 'Not sure? Try the tissue test';

  @override
  String get tissueTitle => 'Tissue test';

  @override
  String get tissueIntro =>
      'A simple way to see how oily your skin is. It takes a minute, plus a short wait.';

  @override
  String get tissueStep1 =>
      'Wash your face with a gentle cleanser and pat it dry. Don’t put anything on it.';

  @override
  String get tissueStep2 =>
      'Wait about 30 minutes to an hour, so your skin settles back to normal.';

  @override
  String get tissueStep3 =>
      'Press a clean tissue or blotting paper lightly on your forehead, nose and cheeks, one at a time.';

  @override
  String get tissueStep4 =>
      'Hold the tissue up to the light and look for oily marks.';

  @override
  String get tissueDone => 'I’ve done the test';

  @override
  String get tissueQuestionTitle => 'What did you see?';

  @override
  String get tissueQuestionHint =>
      'Switch on each place where the tissue had an oily mark. Leave all off if it stayed clean.';

  @override
  String get tissueForehead => 'Oil mark from my forehead';

  @override
  String get tissueNose => 'Oil mark from my nose';

  @override
  String get tissueCheeks => 'Oil mark from my cheeks';

  @override
  String get tissueTight => 'My skin feels tight or flaky';

  @override
  String get tissueOptionCaption => 'Tap if this applies';

  @override
  String tissueResultTitle(String type) {
    return 'Your skin looks $type';
  }

  @override
  String get tissueResultOily =>
      'Oil on your forehead and cheeks suggests oily skin.';

  @override
  String get tissueResultCombination =>
      'Oil only on the forehead and nose, with clearer cheeks, suggests combination skin.';

  @override
  String get tissueResultNormal =>
      'A clean tissue and comfortable skin suggests normal skin.';

  @override
  String get tissueResultDry =>
      'A clean tissue with tight or flaky skin suggests dry skin.';

  @override
  String get tissueResultUnclear =>
      'Oil on your cheeks but not your forehead or nose is unusual. Try the test again on another day.';

  @override
  String get tissueUnclearTitle => 'We can’t tell yet';

  @override
  String get tissueUse => 'Use this result';

  @override
  String get tissueCaveat =>
      'This is a guide, not a diagnosis. Skin changes with the weather and the time of the month, so repeat it on another day if you’re unsure.';

  @override
  String get commonSave => 'Save';

  @override
  String get profileDetailsTitle => 'Your details';

  @override
  String get profileDetailsName => 'Name';

  @override
  String get profileDetailsNameHint => 'What should we call you?';

  @override
  String get profileDetailsAge => 'Age (optional)';

  @override
  String get profileDetailsHelp => 'Only stored on this phone.';

  @override
  String get profileDetailsNameError => 'Enter a name of up to 40 letters.';

  @override
  String get profileDetailsAgeError => 'Enter an age from 16 to 99.';

  @override
  String get profileDetailsEditSemantics => 'Edit your name and age';

  @override
  String get profileSkinSheetTitle => 'Skin profile';

  @override
  String get profileRowSkinType => 'Skin type';

  @override
  String get profileRowConcerns => 'Skin concerns';

  @override
  String get profileRowSensitivity => 'Sensitivity';

  @override
  String get profileRowSafety => 'Health & safety';

  @override
  String get profileValueNone => 'None';

  @override
  String get languageTitle => 'Language';

  @override
  String get languageSemantics => 'Language';

  @override
  String get appearanceTitle => 'Appearance';

  @override
  String get remindersTitle => 'Reminders';

  @override
  String get remindersMorning => 'Morning routine';

  @override
  String get remindersNight => 'Night routine';

  @override
  String remindersChange(String name) {
    return 'Change the time of $name';
  }

  @override
  String get remindersNote => 'Saaf reminds you every day at these times.';

  @override
  String get remindersRationaleTitle => 'Allow notifications';

  @override
  String get remindersRationaleBody =>
      'Saaf sends one gentle reminder for your morning routine and one for your night routine, at the times you choose. Nothing else.';

  @override
  String get remindersDeniedNote =>
      'Notifications are off, so reminders can’t be sent. You can try again any time.';

  @override
  String get remindersBlockedNote =>
      'Notifications are blocked for Saaf. Allow them in your phone’s Settings to get reminders.';

  @override
  String get reminderNotificationMorningTitle =>
      'Time for your morning routine';

  @override
  String get reminderNotificationMorningBody =>
      'Cleanse, moisturise and put on sunscreen. It only takes a few minutes.';

  @override
  String get reminderNotificationNightTitle => 'Time for your night routine';

  @override
  String get reminderNotificationNightBody =>
      'Cleanse and moisturise, then rest well.';

  @override
  String get backupTitle => 'Photo backup';

  @override
  String get backupBody =>
      'Your face photos stay only on this phone. The one exception is photos you choose to send for an AI review. Cloud backup is not available in this version.';

  @override
  String get deleteTitle => 'Delete your account?';

  @override
  String get deleteBody =>
      'This removes your account and everything Saaf keeps about you on this phone: your scans and photos, your answers, your routine and your check-ins. This cannot be undone.';

  @override
  String get deleteConfirm => 'Delete everything';

  @override
  String get deleteFailedRecent =>
      'For your security, please log in again and then delete your account.';

  @override
  String get deleteFailed =>
      'We couldn’t delete your account. Please try again.';

  @override
  String get logoutTitle => 'Log out?';

  @override
  String get logoutBody =>
      'You can log back in with your phone number, Google or Apple.';

  @override
  String get logoutConfirm => 'Log out';

  @override
  String get aiPicksOfferTitle => 'Let Saaf AI choose your products';

  @override
  String get aiPicksOfferBody =>
      'It searches the web, including Reddit’s r/PakistaniSkincare, for products sold in Pakistan that suit your skin, scan and budget, and reviews the products you use now.';

  @override
  String get aiPicksTurnOn => 'Turn on Saaf AI';

  @override
  String get aiPicksLoading =>
      'Saaf AI is searching the web for products for your skin. This can take a minute…';

  @override
  String get aiPicksFailed =>
      'Saaf AI couldn’t choose right now, so these are our picks.';

  @override
  String get aiPicksLabel => 'Picked by Saaf AI';

  @override
  String get aiPicksWhy => 'Why these products';

  @override
  String get aiPicksHide => 'Hide the reasons';

  @override
  String get aiPicksNote =>
      'AI picks can be wrong and prices change. Check the label and patch test anything new.';

  @override
  String get productAiTitle => 'Saaf AI look-up';

  @override
  String get productAiPhotoTitle => 'Look up a product from a photo';

  @override
  String get productAiPhotoBody =>
      'Take a clear photo of the front label. Only this photo, with your skin type and concerns, goes to Saaf AI (Groq, through Saaf’s server). It reads the label and searches the web.';

  @override
  String get productAiCodeTitle => 'Look this product up with Saaf AI';

  @override
  String productAiBarcodeBody(String code) {
    return 'Barcode $code. Only this number, with your skin type and concerns, goes to Saaf AI (Groq, through Saaf’s server), which searches the web for the product.';
  }

  @override
  String productAiQrBody(String text) {
    return 'The QR code says: $text\nOnly this text, with your skin type and concerns, goes to Saaf AI (Groq, through Saaf’s server), which searches the web for the product. Saaf does not open the link.';
  }

  @override
  String get productAiTakePhoto => 'Take a photo';

  @override
  String get productAiChoosePhoto => 'Choose from gallery';

  @override
  String get productAiRetake => 'Retake photo';

  @override
  String get productAiPhotoLabel => 'Photo of the product to send';

  @override
  String get productAiLookUp => 'Look it up';

  @override
  String get productAiSearching => 'Saaf AI is searching the web…';

  @override
  String get productAiNotFoundTitle =>
      'Saaf AI couldn’t tell which product this is';

  @override
  String get productAiNotFoundPhoto =>
      'Try a clear, close photo of the front label in good light.';

  @override
  String get productAiNotFoundCode => 'Try a photo of the front label instead.';

  @override
  String get productAiNotWebChecked =>
      'Saaf AI couldn’t search the web this time, so this is from what it already knows. Check the label.';

  @override
  String get productAiScanAnother => 'Scan another product';

  @override
  String get productAiNeedsConsent =>
      'Saaf AI is off. Turn it on to look products up and to ask about your skin.';

  @override
  String get scanProductCantScanTitle => 'Can’t scan it?';

  @override
  String get scanProductPhotoButton => 'Take a photo of the product';

  @override
  String get productNotFoundAction => 'Look it up with Saaf AI';

  @override
  String aiPicksPeopleSay(String text) {
    return 'What people say: $text';
  }

  @override
  String get aiPicksSources => 'Sources';

  @override
  String aiPicksSourceLink(String site) {
    return 'Open $site';
  }

  @override
  String get currentTitle => 'Products you use now';

  @override
  String get currentVerdictKeep => 'Keep';

  @override
  String get currentVerdictReplace => 'Replace';

  @override
  String get currentVerdictStop => 'Stop';

  @override
  String currentUseInstead(String name) {
    return 'Use instead: $name';
  }

  @override
  String get currentCautionPregnancy =>
      'From your answers: ask a doctor before using this while pregnant or breastfeeding.';

  @override
  String get currentCautionPrescription =>
      'From your answers: check with your doctor first, as you use a prescription skin treatment.';

  @override
  String get currentCautionSensitive =>
      'Your skin often reacts: patch test first and use it slowly.';

  @override
  String get currentAdd => 'Add the products you use';

  @override
  String get currentEdit => 'Edit your products';

  @override
  String get myProductsTitle => 'Products you use now';

  @override
  String get myProductsBody =>
      'Add the skin care products you use now, like your face wash, cream or sunscreen. Saaf AI will tell you which to keep and which to change.';

  @override
  String get myProductsFieldLabel => 'Product name';

  @override
  String get myProductsFieldHint => 'For example: Nivea Soft';

  @override
  String get myProductsAdd => 'Add';

  @override
  String get myProductsEmpty => 'No products added yet.';

  @override
  String get myProductsFull => 'You can add up to 10 products.';

  @override
  String myProductsRemove(String name) {
    return 'Remove $name';
  }

  @override
  String get myProductsPrivacy =>
      'These names stay on your phone. They go to Saaf AI only if you turn it on.';

  @override
  String get profileRowProducts => 'Products you use';

  @override
  String profileProductsValue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count products',
      one: '1 product',
      zero: 'None',
    );
    return '$_temp0';
  }

  @override
  String get checkPricesOnline => 'Check prices online';

  @override
  String get myProductsStepLabel => 'What is it?';

  @override
  String get myProductsStepOther => 'Something else';

  @override
  String get myProductsChooseStep => 'Choose what kind of product it is.';

  @override
  String get routineYours => 'Yours';

  @override
  String get resultsAnalysePhoto => 'Analyse my photo with Saaf AI';

  @override
  String get resultsAnalyseConfirmTitle => 'Send your front photo?';

  @override
  String get resultsAnalyseConfirmBody =>
      'Only this front photo goes to Saaf AI (Groq, through Saaf’s server) to estimate the four measures. It is not kept there. Your side photos stay on your phone.';

  @override
  String get resultsAnalyseSend => 'Send';

  @override
  String get resultsAnalysing => 'Saaf AI is looking at your photo…';

  @override
  String resultsAnalyseUnusable(String problem) {
    return 'Saaf AI couldn’t judge this photo: $problem Try a new scan in good light.';
  }

  @override
  String get resultsAiTitle => 'Estimated by Saaf AI from your photo';

  @override
  String get resultsAiAccuracy =>
      'A rough estimate from one phone photo, not a measurement. Light, angle, make-up and the camera all change it, so watch the trend over several scans.';

  @override
  String get resultsAiSeen => 'What Saaf AI saw';

  @override
  String resultsHowSure(String level) {
    return 'How sure: $level';
  }

  @override
  String get confidenceLow => 'Low';

  @override
  String get confidenceMedium => 'Medium';

  @override
  String get confidenceHigh => 'High';

  @override
  String get resultsFrontPhotoLabel => 'Your front photo';

  @override
  String get resultsNotAnalysedTitle => 'Not analysed yet';

  @override
  String get resultsNotAnalysedBody =>
      'Saaf AI reads your front photo to estimate dark spots, breakouts, oiliness and hydration. Until then there are no numbers here, never a guess.';

  @override
  String get progressNotAnalysedTitle => 'Skin measures not analysed yet';

  @override
  String get progressNotAnalysedBody =>
      'Saaf AI reads the front photos of both scans to see what changed. Until both are analysed there are no numbers here.';

  @override
  String get progressAnalyse => 'Analyse with Saaf AI';

  @override
  String get progressAnalyseConfirmTitle => 'Send your front photos?';

  @override
  String get progressAnalyseConfirmBody =>
      'Only the front photos of these scans go to Saaf AI (Groq, through Saaf’s server) to estimate the four measures. They are not kept there. Your side photos stay on your phone.';

  @override
  String get progressAnalyseFailed =>
      'Saaf AI couldn’t analyse every scan. Try again, or take a new scan in good light.';
}
