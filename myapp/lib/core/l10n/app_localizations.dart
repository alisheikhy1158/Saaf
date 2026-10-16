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
  /// **'Photos stay on your phone unless you turn on backup.'**
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
  /// **'Photos stay on your phone and are never uploaded.'**
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
  /// **'The three photos stay on your phone. They are never uploaded to work out your score.'**
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
