import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ur.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ur'),
  ];

  /// The app name, shown in the app switcher and wordmark.
  ///
  /// In en, this message translates to:
  /// **'Saaf'**
  String get appName;

  /// Screen 01 (Welcome) headline.
  ///
  /// In en, this message translates to:
  /// **'Clear skin, made simple.'**
  String get welcomeTitle;

  /// Screen 01 subtitle under the headline.
  ///
  /// In en, this message translates to:
  /// **'A skincare coach for South Asian skin. Routines built from products you can actually buy in Pakistan.'**
  String get welcomeSubtitle;

  /// Chip on the Welcome hero.
  ///
  /// In en, this message translates to:
  /// **'For South Asian skin'**
  String get welcomeChip;

  /// Caption of the example stat card on the Welcome hero. Must say it is an example (store rule: no unsubstantiated claims).
  ///
  /// In en, this message translates to:
  /// **'Example: dark spots'**
  String get welcomeStatCaption;

  /// Value of the example stat card on the Welcome hero.
  ///
  /// In en, this message translates to:
  /// **'−32% in 8 weeks'**
  String get welcomeStatValue;

  /// Primary button on the Welcome screen.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get getStarted;

  /// Text button on the Welcome screen for returning users.
  ///
  /// In en, this message translates to:
  /// **'I already have an account'**
  String get alreadyHaveAccount;

  /// Screen-reader label of the language switch.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Language switch option.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// Language switch option.
  ///
  /// In en, this message translates to:
  /// **'Urdu'**
  String get languageUrdu;

  /// Tooltip / screen-reader label of the back button in the top bar.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// Screen 04 (Privacy consent) headline. This promise is contractual: the code must make it true.
  ///
  /// In en, this message translates to:
  /// **'Your photos stay\non your phone'**
  String get consentTitle;

  /// Screen 04 subtitle.
  ///
  /// In en, this message translates to:
  /// **'Saaf checks your skin, not your identity. Here’s how we look after your data.'**
  String get consentSubtitle;

  /// Screen 04 privacy point 1 title.
  ///
  /// In en, this message translates to:
  /// **'Saved on your device'**
  String get consentPointDeviceTitle;

  /// Screen 04 privacy point 1 text.
  ///
  /// In en, this message translates to:
  /// **'Your face-scan photos stay on your phone unless you turn on backup. The AI coach only gets photos you choose to send.'**
  String get consentPointDeviceBody;

  /// Screen 04 privacy point 2 title.
  ///
  /// In en, this message translates to:
  /// **'Never sold or shared'**
  String get consentPointNeverSoldTitle;

  /// Screen 04 privacy point 2 text.
  ///
  /// In en, this message translates to:
  /// **'Brands and advertisers never see your face data.'**
  String get consentPointNeverSoldBody;

  /// Screen 04 privacy point 3 title.
  ///
  /// In en, this message translates to:
  /// **'Delete anytime'**
  String get consentPointDeleteTitle;

  /// Screen 04 privacy point 3 text.
  ///
  /// In en, this message translates to:
  /// **'Remove your account and every photo in one tap.'**
  String get consentPointDeleteBody;

  /// Consent checkbox on screen 04. {terms} and {privacy} become tappable links (the names of the two documents).
  ///
  /// In en, this message translates to:
  /// **'I agree to the {terms} and {privacy}'**
  String consentAgree(String terms, String privacy);

  /// Age confirmation checkbox on screen 04.
  ///
  /// In en, this message translates to:
  /// **'I am 16 or older'**
  String get consentAge;

  /// Primary button on screen 04. Disabled until both boxes are ticked.
  ///
  /// In en, this message translates to:
  /// **'Agree and continue'**
  String get consentContinue;

  /// Name of the Terms of Use document.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get termsTitle;

  /// Name of the Privacy Policy document.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicyTitle;

  /// Screen-reader action that opens a legal document.
  ///
  /// In en, this message translates to:
  /// **'Open {name}'**
  String openDocumentAction(String name);

  /// Shown on the Terms / Privacy pages until a lawyer has reviewed them (LegalConfig.isReviewed). Must not ship to the stores.
  ///
  /// In en, this message translates to:
  /// **'Draft: pending legal review'**
  String get legalDraftBanner;

  /// Date line under the title of a legal document.
  ///
  /// In en, this message translates to:
  /// **'Last updated {date}'**
  String legalLastUpdated(String date);

  /// Shown above the legal text when the app language is not English.
  ///
  /// In en, this message translates to:
  /// **'This document is currently available in English only.'**
  String get legalEnglishOnlyNote;

  /// Overline above each quiz question (shown in capitals).
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String quizStepLabel(int current, int total);

  /// Skip the current quiz question.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get quizSkip;

  /// Continue to the next quiz step. Disabled until an answer is picked.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get quizNext;

  /// Quiz question (screen 05).
  ///
  /// In en, this message translates to:
  /// **'What bothers you most about your skin?'**
  String get quizConcernsTitle;

  /// Helper text under the concerns question.
  ///
  /// In en, this message translates to:
  /// **'Pick up to two. You can change this later.'**
  String get quizConcernsHint;

  /// Quiz step 1 question.
  ///
  /// In en, this message translates to:
  /// **'How does your skin feel by midday?'**
  String get quizSkinTypeTitle;

  /// Quiz step 1 helper.
  ///
  /// In en, this message translates to:
  /// **'Pick the closest match. Not sure? That’s fine.'**
  String get quizSkinTypeHint;

  /// Skin type option.
  ///
  /// In en, this message translates to:
  /// **'Oily'**
  String get skinTypeOilyTitle;

  /// Skin type option caption.
  ///
  /// In en, this message translates to:
  /// **'Shiny, especially on the forehead and nose'**
  String get skinTypeOilyCaption;

  /// Skin type option.
  ///
  /// In en, this message translates to:
  /// **'Dry'**
  String get skinTypeDryTitle;

  /// Skin type option caption.
  ///
  /// In en, this message translates to:
  /// **'Tight or flaky, even after moisturiser'**
  String get skinTypeDryCaption;

  /// Skin type option.
  ///
  /// In en, this message translates to:
  /// **'Combination'**
  String get skinTypeCombinationTitle;

  /// Skin type option caption.
  ///
  /// In en, this message translates to:
  /// **'Oily T-zone, drier cheeks'**
  String get skinTypeCombinationCaption;

  /// Skin type option (normal skin).
  ///
  /// In en, this message translates to:
  /// **'Balanced'**
  String get skinTypeNormalTitle;

  /// Skin type option caption.
  ///
  /// In en, this message translates to:
  /// **'Comfortable, neither shiny nor tight'**
  String get skinTypeNormalCaption;

  /// Skin type option.
  ///
  /// In en, this message translates to:
  /// **'Not sure'**
  String get skinTypeNotSureTitle;

  /// Skin type option caption.
  ///
  /// In en, this message translates to:
  /// **'We’ll start gentle and learn with you'**
  String get skinTypeNotSureCaption;

  /// Quiz step 3 question.
  ///
  /// In en, this message translates to:
  /// **'How does your skin react to new products?'**
  String get quizSensitivityTitle;

  /// Quiz step 3 helper.
  ///
  /// In en, this message translates to:
  /// **'Pick one. Strong ingredients stay away from sensitive skin.'**
  String get quizSensitivityHint;

  /// Sensitivity option.
  ///
  /// In en, this message translates to:
  /// **'Rarely reacts'**
  String get sensitivityLowTitle;

  /// Sensitivity option caption.
  ///
  /// In en, this message translates to:
  /// **'New products usually feel fine'**
  String get sensitivityLowCaption;

  /// Sensitivity option.
  ///
  /// In en, this message translates to:
  /// **'Sometimes reacts'**
  String get sensitivitySometimesTitle;

  /// Sensitivity option caption.
  ///
  /// In en, this message translates to:
  /// **'Occasional stinging, redness or breakouts'**
  String get sensitivitySometimesCaption;

  /// Sensitivity option.
  ///
  /// In en, this message translates to:
  /// **'Often reacts'**
  String get sensitivityHighTitle;

  /// Sensitivity option caption.
  ///
  /// In en, this message translates to:
  /// **'Many products sting or irritate'**
  String get sensitivityHighCaption;

  /// Quiz step 4 question.
  ///
  /// In en, this message translates to:
  /// **'Anything we should keep in mind?'**
  String get quizSafetyTitle;

  /// Quiz step 4 helper. Must stay true: this data is not uploaded.
  ///
  /// In en, this message translates to:
  /// **'Optional. This stays on your phone and only helps us avoid ingredients that may not suit you.'**
  String get quizSafetyHint;

  /// Safety option.
  ///
  /// In en, this message translates to:
  /// **'Pregnant or breastfeeding'**
  String get safetyPregnantTitle;

  /// Safety option caption.
  ///
  /// In en, this message translates to:
  /// **'We’ll leave out ingredients usually avoided'**
  String get safetyPregnantCaption;

  /// Safety option.
  ///
  /// In en, this message translates to:
  /// **'On a prescription skin treatment'**
  String get safetyPrescriptionTitle;

  /// Safety option caption.
  ///
  /// In en, this message translates to:
  /// **'We’ll keep things gentle and suggest checking with your doctor'**
  String get safetyPrescriptionCaption;

  /// Safety option.
  ///
  /// In en, this message translates to:
  /// **'A known ingredient allergy'**
  String get safetyAllergyTitle;

  /// Safety option caption.
  ///
  /// In en, this message translates to:
  /// **'For example fragrance or a specific ingredient'**
  String get safetyAllergyCaption;

  /// Safety option: nothing applies.
  ///
  /// In en, this message translates to:
  /// **'None of these'**
  String get safetyNoneTitle;

  /// Safety option caption.
  ///
  /// In en, this message translates to:
  /// **'Nothing to add'**
  String get safetyNoneCaption;

  /// Quiz step 5 question.
  ///
  /// In en, this message translates to:
  /// **'What can you spend on skincare each month?'**
  String get quizBudgetTitle;

  /// Quiz step 5 helper.
  ///
  /// In en, this message translates to:
  /// **'Pick a range. Your routine is built from products that fit it.'**
  String get quizBudgetHint;

  /// Budget option (Pakistani rupees per month).
  ///
  /// In en, this message translates to:
  /// **'Under Rs 3,000'**
  String get budgetEssentialTitle;

  /// Budget option caption.
  ///
  /// In en, this message translates to:
  /// **'Simple, effective basics'**
  String get budgetEssentialCaption;

  /// Budget option.
  ///
  /// In en, this message translates to:
  /// **'Rs 3,000 – 6,000'**
  String get budgetBalancedTitle;

  /// Budget option caption.
  ///
  /// In en, this message translates to:
  /// **'A solid routine with a few extras'**
  String get budgetBalancedCaption;

  /// Budget option.
  ///
  /// In en, this message translates to:
  /// **'Rs 6,000 – 10,000'**
  String get budgetComfortableTitle;

  /// Budget option caption.
  ///
  /// In en, this message translates to:
  /// **'More choice, including treatments'**
  String get budgetComfortableCaption;

  /// Budget option.
  ///
  /// In en, this message translates to:
  /// **'Over Rs 10,000'**
  String get budgetPremiumTitle;

  /// Budget option caption.
  ///
  /// In en, this message translates to:
  /// **'Anything that suits your skin'**
  String get budgetPremiumCaption;

  /// Quiz option.
  ///
  /// In en, this message translates to:
  /// **'Dark spots & pigmentation'**
  String get concernDarkSpotsTitle;

  /// Quiz option caption.
  ///
  /// In en, this message translates to:
  /// **'Marks left by acne or the sun'**
  String get concernDarkSpotsCaption;

  /// Quiz option.
  ///
  /// In en, this message translates to:
  /// **'Acne & breakouts'**
  String get concernAcneTitle;

  /// Quiz option caption.
  ///
  /// In en, this message translates to:
  /// **'Pimples, blackheads, bumps'**
  String get concernAcneCaption;

  /// Quiz option.
  ///
  /// In en, this message translates to:
  /// **'Oiliness & large pores'**
  String get concernOilinessTitle;

  /// Quiz option caption.
  ///
  /// In en, this message translates to:
  /// **'Shiny by midday'**
  String get concernOilinessCaption;

  /// Quiz option.
  ///
  /// In en, this message translates to:
  /// **'Dryness & dullness'**
  String get concernDrynessTitle;

  /// Quiz option caption.
  ///
  /// In en, this message translates to:
  /// **'Tight, flaky or tired-looking'**
  String get concernDrynessCaption;

  /// Quiz option.
  ///
  /// In en, this message translates to:
  /// **'Uneven skin tone'**
  String get concernUnevenToneTitle;

  /// Quiz option caption.
  ///
  /// In en, this message translates to:
  /// **'Patchy colour, dark circles'**
  String get concernUnevenToneCaption;

  /// Screen 02 (Sign up) headline.
  ///
  /// In en, this message translates to:
  /// **'Let’s get you started'**
  String get signUpTitle;

  /// Screen 02 subtitle.
  ///
  /// In en, this message translates to:
  /// **'Use your mobile number. No passwords to remember.'**
  String get signUpSubtitle;

  /// Label above the phone field.
  ///
  /// In en, this message translates to:
  /// **'Mobile number'**
  String get phoneLabel;

  /// Placeholder pattern in the phone field (after the +92 prefix).
  ///
  /// In en, this message translates to:
  /// **'3XX XXX XXXX'**
  String get phoneHint;

  /// Helper under the phone field.
  ///
  /// In en, this message translates to:
  /// **'We’ll text you a 6-digit code.'**
  String get phoneHelper;

  /// Primary button on Sign up.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get sendCode;

  /// Divider between phone sign-in and social sign-in.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get orDivider;

  /// Google sign-in button.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// Sign in with Apple button (iOS only).
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get continueWithApple;

  /// Legal line at the bottom of Sign up. {terms} and {privacy} become links (document names).
  ///
  /// In en, this message translates to:
  /// **'By continuing you agree to Saaf’s {terms} and {privacy}.'**
  String signUpLegal(String terms, String privacy);

  /// Error under the phone field when the code could not be sent.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t send the code. Check your connection and try again.'**
  String get signUpSendFailed;

  /// Error shown when Google/Apple sign-in fails.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t sign you in. Please try again.'**
  String get socialSignInFailed;

  /// Screen 03 (Verify code) headline.
  ///
  /// In en, this message translates to:
  /// **'Enter the code'**
  String get verifyTitle;

  /// Subtitle on Verify code. {phone} is the number; {edit} becomes the Edit link.
  ///
  /// In en, this message translates to:
  /// **'Sent to {phone}  ·  {edit}'**
  String verifySentTo(String phone, String edit);

  /// Link that goes back to change the phone number.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get verifyEdit;

  /// Screen-reader label of the code boxes.
  ///
  /// In en, this message translates to:
  /// **'Verification code'**
  String get verifyCodeLabel;

  /// Countdown before a new code can be requested. {time} is like 0:24.
  ///
  /// In en, this message translates to:
  /// **'Resend code in {time}'**
  String verifyResendIn(String time);

  /// Button that requests a new code once the countdown ends.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get verifyResend;

  /// Primary button on Verify code.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verifyButton;

  /// Error when the entered code is wrong.
  ///
  /// In en, this message translates to:
  /// **'That code doesn’t match. Check it and try again.'**
  String get verifyWrongCode;

  /// Error when verification fails for another reason.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t verify the code. Check your connection and try again.'**
  String get verifyFailed;

  /// Screen-reader label of the keypad delete key.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get keypadDelete;

  /// Title of the page shown for an unknown route.
  ///
  /// In en, this message translates to:
  /// **'Page not found'**
  String get notFoundTitle;

  /// Body text of the not-found page.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find that page.'**
  String get notFoundBody;

  /// Button on the not-found page that returns to the first screen.
  ///
  /// In en, this message translates to:
  /// **'Go to start'**
  String get goToStart;

  /// Screen-reader label of the green check shown when a text field's value is valid.
  ///
  /// In en, this message translates to:
  /// **'Valid'**
  String get fieldValid;

  /// Title of the camera screen (06).
  ///
  /// In en, this message translates to:
  /// **'Face scan'**
  String get scanTitle;

  /// Tooltip of the X button that leaves the face scan.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get scanClose;

  /// Tooltip of the sun button that adds a light frame around the camera view.
  ///
  /// In en, this message translates to:
  /// **'Screen light'**
  String get scanLightToggle;

  /// Step label: the straight-on photo.
  ///
  /// In en, this message translates to:
  /// **'Front'**
  String get scanPoseFront;

  /// Step label: the photo of the left side of the face.
  ///
  /// In en, this message translates to:
  /// **'Left'**
  String get scanPoseLeft;

  /// Step label: the photo of the right side of the face.
  ///
  /// In en, this message translates to:
  /// **'Right'**
  String get scanPoseRight;

  /// Screen-reader label of one step in the three-photo indicator.
  ///
  /// In en, this message translates to:
  /// **'Photo {number} of {total}: {pose}'**
  String scanStepSemantics(int number, int total, String pose);

  /// Screen-reader suffix for a step whose photo is already taken.
  ///
  /// In en, this message translates to:
  /// **'taken'**
  String get scanStepDone;

  /// Instruction chip for the front photo.
  ///
  /// In en, this message translates to:
  /// **'Look straight at the camera'**
  String get scanInstructionFront;

  /// Instruction chip for the left-side photo: turn the head so the left cheek faces the camera.
  ///
  /// In en, this message translates to:
  /// **'Show your left cheek'**
  String get scanInstructionLeft;

  /// Instruction chip for the right-side photo: turn the head so the right cheek faces the camera.
  ///
  /// In en, this message translates to:
  /// **'Show your right cheek'**
  String get scanInstructionRight;

  /// Advice chip when the light is too harsh.
  ///
  /// In en, this message translates to:
  /// **'Move to softer light'**
  String get scanAdviceTooBright;

  /// Advice chip when the light is too dim.
  ///
  /// In en, this message translates to:
  /// **'Find brighter light'**
  String get scanAdviceTooDark;

  /// Quality chip: the light is fine.
  ///
  /// In en, this message translates to:
  /// **'Good light'**
  String get scanChipLight;

  /// Quality chip: the face is in the middle of the oval.
  ///
  /// In en, this message translates to:
  /// **'Centred'**
  String get scanChipCentred;

  /// Quality chip: the phone is steady.
  ///
  /// In en, this message translates to:
  /// **'Hold still'**
  String get scanChipSteady;

  /// Screen-reader suffix of a quality chip whose check has not passed yet, e.g. 'Good light, not yet'.
  ///
  /// In en, this message translates to:
  /// **'not yet'**
  String get scanChipNotYet;

  /// Status line under the chips while the automatic photo counts down.
  ///
  /// In en, this message translates to:
  /// **'Hold still — capturing in {seconds}s'**
  String scanStatusCountdown(int seconds);

  /// Status line when no countdown is running.
  ///
  /// In en, this message translates to:
  /// **'Or tap the button to take it now'**
  String get scanStatusManual;

  /// Tooltip of the gallery button next to the shutter.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get scanGallery;

  /// Screen-reader label of the shutter button.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get scanShutter;

  /// Tooltip of the button that switches between front and back camera.
  ///
  /// In en, this message translates to:
  /// **'Switch camera'**
  String get scanFlip;

  /// Screen-reader label of the live camera area.
  ///
  /// In en, this message translates to:
  /// **'Camera view'**
  String get scanCameraPreview;

  /// Screen-reader label of a photo that was just taken.
  ///
  /// In en, this message translates to:
  /// **'{pose} photo'**
  String scanPhotoOf(String pose);

  /// Status line while a photo that was just taken is shown.
  ///
  /// In en, this message translates to:
  /// **'Is your face clear and well lit?'**
  String get scanReviewQuestion;

  /// Quality chip: the head is turned the way this photo needs.
  ///
  /// In en, this message translates to:
  /// **'Right angle'**
  String get scanChipAngle;

  /// Status line while the shutter waits for the checks.
  ///
  /// In en, this message translates to:
  /// **'The button unlocks when everything is ready'**
  String get scanStatusLocked;

  /// Hint: no face found in the camera picture.
  ///
  /// In en, this message translates to:
  /// **'We can’t see your face'**
  String get scanFaceNoFace;

  /// Hint: more than one face in the camera picture.
  ///
  /// In en, this message translates to:
  /// **'Only one face, please'**
  String get scanFaceSeveral;

  /// Hint: the face is too small.
  ///
  /// In en, this message translates to:
  /// **'Move a little closer'**
  String get scanFaceCloser;

  /// Hint: the face is too big.
  ///
  /// In en, this message translates to:
  /// **'Move a little back'**
  String get scanFaceBack;

  /// Hint: the face is off centre.
  ///
  /// In en, this message translates to:
  /// **'Centre your face in the oval'**
  String get scanFaceCentre;

  /// Hint: the head is turned or tilted for the front photo.
  ///
  /// In en, this message translates to:
  /// **'Look straight at the camera'**
  String get scanFaceStraight;

  /// Hint for the left cheek photo.
  ///
  /// In en, this message translates to:
  /// **'Turn your head to your left'**
  String get scanFaceTurnLeft;

  /// Hint for the right cheek photo.
  ///
  /// In en, this message translates to:
  /// **'Turn your head to your right'**
  String get scanFaceTurnRight;

  /// Hint: the head is turned too far for a side photo.
  ///
  /// In en, this message translates to:
  /// **'Turn back a little'**
  String get scanFaceTurnLess;

  /// Warning under a photo with no face.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t find a face in this photo. Please retake it.'**
  String get scanCheckNoFace;

  /// Warning under a photo with several faces.
  ///
  /// In en, this message translates to:
  /// **'There is more than one face in this photo. Please retake it with only you in it.'**
  String get scanCheckSeveral;

  /// Warning under a photo taken at the wrong angle.
  ///
  /// In en, this message translates to:
  /// **'This is not the angle we need for this photo. Please retake it.'**
  String get scanCheckPose;

  /// Warning under a photo where the face is tiny.
  ///
  /// In en, this message translates to:
  /// **'Your face is too small in this photo. Move closer and retake it.'**
  String get scanCheckSmall;

  /// Warning under a dark photo.
  ///
  /// In en, this message translates to:
  /// **'This photo is too dark. Find brighter light and retake it.'**
  String get scanCheckDark;

  /// Warning under an over-bright photo.
  ///
  /// In en, this message translates to:
  /// **'This photo is too bright. Move to softer light and retake it.'**
  String get scanCheckBright;

  /// Button that keeps a photo the check did not like.
  ///
  /// In en, this message translates to:
  /// **'Use it anyway'**
  String get scanUseAnyway;

  /// Title of the barcode scan screen.
  ///
  /// In en, this message translates to:
  /// **'Scan a product'**
  String get scanProductTitle;

  /// Hint under the barcode camera.
  ///
  /// In en, this message translates to:
  /// **'Point the camera at the barcode or QR code on the pack. Hold it steady.'**
  String get scanProductHint;

  /// Our own explanation before the system camera dialog on the barcode screen.
  ///
  /// In en, this message translates to:
  /// **'Saaf uses your camera only to read a product’s barcode. Nothing is saved or uploaded.'**
  String get scanProductRationaleBody;

  /// Shown when the camera is off on the barcode screen.
  ///
  /// In en, this message translates to:
  /// **'You can still type the barcode number below.'**
  String get scanProductDeniedBody;

  /// Shown when the camera is blocked on the barcode screen.
  ///
  /// In en, this message translates to:
  /// **'Camera access is blocked for Saaf. Allow it in your phone’s Settings, or type the barcode number below.'**
  String get scanProductSettingsBody;

  /// Heading above the barcode number field.
  ///
  /// In en, this message translates to:
  /// **'Or type the barcode number'**
  String get scanProductManualTitle;

  /// Label of the barcode number field.
  ///
  /// In en, this message translates to:
  /// **'Barcode number'**
  String get scanProductManualLabel;

  /// Hint inside the barcode number field.
  ///
  /// In en, this message translates to:
  /// **'e.g. 3337875743563'**
  String get scanProductManualHint;

  /// Button that looks up the typed barcode.
  ///
  /// In en, this message translates to:
  /// **'Look up'**
  String get scanProductLookUp;

  /// Error when the typed barcode is not valid.
  ///
  /// In en, this message translates to:
  /// **'Enter the 8 to 14 digits printed under the barcode.'**
  String get scanProductInvalid;

  /// Demo button that stands in for the camera in Chrome.
  ///
  /// In en, this message translates to:
  /// **'Pretend to scan (demo)'**
  String get scanProductPretend;

  /// Tooltip and screen-reader label of the scan button on Home.
  ///
  /// In en, this message translates to:
  /// **'Scan a product'**
  String get homeScanTooltip;

  /// Title of the AI coach screen.
  ///
  /// In en, this message translates to:
  /// **'Ask Saaf AI'**
  String get aiTitle;

  /// Tooltip of the AI coach menu button.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get aiMenuTooltip;

  /// Menu item that clears the AI conversation.
  ///
  /// In en, this message translates to:
  /// **'New chat'**
  String get aiMenuNewChat;

  /// Menu item that withdraws permission to send chats to the AI.
  ///
  /// In en, this message translates to:
  /// **'Stop sharing with AI'**
  String get aiMenuStop;

  /// Reminder shown above every AI conversation.
  ///
  /// In en, this message translates to:
  /// **'AI answers can be wrong and are not medical advice. See a dermatologist for painful, spreading or worrying skin changes.'**
  String get aiDisclaimer;

  /// Title of the permission screen of the AI coach.
  ///
  /// In en, this message translates to:
  /// **'Before you chat with the AI coach'**
  String get aiConsentTitle;

  /// Introduction on the AI coach permission screen.
  ///
  /// In en, this message translates to:
  /// **'Ask about your routine, ingredients or products, attach a photo of your skin, or let it review your progress photos. An AI model writes the answer.'**
  String get aiConsentIntro;

  /// Heading on the AI permission screen.
  ///
  /// In en, this message translates to:
  /// **'What is sent'**
  String get aiConsentShareTitle;

  /// What is sent to the AI.
  ///
  /// In en, this message translates to:
  /// **'Your message, any photo you attach or choose to send (a progress review, or a product label to look up), and a few facts: your skin type, concerns, sensitivity, budget, the names of your routine products and, to choose products for you, your latest scan scores. Never your name, phone number, side photos, or your pregnancy, medication and allergy answers.'**
  String get aiConsentShareBody;

  /// Heading on the AI permission screen.
  ///
  /// In en, this message translates to:
  /// **'Who receives it'**
  String get aiConsentWhoTitle;

  /// Who receives the data.
  ///
  /// In en, this message translates to:
  /// **'Our server passes it to Groq, which runs an open-source AI model to write the reply. Groq handles it under its own privacy terms. Saaf does not keep your chats on its server.'**
  String get aiConsentWhoBody;

  /// Reassurance on the AI permission screen.
  ///
  /// In en, this message translates to:
  /// **'You can stop sharing at any time in Profile.'**
  String get aiConsentChoice;

  /// Button that gives permission to share chats with the AI.
  ///
  /// In en, this message translates to:
  /// **'I agree, start chatting'**
  String get aiConsentAgree;

  /// Link to the Privacy Policy from the AI permission screen.
  ///
  /// In en, this message translates to:
  /// **'Read the Privacy Policy'**
  String get aiPolicyLink;

  /// Heading of an empty AI conversation.
  ///
  /// In en, this message translates to:
  /// **'Ask me about your skin care'**
  String get aiEmptyTitle;

  /// Text of an empty AI conversation.
  ///
  /// In en, this message translates to:
  /// **'I can explain ingredients, check your routine and look at photos you attach.'**
  String get aiEmptyBody;

  /// Suggested question.
  ///
  /// In en, this message translates to:
  /// **'Is my routine right for me?'**
  String get aiSuggestRoutine;

  /// Suggested question.
  ///
  /// In en, this message translates to:
  /// **'How do I fade dark spots safely?'**
  String get aiSuggestDarkSpots;

  /// Suggested question.
  ///
  /// In en, this message translates to:
  /// **'Can I use vitamin C and niacinamide together?'**
  String get aiSuggestClash;

  /// Suggested question.
  ///
  /// In en, this message translates to:
  /// **'How do I choose a sunscreen?'**
  String get aiSuggestSunscreen;

  /// Hint inside the AI message box.
  ///
  /// In en, this message translates to:
  /// **'Ask about your skin or routine'**
  String get aiInputHint;

  /// Tooltip of the send button in the AI chat.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get aiSend;

  /// Tooltip of the attach-photo button in the AI chat.
  ///
  /// In en, this message translates to:
  /// **'Attach a photo'**
  String get aiAttach;

  /// Option that takes a photo for the AI chat.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get aiTakePhoto;

  /// Option that picks a photo for the AI chat.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get aiChoosePhoto;

  /// Tooltip of the remove button on an attached photo.
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get aiRemovePhoto;

  /// Shown on a message that has photos.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 photo} other{{count} photos}}'**
  String aiPhotosAttached(int count);

  /// Shown when a photo could not be attached.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t get that photo. Please try again.'**
  String get aiPhotoFailed;

  /// Shown while the AI writes its answer.
  ///
  /// In en, this message translates to:
  /// **'Thinking…'**
  String get aiThinking;

  /// Label on every AI reply.
  ///
  /// In en, this message translates to:
  /// **'AI answer'**
  String get aiAnswerLabel;

  /// Tooltip of the report button on an AI reply.
  ///
  /// In en, this message translates to:
  /// **'Report this answer'**
  String get aiReport;

  /// Title of the report sheet.
  ///
  /// In en, this message translates to:
  /// **'What is wrong with this answer?'**
  String get aiReportTitle;

  /// Report reason.
  ///
  /// In en, this message translates to:
  /// **'Harmful or unsafe'**
  String get aiReportHarmful;

  /// Report reason.
  ///
  /// In en, this message translates to:
  /// **'Wrong or misleading'**
  String get aiReportWrong;

  /// Report reason.
  ///
  /// In en, this message translates to:
  /// **'Offensive'**
  String get aiReportOffensive;

  /// Report reason.
  ///
  /// In en, this message translates to:
  /// **'Something else'**
  String get aiReportOther;

  /// Shown on a reply that was reported.
  ///
  /// In en, this message translates to:
  /// **'Reported'**
  String get aiReported;

  /// Shown after a report was sent.
  ///
  /// In en, this message translates to:
  /// **'Thank you. We will review this answer.'**
  String get aiReportThanks;

  /// Shown when a report could not be sent.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t send your report. Please try again.'**
  String get aiReportFailed;

  /// AI error: no connection.
  ///
  /// In en, this message translates to:
  /// **'No connection. Check your internet and try again.'**
  String get aiErrorNetwork;

  /// AI error: daily limit.
  ///
  /// In en, this message translates to:
  /// **'You’ve reached today’s limit. Please try again tomorrow.'**
  String get aiErrorLimit;

  /// AI error: service down.
  ///
  /// In en, this message translates to:
  /// **'The AI coach isn’t available right now. Please try again later.'**
  String get aiErrorUnavailable;

  /// AI error: not signed in.
  ///
  /// In en, this message translates to:
  /// **'Please sign in again to use the AI coach.'**
  String get aiErrorSignIn;

  /// AI error: anything else.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get aiErrorGeneric;

  /// Tooltip of the AI coach button on Home.
  ///
  /// In en, this message translates to:
  /// **'Ask the AI coach'**
  String get homeAiTooltip;

  /// Settings row for sharing chats with the AI coach.
  ///
  /// In en, this message translates to:
  /// **'AI coach sharing'**
  String get profileRowAi;

  /// Value of a setting that is on.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get profileValueOn;

  /// Title of the sheet that switches AI sharing on or off.
  ///
  /// In en, this message translates to:
  /// **'AI coach sharing'**
  String get aiSheetTitle;

  /// Explanation in the AI sharing sheet.
  ///
  /// In en, this message translates to:
  /// **'When on, your questions and the photos you attach are sent to the AI coach, as described in the Privacy Policy. Turning it off also clears the conversation.'**
  String get aiSheetBody;

  /// Label of the AI sharing switch.
  ///
  /// In en, this message translates to:
  /// **'Share with the AI coach'**
  String get aiSheetSwitch;

  /// Shown on the progress screen: days until the next 2-week scan.
  ///
  /// In en, this message translates to:
  /// **'Next scan in {days, plural, =1{1 day} other{{days} days}}'**
  String progressNextScan(int days);

  /// Shown when a new face scan is due.
  ///
  /// In en, this message translates to:
  /// **'Your 2-week scan is due'**
  String get progressScanDue;

  /// Button that starts the face scan.
  ///
  /// In en, this message translates to:
  /// **'Scan now'**
  String get progressScanNow;

  /// Title of the AI review card on the progress screen.
  ///
  /// In en, this message translates to:
  /// **'AI progress review'**
  String get progressAiTitle;

  /// Body of the AI review card.
  ///
  /// In en, this message translates to:
  /// **'Let the AI coach look at your photos from the start until now and explain what has changed.'**
  String get progressAiBody;

  /// Button that opens the AI review confirmation.
  ///
  /// In en, this message translates to:
  /// **'Review my progress with AI'**
  String get progressAiButton;

  /// Button shown before the user has agreed to the AI coach.
  ///
  /// In en, this message translates to:
  /// **'Set up the AI coach'**
  String get progressAiSetup;

  /// Title of the confirmation before sending progress photos.
  ///
  /// In en, this message translates to:
  /// **'Send these photos to the AI?'**
  String get progressAiConfirmTitle;

  /// Body of the confirmation before sending progress photos; says who receives them.
  ///
  /// In en, this message translates to:
  /// **'Only the front photos below are sent, to the AI coach (Groq, through Saaf’s server), to describe what changed. Your side photos stay on your phone.'**
  String get progressAiConfirmBody;

  /// Button that sends the progress photos to the AI.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get progressAiSend;

  /// Shown when the progress photos could not be prepared.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t prepare your photos. Please try again.'**
  String get progressAiPhotoError;

  /// Screen-reader label of a photo in the send confirmation.
  ///
  /// In en, this message translates to:
  /// **'Photo from {date}'**
  String progressAiPhotoSemantics(String date);

  /// The question sent for an AI progress review (shown in the chat).
  ///
  /// In en, this message translates to:
  /// **'Please compare my face photos over time and tell me, in general terms, what has changed in my skin and what I should do next.'**
  String get aiReviewQuestion;

  /// Describes the first progress photo.
  ///
  /// In en, this message translates to:
  /// **'Photo {n} is my first scan, taken {date}.'**
  String aiReviewFirst(int n, String date);

  /// Describes a middle progress photo.
  ///
  /// In en, this message translates to:
  /// **'Photo {n} was taken {date}.'**
  String aiReviewMiddle(int n, String date);

  /// Describes the latest progress photo.
  ///
  /// In en, this message translates to:
  /// **'Photo {n} is my latest scan, taken {date}.'**
  String aiReviewLatest(int n, String date);

  /// Button that discards the photo and shows the camera again.
  ///
  /// In en, this message translates to:
  /// **'Retake'**
  String get scanRetake;

  /// Button that keeps the photo and moves to the next one.
  ///
  /// In en, this message translates to:
  /// **'Use this photo'**
  String get scanUsePhoto;

  /// Button on the last photo that saves the scan and shows the results.
  ///
  /// In en, this message translates to:
  /// **'Analyse my skin'**
  String get scanAnalyse;

  /// Shown while the three photos are saved on the phone.
  ///
  /// In en, this message translates to:
  /// **'Saving your photos…'**
  String get scanSaving;

  /// Error when saving the photos fails.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t save your photos. Please try again.'**
  String get scanSaveFailed;

  /// Error when the chosen gallery photo cannot be used.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t open that photo. Please try another.'**
  String get scanPickFailed;

  /// Error when taking a photo fails.
  ///
  /// In en, this message translates to:
  /// **'The photo didn’t work. Please try again.'**
  String get scanCaptureFailed;

  /// Reassurance shown in the camera permission sheet and under the review buttons.
  ///
  /// In en, this message translates to:
  /// **'Photos stay on your phone unless you choose to send them to the AI coach.'**
  String get scanPrivacyNote;

  /// Title of our own explanation shown before the system camera dialog.
  ///
  /// In en, this message translates to:
  /// **'Allow camera access'**
  String get scanRationaleTitle;

  /// Body of our camera explanation.
  ///
  /// In en, this message translates to:
  /// **'Saaf uses your camera only to take the three photos of your face scan: front, left and right.'**
  String get scanRationaleBody;

  /// Button that moves on to the system camera dialog.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get scanContinue;

  /// Button that skips the camera and leaves the scan.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get scanNotNow;

  /// Title shown after the user refused the camera.
  ///
  /// In en, this message translates to:
  /// **'Camera access is off'**
  String get scanDeniedTitle;

  /// Body shown after the user refused the camera.
  ///
  /// In en, this message translates to:
  /// **'You can try again, or choose photos from your gallery instead.'**
  String get scanDeniedBody;

  /// Title shown when the camera was refused for good.
  ///
  /// In en, this message translates to:
  /// **'Turn on the camera in Settings'**
  String get scanSettingsTitle;

  /// Body shown when the camera was refused for good.
  ///
  /// In en, this message translates to:
  /// **'Camera access is blocked for Saaf. You can allow it in your phone’s Settings, or choose photos from your gallery.'**
  String get scanSettingsBody;

  /// Button that opens the phone's settings for Saaf.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get scanOpenSettings;

  /// Button that tries the camera again.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get scanTryAgain;

  /// Title shown when the camera could not start.
  ///
  /// In en, this message translates to:
  /// **'The camera didn’t start'**
  String get scanFailedTitle;

  /// Body shown when the camera could not start.
  ///
  /// In en, this message translates to:
  /// **'Close other apps that use the camera and try again, or choose photos from your gallery.'**
  String get scanFailedBody;

  /// Small caps line above the results title. {date} is like 15 OCT 2026.
  ///
  /// In en, this message translates to:
  /// **'SCAN · {date}'**
  String resultsOverline(String date);

  /// Title of the analysis results screen (07).
  ///
  /// In en, this message translates to:
  /// **'Here’s your skin today'**
  String get resultsTitle;

  /// Tooltip of the share button on the results screen.
  ///
  /// In en, this message translates to:
  /// **'Share your result'**
  String get resultsShare;

  /// Caption under the score number in the ring.
  ///
  /// In en, this message translates to:
  /// **'Skin score'**
  String get resultsScoreLabel;

  /// Screen-reader label of the score ring.
  ///
  /// In en, this message translates to:
  /// **'Skin score {score} out of 100'**
  String resultsScoreSemantics(int score);

  /// Score-card headline when the score is 75 or more.
  ///
  /// In en, this message translates to:
  /// **'Good base, two things to work on'**
  String get resultsHeadlineGood;

  /// Score-card headline when the score is 50 to 74.
  ///
  /// In en, this message translates to:
  /// **'A fair start, two things to work on'**
  String get resultsHeadlineFair;

  /// Score-card headline when the score is below 50.
  ///
  /// In en, this message translates to:
  /// **'Your skin needs some care. Start with two things'**
  String get resultsHeadlineNeedsCare;

  /// Score-card line naming the two areas to work on first.
  ///
  /// In en, this message translates to:
  /// **'{first} and {second} are your main focus.'**
  String resultsFocus(String first, String second);

  /// Section title above the four measures.
  ///
  /// In en, this message translates to:
  /// **'Concerns'**
  String get resultsConcerns;

  /// Link beside the Concerns title that opens the explanation page.
  ///
  /// In en, this message translates to:
  /// **'How we score'**
  String get resultsHowWeScore;

  /// Measure name.
  ///
  /// In en, this message translates to:
  /// **'Dark spots'**
  String get metricDarkSpots;

  /// Measure name.
  ///
  /// In en, this message translates to:
  /// **'Breakouts'**
  String get metricBreakouts;

  /// Measure name.
  ///
  /// In en, this message translates to:
  /// **'Oiliness'**
  String get metricOiliness;

  /// Measure name.
  ///
  /// In en, this message translates to:
  /// **'Hydration'**
  String get metricHydration;

  /// Rating of a concern that is small.
  ///
  /// In en, this message translates to:
  /// **'Mild'**
  String get ratingMild;

  /// Rating of a concern that is in the middle.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get ratingModerate;

  /// Rating of a concern that is large.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get ratingHigh;

  /// Rating of hydration that is low.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get ratingLow;

  /// Rating of hydration that is in the middle.
  ///
  /// In en, this message translates to:
  /// **'Fair'**
  String get ratingFair;

  /// Rating of hydration that is good.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get ratingGood;

  /// Screen-reader label of one measure card, e.g. 'Dark spots: Moderate'.
  ///
  /// In en, this message translates to:
  /// **'{name}: {rating}'**
  String metricSemantics(String name, String rating);

  /// Disclaimer under the measures.
  ///
  /// In en, this message translates to:
  /// **'A cosmetic screening, not a medical diagnosis. See a dermatologist for anything that worries you.'**
  String get resultsDisclaimer;

  /// Primary button on the results screen.
  ///
  /// In en, this message translates to:
  /// **'See my routine'**
  String get resultsSeeRoutine;

  /// Title shown on the results screen when there is no finished scan.
  ///
  /// In en, this message translates to:
  /// **'No scan yet'**
  String get resultsEmptyTitle;

  /// Body shown when there is no finished scan.
  ///
  /// In en, this message translates to:
  /// **'Take your three face photos to see how your skin looks today.'**
  String get resultsEmptyBody;

  /// Button that opens the camera screen.
  ///
  /// In en, this message translates to:
  /// **'Start a scan'**
  String get resultsEmptyAction;

  /// Title shown when the analysis fails.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t read your results'**
  String get resultsErrorTitle;

  /// Button that runs the analysis again.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get resultsErrorAction;

  /// Text shared from the results screen. Never includes photos.
  ///
  /// In en, this message translates to:
  /// **'My Saaf skin score: {score}/100. Main focus: {focus}. A cosmetic screening, not medical advice.'**
  String resultsShareText(int score, String focus);

  /// Title of the explanation page.
  ///
  /// In en, this message translates to:
  /// **'How we score'**
  String get howWeScoreTitle;

  /// Intro paragraph of the explanation page.
  ///
  /// In en, this message translates to:
  /// **'Your Saaf skin score is a number from 40 to 100 that sums up how your skin looks today. It is a guide for choosing a routine, not a medical measurement.'**
  String get howWeScoreIntro;

  /// Section heading.
  ///
  /// In en, this message translates to:
  /// **'What we look at'**
  String get howWeScoreLooksTitle;

  /// Bullet.
  ///
  /// In en, this message translates to:
  /// **'Dark spots: uneven colour and marks left by the sun or by acne.'**
  String get howWeScoreSpots;

  /// Bullet.
  ///
  /// In en, this message translates to:
  /// **'Breakouts: pimples, blackheads and bumps.'**
  String get howWeScoreBreakouts;

  /// Bullet.
  ///
  /// In en, this message translates to:
  /// **'Oiliness: shine and visible pores, mostly on the forehead and nose.'**
  String get howWeScoreOil;

  /// Bullet.
  ///
  /// In en, this message translates to:
  /// **'Hydration: how comfortable and smooth your skin looks. This is the only measure where more is better.'**
  String get howWeScoreHydration;

  /// Section heading.
  ///
  /// In en, this message translates to:
  /// **'How the number is made'**
  String get howWeScoreMathTitle;

  /// Paragraph explaining the score.
  ///
  /// In en, this message translates to:
  /// **'Dark spots, breakouts and oiliness can take up to 40 points off between them. Low hydration can take off up to 20 more. A skin with none of these scores 100.'**
  String get howWeScoreMath;

  /// Section heading.
  ///
  /// In en, this message translates to:
  /// **'Your photos'**
  String get howWeScorePhotosTitle;

  /// Paragraph about photo privacy.
  ///
  /// In en, this message translates to:
  /// **'The three photos stay on your phone and your score is worked out there. They go to the AI coach only if you choose that.'**
  String get howWeScorePhotos;

  /// Section heading.
  ///
  /// In en, this message translates to:
  /// **'Not medical advice'**
  String get howWeScoreMedicalTitle;

  /// Paragraph with the medical disclaimer.
  ///
  /// In en, this message translates to:
  /// **'Saaf cannot diagnose skin conditions. If a spot changes, bleeds, itches or worries you, please see a dermatologist.'**
  String get howWeScoreMedical;

  /// Title of the routine screen (08).
  ///
  /// In en, this message translates to:
  /// **'Your routine'**
  String get routineTitle;

  /// Start of the routine subtitle. {concerns} is like 'dark spots & breakouts'.
  ///
  /// In en, this message translates to:
  /// **'For {concerns}'**
  String routineFor(String concerns);

  /// Start of the routine subtitle when the user picked no concern.
  ///
  /// In en, this message translates to:
  /// **'For everyday skin health'**
  String get routineForGeneral;

  /// Budget part of the routine subtitle. {amount} is like Rs 6,000.
  ///
  /// In en, this message translates to:
  /// **'Budget {amount}/month'**
  String routineBudget(String amount);

  /// Budget part of the routine subtitle for the highest budget band.
  ///
  /// In en, this message translates to:
  /// **'No budget limit'**
  String get routineBudgetNoLimit;

  /// Routine subtitle joining who it is for and the budget.
  ///
  /// In en, this message translates to:
  /// **'{forText} · {budgetText}'**
  String routineSubtitle(String forText, String budgetText);

  /// Joins two concern names, e.g. 'dark spots & breakouts'.
  ///
  /// In en, this message translates to:
  /// **'{first} & {second}'**
  String routineAnd(String first, String second);

  /// Concern name inside a sentence (lower case).
  ///
  /// In en, this message translates to:
  /// **'dark spots'**
  String get concernDarkSpots;

  /// Concern name inside a sentence (lower case).
  ///
  /// In en, this message translates to:
  /// **'breakouts'**
  String get concernAcne;

  /// Concern name inside a sentence (lower case).
  ///
  /// In en, this message translates to:
  /// **'oiliness'**
  String get concernOiliness;

  /// Concern name inside a sentence (lower case).
  ///
  /// In en, this message translates to:
  /// **'dryness'**
  String get concernDryness;

  /// Concern name inside a sentence (lower case).
  ///
  /// In en, this message translates to:
  /// **'uneven tone'**
  String get concernUnevenTone;

  /// A price in Pakistani rupees. {amount} is like 1,450.
  ///
  /// In en, this message translates to:
  /// **'Rs {amount}'**
  String priceRs(String amount);

  /// Tab: the morning routine.
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get routineMorning;

  /// Tab: the night routine.
  ///
  /// In en, this message translates to:
  /// **'Night'**
  String get routineNight;

  /// Screen-reader name of the Morning / Night tabs.
  ///
  /// In en, this message translates to:
  /// **'Time of day'**
  String get routineTabsLabel;

  /// Line above the routine list.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 step} other{{count} steps}} · about {minutes} min'**
  String routineSummary(int count, int minutes);

  /// Total price of the shown routine. {price} is like Rs 5,050.
  ///
  /// In en, this message translates to:
  /// **'{price} total'**
  String routineTotal(String price);

  /// Caption under a product name.
  ///
  /// In en, this message translates to:
  /// **'Step {number} · {category}'**
  String routineStepLine(int number, String category);

  /// Step kind.
  ///
  /// In en, this message translates to:
  /// **'Cleanser'**
  String get stepCleanser;

  /// Step kind.
  ///
  /// In en, this message translates to:
  /// **'Treatment'**
  String get stepTreatment;

  /// Step kind.
  ///
  /// In en, this message translates to:
  /// **'Moisturiser'**
  String get stepMoisturiser;

  /// Step kind.
  ///
  /// In en, this message translates to:
  /// **'Sun protection'**
  String get stepSunscreen;

  /// Title of the info card under the routine.
  ///
  /// In en, this message translates to:
  /// **'Results in 6–8 weeks'**
  String get routineResultsTitle;

  /// Body of the info card. {date} is like 14 Nov.
  ///
  /// In en, this message translates to:
  /// **'Use it every day. Your next progress photo is on {date}.'**
  String routineResultsBody(String date);

  /// Body of the info card when there is no scan date yet.
  ///
  /// In en, this message translates to:
  /// **'Use it every day and check your progress every two weeks.'**
  String get routineResultsBodyNoDate;

  /// Primary button on the routine screen.
  ///
  /// In en, this message translates to:
  /// **'Start my routine'**
  String get routineStart;

  /// Shown when the cheapest suitable routine is more than the user's budget.
  ///
  /// In en, this message translates to:
  /// **'This is a little over your monthly budget.'**
  String get routineOverBudget;

  /// Note under the routine list.
  ///
  /// In en, this message translates to:
  /// **'Prices are a guide and may differ in shops.'**
  String get routinePriceNote;

  /// Tooltip of the bell button on the routine screen.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get routineReminders;

  /// Title when there are no products to suggest.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t build a routine yet'**
  String get routineEmptyTitle;

  /// Body when there are no products to suggest.
  ///
  /// In en, this message translates to:
  /// **'Answer the skin quiz and we will pick products for you.'**
  String get routineEmptyBody;

  /// Button that opens the skin quiz.
  ///
  /// In en, this message translates to:
  /// **'Take the skin quiz'**
  String get routineEmptyAction;

  /// Title when loading the routine fails.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t load your routine'**
  String get routineErrorTitle;

  /// Button that loads the routine again.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get routineErrorAction;

  /// Bottom navigation: Home tab.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// Bottom navigation: face scan tab.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get navScan;

  /// Bottom navigation: progress tab.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get navProgress;

  /// Bottom navigation: profile tab.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// Greeting on Home when the user's name is known.
  ///
  /// In en, this message translates to:
  /// **'Salam, {name}'**
  String homeGreeting(String name);

  /// Greeting on Home when the name is not known.
  ///
  /// In en, this message translates to:
  /// **'Salam'**
  String get homeGreetingNoName;

  /// Small label on the progress card.
  ///
  /// In en, this message translates to:
  /// **'Today’s progress'**
  String get homeProgressLabel;

  /// Headline of the progress card, e.g. '2 of 4 steps done'.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total, plural, =1{1 step} other{{total} steps}} done'**
  String homeStepsDone(int done, int total);

  /// Screen-reader label of the progress ring.
  ///
  /// In en, this message translates to:
  /// **'{percent} percent of today’s routine done'**
  String homeProgressSemantics(int percent);

  /// Section title above the checklist.
  ///
  /// In en, this message translates to:
  /// **'Today’s routine'**
  String get homeRoutineTitle;

  /// Tooltip of the Morning / Night chip: switches to the other routine.
  ///
  /// In en, this message translates to:
  /// **'Show the {time} routine'**
  String homeSwitchTime(String time);

  /// Caption under a product name in the checklist, e.g. 'Cleanser · Rs 650'.
  ///
  /// In en, this message translates to:
  /// **'{category} · {price}'**
  String homeStepCaption(String category, String price);

  /// Screen-reader label of a ticked checklist step.
  ///
  /// In en, this message translates to:
  /// **'{name}, done'**
  String homeStepDone(String name);

  /// Screen-reader label of an unticked checklist step.
  ///
  /// In en, this message translates to:
  /// **'{name}, not done yet'**
  String homeStepNotDone(String name);

  /// Screen-reader label of a day in the week strip when its routine was completed.
  ///
  /// In en, this message translates to:
  /// **'{day}, all steps done'**
  String homeDayComplete(String day);

  /// Screen-reader label of a day in the week strip that was not completed.
  ///
  /// In en, this message translates to:
  /// **'{day}'**
  String homeDayOpen(String day);

  /// Screen-reader label of today in the week strip.
  ///
  /// In en, this message translates to:
  /// **'{day}, today'**
  String homeToday(String day);

  /// Screen-reader name of the week strip.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get homeWeekLabel;

  /// Title when Home cannot load.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t load today’s routine'**
  String get homeErrorTitle;

  /// Button that loads Home again.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get homeErrorAction;

  /// Top bar title of the product scan result (10).
  ///
  /// In en, this message translates to:
  /// **'Scan result'**
  String get productScanTitle;

  /// Tooltip of the share button on the product result.
  ///
  /// In en, this message translates to:
  /// **'Share this product'**
  String get productShare;

  /// Text shared from the product result. {price} is like Rs 1,450.
  ///
  /// In en, this message translates to:
  /// **'{brand} {name}: from {price} on Saaf. Cosmetic guidance only.'**
  String productShareText(String brand, String name, String price);

  /// Chip on the product photo.
  ///
  /// In en, this message translates to:
  /// **'Barcode matched'**
  String get productBarcodeMatched;

  /// Chip: the product suits the answers of the user.
  ///
  /// In en, this message translates to:
  /// **'Good match for you'**
  String get productFitGood;

  /// Chip: the product may not suit the user.
  ///
  /// In en, this message translates to:
  /// **'Use with care'**
  String get productFitCareful;

  /// Chip: the safety answers of the user say to avoid this product.
  ///
  /// In en, this message translates to:
  /// **'Not recommended for you'**
  String get productFitAvoid;

  /// Skin-type chip for a gentle product.
  ///
  /// In en, this message translates to:
  /// **'All skin types'**
  String get productAllSkin;

  /// Skin-type chip part for a product that helps acne.
  ///
  /// In en, this message translates to:
  /// **'Acne-prone'**
  String get productAcneProne;

  /// Ingredient clash title.
  ///
  /// In en, this message translates to:
  /// **'Don’t mix with Vitamin C'**
  String get clashNiacinamideVitaminCTitle;

  /// Advice when the clash is in the morning routine and the product can be used at night.
  ///
  /// In en, this message translates to:
  /// **'Use this at night if your morning routine has Vitamin C.'**
  String get clashMoveToNight;

  /// Advice when the clash is in the night routine and the product can be used in the morning.
  ///
  /// In en, this message translates to:
  /// **'Use this in the morning if your night routine has Vitamin C.'**
  String get clashMoveToMorning;

  /// Advice when the product cannot simply move to the other time of day.
  ///
  /// In en, this message translates to:
  /// **'Use it on different days from your Vitamin C.'**
  String get clashDifferentDays;

  /// Ingredient clash title.
  ///
  /// In en, this message translates to:
  /// **'Don’t layer with exfoliating acids'**
  String get clashRetinolExfoliantsTitle;

  /// Advice for retinol with acids.
  ///
  /// In en, this message translates to:
  /// **'Use them on different nights to avoid irritation.'**
  String get clashRetinolExfoliants;

  /// Ingredient clash title.
  ///
  /// In en, this message translates to:
  /// **'Don’t layer with benzoyl peroxide'**
  String get clashBenzoylRetinolTitle;

  /// Advice for retinol with benzoyl peroxide.
  ///
  /// In en, this message translates to:
  /// **'Use them at different times of day to avoid irritation.'**
  String get clashBenzoylRetinol;

  /// Warning card title when the product may not suit the user.
  ///
  /// In en, this message translates to:
  /// **'Check before you use it'**
  String get productCarefulTitle;

  /// Warning card body.
  ///
  /// In en, this message translates to:
  /// **'It may not suit your skin type or sensitivity. Test a small patch first.'**
  String get productCarefulBody;

  /// Warning card title when the safety answers say to avoid the product.
  ///
  /// In en, this message translates to:
  /// **'Usually avoided for you'**
  String get productAvoidTitle;

  /// Warning card body.
  ///
  /// In en, this message translates to:
  /// **'Your answers say products like this are best avoided. Ask a doctor or pharmacist first.'**
  String get productAvoidBody;

  /// Section title above the stores.
  ///
  /// In en, this message translates to:
  /// **'Where to buy'**
  String get productWhereToBuy;

  /// Shown instead of a price when only a search link is known.
  ///
  /// In en, this message translates to:
  /// **'Check price'**
  String get productCheckPrice;

  /// Shown above the shops when none of them has a known price.
  ///
  /// In en, this message translates to:
  /// **'Prices vary by shop'**
  String get productPricesVary;

  /// Label beside the section title when the prices were checked today.
  ///
  /// In en, this message translates to:
  /// **'Prices today'**
  String get productPricesToday;

  /// Label beside the section title when the prices are older than today.
  ///
  /// In en, this message translates to:
  /// **'Prices as of {date}'**
  String productPricesAsOf(String date);

  /// Button that opens the page of the store in the browser.
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get productBuy;

  /// Screen-reader label of a Buy button.
  ///
  /// In en, this message translates to:
  /// **'Buy from {store} for {price}'**
  String productBuySemantics(String store, String price);

  /// Affiliate disclosure under the store list.
  ///
  /// In en, this message translates to:
  /// **'Some Buy links may earn Saaf a small commission. It never changes your price.'**
  String get productAffiliate;

  /// Disclaimer at the end of the product result.
  ///
  /// In en, this message translates to:
  /// **'Ingredient advice is general guidance, not medical advice.'**
  String get productDisclaimer;

  /// Message when a Buy link cannot be opened.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t open that link.'**
  String get productLinkFailed;

  /// Title when the result screen is opened without a barcode.
  ///
  /// In en, this message translates to:
  /// **'No product scanned yet'**
  String get productNoneTitle;

  /// Body when the result screen is opened without a barcode.
  ///
  /// In en, this message translates to:
  /// **'Scan a product barcode to see if it suits your skin.'**
  String get productNoneBody;

  /// Button on the empty product result.
  ///
  /// In en, this message translates to:
  /// **'Go to Home'**
  String get productNoneAction;

  /// Title when the barcode is not in the catalogue.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t find that product'**
  String get productNotFoundTitle;

  /// Body when the barcode is not in the catalogue.
  ///
  /// In en, this message translates to:
  /// **'Saaf AI can search the web for it instead.'**
  String get productNotFoundBody;

  /// Title when the product lookup fails.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t load this product'**
  String get productErrorTitle;

  /// Button that repeats the lookup.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get productErrorAction;

  /// Top bar title of the weekly check-in (11).
  ///
  /// In en, this message translates to:
  /// **'Weekly check-in'**
  String get checkInTitle;

  /// Tooltip of the info button on the check-in.
  ///
  /// In en, this message translates to:
  /// **'About check-ins'**
  String get checkInInfo;

  /// Chip at the top of the check-in.
  ///
  /// In en, this message translates to:
  /// **'Week {week} of your routine'**
  String checkInWeek(int week);

  /// First coach message when the name is known.
  ///
  /// In en, this message translates to:
  /// **'Salam {name}! How has your skin felt this week?'**
  String checkInGreeting(String name);

  /// First coach message when the name is not known.
  ///
  /// In en, this message translates to:
  /// **'Salam! How has your skin felt this week?'**
  String get checkInGreetingNoName;

  /// Quick reply.
  ///
  /// In en, this message translates to:
  /// **'Less oily than before'**
  String get checkInFeelLessOily;

  /// Quick reply.
  ///
  /// In en, this message translates to:
  /// **'About the same'**
  String get checkInFeelSame;

  /// Quick reply.
  ///
  /// In en, this message translates to:
  /// **'Drier or tighter'**
  String get checkInFeelDrier;

  /// Quick reply.
  ///
  /// In en, this message translates to:
  /// **'More irritated'**
  String get checkInFeelIrritated;

  /// Second question after a good answer.
  ///
  /// In en, this message translates to:
  /// **'Nice. Any new breakouts since last week?'**
  String get checkInQ2Nice;

  /// Second question after a neutral answer.
  ///
  /// In en, this message translates to:
  /// **'Thanks. Any new breakouts since last week?'**
  String get checkInQ2Thanks;

  /// Second question after a drier answer.
  ///
  /// In en, this message translates to:
  /// **'Got it. Any new breakouts since last week?'**
  String get checkInQ2Noted;

  /// Second question after an irritated answer.
  ///
  /// In en, this message translates to:
  /// **'Sorry to hear that. Any new breakouts since last week?'**
  String get checkInQ2Sorry;

  /// Quick reply.
  ///
  /// In en, this message translates to:
  /// **'No new ones'**
  String get checkInBreakNone;

  /// Quick reply.
  ///
  /// In en, this message translates to:
  /// **'1–2 small ones'**
  String get checkInBreakFew;

  /// Quick reply.
  ///
  /// In en, this message translates to:
  /// **'A few more than before'**
  String get checkInBreakMore;

  /// Quick reply.
  ///
  /// In en, this message translates to:
  /// **'Many or painful'**
  String get checkInBreakSevere;

  /// Result title.
  ///
  /// In en, this message translates to:
  /// **'Likely on track'**
  String get checkInOnTrack;

  /// Result title.
  ///
  /// In en, this message translates to:
  /// **'Keep going'**
  String get checkInKeepGoing;

  /// Result title.
  ///
  /// In en, this message translates to:
  /// **'Let’s adjust a little'**
  String get checkInAdjust;

  /// Result title.
  ///
  /// In en, this message translates to:
  /// **'Please check with a professional'**
  String get checkInSeePro;

  /// Result sentence about the skin feel.
  ///
  /// In en, this message translates to:
  /// **'Oil control is improving.'**
  String get checkInSentenceLessOily;

  /// Result sentence about the skin feel.
  ///
  /// In en, this message translates to:
  /// **'Your skin feels about the same.'**
  String get checkInSentenceSame;

  /// Result sentence about the skin feel.
  ///
  /// In en, this message translates to:
  /// **'Your skin feels drier, which is common with new products.'**
  String get checkInSentenceDrier;

  /// Result sentence about the skin feel.
  ///
  /// In en, this message translates to:
  /// **'Your skin feels irritated.'**
  String get checkInSentenceIrritated;

  /// Result sentence about breakouts.
  ///
  /// In en, this message translates to:
  /// **'No new breakouts is a good sign.'**
  String get checkInSentenceNone;

  /// Result sentence about breakouts.
  ///
  /// In en, this message translates to:
  /// **'A few small breakouts are common in week {week}.'**
  String checkInSentenceFew(int week);

  /// Result sentence about breakouts.
  ///
  /// In en, this message translates to:
  /// **'More breakouts than before can happen while skin adjusts.'**
  String get checkInSentenceMore;

  /// Result sentence about breakouts.
  ///
  /// In en, this message translates to:
  /// **'Many or painful breakouts need a professional look.'**
  String get checkInSentenceSevere;

  /// Closing sentence of an on-track result.
  ///
  /// In en, this message translates to:
  /// **'Keep going and try not to pick.'**
  String get checkInAdviceOnTrack;

  /// Closing sentence of a keep-going result.
  ///
  /// In en, this message translates to:
  /// **'Results usually take 6–8 weeks, so keep going.'**
  String get checkInAdviceKeepGoing;

  /// Closing sentence of an adjust result.
  ///
  /// In en, this message translates to:
  /// **'Try a richer moisturiser and use strong products less often. If nothing changes in two weeks, ask a pharmacist.'**
  String get checkInAdviceAdjust;

  /// Closing sentence of a see-a-professional result.
  ///
  /// In en, this message translates to:
  /// **'Pause any new products and ask a dermatologist or pharmacist, especially if it is painful or keeps getting worse.'**
  String get checkInAdviceSeePro;

  /// Chip in the result card. {date} is like 14 Nov.
  ///
  /// In en, this message translates to:
  /// **'Next photo check · {date}'**
  String checkInNextPhoto(String date);

  /// Hint inside the reply field.
  ///
  /// In en, this message translates to:
  /// **'Reply in English or Urdu…'**
  String get checkInHint;

  /// Tooltip of the send button.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get checkInSend;

  /// Coach message after the user types a note once the check-in is done.
  ///
  /// In en, this message translates to:
  /// **'Thanks, I’ve saved your note for your next check-in.'**
  String get checkInNoteSaved;

  /// Initial letter in the coach avatar.
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get checkInCoachInitial;

  /// Screen-reader label of a coach message.
  ///
  /// In en, this message translates to:
  /// **'Saaf says: {text}'**
  String checkInCoachSays(String text);

  /// Screen-reader label of a message from the user.
  ///
  /// In en, this message translates to:
  /// **'You said: {text}'**
  String checkInYouSaid(String text);

  /// Screen-reader label of the result card.
  ///
  /// In en, this message translates to:
  /// **'Result: {title}. {body}'**
  String checkInResultSemantics(String title, String body);

  /// Title of the info dialog.
  ///
  /// In en, this message translates to:
  /// **'About check-ins'**
  String get checkInInfoTitle;

  /// Body of the info dialog.
  ///
  /// In en, this message translates to:
  /// **'Your check-in uses simple rules, not AI. Your answers are kept on your phone. It cannot diagnose skin conditions: if something worries you, please see a dermatologist.'**
  String get checkInInfoBody;

  /// Button that closes the info dialog.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get checkInInfoClose;

  /// Chip at the top of the paywall (13).
  ///
  /// In en, this message translates to:
  /// **'Saaf Pro'**
  String get paywallProChip;

  /// Paywall headline.
  ///  is a line break.
  ///
  /// In en, this message translates to:
  /// **'See real change,\nevery two weeks'**
  String get paywallTitle;

  /// Benefit.
  ///
  /// In en, this message translates to:
  /// **'Aligned photo comparisons every 2 weeks'**
  String get paywallBenefitPhotos;

  /// Benefit.
  ///
  /// In en, this message translates to:
  /// **'Unlimited skin and product scans'**
  String get paywallBenefitScans;

  /// Benefit.
  ///
  /// In en, this message translates to:
  /// **'Price-drop alerts on your products'**
  String get paywallBenefitAlerts;

  /// Benefit.
  ///
  /// In en, this message translates to:
  /// **'Weekly coach check-ins and reports'**
  String get paywallBenefitCoach;

  /// Plan name.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get planYearly;

  /// Plan name.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get planMonthly;

  /// Chip on the yearly plan.
  ///
  /// In en, this message translates to:
  /// **'Save {percent}%'**
  String planSave(int percent);

  /// Caption of the yearly plan. {price} is the store's monthly equivalent.
  ///
  /// In en, this message translates to:
  /// **'{price}/month, billed yearly'**
  String planPerMonthBilledYearly(String price);

  /// Caption of the monthly plan.
  ///
  /// In en, this message translates to:
  /// **'Cancel anytime'**
  String get planCancelAnytime;

  /// Screen-reader label of a plan tile.
  ///
  /// In en, this message translates to:
  /// **'{title}. {price}. {caption}'**
  String planSemantics(String title, String price, String caption);

  /// Primary button when the plan has a free trial.
  ///
  /// In en, this message translates to:
  /// **'Start {days}-day free trial'**
  String paywallStartTrial(int days);

  /// Primary button when the plan has no free trial.
  ///
  /// In en, this message translates to:
  /// **'Subscribe'**
  String get paywallSubscribe;

  /// Used in the fine print: Rs 3,999/year.
  ///
  /// In en, this message translates to:
  /// **'year'**
  String get paywallPeriodYear;

  /// Used in the fine print: Rs 599/month.
  ///
  /// In en, this message translates to:
  /// **'month'**
  String get paywallPeriodMonth;

  /// Where to cancel on iPhone.
  ///
  /// In en, this message translates to:
  /// **'the App Store'**
  String get paywallStoreApple;

  /// Where to cancel on Android.
  ///
  /// In en, this message translates to:
  /// **'Google Play'**
  String get paywallStoreGoogle;

  /// Where to cancel elsewhere.
  ///
  /// In en, this message translates to:
  /// **'your store settings'**
  String get paywallStoreOther;

  /// Fine print under the button when there is a free trial.
  ///
  /// In en, this message translates to:
  /// **'Free for {days} days, then {price}/{period}. Cancel anytime in {store}.'**
  String paywallFinePrintTrial(
    int days,
    String price,
    String period,
    String store,
  );

  /// Fine print under the button when there is no free trial.
  ///
  /// In en, this message translates to:
  /// **'{price}/{period}. Renews automatically. Cancel anytime in {store}.'**
  String paywallFinePrint(String price, String period, String store);

  /// Button that asks the store for earlier purchases.
  ///
  /// In en, this message translates to:
  /// **'Restore purchases'**
  String get paywallRestore;

  /// Message when a purchase was restored.
  ///
  /// In en, this message translates to:
  /// **'Welcome back to Saaf Pro.'**
  String get paywallRestored;

  /// Message when there is nothing to restore.
  ///
  /// In en, this message translates to:
  /// **'No earlier purchase found.'**
  String get paywallNothingToRestore;

  /// Message when restoring fails.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t check your purchases. Please try again.'**
  String get paywallRestoreFailed;

  /// Message when buying fails.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t complete the purchase. You have not been charged.'**
  String get paywallPurchaseFailed;

  /// Tooltip of the X button on the paywall.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get paywallClose;

  /// Title when no plans can be loaded.
  ///
  /// In en, this message translates to:
  /// **'Subscriptions aren’t available right now'**
  String get paywallUnavailableTitle;

  /// Body when no plans can be loaded.
  ///
  /// In en, this message translates to:
  /// **'Please try again later.'**
  String get paywallUnavailableBody;

  /// Button that loads the plans again.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get paywallRetry;

  /// Title when the user already has Pro.
  ///
  /// In en, this message translates to:
  /// **'You’re on Saaf Pro'**
  String get paywallAlreadyProTitle;

  /// Body when the user already has Pro.
  ///
  /// In en, this message translates to:
  /// **'Thank you for supporting Saaf. You can manage your plan in {store}.'**
  String paywallAlreadyProBody(String store);

  /// Overline above the progress title: the week of using Saaf (scans are every two weeks).
  ///
  /// In en, this message translates to:
  /// **'WEEK {week}'**
  String progressWeek(int week);

  /// Title of the monthly progress screen.
  ///
  /// In en, this message translates to:
  /// **'Your progress'**
  String get progressTitle;

  /// Tooltip of the share button.
  ///
  /// In en, this message translates to:
  /// **'Share your progress'**
  String get progressShare;

  /// Text shared from the progress screen. Never includes photos.
  ///
  /// In en, this message translates to:
  /// **'My Saaf progress, week {week}: {first}, {second}. A cosmetic guide, not medical advice.'**
  String progressShareText(int week, String first, String second);

  /// Dates and photo count under the title.
  ///
  /// In en, this message translates to:
  /// **'{from} → {to}  ·  {count, plural, =1{1 aligned photo} other{{count} aligned photos}}'**
  String progressRange(String from, String to, int count);

  /// Chip on the earlier photo.
  ///
  /// In en, this message translates to:
  /// **'Before · {date}'**
  String progressBefore(String date);

  /// Chip on the later photo.
  ///
  /// In en, this message translates to:
  /// **'After · {date}'**
  String progressAfter(String date);

  /// Screen-reader name of the slider.
  ///
  /// In en, this message translates to:
  /// **'Compare before and after'**
  String get progressCompare;

  /// Caption of a change card, the date of the earlier scan.
  ///
  /// In en, this message translates to:
  /// **'vs {date}'**
  String progressVs(String date);

  /// Screen-reader label of a change card.
  ///
  /// In en, this message translates to:
  /// **'{name}: {change} {since}'**
  String progressChangeSemantics(String name, String change, String since);

  /// Label of the summary card.
  ///
  /// In en, this message translates to:
  /// **'Coach summary'**
  String get progressCoach;

  /// Summary when something improved. {metric} is a measure name.
  ///
  /// In en, this message translates to:
  /// **'Good news: {metric} improved. Daily sun protection keeps the progress, so keep it up.'**
  String progressSummaryImproving(String metric);

  /// Summary when nothing changed much.
  ///
  /// In en, this message translates to:
  /// **'Your skin looks steady since {date}. Results often take 6–8 weeks, so keep going.'**
  String progressSummarySteady(String date);

  /// Summary when something got worse.
  ///
  /// In en, this message translates to:
  /// **'Some areas look a little worse than last time. Check your routine and sun protection, and see a dermatologist if you are worried.'**
  String get progressSummarySlipping;

  /// Title shown to users without Saaf Pro.
  ///
  /// In en, this message translates to:
  /// **'Progress tracking is part of Saaf Pro'**
  String get progressLockedTitle;

  /// Body shown to users without Saaf Pro.
  ///
  /// In en, this message translates to:
  /// **'Compare aligned photos every two weeks and see what is changing.'**
  String get progressLockedBody;

  /// Button that opens the paywall.
  ///
  /// In en, this message translates to:
  /// **'See Saaf Pro'**
  String get progressLockedAction;

  /// Title when there are fewer than two scans.
  ///
  /// In en, this message translates to:
  /// **'Your first comparison is on its way'**
  String get progressEmptyTitle;

  /// Body when there are fewer than two scans.
  ///
  /// In en, this message translates to:
  /// **'Take another face scan in two weeks and Saaf will show what changed.'**
  String get progressEmptyBody;

  /// Button that opens the camera screen.
  ///
  /// In en, this message translates to:
  /// **'Take a scan'**
  String get progressEmptyAction;

  /// Title when the comparison fails.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t load your progress'**
  String get progressErrorTitle;

  /// Button that repeats the comparison.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get progressErrorAction;

  /// Button that opens the weekly check-in.
  ///
  /// In en, this message translates to:
  /// **'Start your weekly check-in'**
  String get progressCheckIn;

  /// Title of the profile screen (14).
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// Name shown when the user has no name.
  ///
  /// In en, this message translates to:
  /// **'Saaf member'**
  String get profileNameFallback;

  /// Shown instead of a name when only a phone number is known.
  ///
  /// In en, this message translates to:
  /// **'Phone ending {digits}'**
  String profilePhoneFallback(String digits);

  /// Skin type in the identity line, e.g. 'Oily skin'.
  ///
  /// In en, this message translates to:
  /// **'{type} skin'**
  String profileSkinType(String type);

  /// Promo card title for free users.
  ///
  /// In en, this message translates to:
  /// **'You’re on the free plan'**
  String get profilePlanFree;

  /// Promo card body for free users.
  ///
  /// In en, this message translates to:
  /// **'Unlock photo tracking every 2 weeks'**
  String get profilePlanFreeBody;

  /// Button on the promo card.
  ///
  /// In en, this message translates to:
  /// **'Go Pro'**
  String get profileGoPro;

  /// Promo card title for Pro users.
  ///
  /// In en, this message translates to:
  /// **'You’re on Saaf Pro'**
  String get profilePlanPro;

  /// Promo card body for Pro users.
  ///
  /// In en, this message translates to:
  /// **'Thank you for supporting Saaf'**
  String get profilePlanProBody;

  /// Button on the promo card for Pro users.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get profileManage;

  /// Section heading.
  ///
  /// In en, this message translates to:
  /// **'Routine'**
  String get profileSectionRoutine;

  /// Section heading.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get profileSectionPrivacy;

  /// Section heading.
  ///
  /// In en, this message translates to:
  /// **'App'**
  String get profileSectionApp;

  /// Settings row.
  ///
  /// In en, this message translates to:
  /// **'Skin profile'**
  String get profileRowSkin;

  /// Settings row.
  ///
  /// In en, this message translates to:
  /// **'Monthly budget'**
  String get profileRowBudget;

  /// Settings row.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get profileRowReminders;

  /// Settings row.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get profileRowLanguage;

  /// Settings row.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get profileRowAppearance;

  /// Settings row.
  ///
  /// In en, this message translates to:
  /// **'Photo backup'**
  String get profileRowBackup;

  /// Settings row.
  ///
  /// In en, this message translates to:
  /// **'Delete my account'**
  String get profileRowDelete;

  /// Settings row.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get profileRowLogout;

  /// Screen-reader label of a settings row with a value.
  ///
  /// In en, this message translates to:
  /// **'{title}, {value}'**
  String profileRowSemantics(String title, String value);

  /// Row value when the user has not answered.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get profileValueNotSet;

  /// Row value for something that is off.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get profileValueOff;

  /// Budget row value for the highest band.
  ///
  /// In en, this message translates to:
  /// **'No limit'**
  String get profileValueNoLimit;

  /// Language name.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get profileLangEnglish;

  /// Language name in its own script.
  ///
  /// In en, this message translates to:
  /// **'اردو'**
  String get profileLangUrdu;

  /// Appearance option: follow the phone.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get profileThemeSystem;

  /// Appearance option.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get profileThemeLight;

  /// Appearance option.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get profileThemeDark;

  /// Button that closes a sheet.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get commonDone;

  /// Button that cancels a dialog.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// Button on the skin type quiz step that opens the tissue test.
  ///
  /// In en, this message translates to:
  /// **'Not sure? Try the tissue test'**
  String get quizTissueEntry;

  /// Title of the tissue test screen.
  ///
  /// In en, this message translates to:
  /// **'Tissue test'**
  String get tissueTitle;

  /// Introduction of the tissue test.
  ///
  /// In en, this message translates to:
  /// **'A simple way to see how oily your skin is. It takes a minute, plus a short wait.'**
  String get tissueIntro;

  /// Tissue test step 1.
  ///
  /// In en, this message translates to:
  /// **'Wash your face with a gentle cleanser and pat it dry. Don’t put anything on it.'**
  String get tissueStep1;

  /// Tissue test step 2.
  ///
  /// In en, this message translates to:
  /// **'Wait about 30 minutes to an hour, so your skin settles back to normal.'**
  String get tissueStep2;

  /// Tissue test step 3.
  ///
  /// In en, this message translates to:
  /// **'Press a clean tissue or blotting paper lightly on your forehead, nose and cheeks, one at a time.'**
  String get tissueStep3;

  /// Tissue test step 4.
  ///
  /// In en, this message translates to:
  /// **'Hold the tissue up to the light and look for oily marks.'**
  String get tissueStep4;

  /// Button that moves to the tissue test questions.
  ///
  /// In en, this message translates to:
  /// **'I’ve done the test'**
  String get tissueDone;

  /// Heading above the tissue test questions.
  ///
  /// In en, this message translates to:
  /// **'What did you see?'**
  String get tissueQuestionTitle;

  /// Explains the tissue test questions.
  ///
  /// In en, this message translates to:
  /// **'Switch on each place where the tissue had an oily mark. Leave all off if it stayed clean.'**
  String get tissueQuestionHint;

  /// Tissue test option.
  ///
  /// In en, this message translates to:
  /// **'Oil mark from my forehead'**
  String get tissueForehead;

  /// Tissue test option.
  ///
  /// In en, this message translates to:
  /// **'Oil mark from my nose'**
  String get tissueNose;

  /// Tissue test option.
  ///
  /// In en, this message translates to:
  /// **'Oil mark from my cheeks'**
  String get tissueCheeks;

  /// Tissue test option.
  ///
  /// In en, this message translates to:
  /// **'My skin feels tight or flaky'**
  String get tissueTight;

  /// Caption under each tissue test option.
  ///
  /// In en, this message translates to:
  /// **'Tap if this applies'**
  String get tissueOptionCaption;

  /// Result heading; the type is a lower-case skin type name.
  ///
  /// In en, this message translates to:
  /// **'Your skin looks {type}'**
  String tissueResultTitle(String type);

  /// Explanation of the oily result.
  ///
  /// In en, this message translates to:
  /// **'Oil on your forehead and cheeks suggests oily skin.'**
  String get tissueResultOily;

  /// Explanation of the combination result.
  ///
  /// In en, this message translates to:
  /// **'Oil only on the forehead and nose, with clearer cheeks, suggests combination skin.'**
  String get tissueResultCombination;

  /// Explanation of the normal result.
  ///
  /// In en, this message translates to:
  /// **'A clean tissue and comfortable skin suggests normal skin.'**
  String get tissueResultNormal;

  /// Explanation of the dry result.
  ///
  /// In en, this message translates to:
  /// **'A clean tissue with tight or flaky skin suggests dry skin.'**
  String get tissueResultDry;

  /// Shown when the tissue test result is unclear.
  ///
  /// In en, this message translates to:
  /// **'Oil on your cheeks but not your forehead or nose is unusual. Try the test again on another day.'**
  String get tissueResultUnclear;

  /// Result heading when the tissue test is unclear.
  ///
  /// In en, this message translates to:
  /// **'We can’t tell yet'**
  String get tissueUnclearTitle;

  /// Button that sets the skin type from the tissue test.
  ///
  /// In en, this message translates to:
  /// **'Use this result'**
  String get tissueUse;

  /// Reminder under the tissue test result.
  ///
  /// In en, this message translates to:
  /// **'This is a guide, not a diagnosis. Skin changes with the weather and the time of the month, so repeat it on another day if you’re unsure.'**
  String get tissueCaveat;

  /// Button that saves what was changed.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// Title of the sheet where the name and age are edited.
  ///
  /// In en, this message translates to:
  /// **'Your details'**
  String get profileDetailsTitle;

  /// Label of the name field.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get profileDetailsName;

  /// Hint inside the name field.
  ///
  /// In en, this message translates to:
  /// **'What should we call you?'**
  String get profileDetailsNameHint;

  /// Label of the age field.
  ///
  /// In en, this message translates to:
  /// **'Age (optional)'**
  String get profileDetailsAge;

  /// Reassurance under the details fields.
  ///
  /// In en, this message translates to:
  /// **'Only stored on this phone.'**
  String get profileDetailsHelp;

  /// Error when the name is empty or too long.
  ///
  /// In en, this message translates to:
  /// **'Enter a name of up to 40 letters.'**
  String get profileDetailsNameError;

  /// Error when the age is not allowed.
  ///
  /// In en, this message translates to:
  /// **'Enter an age from 16 to 99.'**
  String get profileDetailsAgeError;

  /// Screen-reader label of the profile card.
  ///
  /// In en, this message translates to:
  /// **'Edit your name and age'**
  String get profileDetailsEditSemantics;

  /// Title of the sheet that lists the skin answers.
  ///
  /// In en, this message translates to:
  /// **'Skin profile'**
  String get profileSkinSheetTitle;

  /// Row in the skin profile sheet.
  ///
  /// In en, this message translates to:
  /// **'Skin type'**
  String get profileRowSkinType;

  /// Row in the skin profile sheet.
  ///
  /// In en, this message translates to:
  /// **'Skin concerns'**
  String get profileRowConcerns;

  /// Row in the skin profile sheet.
  ///
  /// In en, this message translates to:
  /// **'Sensitivity'**
  String get profileRowSensitivity;

  /// Row in the skin profile sheet.
  ///
  /// In en, this message translates to:
  /// **'Health & safety'**
  String get profileRowSafety;

  /// Value of the safety row when the user has none of the listed conditions.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get profileValueNone;

  /// Title of the language sheet.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageTitle;

  /// Screen-reader name of the language switch.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageSemantics;

  /// Title of the appearance sheet.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearanceTitle;

  /// Title of the reminders sheet.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get remindersTitle;

  /// Reminder name.
  ///
  /// In en, this message translates to:
  /// **'Morning routine'**
  String get remindersMorning;

  /// Reminder name.
  ///
  /// In en, this message translates to:
  /// **'Night routine'**
  String get remindersNight;

  /// Tooltip and screen-reader label of a reminder time button.
  ///
  /// In en, this message translates to:
  /// **'Change the time of {name}'**
  String remindersChange(String name);

  /// Footer of the reminders sheet.
  ///
  /// In en, this message translates to:
  /// **'Saaf reminds you every day at these times.'**
  String get remindersNote;

  /// Title of our own explanation shown before the system notification dialog.
  ///
  /// In en, this message translates to:
  /// **'Allow notifications'**
  String get remindersRationaleTitle;

  /// Body of our notification explanation.
  ///
  /// In en, this message translates to:
  /// **'Saaf sends one gentle reminder for your morning routine and one for your night routine, at the times you choose. Nothing else.'**
  String get remindersRationaleBody;

  /// Shown in the reminders sheet after the user refused notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications are off, so reminders can’t be sent. You can try again any time.'**
  String get remindersDeniedNote;

  /// Shown in the reminders sheet when notifications are blocked in the phone's settings.
  ///
  /// In en, this message translates to:
  /// **'Notifications are blocked for Saaf. Allow them in your phone’s Settings to get reminders.'**
  String get remindersBlockedNote;

  /// Title of the daily morning notification.
  ///
  /// In en, this message translates to:
  /// **'Time for your morning routine'**
  String get reminderNotificationMorningTitle;

  /// Body of the daily morning notification.
  ///
  /// In en, this message translates to:
  /// **'Cleanse, moisturise and put on sunscreen. It only takes a few minutes.'**
  String get reminderNotificationMorningBody;

  /// Title of the daily night notification.
  ///
  /// In en, this message translates to:
  /// **'Time for your night routine'**
  String get reminderNotificationNightTitle;

  /// Body of the daily night notification.
  ///
  /// In en, this message translates to:
  /// **'Cleanse and moisturise, then rest well.'**
  String get reminderNotificationNightBody;

  /// Title of the photo backup sheet.
  ///
  /// In en, this message translates to:
  /// **'Photo backup'**
  String get backupTitle;

  /// Body of the photo backup sheet.
  ///
  /// In en, this message translates to:
  /// **'Your face photos stay only on this phone. The one exception is photos you choose to send for an AI review. Cloud backup is not available in this version.'**
  String get backupBody;

  /// Title of the delete dialog.
  ///
  /// In en, this message translates to:
  /// **'Delete your account?'**
  String get deleteTitle;

  /// Body of the delete dialog.
  ///
  /// In en, this message translates to:
  /// **'This removes your account and everything Saaf keeps about you on this phone: your scans and photos, your answers, your routine and your check-ins. This cannot be undone.'**
  String get deleteBody;

  /// Destructive button of the delete dialog.
  ///
  /// In en, this message translates to:
  /// **'Delete everything'**
  String get deleteConfirm;

  /// Message when the login is too old to delete the account.
  ///
  /// In en, this message translates to:
  /// **'For your security, please log in again and then delete your account.'**
  String get deleteFailedRecent;

  /// Message when deleting fails.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t delete your account. Please try again.'**
  String get deleteFailed;

  /// Title of the log-out dialog.
  ///
  /// In en, this message translates to:
  /// **'Log out?'**
  String get logoutTitle;

  /// Body of the log-out dialog.
  ///
  /// In en, this message translates to:
  /// **'You can log back in with your phone number, Google or Apple.'**
  String get logoutBody;

  /// Button of the log-out dialog.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logoutConfirm;

  /// Card on the routine before Saaf AI is turned on.
  ///
  /// In en, this message translates to:
  /// **'Let Saaf AI choose your products'**
  String get aiPicksOfferTitle;

  /// Body of the Saaf AI picks offer.
  ///
  /// In en, this message translates to:
  /// **'It picks from real products sold in Pakistan to suit your skin, your latest scan and your budget.'**
  String get aiPicksOfferBody;

  /// Button that opens the AI permission screen.
  ///
  /// In en, this message translates to:
  /// **'Turn on Saaf AI'**
  String get aiPicksTurnOn;

  /// Shown while Saaf AI chooses products.
  ///
  /// In en, this message translates to:
  /// **'Saaf AI is choosing products for your skin…'**
  String get aiPicksLoading;

  /// Shown when Saaf AI picks failed.
  ///
  /// In en, this message translates to:
  /// **'Saaf AI couldn’t choose right now, so these are our picks.'**
  String get aiPicksFailed;

  /// Label on the routine when Saaf AI chose the products.
  ///
  /// In en, this message translates to:
  /// **'Picked by Saaf AI'**
  String get aiPicksLabel;

  /// Button that shows the reason for each product.
  ///
  /// In en, this message translates to:
  /// **'Why these products'**
  String get aiPicksWhy;

  /// Button that hides the reasons.
  ///
  /// In en, this message translates to:
  /// **'Hide the reasons'**
  String get aiPicksHide;

  /// Small note under Saaf AI picks.
  ///
  /// In en, this message translates to:
  /// **'AI picks can be wrong. Check the label and patch test anything new.'**
  String get aiPicksNote;

  /// Top bar title of the product look-up screen.
  ///
  /// In en, this message translates to:
  /// **'Saaf AI look-up'**
  String get productAiTitle;

  /// Title when looking a product up from a photo.
  ///
  /// In en, this message translates to:
  /// **'Look up a product from a photo'**
  String get productAiPhotoTitle;

  /// What is sent for a photo look-up.
  ///
  /// In en, this message translates to:
  /// **'Take a clear photo of the front label. Only this photo, with your skin type and concerns, goes to Saaf AI (Groq, through Saaf’s server). It reads the label and searches the web.'**
  String get productAiPhotoBody;

  /// Title when looking a barcode or QR code up.
  ///
  /// In en, this message translates to:
  /// **'Look this product up with Saaf AI'**
  String get productAiCodeTitle;

  /// What is sent for a barcode look-up.
  ///
  /// In en, this message translates to:
  /// **'Barcode {code}. Only this number, with your skin type and concerns, goes to Saaf AI (Groq, through Saaf’s server), which searches the web for the product.'**
  String productAiBarcodeBody(String code);

  /// What is sent for a QR look-up.
  ///
  /// In en, this message translates to:
  /// **'The QR code says: {text}\nOnly this text, with your skin type and concerns, goes to Saaf AI (Groq, through Saaf’s server), which searches the web for the product. Saaf does not open the link.'**
  String productAiQrBody(String text);

  /// Button: take a photo of the product.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get productAiTakePhoto;

  /// Button: choose a product photo.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get productAiChoosePhoto;

  /// Button: take the product photo again.
  ///
  /// In en, this message translates to:
  /// **'Retake photo'**
  String get productAiRetake;

  /// Screen-reader label of the product photo preview.
  ///
  /// In en, this message translates to:
  /// **'Photo of the product to send'**
  String get productAiPhotoLabel;

  /// Button that sends the look-up.
  ///
  /// In en, this message translates to:
  /// **'Look it up'**
  String get productAiLookUp;

  /// Shown while the look-up runs.
  ///
  /// In en, this message translates to:
  /// **'Saaf AI is searching the web…'**
  String get productAiSearching;

  /// Title when the product was not found.
  ///
  /// In en, this message translates to:
  /// **'Saaf AI couldn’t tell which product this is'**
  String get productAiNotFoundTitle;

  /// Advice after a photo was not recognised.
  ///
  /// In en, this message translates to:
  /// **'Try a clear, close photo of the front label in good light.'**
  String get productAiNotFoundPhoto;

  /// Advice after a code was not recognised.
  ///
  /// In en, this message translates to:
  /// **'Try a photo of the front label instead.'**
  String get productAiNotFoundCode;

  /// Note when the web search failed.
  ///
  /// In en, this message translates to:
  /// **'Saaf AI couldn’t search the web this time, so this is from what it already knows. Check the label.'**
  String get productAiNotWebChecked;

  /// Button after a look-up.
  ///
  /// In en, this message translates to:
  /// **'Scan another product'**
  String get productAiScanAnother;

  /// Shown when Saaf AI has not been turned on.
  ///
  /// In en, this message translates to:
  /// **'Saaf AI is off. Turn it on to look products up and to ask about your skin.'**
  String get productAiNeedsConsent;

  /// Heading above the photo look-up button.
  ///
  /// In en, this message translates to:
  /// **'Can’t scan it?'**
  String get scanProductCantScanTitle;

  /// Button that opens the photo look-up.
  ///
  /// In en, this message translates to:
  /// **'Take a photo of the product'**
  String get scanProductPhotoButton;

  /// Button on the not-found state.
  ///
  /// In en, this message translates to:
  /// **'Look it up with Saaf AI'**
  String get productNotFoundAction;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ur'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ur':
      return AppLocalizationsUr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
