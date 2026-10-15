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

  /// Temporary body of the Terms / Privacy pages. Must be replaced by the real documents before store submission.
  ///
  /// In en, this message translates to:
  /// **'The full text will be published here before Saaf is released.'**
  String get legalPlaceholderBody;

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
