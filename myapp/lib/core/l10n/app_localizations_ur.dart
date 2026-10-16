// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Urdu (`ur`).
class AppLocalizationsUr extends AppLocalizations {
  AppLocalizationsUr([String locale = 'ur']) : super(locale);

  @override
  String get appName => 'صاف';

  @override
  String get welcomeTitle => 'صاف جلد، آسان انداز میں۔';

  @override
  String get welcomeSubtitle =>
      'جنوبی ایشیائی جلد کے لیے اسکن کیئر کوچ۔ ایسی روٹینز جو پاکستان میں دستیاب مصنوعات سے بنی ہیں۔';

  @override
  String get welcomeChip => 'جنوبی ایشیائی جلد کے لیے';

  @override
  String get welcomeStatCaption => 'مثال: جلد کے داغ';

  @override
  String get welcomeStatValue => '8 ہفتوں میں 32٪ کمی';

  @override
  String get getStarted => 'شروع کریں';

  @override
  String get alreadyHaveAccount => 'میرا اکاؤنٹ پہلے سے موجود ہے';

  @override
  String get language => 'زبان';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageUrdu => 'اردو';

  @override
  String get back => 'واپس';

  @override
  String get consentTitle => 'آپ کی تصاویر آپ کے فون پر رہتی ہیں';

  @override
  String get consentSubtitle =>
      'صاف آپ کی جلد کو دیکھتا ہے، آپ کی شناخت کو نہیں۔ دیکھیے ہم آپ کے ڈیٹا کی حفاظت کیسے کرتے ہیں۔';

  @override
  String get consentPointDeviceTitle => 'آپ کے آلے پر محفوظ';

  @override
  String get consentPointDeviceBody =>
      'تصاویر آپ کے فون پر ہی رہتی ہیں، جب تک آپ بیک اپ آن نہ کریں۔';

  @override
  String get consentPointNeverSoldTitle => 'نہ فروخت، نہ شیئر';

  @override
  String get consentPointNeverSoldBody =>
      'برانڈز اور اشتہاری ادارے آپ کے چہرے کا ڈیٹا کبھی نہیں دیکھتے۔';

  @override
  String get consentPointDeleteTitle => 'جب چاہیں حذف کریں';

  @override
  String get consentPointDeleteBody =>
      'ایک ٹیپ میں اپنا اکاؤنٹ اور ہر تصویر ہٹا دیں۔';

  @override
  String consentAgree(String terms, String privacy) {
    return 'میں $terms اور $privacy سے متفق ہوں';
  }

  @override
  String get consentAge => 'میری عمر 16 سال یا اس سے زیادہ ہے';

  @override
  String get consentContinue => 'اتفاق کریں اور آگے بڑھیں';

  @override
  String get termsTitle => 'استعمال کی شرائط';

  @override
  String get privacyPolicyTitle => 'رازداری کی پالیسی';

  @override
  String openDocumentAction(String name) {
    return '$name کھولیں';
  }

  @override
  String get legalDraftBanner => 'مسودہ: قانونی جائزہ باقی ہے';

  @override
  String legalLastUpdated(String date) {
    return 'آخری تازہ کاری $date';
  }

  @override
  String get legalEnglishOnlyNote =>
      'یہ دستاویز فی الحال صرف انگریزی میں دستیاب ہے۔';

  @override
  String quizStepLabel(int current, int total) {
    return 'مرحلہ $current از $total';
  }

  @override
  String get quizSkip => 'چھوڑیں';

  @override
  String get quizNext => 'آگے';

  @override
  String get quizConcernsTitle =>
      'آپ کی جلد کے بارے میں سب سے زیادہ کیا پریشان کرتا ہے؟';

  @override
  String get quizConcernsHint =>
      'زیادہ سے زیادہ دو چنیں۔ آپ بعد میں تبدیل کر سکتے ہیں۔';

  @override
  String get quizSkinTypeTitle => 'دوپہر تک آپ کی جلد کیسی محسوس ہوتی ہے؟';

  @override
  String get quizSkinTypeHint =>
      'سب سے قریب جواب چنیں۔ یقین نہیں؟ کوئی بات نہیں۔';

  @override
  String get skinTypeOilyTitle => 'چکنی';

  @override
  String get skinTypeOilyCaption => 'چمکدار، خاص طور پر ماتھے اور ناک پر';

  @override
  String get skinTypeDryTitle => 'خشک';

  @override
  String get skinTypeDryCaption => 'موئسچرائزر کے بعد بھی کھنچاؤ یا پپڑی';

  @override
  String get skinTypeCombinationTitle => 'ملی جلی';

  @override
  String get skinTypeCombinationCaption => 'ٹی زون چکنا، گال نسبتاً خشک';

  @override
  String get skinTypeNormalTitle => 'متوازن';

  @override
  String get skinTypeNormalCaption => 'آرام دہ، نہ چمکدار نہ کھنچی ہوئی';

  @override
  String get skinTypeNotSureTitle => 'یقین نہیں';

  @override
  String get skinTypeNotSureCaption =>
      'ہم نرمی سے شروع کریں گے اور آپ کے ساتھ سیکھیں گے';

  @override
  String get quizSensitivityTitle =>
      'نئی مصنوعات پر آپ کی جلد کا ردِعمل کیسا ہوتا ہے؟';

  @override
  String get quizSensitivityHint =>
      'ایک چنیں۔ حساس جلد سے تیز اجزاء دور رکھے جاتے ہیں۔';

  @override
  String get sensitivityLowTitle => 'کم ہی ردِعمل ہوتا ہے';

  @override
  String get sensitivityLowCaption => 'نئی مصنوعات عموماً ٹھیک رہتی ہیں';

  @override
  String get sensitivitySometimesTitle => 'کبھی کبھار ردِعمل ہوتا ہے';

  @override
  String get sensitivitySometimesCaption => 'کبھی جلن، سرخی یا دانے';

  @override
  String get sensitivityHighTitle => 'اکثر ردِعمل ہوتا ہے';

  @override
  String get sensitivityHighCaption => 'کئی مصنوعات سے جلن یا خارش';

  @override
  String get quizSafetyTitle => 'کیا کوئی بات ہمیں ذہن میں رکھنی چاہیے؟';

  @override
  String get quizSafetyHint =>
      'اختیاری۔ یہ آپ کے فون پر ہی رہتا ہے اور صرف ایسے اجزاء سے بچنے میں مدد دیتا ہے جو آپ کو موافق نہ آئیں۔';

  @override
  String get safetyPregnantTitle => 'حمل یا دودھ پلانے کا دور';

  @override
  String get safetyPregnantCaption =>
      'ہم عموماً اجتناب کیے جانے والے اجزاء شامل نہیں کریں گے';

  @override
  String get safetyPrescriptionTitle => 'جلد کا نسخے والا علاج جاری ہے';

  @override
  String get safetyPrescriptionCaption =>
      'ہم نرم طریقہ رکھیں گے اور ڈاکٹر سے مشورے کا کہیں گے';

  @override
  String get safetyAllergyTitle => 'کسی جزو سے معلوم الرجی';

  @override
  String get safetyAllergyCaption => 'مثلاً خوشبو یا کوئی خاص جزو';

  @override
  String get safetyNoneTitle => 'ان میں سے کوئی نہیں';

  @override
  String get safetyNoneCaption => 'کچھ شامل کرنے کی ضرورت نہیں';

  @override
  String get quizBudgetTitle =>
      'آپ ہر ماہ جلد کی دیکھ بھال پر کتنا خرچ کر سکتے ہیں؟';

  @override
  String get quizBudgetHint =>
      'ایک حد چنیں۔ آپ کی روٹین اسی میں آنے والی مصنوعات سے بنے گی۔';

  @override
  String get budgetEssentialTitle => '3,000 روپے سے کم';

  @override
  String get budgetEssentialCaption => 'سادہ اور مؤثر بنیادی چیزیں';

  @override
  String get budgetBalancedTitle => '3,000 – 6,000 روپے';

  @override
  String get budgetBalancedCaption => 'ایک مضبوط روٹین اور کچھ اضافی چیزیں';

  @override
  String get budgetComfortableTitle => '6,000 – 10,000 روپے';

  @override
  String get budgetComfortableCaption => 'زیادہ انتخاب، علاج سمیت';

  @override
  String get budgetPremiumTitle => '10,000 روپے سے زیادہ';

  @override
  String get budgetPremiumCaption => 'جو بھی آپ کی جلد کو موافق ہو';

  @override
  String get concernDarkSpotsTitle => 'داغ دھبے اور رنگت';

  @override
  String get concernDarkSpotsCaption => 'مہاسوں یا دھوپ کے نشانات';

  @override
  String get concernAcneTitle => 'مہاسے اور دانے';

  @override
  String get concernAcneCaption => 'دانے، بلیک ہیڈز، ابھار';

  @override
  String get concernOilinessTitle => 'چکناہٹ اور کھلے مسام';

  @override
  String get concernOilinessCaption => 'دوپہر تک چمکتی جلد';

  @override
  String get concernDrynessTitle => 'خشکی اور بے رونقی';

  @override
  String get concernDrynessCaption => 'کھنچاؤ، پپڑی یا تھکی ہوئی جلد';

  @override
  String get concernUnevenToneTitle => 'ناہموار رنگت';

  @override
  String get concernUnevenToneCaption => 'دھبے دار رنگ، سیاہ حلقے';

  @override
  String get signUpTitle => 'آئیے شروع کرتے ہیں';

  @override
  String get signUpSubtitle =>
      'اپنا موبائل نمبر استعمال کریں۔ کوئی پاس ورڈ یاد رکھنے کی ضرورت نہیں۔';

  @override
  String get phoneLabel => 'موبائل نمبر';

  @override
  String get phoneHint => '3XX XXX XXXX';

  @override
  String get phoneHelper => 'ہم آپ کو 6 ہندسوں کا کوڈ ایس ایم ایس کریں گے۔';

  @override
  String get sendCode => 'کوڈ بھیجیں';

  @override
  String get orDivider => 'یا';

  @override
  String get continueWithGoogle => 'گوگل کے ساتھ جاری رکھیں';

  @override
  String get continueWithApple => 'ایپل کے ساتھ جاری رکھیں';

  @override
  String signUpLegal(String terms, String privacy) {
    return 'جاری رکھ کر آپ صاف کی $terms اور $privacy سے متفق ہوتے ہیں۔';
  }

  @override
  String get signUpSendFailed =>
      'ہم کوڈ نہیں بھیج سکے۔ اپنا کنکشن چیک کریں اور دوبارہ کوشش کریں۔';

  @override
  String get socialSignInFailed =>
      'ہم آپ کو سائن اِن نہیں کر سکے۔ دوبارہ کوشش کریں۔';

  @override
  String get verifyTitle => 'کوڈ درج کریں';

  @override
  String verifySentTo(String phone, String edit) {
    return '$phone پر بھیجا گیا  ·  $edit';
  }

  @override
  String get verifyEdit => 'تبدیل کریں';

  @override
  String get verifyCodeLabel => 'تصدیقی کوڈ';

  @override
  String verifyResendIn(String time) {
    return '$time میں کوڈ دوبارہ بھیجیں';
  }

  @override
  String get verifyResend => 'کوڈ دوبارہ بھیجیں';

  @override
  String get verifyButton => 'تصدیق کریں';

  @override
  String get verifyWrongCode => 'یہ کوڈ درست نہیں۔ دوبارہ چیک کر کے کوشش کریں۔';

  @override
  String get verifyFailed =>
      'ہم کوڈ کی تصدیق نہیں کر سکے۔ اپنا کنکشن چیک کریں اور دوبارہ کوشش کریں۔';

  @override
  String get keypadDelete => 'مٹائیں';

  @override
  String get notFoundTitle => 'صفحہ نہیں ملا';

  @override
  String get notFoundBody => 'ہمیں یہ صفحہ نہیں مل سکا۔';

  @override
  String get goToStart => 'شروع پر جائیں';

  @override
  String get fieldValid => 'درست';

  @override
  String get scanTitle => 'چہرے کا اسکین';

  @override
  String get scanClose => 'بند کریں';

  @override
  String get scanLightToggle => 'اسکرین کی روشنی';

  @override
  String get scanPoseFront => 'سامنے';

  @override
  String get scanPoseLeft => 'بایاں';

  @override
  String get scanPoseRight => 'دایاں';

  @override
  String scanStepSemantics(int number, int total, String pose) {
    return 'تصویر $number از $total: $pose';
  }

  @override
  String get scanStepDone => 'لی جا چکی';

  @override
  String get scanInstructionFront => 'سیدھا کیمرے کی طرف دیکھیں';

  @override
  String get scanInstructionLeft => 'اپنا بایاں گال دکھائیں';

  @override
  String get scanInstructionRight => 'اپنا دایاں گال دکھائیں';

  @override
  String get scanAdviceTooBright => 'نرم روشنی میں جائیں';

  @override
  String get scanAdviceTooDark => 'زیادہ روشنی والی جگہ تلاش کریں';

  @override
  String get scanChipLight => 'اچھی روشنی';

  @override
  String get scanChipCentred => 'درمیان میں';

  @override
  String get scanChipSteady => 'ہلیں نہیں';

  @override
  String get scanChipNotYet => 'ابھی نہیں';

  @override
  String scanStatusCountdown(int seconds) {
    return 'ہلیں نہیں — $seconds سیکنڈ میں تصویر';
  }

  @override
  String get scanStatusManual => 'یا ابھی لینے کے لیے بٹن دبائیں';

  @override
  String get scanGallery => 'گیلری سے منتخب کریں';

  @override
  String get scanShutter => 'تصویر لیں';

  @override
  String get scanFlip => 'کیمرہ بدلیں';

  @override
  String get scanCameraPreview => 'کیمرے کا منظر';

  @override
  String scanPhotoOf(String pose) {
    return '$pose کی تصویر';
  }

  @override
  String get scanReviewQuestion => 'کیا آپ کا چہرہ صاف اور روشن نظر آ رہا ہے؟';

  @override
  String get scanRetake => 'دوبارہ لیں';

  @override
  String get scanUsePhoto => 'یہ تصویر استعمال کریں';

  @override
  String get scanAnalyse => 'میری جلد کا تجزیہ کریں';

  @override
  String get scanSaving => 'آپ کی تصاویر محفوظ ہو رہی ہیں…';

  @override
  String get scanSaveFailed =>
      'ہم آپ کی تصاویر محفوظ نہیں کر سکے۔ دوبارہ کوشش کریں۔';

  @override
  String get scanPickFailed =>
      'ہم یہ تصویر نہیں کھول سکے۔ کوئی اور منتخب کریں۔';

  @override
  String get scanCaptureFailed => 'تصویر نہیں بن سکی۔ دوبارہ کوشش کریں۔';

  @override
  String get scanPrivacyNote =>
      'تصاویر آپ کے فون ہی میں رہتی ہیں اور کبھی اپ لوڈ نہیں ہوتیں۔';

  @override
  String get scanRationaleTitle => 'کیمرے کی اجازت دیں';

  @override
  String get scanRationaleBody =>
      'ثاف آپ کا کیمرہ صرف چہرے کے اسکین کی تین تصاویر کے لیے استعمال کرتا ہے: سامنے، بائیں اور دائیں۔';

  @override
  String get scanContinue => 'جاری رکھیں';

  @override
  String get scanNotNow => 'ابھی نہیں';

  @override
  String get scanDeniedTitle => 'کیمرے کی اجازت بند ہے';

  @override
  String get scanDeniedBody =>
      'آپ دوبارہ کوشش کر سکتے ہیں، یا اس کے بجائے گیلری سے تصاویر منتخب کریں۔';

  @override
  String get scanSettingsTitle => 'سیٹنگز میں کیمرہ آن کریں';

  @override
  String get scanSettingsBody =>
      'ثاف کے لیے کیمرے کی اجازت بند ہے۔ آپ اپنے فون کی سیٹنگز میں اجازت دے سکتے ہیں، یا گیلری سے تصاویر منتخب کریں۔';

  @override
  String get scanOpenSettings => 'سیٹنگز کھولیں';

  @override
  String get scanTryAgain => 'دوبارہ کوشش کریں';

  @override
  String get scanFailedTitle => 'کیمرہ شروع نہیں ہوا';

  @override
  String get scanFailedBody =>
      'کیمرہ استعمال کرنے والی دوسری ایپس بند کریں اور دوبارہ کوشش کریں، یا گیلری سے تصاویر منتخب کریں۔';

  @override
  String resultsOverline(String date) {
    return 'اسکین · $date';
  }

  @override
  String get resultsTitle => 'آج آپ کی جلد کی کیفیت';

  @override
  String get resultsShare => 'اپنا نتیجہ شیئر کریں';

  @override
  String get resultsScoreLabel => 'جلد کا اسکور';

  @override
  String resultsScoreSemantics(int score) {
    return 'جلد کا اسکور 100 میں سے $score';
  }

  @override
  String get resultsHeadlineGood => 'بنیاد اچھی ہے، دو چیزوں پر کام کرنا ہے';

  @override
  String get resultsHeadlineFair => 'اچھی شروعات ہے، دو چیزوں پر کام کرنا ہے';

  @override
  String get resultsHeadlineNeedsCare =>
      'آپ کی جلد کو کچھ توجہ چاہیے۔ دو چیزوں سے شروع کریں';

  @override
  String resultsFocus(String first, String second) {
    return '$first اور $second آپ کی بنیادی توجہ ہیں۔';
  }

  @override
  String get resultsConcerns => 'مسائل';

  @override
  String get resultsHowWeScore => 'ہم اسکور کیسے دیتے ہیں';

  @override
  String get metricDarkSpots => 'داغ دھبے';

  @override
  String get metricBreakouts => 'دانے';

  @override
  String get metricOiliness => 'چکناہٹ';

  @override
  String get metricHydration => 'نمی';

  @override
  String get ratingMild => 'ہلکا';

  @override
  String get ratingModerate => 'درمیانہ';

  @override
  String get ratingHigh => 'زیادہ';

  @override
  String get ratingLow => 'کم';

  @override
  String get ratingFair => 'ٹھیک ٹھاک';

  @override
  String get ratingGood => 'اچھی';

  @override
  String metricSemantics(String name, String rating) {
    return '$name: $rating';
  }

  @override
  String get resultsDisclaimer =>
      'یہ صرف ظاہری جانچ ہے، طبی تشخیص نہیں۔ جو بات آپ کو پریشان کرے اس کے لیے ماہرِ جلد سے ملیں۔';

  @override
  String get resultsSeeRoutine => 'میرا روٹین دیکھیں';

  @override
  String get resultsEmptyTitle => 'ابھی کوئی اسکین نہیں';

  @override
  String get resultsEmptyBody =>
      'آج آپ کی جلد کیسی ہے یہ دیکھنے کے لیے چہرے کی تین تصاویر لیں۔';

  @override
  String get resultsEmptyAction => 'اسکین شروع کریں';

  @override
  String get resultsErrorTitle => 'ہم آپ کا نتیجہ نہیں پڑھ سکے';

  @override
  String get resultsErrorAction => 'دوبارہ کوشش کریں';

  @override
  String resultsShareText(int score, String focus) {
    return 'میرا ثاف جلد کا اسکور: 100 میں سے $score۔ بنیادی توجہ: $focus۔ یہ صرف ظاہری جانچ ہے، طبی مشورہ نہیں۔';
  }

  @override
  String get howWeScoreTitle => 'ہم اسکور کیسے دیتے ہیں';

  @override
  String get howWeScoreIntro =>
      'آپ کا ثاف جلد کا اسکور 40 سے 100 کے درمیان ایک عدد ہے جو بتاتا ہے کہ آج آپ کی جلد کیسی دکھائی دیتی ہے۔ یہ روٹین چننے میں رہنمائی ہے، طبی پیمائش نہیں۔';

  @override
  String get howWeScoreLooksTitle => 'ہم کیا دیکھتے ہیں';

  @override
  String get howWeScoreSpots =>
      'داغ دھبے: ناہموار رنگت اور دھوپ یا دانوں کے نشان۔';

  @override
  String get howWeScoreBreakouts => 'دانے: پھنسیاں، بلیک ہیڈز اور ابھار۔';

  @override
  String get howWeScoreOil =>
      'چکناہٹ: چمک اور نظر آنے والے مسام، خاص طور پر ماتھے اور ناک پر۔';

  @override
  String get howWeScoreHydration =>
      'نمی: آپ کی جلد کتنی نرم اور ہموار دکھتی ہے۔ یہ واحد پیمانہ ہے جس میں زیادہ بہتر ہے۔';

  @override
  String get howWeScoreMathTitle => 'عدد کیسے بنتا ہے';

  @override
  String get howWeScoreMath =>
      'داغ دھبے، دانے اور چکناہٹ مل کر زیادہ سے زیادہ 40 پوائنٹ کم کر سکتے ہیں۔ نمی کی کمی مزید 20 تک کم کر سکتی ہے۔ جس جلد میں ان میں سے کچھ نہ ہو اس کا اسکور 100 ہے۔';

  @override
  String get howWeScorePhotosTitle => 'آپ کی تصاویر';

  @override
  String get howWeScorePhotos =>
      'تینوں تصاویر آپ کے فون ہی میں رہتی ہیں۔ اسکور بنانے کے لیے انہیں کبھی اپ لوڈ نہیں کیا جاتا۔';

  @override
  String get howWeScoreMedicalTitle => 'طبی مشورہ نہیں';

  @override
  String get howWeScoreMedical =>
      'ثاف جلد کی بیماریوں کی تشخیص نہیں کر سکتا۔ اگر کوئی نشان بدلے، خون آئے، خارش ہو یا آپ کو پریشان کرے تو براہِ کرم ماہرِ جلد سے ملیں۔';

  @override
  String get routineTitle => 'آپ کا روٹین';

  @override
  String routineFor(String concerns) {
    return '$concerns کے لیے';
  }

  @override
  String get routineForGeneral => 'جلد کی روزمرہ صحت کے لیے';

  @override
  String routineBudget(String amount) {
    return 'بجٹ $amount ماہانہ';
  }

  @override
  String get routineBudgetNoLimit => 'بجٹ کی کوئی حد نہیں';

  @override
  String routineSubtitle(String forText, String budgetText) {
    return '$forText · $budgetText';
  }

  @override
  String routineAnd(String first, String second) {
    return '$first اور $second';
  }

  @override
  String get concernDarkSpots => 'داغ دھبے';

  @override
  String get concernAcne => 'دانے';

  @override
  String get concernOiliness => 'چکناہٹ';

  @override
  String get concernDryness => 'خشکی';

  @override
  String get concernUnevenTone => 'ناہموار رنگت';

  @override
  String priceRs(String amount) {
    return '$amount روپے';
  }

  @override
  String get routineMorning => 'صبح';

  @override
  String get routineNight => 'رات';

  @override
  String get routineTabsLabel => 'دن کا وقت';

  @override
  String routineSummary(int count, int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مراحل',
    );
    return '$_temp0 · تقریباً $minutes منٹ';
  }

  @override
  String routineTotal(String price) {
    return 'کل $price';
  }

  @override
  String routineStepLine(int number, String category) {
    return 'مرحلہ $number · $category';
  }

  @override
  String get stepCleanser => 'کلینزر';

  @override
  String get stepTreatment => 'ٹریٹمنٹ';

  @override
  String get stepMoisturiser => 'موئسچرائزر';

  @override
  String get stepSunscreen => 'دھوپ سے بچاؤ';

  @override
  String get routineResultsTitle => 'نتائج 6 سے 8 ہفتوں میں';

  @override
  String routineResultsBody(String date) {
    return 'روزانہ استعمال کریں۔ آپ کی اگلی پروگریس تصویر $date کو ہے۔';
  }

  @override
  String get routineResultsBodyNoDate =>
      'روزانہ استعمال کریں اور مہینے میں ایک بار اپنی پیش رفت دیکھیں۔';

  @override
  String get routineStart => 'میرا روٹین شروع کریں';

  @override
  String get routineOverBudget => 'یہ آپ کے ماہانہ بجٹ سے کچھ زیادہ ہے۔';

  @override
  String get routinePriceNote =>
      'قیمتیں صرف رہنمائی کے لیے ہیں اور دکانوں میں مختلف ہو سکتی ہیں۔';

  @override
  String get routineReminders => 'یاد دہانیاں';

  @override
  String get routineEmptyTitle => 'ہم ابھی روٹین نہیں بنا سکے';

  @override
  String get routineEmptyBody =>
      'جلد کا کوئز مکمل کریں تاکہ ہم آپ کے لیے مصنوعات چن سکیں۔';

  @override
  String get routineEmptyAction => 'جلد کا کوئز لیں';

  @override
  String get routineErrorTitle => 'ہم آپ کا روٹین لوڈ نہیں کر سکے';

  @override
  String get routineErrorAction => 'دوبارہ کوشش کریں';

  @override
  String get navHome => 'ہوم';

  @override
  String get navScan => 'اسکین';

  @override
  String get navProgress => 'پیش رفت';

  @override
  String get navProfile => 'پروفائل';

  @override
  String homeGreeting(String name) {
    return 'سلام، $name';
  }

  @override
  String get homeGreetingNoName => 'سلام';

  @override
  String get homeProgressLabel => 'آج کی پیش رفت';

  @override
  String homeStepsDone(int done, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$total مراحل',
    );
    return '$_temp0 میں سے $done مکمل';
  }

  @override
  String homeProgressSemantics(int percent) {
    return 'آج کا روٹین $percent فیصد مکمل';
  }

  @override
  String get homeRoutineTitle => 'آج کا روٹین';

  @override
  String homeSwitchTime(String time) {
    return '$time کا روٹین دکھائیں';
  }

  @override
  String homeStepCaption(String category, String price) {
    return '$category · $price';
  }

  @override
  String homeStepDone(String name) {
    return '$name، مکمل';
  }

  @override
  String homeStepNotDone(String name) {
    return '$name، ابھی مکمل نہیں';
  }

  @override
  String homeDayComplete(String day) {
    return '$day، تمام مراحل مکمل';
  }

  @override
  String homeDayOpen(String day) {
    return '$day';
  }

  @override
  String homeToday(String day) {
    return '$day، آج';
  }

  @override
  String get homeWeekLabel => 'اس ہفتے';

  @override
  String get homeErrorTitle => 'ہم آج کا روٹین لوڈ نہیں کر سکے';

  @override
  String get homeErrorAction => 'دوبارہ کوشش کریں';
}
