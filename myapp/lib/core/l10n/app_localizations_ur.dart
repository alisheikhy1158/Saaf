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
      'چہرے کے سکین کی تصاویر آپ کے فون پر ہی رہتی ہیں، جب تک آپ بیک اپ آن نہ کریں۔ اے آئی کوچ کو صرف وہی تصاویر ملتی ہیں جو آپ خود بھیجیں۔';

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
  String get scanChipAngle => 'درست زاویہ';

  @override
  String get scanStatusLocked => 'جب سب کچھ ٹھیک ہو جائے گا تو بٹن کھل جائے گا';

  @override
  String get scanFaceNoFace => 'ہمیں آپ کا چہرہ نظر نہیں آ رہا';

  @override
  String get scanFaceSeveral => 'براہِ کرم صرف ایک چہرہ';

  @override
  String get scanFaceCloser => 'تھوڑا قریب آئیں';

  @override
  String get scanFaceBack => 'تھوڑا پیچھے ہٹیں';

  @override
  String get scanFaceCentre => 'اپنا چہرہ بیضوی شکل کے بیچ میں لائیں';

  @override
  String get scanFaceStraight => 'سیدھا کیمرے کی طرف دیکھیں';

  @override
  String get scanFaceTurnLeft => 'اپنا سر اپنے بائیں طرف موڑیں';

  @override
  String get scanFaceTurnRight => 'اپنا سر اپنے دائیں طرف موڑیں';

  @override
  String get scanFaceTurnLess => 'تھوڑا واپس موڑیں';

  @override
  String get scanCheckNoFace =>
      'اس تصویر میں ہمیں چہرہ نہیں ملا۔ براہِ کرم دوبارہ لیں۔';

  @override
  String get scanCheckSeveral =>
      'اس تصویر میں ایک سے زیادہ چہرے ہیں۔ براہِ کرم صرف اپنی تصویر دوبارہ لیں۔';

  @override
  String get scanCheckPose =>
      'اس تصویر کے لیے یہ زاویہ درست نہیں۔ براہِ کرم دوبارہ لیں۔';

  @override
  String get scanCheckSmall =>
      'اس تصویر میں آپ کا چہرہ بہت چھوٹا ہے۔ قریب آ کر دوبارہ لیں۔';

  @override
  String get scanCheckDark =>
      'یہ تصویر بہت تاریک ہے۔ زیادہ روشنی میں جا کر دوبارہ لیں۔';

  @override
  String get scanCheckBright =>
      'یہ تصویر بہت زیادہ روشن ہے۔ نرم روشنی میں جا کر دوبارہ لیں۔';

  @override
  String get scanUseAnyway => 'پھر بھی استعمال کریں';

  @override
  String get scanProductTitle => 'پروڈکٹ سکین کریں';

  @override
  String get scanProductHint =>
      'کیمرہ پیکٹ پر بنے بار کوڈ یا کیو آر کوڈ کی طرف کریں۔ اسے مستحکم رکھیں۔';

  @override
  String get scanProductRationaleBody =>
      'ثاف آپ کا کیمرہ صرف پروڈکٹ کا بار کوڈ پڑھنے کے لیے استعمال کرتا ہے۔ کچھ بھی محفوظ یا اپ لوڈ نہیں ہوتا۔';

  @override
  String get scanProductDeniedBody => 'آپ نیچے بار کوڈ کا نمبر لکھ سکتے ہیں۔';

  @override
  String get scanProductSettingsBody =>
      'ثاف کے لیے کیمرے کی اجازت بند ہے۔ اسے اپنے فون کی سیٹنگز میں دیں، یا نیچے بار کوڈ کا نمبر لکھیں۔';

  @override
  String get scanProductManualTitle => 'یا بار کوڈ کا نمبر لکھیں';

  @override
  String get scanProductManualLabel => 'بار کوڈ نمبر';

  @override
  String get scanProductManualHint => 'مثلاً 3337875743563';

  @override
  String get scanProductLookUp => 'تلاش کریں';

  @override
  String get scanProductInvalid => 'بار کوڈ کے نیچے چھپے 8 سے 14 ہندسے لکھیں۔';

  @override
  String get scanProductPretend => 'سکین کا ڈیمو';

  @override
  String get homeScanTooltip => 'پروڈکٹ سکین کریں';

  @override
  String get aiTitle => 'ثاف اے آئی سے پوچھیں';

  @override
  String get aiMenuTooltip => 'مزید';

  @override
  String get aiMenuNewChat => 'نئی گفتگو';

  @override
  String get aiMenuStop => 'اے آئی کے ساتھ شیئرنگ بند کریں';

  @override
  String get aiDisclaimer =>
      'اے آئی کے جوابات غلط ہو سکتے ہیں اور طبی مشورہ نہیں ہیں۔ تکلیف دہ، پھیلتی ہوئی یا فکر انگیز جلدی تبدیلیوں کے لیے ڈرماٹولوجسٹ سے ملیں۔';

  @override
  String get aiConsentTitle => 'اے آئی کوچ سے بات کرنے سے پہلے';

  @override
  String get aiConsentIntro =>
      'اپنے روٹین، اجزاء یا پروڈکٹس کے بارے میں پوچھیں، اپنی جلد کی تصویر لگائیں، یا اسے اپنی پیش رفت کی تصاویر دکھائیں۔ جواب ایک اے آئی ماڈل لکھتا ہے۔';

  @override
  String get aiConsentShareTitle => 'کیا بھیجا جاتا ہے';

  @override
  String get aiConsentShareBody =>
      'آپ کا پیغام، آپ کی لگائی ہوئی یا بھیجنے کے لیے چنی ہوئی کوئی تصویر (جلد کا اندازہ یا پیش رفت کا جائزہ، یا معلوم کرنے کے لیے پروڈکٹ کا لیبل)، اور چند باتیں: آپ کی جلد کی قسم، مسائل، حساسیت، بجٹ، آپ کے روٹین اور موجودہ پروڈکٹس کے نام اور، پروڈکٹس چننے کے لیے، آپ کے آخری اسکین کے اسکور۔ آپ کا نام، فون نمبر، سائیڈ کی تصاویر، یا حمل، دوائی اور الرجی کے جوابات ہرگز نہیں۔';

  @override
  String get aiConsentWhoTitle => 'کس کو ملتا ہے';

  @override
  String get aiConsentWhoBody =>
      'ہمارا سرور اسے Groq کو دیتا ہے، جو جواب لکھنے کے لیے ایک اوپن سورس اے آئی ماڈل چلاتی ہے۔ Groq اسے اپنی پرائیویسی شرائط کے تحت سنبھالتی ہے۔ ثاف آپ کی گفتگو اپنے سرور پر محفوظ نہیں کرتا۔';

  @override
  String get aiConsentChoice =>
      'آپ کسی بھی وقت پروفائل میں شیئرنگ بند کر سکتے ہیں۔';

  @override
  String get aiConsentAgree => 'میں متفق ہوں، گفتگو شروع کریں';

  @override
  String get aiPolicyLink => 'پرائیویسی پالیسی پڑھیں';

  @override
  String get aiEmptyTitle => 'اپنی اسکن کیئر کے بارے میں پوچھیں';

  @override
  String get aiEmptyBody =>
      'میں اجزاء سمجھا سکتی ہوں، آپ کا روٹین دیکھ سکتی ہوں اور آپ کی لگائی ہوئی تصاویر دیکھ سکتی ہوں۔';

  @override
  String get aiSuggestRoutine => 'کیا میرا روٹین میرے لیے ٹھیک ہے؟';

  @override
  String get aiSuggestDarkSpots => 'داغ دھبے محفوظ طریقے سے کیسے ہلکے کروں؟';

  @override
  String get aiSuggestClash =>
      'کیا میں وٹامن سی اور نیاسینامائڈ اکٹھے استعمال کر سکتی ہوں؟';

  @override
  String get aiSuggestSunscreen => 'سن اسکرین کیسے چنوں؟';

  @override
  String get aiInputHint => 'اپنی جلد یا روٹین کے بارے میں پوچھیں';

  @override
  String get aiSend => 'بھیجیں';

  @override
  String get aiAttach => 'تصویر لگائیں';

  @override
  String get aiTakePhoto => 'تصویر کھینچیں';

  @override
  String get aiChoosePhoto => 'گیلری سے چنیں';

  @override
  String get aiRemovePhoto => 'تصویر ہٹائیں';

  @override
  String aiPhotosAttached(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count تصاویر',
      one: '1 تصویر',
    );
    return '$_temp0';
  }

  @override
  String get aiPhotoFailed =>
      'ہم وہ تصویر حاصل نہیں کر سکے۔ براہِ کرم دوبارہ کوشش کریں۔';

  @override
  String get aiThinking => 'سوچ رہی ہوں…';

  @override
  String get aiAnswerLabel => 'اے آئی کا جواب';

  @override
  String get aiReport => 'اس جواب کی رپورٹ کریں';

  @override
  String get aiReportTitle => 'اس جواب میں کیا خرابی ہے؟';

  @override
  String get aiReportHarmful => 'نقصان دہ یا غیر محفوظ';

  @override
  String get aiReportWrong => 'غلط یا گمراہ کن';

  @override
  String get aiReportOffensive => 'نازیبا';

  @override
  String get aiReportOther => 'کچھ اور';

  @override
  String get aiReported => 'رپورٹ ہو گیا';

  @override
  String get aiReportThanks => 'شکریہ۔ ہم اس جواب کا جائزہ لیں گے۔';

  @override
  String get aiReportFailed =>
      'ہم آپ کی رپورٹ نہیں بھیج سکے۔ براہِ کرم دوبارہ کوشش کریں۔';

  @override
  String get aiErrorNetwork =>
      'کنکشن نہیں ہے۔ اپنا انٹرنیٹ دیکھیں اور دوبارہ کوشش کریں۔';

  @override
  String get aiErrorLimit =>
      'آپ آج کی حد تک پہنچ گئے ہیں۔ براہِ کرم کل دوبارہ کوشش کریں۔';

  @override
  String get aiErrorUnavailable =>
      'اے آئی کوچ ابھی دستیاب نہیں۔ براہِ کرم بعد میں کوشش کریں۔';

  @override
  String get aiErrorSignIn =>
      'اے آئی کوچ استعمال کرنے کے لیے براہِ کرم دوبارہ سائن ان کریں۔';

  @override
  String get aiErrorGeneric => 'کچھ غلط ہو گیا۔ براہِ کرم دوبارہ کوشش کریں۔';

  @override
  String get homeAiTooltip => 'اے آئی کوچ سے پوچھیں';

  @override
  String get profileRowAi => 'اے آئی کوچ کے ساتھ شیئرنگ';

  @override
  String get profileValueOn => 'آن';

  @override
  String get aiSheetTitle => 'اے آئی کوچ کے ساتھ شیئرنگ';

  @override
  String get aiSheetBody =>
      'آن ہونے پر آپ کے سوالات اور لگائی گئی تصاویر پرائیویسی پالیسی کے مطابق اے آئی کوچ کو بھیجی جاتی ہیں۔ بند کرنے سے گفتگو بھی صاف ہو جاتی ہے۔';

  @override
  String get aiSheetSwitch => 'اے آئی کوچ کے ساتھ شیئر کریں';

  @override
  String progressNextScan(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days دن',
      one: '1 دن',
    );
    return 'اگلا اسکین $_temp0 میں';
  }

  @override
  String get progressScanDue => 'آپ کا 2 ہفتے کا اسکین واجب ہے';

  @override
  String get progressScanNow => 'ابھی اسکین کریں';

  @override
  String get progressAiTitle => 'اے آئی پیش رفت کا جائزہ';

  @override
  String get progressAiBody =>
      'اے آئی کوچ کو شروع سے اب تک کی آپ کی تصاویر دیکھنے دیں اور بتانے دیں کہ کیا بدلا۔';

  @override
  String get progressAiButton => 'اے آئی سے میری پیش رفت کا جائزہ لیں';

  @override
  String get progressAiSetup => 'اے آئی کوچ سیٹ اپ کریں';

  @override
  String get progressAiConfirmTitle => 'کیا یہ تصاویر اے آئی کو بھیجیں؟';

  @override
  String get progressAiConfirmBody =>
      'صرف نیچے دی گئی سامنے کی تصاویر اے آئی کوچ (Groq، ثاف کے سرور کے ذریعے) کو بھیجی جاتی ہیں تاکہ وہ بتائے کیا بدلا۔ آپ کی سائیڈ کی تصاویر آپ کے فون پر رہتی ہیں۔';

  @override
  String get progressAiSend => 'بھیجیں';

  @override
  String get progressAiPhotoError =>
      'ہم آپ کی تصاویر تیار نہیں کر سکے۔ براہِ کرم دوبارہ کوشش کریں۔';

  @override
  String progressAiPhotoSemantics(String date) {
    return '$date کی تصویر';
  }

  @override
  String get aiReviewQuestion =>
      'براہِ کرم وقت کے ساتھ میرے چہرے کی تصاویر کا موازنہ کریں اور عمومی طور پر بتائیں کہ میری جلد میں کیا بدلا اور اب مجھے کیا کرنا چاہیے۔';

  @override
  String aiReviewFirst(int n, String date) {
    return 'تصویر $n میرا پہلا اسکین ہے، جو $date کو لیا گیا۔';
  }

  @override
  String aiReviewMiddle(int n, String date) {
    return 'تصویر $n $date کو لی گئی۔';
  }

  @override
  String aiReviewLatest(int n, String date) {
    return 'تصویر $n میرا تازہ ترین اسکین ہے، جو $date کو لیا گیا۔';
  }

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
      'تصاویر آپ کے فون ہی میں رہتی ہیں، جب تک آپ انہیں اے آئی کوچ کو بھیجنے کا انتخاب نہ کریں۔';

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
      'آپ کا ثاف جلد کا اسکور 40 سے 100 کے درمیان ایک عدد ہے جو بتاتا ہے کہ ثاف اے آئی کو آپ کی سامنے کی تصویر میں جلد کیسی دکھائی دیتی ہے۔ یہ روٹین چننے میں موٹی رہنمائی ہے، طبی پیمائش نہیں۔';

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
      'ثاف اے آئی آپ کی سامنے کی تصویر سے چاروں پیمانوں کا اندازہ لگاتا ہے۔ یہ صرف آپ کی اجازت کے بعد (Groq کو، ثاف کے سرور کے ذریعے) بھیجی جاتی ہے اور وہاں محفوظ نہیں رہتی؛ سائیڈ کی تصاویر آپ کے فون پر رہتی ہیں۔ ہر پیمانہ بتاتا ہے کہ ثاف اے آئی کو کتنا یقین ہے، اور تصویر کے تجزیے سے پہلے کوئی عدد نہیں دکھایا جاتا۔';

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
      'روزانہ استعمال کریں اور ہر دو ہفتے بعد اپنی پیش رفت دیکھیں۔';

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

  @override
  String get productScanTitle => 'اسکین کا نتیجہ';

  @override
  String get productShare => 'یہ پروڈکٹ شیئر کریں';

  @override
  String productShareText(String brand, String name, String price) {
    return '$brand $name: ثاف پر $price سے۔ صرف ظاہری رہنمائی۔';
  }

  @override
  String get productBarcodeMatched => 'بار کوڈ مل گیا';

  @override
  String get productFitGood => 'آپ کے لیے اچھا انتخاب';

  @override
  String get productFitCareful => 'احتیاط سے استعمال کریں';

  @override
  String get productFitAvoid => 'آپ کے لیے تجویز نہیں';

  @override
  String get productAllSkin => 'ہر قسم کی جلد';

  @override
  String get productAcneProne => 'دانوں والی جلد';

  @override
  String get clashNiacinamideVitaminCTitle => 'وٹامن سی کے ساتھ نہ ملائیں';

  @override
  String get clashMoveToNight =>
      'اگر آپ کے صبح کے روٹین میں وٹامن سی ہے تو اسے رات کو استعمال کریں۔';

  @override
  String get clashMoveToMorning =>
      'اگر آپ کے رات کے روٹین میں وٹامن سی ہے تو اسے صبح استعمال کریں۔';

  @override
  String get clashDifferentDays =>
      'اسے اپنے وٹامن سی سے الگ دنوں میں استعمال کریں۔';

  @override
  String get clashRetinolExfoliantsTitle =>
      'ایکسفولیئٹنگ ایسڈز کے ساتھ تہہ نہ لگائیں';

  @override
  String get clashRetinolExfoliants =>
      'جلن سے بچنے کے لیے انہیں الگ الگ راتوں میں استعمال کریں۔';

  @override
  String get clashBenzoylRetinolTitle =>
      'بینزائل پرآکسائیڈ کے ساتھ تہہ نہ لگائیں';

  @override
  String get clashBenzoylRetinol =>
      'جلن سے بچنے کے لیے انہیں دن کے الگ الگ اوقات میں استعمال کریں۔';

  @override
  String get productCarefulTitle => 'استعمال سے پہلے جانچ لیں';

  @override
  String get productCarefulBody =>
      'ہو سکتا ہے یہ آپ کی جلد کی قسم یا حساسیت کے مطابق نہ ہو۔ پہلے ذرا سی جگہ پر آزما لیں۔';

  @override
  String get productAvoidTitle => 'آپ کے لیے عموماً پرہیز';

  @override
  String get productAvoidBody =>
      'آپ کے جوابات کے مطابق ایسی مصنوعات سے پرہیز بہتر ہے۔ پہلے ڈاکٹر یا فارماسسٹ سے پوچھیں۔';

  @override
  String get productWhereToBuy => 'کہاں سے خریدیں';

  @override
  String get productCheckPrice => 'قیمت دیکھیں';

  @override
  String get productPricesVary => 'قیمتیں دکان کے لحاظ سے مختلف ہوتی ہیں';

  @override
  String get productPricesToday => 'آج کی قیمتیں';

  @override
  String productPricesAsOf(String date) {
    return '$date تک کی قیمتیں';
  }

  @override
  String get productBuy => 'خریدیں';

  @override
  String productBuySemantics(String store, String price) {
    return '$store سے $price میں خریدیں';
  }

  @override
  String get productAffiliate =>
      'کچھ خریداری کے لنکس سے ثاف کو معمولی کمیشن مل سکتا ہے۔ اس سے آپ کی قیمت نہیں بدلتی۔';

  @override
  String get productDisclaimer =>
      'اجزاء کے بارے میں مشورہ عمومی رہنمائی ہے، طبی مشورہ نہیں۔';

  @override
  String get productLinkFailed => 'ہم یہ لنک نہیں کھول سکے۔';

  @override
  String get productNoneTitle => 'ابھی کوئی پروڈکٹ اسکین نہیں ہوئی';

  @override
  String get productNoneBody =>
      'یہ دیکھنے کے لیے کہ کوئی پروڈکٹ آپ کی جلد کے لیے ٹھیک ہے، اس کا بار کوڈ اسکین کریں۔';

  @override
  String get productNoneAction => 'ہوم پر جائیں';

  @override
  String get productNotFoundTitle => 'ہمیں یہ پروڈکٹ نہیں ملی';

  @override
  String get productNotFoundBody =>
      'ثاف اے آئی اس کے بجائے ویب پر اسے تلاش کر سکتا ہے۔';

  @override
  String get productErrorTitle => 'ہم یہ پروڈکٹ لوڈ نہیں کر سکے';

  @override
  String get productErrorAction => 'دوبارہ کوشش کریں';

  @override
  String get checkInTitle => 'ہفتہ وار جائزہ';

  @override
  String get checkInInfo => 'جائزے کے بارے میں';

  @override
  String checkInWeek(int week) {
    return 'آپ کے روٹین کا ہفتہ $week';
  }

  @override
  String checkInGreeting(String name) {
    return 'سلام $name! اس ہفتے آپ کی جلد کیسی رہی؟';
  }

  @override
  String get checkInGreetingNoName => 'سلام! اس ہفتے آپ کی جلد کیسی رہی؟';

  @override
  String get checkInFeelLessOily => 'پہلے سے کم چکنی';

  @override
  String get checkInFeelSame => 'تقریباً ویسی ہی';

  @override
  String get checkInFeelDrier => 'زیادہ خشک یا کھنچی ہوئی';

  @override
  String get checkInFeelIrritated => 'زیادہ جلن';

  @override
  String get checkInQ2Nice => 'بہت اچھا۔ پچھلے ہفتے سے کوئی نئے دانے نکلے؟';

  @override
  String get checkInQ2Thanks => 'شکریہ۔ پچھلے ہفتے سے کوئی نئے دانے نکلے؟';

  @override
  String get checkInQ2Noted => 'سمجھ گیا۔ پچھلے ہفتے سے کوئی نئے دانے نکلے؟';

  @override
  String get checkInQ2Sorry =>
      'یہ سن کر افسوس ہوا۔ پچھلے ہفتے سے کوئی نئے دانے نکلے؟';

  @override
  String get checkInBreakNone => 'کوئی نیا نہیں';

  @override
  String get checkInBreakFew => '1 یا 2 چھوٹے';

  @override
  String get checkInBreakMore => 'پہلے سے کچھ زیادہ';

  @override
  String get checkInBreakSevere => 'بہت سے یا تکلیف دہ';

  @override
  String get checkInOnTrack => 'غالباً صحیح راستے پر';

  @override
  String get checkInKeepGoing => 'جاری رکھیں';

  @override
  String get checkInAdjust => 'تھوڑی تبدیلی کرتے ہیں';

  @override
  String get checkInSeePro => 'براہِ کرم کسی ماہر سے مشورہ کریں';

  @override
  String get checkInSentenceLessOily => 'چکناہٹ پر قابو بہتر ہو رہا ہے۔';

  @override
  String get checkInSentenceSame => 'آپ کی جلد تقریباً ویسی ہی ہے۔';

  @override
  String get checkInSentenceDrier =>
      'آپ کی جلد زیادہ خشک ہے، جو نئی مصنوعات کے ساتھ عام بات ہے۔';

  @override
  String get checkInSentenceIrritated => 'آپ کی جلد میں جلن ہے۔';

  @override
  String get checkInSentenceNone => 'کوئی نیا دانہ نہ نکلنا اچھی علامت ہے۔';

  @override
  String checkInSentenceFew(int week) {
    return 'ہفتہ $week میں چند چھوٹے دانے عام ہیں۔';
  }

  @override
  String get checkInSentenceMore =>
      'جلد کے ڈھلنے کے دوران پہلے سے زیادہ دانے نکل سکتے ہیں۔';

  @override
  String get checkInSentenceSevere =>
      'بہت سے یا تکلیف دہ دانوں کو ماہر کو دکھانا چاہیے۔';

  @override
  String get checkInAdviceOnTrack => 'جاری رکھیں اور دانوں کو نوچنے سے بچیں۔';

  @override
  String get checkInAdviceKeepGoing =>
      'نتائج عموماً 6 سے 8 ہفتے میں آتے ہیں، اس لیے جاری رکھیں۔';

  @override
  String get checkInAdviceAdjust =>
      'زیادہ نرم موئسچرائزر آزمائیں اور تیز مصنوعات کم استعمال کریں۔ دو ہفتے میں فرق نہ پڑے تو فارماسسٹ سے پوچھیں۔';

  @override
  String get checkInAdviceSeePro =>
      'کوئی بھی نئی مصنوعات روک دیں اور ماہرِ جلد یا فارماسسٹ سے پوچھیں، خاص طور پر اگر تکلیف ہو یا حالت بگڑتی جائے۔';

  @override
  String checkInNextPhoto(String date) {
    return 'اگلی تصویر کا جائزہ · $date';
  }

  @override
  String get checkInHint => 'اردو یا انگریزی میں جواب دیں…';

  @override
  String get checkInSend => 'بھیجیں';

  @override
  String get checkInNoteSaved =>
      'شکریہ، میں نے آپ کا نوٹ اگلے جائزے کے لیے محفوظ کر لیا ہے۔';

  @override
  String get checkInCoachInitial => 'ث';

  @override
  String checkInCoachSays(String text) {
    return 'ثاف کہتا ہے: $text';
  }

  @override
  String checkInYouSaid(String text) {
    return 'آپ نے کہا: $text';
  }

  @override
  String checkInResultSemantics(String title, String body) {
    return 'نتیجہ: $title۔ $body';
  }

  @override
  String get checkInInfoTitle => 'جائزے کے بارے میں';

  @override
  String get checkInInfoBody =>
      'آپ کا جائزہ سادہ اصولوں پر چلتا ہے، مصنوعی ذہانت پر نہیں۔ آپ کے جوابات آپ کے فون ہی میں رہتے ہیں۔ یہ جلد کی بیماریوں کی تشخیص نہیں کر سکتا: اگر کوئی بات پریشان کرے تو براہِ کرم ماہرِ جلد سے ملیں۔';

  @override
  String get checkInInfoClose => 'ٹھیک ہے';

  @override
  String get paywallProChip => 'ثاف پرو';

  @override
  String get paywallTitle => 'ہر دو ہفتے\nحقیقی تبدیلی دیکھیں';

  @override
  String get paywallBenefitPhotos => 'ہر 2 ہفتے بعد ہم آہنگ تصاویر کا موازنہ';

  @override
  String get paywallBenefitScans => 'جلد اور پروڈکٹ کے لامحدود اسکین';

  @override
  String get paywallBenefitAlerts => 'آپ کی مصنوعات کی قیمت گرنے پر الرٹ';

  @override
  String get paywallBenefitCoach => 'ہفتہ وار کوچ جائزے اور رپورٹس';

  @override
  String get planYearly => 'سالانہ';

  @override
  String get planMonthly => 'ماہانہ';

  @override
  String planSave(int percent) {
    return '$percent% بچت';
  }

  @override
  String planPerMonthBilledYearly(String price) {
    return '$price ماہانہ، سالانہ بل';
  }

  @override
  String get planCancelAnytime => 'کسی بھی وقت منسوخ کریں';

  @override
  String planSemantics(String title, String price, String caption) {
    return '$title۔ $price۔ $caption';
  }

  @override
  String paywallStartTrial(int days) {
    return '$days دن کا مفت ٹرائل شروع کریں';
  }

  @override
  String get paywallSubscribe => 'سبسکرائب کریں';

  @override
  String get paywallPeriodYear => 'سال';

  @override
  String get paywallPeriodMonth => 'مہینہ';

  @override
  String get paywallStoreApple => 'ایپ اسٹور';

  @override
  String get paywallStoreGoogle => 'گوگل پلے';

  @override
  String get paywallStoreOther => 'آپ کے اسٹور کی سیٹنگز';

  @override
  String paywallFinePrintTrial(
    int days,
    String price,
    String period,
    String store,
  ) {
    return '$days دن مفت، پھر $price فی $period۔ $store میں کسی بھی وقت منسوخ کریں۔';
  }

  @override
  String paywallFinePrint(String price, String period, String store) {
    return '$price فی $period۔ خودکار تجدید ہوتی ہے۔ $store میں کسی بھی وقت منسوخ کریں۔';
  }

  @override
  String get paywallRestore => 'خریداری بحال کریں';

  @override
  String get paywallRestored => 'ثاف پرو میں خوش آمدید۔';

  @override
  String get paywallNothingToRestore => 'پچھلی کوئی خریداری نہیں ملی۔';

  @override
  String get paywallRestoreFailed =>
      'ہم آپ کی خریداریاں چیک نہیں کر سکے۔ دوبارہ کوشش کریں۔';

  @override
  String get paywallPurchaseFailed =>
      'ہم خریداری مکمل نہیں کر سکے۔ آپ سے کوئی رقم نہیں لی گئی۔';

  @override
  String get paywallClose => 'بند کریں';

  @override
  String get paywallUnavailableTitle => 'سبسکرپشنز ابھی دستیاب نہیں';

  @override
  String get paywallUnavailableBody => 'براہِ کرم بعد میں دوبارہ کوشش کریں۔';

  @override
  String get paywallRetry => 'دوبارہ کوشش کریں';

  @override
  String get paywallAlreadyProTitle => 'آپ ثاف پرو پر ہیں';

  @override
  String paywallAlreadyProBody(String store) {
    return 'ثاف کا ساتھ دینے کا شکریہ۔ آپ اپنا پلان $store میں سنبھال سکتے ہیں۔';
  }

  @override
  String progressWeek(int week) {
    return 'ہفتہ $week';
  }

  @override
  String get progressTitle => 'آپ کی پیش رفت';

  @override
  String get progressShare => 'اپنی پیش رفت شیئر کریں';

  @override
  String progressShareText(int week, String first, String second) {
    return 'میری ثاف پیش رفت، ہفتہ $week: $first، $second۔ یہ صرف ظاہری رہنمائی ہے، طبی مشورہ نہیں۔';
  }

  @override
  String progressRange(String from, String to, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ہم آہنگ تصاویر',
    );
    return '$from → $to  ·  $_temp0';
  }

  @override
  String progressBefore(String date) {
    return 'پہلے · $date';
  }

  @override
  String progressAfter(String date) {
    return 'بعد · $date';
  }

  @override
  String get progressCompare => 'پہلے اور بعد کا موازنہ';

  @override
  String progressVs(String date) {
    return 'بمقابلہ $date';
  }

  @override
  String progressChangeSemantics(String name, String change, String since) {
    return '$name: $change $since';
  }

  @override
  String get progressCoach => 'کوچ کا خلاصہ';

  @override
  String progressSummaryImproving(String metric) {
    return 'اچھی خبر: $metric بہتر ہوا ہے۔ روزانہ دھوپ سے بچاؤ اس پیش رفت کو قائم رکھتا ہے، اس لیے جاری رکھیں۔';
  }

  @override
  String progressSummarySteady(String date) {
    return '$date کے بعد سے آپ کی جلد مستحکم لگتی ہے۔ نتائج عموماً 6 سے 8 ہفتے میں آتے ہیں، اس لیے جاری رکھیں۔';
  }

  @override
  String get progressSummarySlipping =>
      'کچھ حصے پچھلی بار سے تھوڑے خراب لگ رہے ہیں۔ اپنا روٹین اور دھوپ سے بچاؤ دیکھیں، اور فکر ہو تو ماہرِ جلد سے ملیں۔';

  @override
  String get progressLockedTitle => 'پیش رفت کی ٹریکنگ ثاف پرو کا حصہ ہے';

  @override
  String get progressLockedBody =>
      'ہر دو ہفتے بعد ہم آہنگ تصاویر کا موازنہ کریں اور دیکھیں کیا بدل رہا ہے۔';

  @override
  String get progressLockedAction => 'ثاف پرو دیکھیں';

  @override
  String get progressEmptyTitle => 'آپ کا پہلا موازنہ آنے والا ہے';

  @override
  String get progressEmptyBody =>
      'دو ہفتے بعد چہرے کا ایک اور اسکین لیں، ثاف دکھائے گا کیا بدلا۔';

  @override
  String get progressEmptyAction => 'اسکین لیں';

  @override
  String get progressErrorTitle => 'ہم آپ کی پیش رفت لوڈ نہیں کر سکے';

  @override
  String get progressErrorAction => 'دوبارہ کوشش کریں';

  @override
  String get progressCheckIn => 'اپنا ہفتہ وار جائزہ شروع کریں';

  @override
  String get profileTitle => 'پروفائل';

  @override
  String get profileNameFallback => 'ثاف ممبر';

  @override
  String profilePhoneFallback(String digits) {
    return 'فون نمبر جس کے آخر میں $digits';
  }

  @override
  String profileSkinType(String type) {
    return '$type جلد';
  }

  @override
  String get profilePlanFree => 'آپ مفت پلان پر ہیں';

  @override
  String get profilePlanFreeBody => 'ہر 2 ہفتے بعد تصاویر کی ٹریکنگ کھولیں';

  @override
  String get profileGoPro => 'پرو لیں';

  @override
  String get profilePlanPro => 'آپ ثاف پرو پر ہیں';

  @override
  String get profilePlanProBody => 'ثاف کا ساتھ دینے کا شکریہ';

  @override
  String get profileManage => 'سنبھالیں';

  @override
  String get profileSectionRoutine => 'روٹین';

  @override
  String get profileSectionPrivacy => 'رازداری';

  @override
  String get profileSectionApp => 'ایپ';

  @override
  String get profileRowSkin => 'جلد کا پروفائل';

  @override
  String get profileRowBudget => 'ماہانہ بجٹ';

  @override
  String get profileRowReminders => 'یاد دہانیاں';

  @override
  String get profileRowLanguage => 'زبان';

  @override
  String get profileRowAppearance => 'ظاہری شکل';

  @override
  String get profileRowBackup => 'تصاویر کا بیک اپ';

  @override
  String get profileRowDelete => 'میرا اکاؤنٹ حذف کریں';

  @override
  String get profileRowLogout => 'لاگ آؤٹ';

  @override
  String profileRowSemantics(String title, String value) {
    return '$title، $value';
  }

  @override
  String get profileValueNotSet => 'طے نہیں';

  @override
  String get profileValueOff => 'بند';

  @override
  String get profileValueNoLimit => 'کوئی حد نہیں';

  @override
  String get profileLangEnglish => 'English';

  @override
  String get profileLangUrdu => 'اردو';

  @override
  String get profileThemeSystem => 'سسٹم';

  @override
  String get profileThemeLight => 'روشن';

  @override
  String get profileThemeDark => 'گہرا';

  @override
  String get commonDone => 'مکمل';

  @override
  String get commonCancel => 'منسوخ کریں';

  @override
  String get quizTissueEntry => 'یقین نہیں؟ ٹشو ٹیسٹ آزمائیں';

  @override
  String get tissueTitle => 'ٹشو ٹیسٹ';

  @override
  String get tissueIntro =>
      'یہ دیکھنے کا آسان طریقہ کہ آپ کی جلد کتنی چکنی ہے۔ اس میں ایک منٹ لگتا ہے، اور کچھ دیر انتظار کرنا ہوتا ہے۔';

  @override
  String get tissueStep1 =>
      'ہلکے کلینزر سے چہرہ دھوئیں اور تھپتھپا کر خشک کریں۔ اس پر کچھ نہ لگائیں۔';

  @override
  String get tissueStep2 =>
      'تقریباً 30 منٹ سے ایک گھنٹہ انتظار کریں تاکہ آپ کی جلد اپنی قدرتی حالت میں آ جائے۔';

  @override
  String get tissueStep3 =>
      'صاف ٹشو یا بلاٹنگ پیپر کو ہلکے سے ماتھے، ناک اور گالوں پر ایک ایک کر کے دبائیں۔';

  @override
  String get tissueStep4 =>
      'ٹشو کو روشنی کے سامنے کریں اور چکنائی کے نشان دیکھیں۔';

  @override
  String get tissueDone => 'میں نے ٹیسٹ کر لیا';

  @override
  String get tissueQuestionTitle => 'آپ نے کیا دیکھا؟';

  @override
  String get tissueQuestionHint =>
      'جہاں ٹشو پر چکنائی کا نشان آیا وہ چنیں۔ اگر ٹشو صاف رہا تو کچھ نہ چنیں۔';

  @override
  String get tissueForehead => 'ماتھے سے چکنائی کا نشان';

  @override
  String get tissueNose => 'ناک سے چکنائی کا نشان';

  @override
  String get tissueCheeks => 'گالوں سے چکنائی کا نشان';

  @override
  String get tissueTight => 'میری جلد کھنچی ہوئی یا پپڑی دار محسوس ہوتی ہے';

  @override
  String get tissueOptionCaption => 'اگر یہ آپ پر لاگو ہو تو دبائیں';

  @override
  String tissueResultTitle(String type) {
    return 'آپ کی جلد $type لگتی ہے';
  }

  @override
  String get tissueResultOily =>
      'ماتھے اور گالوں پر چکنائی سے لگتا ہے کہ آپ کی جلد چکنی ہے۔';

  @override
  String get tissueResultCombination =>
      'صرف ماتھے اور ناک پر چکنائی اور صاف گالوں سے لگتا ہے کہ آپ کی جلد مخلوط ہے۔';

  @override
  String get tissueResultNormal =>
      'صاف ٹشو اور آرام دہ جلد سے لگتا ہے کہ آپ کی جلد نارمل ہے۔';

  @override
  String get tissueResultDry =>
      'صاف ٹشو کے ساتھ کھنچی ہوئی یا پپڑی دار جلد سے لگتا ہے کہ آپ کی جلد خشک ہے۔';

  @override
  String get tissueResultUnclear =>
      'گالوں پر چکنائی مگر ماتھے اور ناک پر نہ ہونا غیر معمولی ہے۔ کسی اور دن ٹیسٹ دوبارہ کریں۔';

  @override
  String get tissueUnclearTitle => 'ابھی ہم بتا نہیں سکتے';

  @override
  String get tissueUse => 'یہ نتیجہ استعمال کریں';

  @override
  String get tissueCaveat =>
      'یہ ایک رہنمائی ہے، تشخیص نہیں۔ موسم اور مہینے کے وقت کے ساتھ جلد بدلتی ہے، اس لیے یقین نہ ہو تو کسی اور دن دہرائیں۔';

  @override
  String get commonSave => 'محفوظ کریں';

  @override
  String get profileDetailsTitle => 'آپ کی تفصیلات';

  @override
  String get profileDetailsName => 'نام';

  @override
  String get profileDetailsNameHint => 'ہم آپ کو کس نام سے پکاریں؟';

  @override
  String get profileDetailsAge => 'عمر (اختیاری)';

  @override
  String get profileDetailsHelp => 'یہ صرف آپ کے فون پر محفوظ رہتا ہے۔';

  @override
  String get profileDetailsNameError =>
      'زیادہ سے زیادہ 40 حروف کا نام درج کریں۔';

  @override
  String get profileDetailsAgeError => '16 سے 99 کے درمیان عمر درج کریں۔';

  @override
  String get profileDetailsEditSemantics => 'اپنا نام اور عمر تبدیل کریں';

  @override
  String get profileSkinSheetTitle => 'جلد کا پروفائل';

  @override
  String get profileRowSkinType => 'جلد کی قسم';

  @override
  String get profileRowConcerns => 'جلد کے مسائل';

  @override
  String get profileRowSensitivity => 'حساسیت';

  @override
  String get profileRowSafety => 'صحت اور حفاظت';

  @override
  String get profileValueNone => 'کوئی نہیں';

  @override
  String get languageTitle => 'زبان';

  @override
  String get languageSemantics => 'زبان';

  @override
  String get appearanceTitle => 'ظاہری شکل';

  @override
  String get remindersTitle => 'یاد دہانیاں';

  @override
  String get remindersMorning => 'صبح کا روٹین';

  @override
  String get remindersNight => 'رات کا روٹین';

  @override
  String remindersChange(String name) {
    return '$name کا وقت بدلیں';
  }

  @override
  String get remindersNote => 'ثاف ہر روز ان اوقات پر آپ کو یاد دلاتا ہے۔';

  @override
  String get remindersRationaleTitle => 'نوٹیفکیشن کی اجازت دیں';

  @override
  String get remindersRationaleBody =>
      'ثاف آپ کے منتخب کردہ اوقات پر صبح کے روٹین کی ایک اور رات کے روٹین کی ایک نرم یاد دہانی بھیجتا ہے۔ اس کے علاوہ کچھ نہیں۔';

  @override
  String get remindersDeniedNote =>
      'نوٹیفکیشن بند ہیں، اس لیے یاد دہانی نہیں بھیجی جا سکتی۔ آپ کسی بھی وقت دوبارہ کوشش کر سکتے ہیں۔';

  @override
  String get remindersBlockedNote =>
      'ثاف کے لیے نوٹیفکیشن بلاک ہیں۔ یاد دہانی کے لیے انہیں اپنے فون کی سیٹنگز میں اجازت دیں۔';

  @override
  String get reminderNotificationMorningTitle => 'صبح کے روٹین کا وقت';

  @override
  String get reminderNotificationMorningBody =>
      'چہرہ دھوئیں، موئسچرائزر اور سن اسکرین لگائیں۔ بس چند منٹ لگتے ہیں۔';

  @override
  String get reminderNotificationNightTitle => 'رات کے روٹین کا وقت';

  @override
  String get reminderNotificationNightBody =>
      'چہرہ دھوئیں اور موئسچرائزر لگائیں، پھر آرام سے سو جائیں۔';

  @override
  String get backupTitle => 'تصاویر کا بیک اپ';

  @override
  String get backupBody =>
      'آپ کے چہرے کی تصاویر صرف اس فون پر رہتی ہیں۔ واحد استثنا وہ تصاویر ہیں جو آپ اے آئی جائزے کے لیے خود بھیجیں۔ اس ورژن میں کلاؤڈ بیک اپ دستیاب نہیں۔';

  @override
  String get deleteTitle => 'اکاؤنٹ حذف کریں؟';

  @override
  String get deleteBody =>
      'اس سے آپ کا اکاؤنٹ اور ثاف نے اس فون پر آپ کے بارے میں جو کچھ رکھا ہے وہ سب ہٹ جائے گا: آپ کے اسکین اور تصاویر، جوابات، روٹین اور جائزے۔ یہ واپس نہیں ہو سکتا۔';

  @override
  String get deleteConfirm => 'سب کچھ حذف کریں';

  @override
  String get deleteFailedRecent =>
      'آپ کی حفاظت کے لیے، براہِ کرم دوبارہ لاگ اِن کریں اور پھر اکاؤنٹ حذف کریں۔';

  @override
  String get deleteFailed =>
      'ہم آپ کا اکاؤنٹ حذف نہیں کر سکے۔ دوبارہ کوشش کریں۔';

  @override
  String get logoutTitle => 'لاگ آؤٹ کریں؟';

  @override
  String get logoutBody =>
      'آپ اپنے فون نمبر، گوگل یا ایپل سے دوبارہ لاگ اِن کر سکتے ہیں۔';

  @override
  String get logoutConfirm => 'لاگ آؤٹ';

  @override
  String get aiPicksOfferTitle => 'ثاف اے آئی کو اپنی پروڈکٹس چننے دیں';

  @override
  String get aiPicksOfferBody =>
      'یہ ویب پر، بشمول Reddit کے r/PakistaniSkincare، پاکستان میں ملنے والی ایسی پروڈکٹس تلاش کرتا ہے جو آپ کی جلد، اسکین اور بجٹ کے مطابق ہوں، اور آپ کی موجودہ پروڈکٹس کا جائزہ لیتا ہے۔';

  @override
  String get aiPicksTurnOn => 'ثاف اے آئی آن کریں';

  @override
  String get aiPicksLoading =>
      'ثاف اے آئی آپ کی جلد کے لیے ویب پر پروڈکٹس تلاش کر رہا ہے۔ اس میں ایک منٹ لگ سکتا ہے…';

  @override
  String get aiPicksFailed =>
      'ثاف اے آئی ابھی نہیں چن سکا، اس لیے یہ ہماری چنی ہوئی پروڈکٹس ہیں۔';

  @override
  String get aiPicksLabel => 'ثاف اے آئی کی چنی ہوئی';

  @override
  String get aiPicksWhy => 'یہ پروڈکٹس کیوں';

  @override
  String get aiPicksHide => 'وجوہات چھپائیں';

  @override
  String get aiPicksNote =>
      'اے آئی کا انتخاب غلط ہو سکتا ہے اور قیمتیں بدلتی رہتی ہیں۔ لیبل دیکھیں اور ہر نئی چیز کا پیچ ٹیسٹ کریں۔';

  @override
  String get productAiTitle => 'ثاف اے آئی سے معلوم کریں';

  @override
  String get productAiPhotoTitle => 'تصویر سے پروڈکٹ معلوم کریں';

  @override
  String get productAiPhotoBody =>
      'سامنے والے لیبل کی صاف تصویر لیں۔ صرف یہ تصویر، آپ کی جلد کی قسم اور مسائل کے ساتھ، ثاف اے آئی (Groq، ثاف کے سرور کے ذریعے) کو جاتی ہے۔ یہ لیبل پڑھ کر ویب پر تلاش کرتا ہے۔';

  @override
  String get productAiCodeTitle => 'یہ پروڈکٹ ثاف اے آئی سے معلوم کریں';

  @override
  String productAiBarcodeBody(String code) {
    return 'بار کوڈ $code۔ صرف یہ نمبر، آپ کی جلد کی قسم اور مسائل کے ساتھ، ثاف اے آئی (Groq، ثاف کے سرور کے ذریعے) کو جاتا ہے، جو ویب پر پروڈکٹ تلاش کرتا ہے۔';
  }

  @override
  String productAiQrBody(String text) {
    return 'کیو آر کوڈ میں لکھا ہے: $text\nصرف یہ تحریر، آپ کی جلد کی قسم اور مسائل کے ساتھ، ثاف اے آئی (Groq، ثاف کے سرور کے ذریعے) کو جاتی ہے، جو ویب پر پروڈکٹ تلاش کرتا ہے۔ ثاف لنک نہیں کھولتا۔';
  }

  @override
  String get productAiTakePhoto => 'تصویر لیں';

  @override
  String get productAiChoosePhoto => 'گیلری سے چنیں';

  @override
  String get productAiRetake => 'دوبارہ تصویر لیں';

  @override
  String get productAiPhotoLabel => 'بھیجنے کے لیے پروڈکٹ کی تصویر';

  @override
  String get productAiLookUp => 'معلوم کریں';

  @override
  String get productAiSearching => 'ثاف اے آئی ویب پر تلاش کر رہا ہے…';

  @override
  String get productAiNotFoundTitle =>
      'ثاف اے آئی نہیں بتا سکا کہ یہ کون سی پروڈکٹ ہے';

  @override
  String get productAiNotFoundPhoto =>
      'اچھی روشنی میں سامنے والے لیبل کی صاف اور قریب سے تصویر لیں۔';

  @override
  String get productAiNotFoundCode =>
      'اس کے بجائے سامنے والے لیبل کی تصویر آزمائیں۔';

  @override
  String get productAiNotWebChecked =>
      'ثاف اے آئی اس بار ویب پر تلاش نہیں کر سکا، اس لیے یہ اس کی اپنی معلومات ہیں۔ لیبل ضرور دیکھیں۔';

  @override
  String get productAiScanAnother => 'ایک اور پروڈکٹ اسکین کریں';

  @override
  String get productAiNeedsConsent =>
      'ثاف اے آئی بند ہے۔ پروڈکٹس معلوم کرنے اور اپنی جلد کے بارے میں پوچھنے کے لیے اسے آن کریں۔';

  @override
  String get scanProductCantScanTitle => 'اسکین نہیں ہو رہا؟';

  @override
  String get scanProductPhotoButton => 'پروڈکٹ کی تصویر لیں';

  @override
  String get productNotFoundAction => 'ثاف اے آئی سے معلوم کریں';

  @override
  String aiPicksPeopleSay(String text) {
    return 'لوگ کیا کہتے ہیں: $text';
  }

  @override
  String get aiPicksSources => 'ذرائع';

  @override
  String aiPicksSourceLink(String site) {
    return '$site کھولیں';
  }

  @override
  String get currentTitle => 'جو پروڈکٹس آپ ابھی استعمال کرتے ہیں';

  @override
  String get currentVerdictKeep => 'جاری رکھیں';

  @override
  String get currentVerdictReplace => 'بدل دیں';

  @override
  String get currentVerdictStop => 'بند کریں';

  @override
  String currentUseInstead(String name) {
    return 'اس کے بجائے: $name';
  }

  @override
  String get currentCautionPregnancy =>
      'آپ کے جوابات کے مطابق: حمل یا دودھ پلانے کے دوران اسے استعمال کرنے سے پہلے ڈاکٹر سے پوچھیں۔';

  @override
  String get currentCautionPrescription =>
      'آپ کے جوابات کے مطابق: پہلے اپنے ڈاکٹر سے پوچھیں، کیونکہ آپ جلد کی کوئی نسخے والی دوا استعمال کرتے ہیں۔';

  @override
  String get currentCautionSensitive =>
      'آپ کی جلد اکثر ردعمل دیتی ہے: پہلے پیچ ٹیسٹ کریں اور آہستہ آہستہ استعمال کریں۔';

  @override
  String get currentAdd => 'اپنی استعمال کی پروڈکٹس شامل کریں';

  @override
  String get currentEdit => 'اپنی پروڈکٹس بدلیں';

  @override
  String get myProductsTitle => 'جو پروڈکٹس آپ ابھی استعمال کرتے ہیں';

  @override
  String get myProductsBody =>
      'وہ پروڈکٹس شامل کریں جو آپ ابھی جلد کے لیے استعمال کرتے ہیں، جیسے فیس واش، کریم یا سن اسکرین۔ ثاف اے آئی بتائے گا کون سی جاری رکھیں اور کون سی بدلیں۔';

  @override
  String get myProductsFieldLabel => 'پروڈکٹ کا نام';

  @override
  String get myProductsFieldHint => 'مثلاً: Nivea Soft';

  @override
  String get myProductsAdd => 'شامل کریں';

  @override
  String get myProductsEmpty => 'ابھی کوئی پروڈکٹ شامل نہیں کی گئی۔';

  @override
  String get myProductsFull => 'آپ زیادہ سے زیادہ 10 پروڈکٹس شامل کر سکتے ہیں۔';

  @override
  String myProductsRemove(String name) {
    return '$name ہٹائیں';
  }

  @override
  String get myProductsPrivacy =>
      'یہ نام آپ کے فون پر رہتے ہیں۔ یہ ثاف اے آئی کو صرف تب جاتے ہیں جب آپ اسے آن کریں۔';

  @override
  String get profileRowProducts => 'آپ کی پروڈکٹس';

  @override
  String profileProductsValue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count پروڈکٹس',
      one: '1 پروڈکٹ',
      zero: 'کوئی نہیں',
    );
    return '$_temp0';
  }

  @override
  String get checkPricesOnline => 'آن لائن قیمتیں دیکھیں';

  @override
  String get myProductsStepLabel => 'یہ کیا ہے؟';

  @override
  String get myProductsStepOther => 'کچھ اور';

  @override
  String get myProductsChooseStep => 'منتخب کریں کہ یہ کس قسم کی پروڈکٹ ہے۔';

  @override
  String get routineYours => 'آپ کی';

  @override
  String get resultsAnalysePhoto => 'ثاف اے آئی سے میری تصویر کا تجزیہ کریں';

  @override
  String get resultsAnalyseConfirmTitle => 'اپنی سامنے کی تصویر بھیجیں؟';

  @override
  String get resultsAnalyseConfirmBody =>
      'صرف یہ سامنے کی تصویر ثاف اے آئی (Groq، ثاف کے سرور کے ذریعے) کو جاتی ہے تاکہ چاروں پیمانوں کا اندازہ لگایا جا سکے۔ یہ وہاں محفوظ نہیں رہتی۔ آپ کی سائیڈ کی تصاویر آپ کے فون پر رہتی ہیں۔';

  @override
  String get resultsAnalyseSend => 'بھیجیں';

  @override
  String get resultsAnalysing => 'ثاف اے آئی آپ کی تصویر دیکھ رہا ہے…';

  @override
  String resultsAnalyseUnusable(String problem) {
    return 'ثاف اے آئی اس تصویر کا اندازہ نہیں لگا سکا: $problem اچھی روشنی میں نیا اسکین کریں۔';
  }

  @override
  String get resultsAiTitle => 'ثاف اے آئی کا آپ کی تصویر سے اندازہ';

  @override
  String get resultsAiAccuracy =>
      'یہ ایک فون تصویر سے موٹا اندازہ ہے، پیمائش نہیں۔ روشنی، زاویہ، میک اپ اور کیمرہ سب اسے بدلتے ہیں، اس لیے کئی اسکینز میں رجحان دیکھیں۔';

  @override
  String get resultsAiSeen => 'ثاف اے آئی نے کیا دیکھا';

  @override
  String resultsHowSure(String level) {
    return 'یقین: $level';
  }

  @override
  String get confidenceLow => 'کم';

  @override
  String get confidenceMedium => 'درمیانہ';

  @override
  String get confidenceHigh => 'زیادہ';

  @override
  String get resultsFrontPhotoLabel => 'آپ کی سامنے کی تصویر';

  @override
  String get resultsNotAnalysedTitle => 'ابھی تجزیہ نہیں ہوا';

  @override
  String get resultsNotAnalysedBody =>
      'ثاف اے آئی آپ کی سامنے کی تصویر دیکھ کر داغ، دانے، چکنائی اور نمی کا اندازہ لگاتا ہے۔ تب تک یہاں کوئی عدد نہیں، کبھی کوئی اندازہ نہیں۔';

  @override
  String get progressNotAnalysedTitle => 'جلد کی پیمائش کا ابھی تجزیہ نہیں ہوا';

  @override
  String get progressNotAnalysedBody =>
      'ثاف اے آئی دونوں اسکینز کی سامنے کی تصاویر دیکھ کر بتاتا ہے کیا بدلا۔ دونوں کا تجزیہ ہونے تک یہاں کوئی عدد نہیں۔';

  @override
  String get progressAnalyse => 'ثاف اے آئی سے تجزیہ کریں';

  @override
  String get progressAnalyseConfirmTitle => 'اپنی سامنے کی تصاویر بھیجیں؟';

  @override
  String get progressAnalyseConfirmBody =>
      'صرف ان اسکینز کی سامنے کی تصاویر ثاف اے آئی (Groq، ثاف کے سرور کے ذریعے) کو جاتی ہیں تاکہ چاروں پیمانوں کا اندازہ لگایا جا سکے۔ یہ وہاں محفوظ نہیں رہتیں۔ آپ کی سائیڈ کی تصاویر آپ کے فون پر رہتی ہیں۔';

  @override
  String get progressAnalyseFailed =>
      'ثاف اے آئی ہر اسکین کا تجزیہ نہیں کر سکا۔ دوبارہ کوشش کریں، یا اچھی روشنی میں نیا اسکین کریں۔';

  @override
  String get autoAnalyseTitle => 'ہر اسکین کا خودبخود تجزیہ کریں؟';

  @override
  String get autoAnalyseBody =>
      'ثاف اے آئی ہر اسکین کی تصویر دیکھ کر آپ کو اصل نتائج دیتا ہے۔ صرف سامنے کی تصویر بھیجی جاتی ہے (Groq کو، ثاف کے سرور کے ذریعے) اور وہاں محفوظ نہیں رہتی۔ آپ کی سائیڈ کی تصاویر آپ کے فون پر رہتی ہیں۔ آپ اسے پروفائل میں بند کر سکتے ہیں۔';

  @override
  String get autoAnalyseEvery => 'ہاں، ہر اسکین';

  @override
  String get autoAnalyseOnce => 'صرف یہ اسکین';

  @override
  String get profileAutoAnalyse => 'ہر اسکین کا خودبخود تجزیہ';

  @override
  String get profileAutoAnalyseHint =>
      'ہر نئے اسکین کی سامنے کی تصویر آپ کے نتائج کے لیے ثاف اے آئی کو بھیجتا ہے۔';

  @override
  String get weatherOfferTitle => 'جلد کا موسم';

  @override
  String get weatherOfferBody =>
      'آپ کے شہر کی دھوپ، گرمی اور اسموگ کے مطابق روزانہ مشورے۔';

  @override
  String get weatherPickCity => 'اپنا شہر چنیں';

  @override
  String get weatherChangeCity => 'شہر بدلیں';

  @override
  String get weatherCitySheetTitle => 'آپ کا شہر';

  @override
  String get weatherCityNote =>
      'اس کے لیے صرف آپ کا چنا ہوا شہر استعمال ہوتا ہے، آپ کی اصل جگہ کبھی نہیں۔';

  @override
  String weatherTitle(String city) {
    return 'جلد کا موسم · $city';
  }

  @override
  String weatherUv(String uv) {
    return 'UV $uv';
  }

  @override
  String weatherTemp(String t) {
    return '$t°C';
  }

  @override
  String weatherHumidity(String h) {
    return '$h% نمی';
  }

  @override
  String weatherAqi(String aqi) {
    return 'AQI $aqi';
  }

  @override
  String get weatherUnavailable => 'آج کا موسم لوڈ نہیں ہو سکا۔';

  @override
  String get weatherCredit =>
      'موسم کا ڈیٹا Open-Meteo.com سے · ہوا کا معیار CAMS سے';

  @override
  String weatherTipUvExtreme(String uv) {
    return 'آج بہت تیز دھوپ ہے (UV $uv)۔ باہر ہر 2 گھنٹے بعد دوبارہ سن اسکرین لگائیں، اور 11 سے 3 بجے تک سائے میں رہیں۔';
  }

  @override
  String weatherTipUvHigh(String uv) {
    return 'آج تیز دھوپ ہے (UV $uv)۔ باہر جائیں تو دوپہر کے قریب دوبارہ سن اسکرین لگائیں۔';
  }

  @override
  String weatherTipUvModerate(String uv) {
    return 'آج درمیانی دھوپ ہے (UV $uv)۔ صبح کی سن اسکرین کافی ہے، جب تک آپ دیر تک باہر نہ رہیں۔';
  }

  @override
  String weatherTipUvLow(String uv) {
    return 'آج دھوپ کم ہے (UV $uv)، پھر بھی سن اسکرین لگائیں: یہ داغوں کو مزید گہرا ہونے سے روکتی ہے۔';
  }

  @override
  String weatherTipSmog(String aqi) {
    return 'اسموگ والی ہوا (AQI $aqi)۔ آج رات اچھی طرح چہرہ صاف کریں؛ اگر سن اسکرین یا میک اپ لگایا تھا تو دو بار۔';
  }

  @override
  String weatherTipHaze(String aqi) {
    return 'دھندلی ہوا (AQI $aqi)۔ آج رات نرمی سے چہرہ دھوئیں تاکہ گرد صاف ہو جائے۔';
  }

  @override
  String weatherTipHeat(String t) {
    return 'گرم دن ($t°C)۔ پسینہ سن اسکرین بہا دیتا ہے: پسینہ تھپتھپا کر صاف کریں، دوبارہ لگائیں اور ہلکی تہیں رکھیں۔';
  }

  @override
  String weatherTipHumid(String h) {
    return 'مرطوب ہوا ($h%)۔ آج ہلکا جیل موئسچرائزر کافی ہے۔';
  }

  @override
  String weatherTipDry(String h) {
    return 'خشک ہوا ($h%)۔ گاڑھا موئسچرائزر لگائیں اور رات کو ہرگز نہ چھوڑیں۔';
  }

  @override
  String get cityKarachi => 'کراچی';

  @override
  String get cityLahore => 'لاہور';

  @override
  String get cityIslamabad => 'اسلام آباد';

  @override
  String get cityRawalpindi => 'راولپنڈی';

  @override
  String get cityFaisalabad => 'فیصل آباد';

  @override
  String get cityMultan => 'ملتان';

  @override
  String get cityPeshawar => 'پشاور';

  @override
  String get cityQuetta => 'کوئٹہ';

  @override
  String get cityHyderabad => 'حیدرآباد';

  @override
  String get cityGujranwala => 'گوجرانوالہ';

  @override
  String get citySialkot => 'سیالکوٹ';

  @override
  String get cityBahawalpur => 'بہاولپور';

  @override
  String get citySukkur => 'سکھر';

  @override
  String get cityAbbottabad => 'ایبٹ آباد';

  @override
  String get creamTitle => 'کیا یہ کریم محفوظ ہے؟';

  @override
  String get creamIntro =>
      'رنگ گورا کرنے والی اور “فارمولا” کریموں میں اکثر پارہ، ہائیڈروکوئنون یا تیز اسٹیرائڈ پائے جاتے ہیں جو جلد کو بری طرح نقصان پہنچا سکتے ہیں۔ ثاف اے آئی لیبل پڑھتا ہے اور اسی پروڈکٹ کے بارے میں انتباہات تلاش کرتا ہے۔';

  @override
  String get creamNameLabel => 'کریم کا نام';

  @override
  String get creamNameHint => 'نام لکھیں، یا لیبل کی تصویر لیں';

  @override
  String get creamTakePhoto => 'لیبل کی تصویر لیں';

  @override
  String get creamWhatIsSent =>
      'صرف تصویر یا نام ثاف اے آئی (Groq، ثاف کے سرور کے ذریعے) کو جاتا ہے، آپ کے بارے میں کچھ نہیں۔';

  @override
  String get creamCheck => 'چیک کریں';

  @override
  String get creamChecking =>
      'ثاف اے آئی لیبل پڑھ رہا ہے اور انتباہات تلاش کر رہا ہے۔ اس میں ایک منٹ لگ سکتا ہے…';

  @override
  String get creamNotFoundBody =>
      'سامنے اور اجزا کی فہرست کی صاف تصویر لیں، یا پورا نام لکھیں۔';

  @override
  String get creamDangerTitle => 'خطرہ: اسے استعمال نہ کریں';

  @override
  String get creamDangerBody =>
      'اسے استعمال کرنا بند کریں۔ پارہ، ہائیڈروکوئنون اور تیز اسٹیرائڈ آپ کی جلد اور صحت کو نقصان پہنچا سکتے ہیں۔ اگر آپ نے ہفتوں استعمال کی ہے تو ڈاکٹر یا ڈرماٹولوجسٹ سے ملیں: اسٹیرائڈ کریم چھوڑنے پر جلد بگڑ سکتی ہے جس میں وہ مدد کر سکتے ہیں۔';

  @override
  String get creamCautionTitle => 'احتیاط کریں';

  @override
  String get creamCautionBody =>
      'اسے صرف احتیاط سے استعمال کریں، اور شک ہو تو ڈرماٹولوجسٹ سے پوچھیں۔ زخمی یا جلن والی جلد پر نہ لگائیں۔';

  @override
  String get creamNoKnownTitle => 'کوئی معلوم مسئلہ نہیں ملا';

  @override
  String get creamNoKnownBody =>
      'ہمیں اس پروڈکٹ کے بارے میں کوئی انتباہ نہیں ملا۔ پھر بھی یہ ایسے مسائل پیدا کر سکتی ہے جو کسی نے رپورٹ نہیں کیے، اس لیے پہلے پیچ ٹیسٹ کریں۔';

  @override
  String get creamOnLabel => 'لیبل پر';

  @override
  String get creamFound => 'ثاف اے آئی کو کیا ملا';

  @override
  String get creamNoIngredients =>
      'پیکٹ پر اجزا کی فہرست نہیں چھپی، اس لیے کوئی نہیں بتا سکتا کہ اس میں کیا ہے۔';

  @override
  String creamFlagMercury(String ingredient) {
    return 'پارہ ($ingredient): جلد، گردوں اور اعصاب کو نقصان پہنچاتا ہے۔';
  }

  @override
  String creamFlagHydroquinone(String ingredient) {
    return 'ہائیڈروکوئنون ($ingredient): رنگ اڑانے والا جز جو سیاہ دھبے بنا سکتا ہے؛ کئی ممالک میں صرف نسخے پر۔';
  }

  @override
  String creamFlagStrongSteroid(String ingredient) {
    return 'تیز اسٹیرائڈ ($ingredient): جلد کو پتلا کرتا ہے، دانے اور دوبارہ سرخی پیدا کرتا ہے۔';
  }

  @override
  String creamFlagSteroid(String ingredient) {
    return 'اسٹیرائڈ ($ingredient): ڈاکٹر کے بغیر روزانہ چہرے پر استعمال کے لیے نہیں۔';
  }

  @override
  String creamFlagRetinoid(String ingredient) {
    return 'نسخے والا ریٹینائڈ ($ingredient): صرف ڈاکٹر کے کہنے پر، حمل میں کبھی نہیں۔';
  }

  @override
  String get creamDisclaimer =>
      'ثاف صرف وہی چیک کر سکتا ہے جو چھپا ہے اور جو رپورٹ ہوا ہے۔ یہ لیب ٹیسٹ یا طبی مشورہ نہیں۔';

  @override
  String get creamCheckAnother => 'دوسری کریم چیک کریں';

  @override
  String get creamHomeTitle => 'کیا آپ کی کریم محفوظ ہے؟';

  @override
  String get creamHomeBody =>
      'رنگ گورا کرنے والی اور “فارمولا” کریموں میں پارہ اور اسٹیرائڈ چیک کریں۔';

  @override
  String get creamHomeAction => 'کریم چیک کریں';

  @override
  String get progressShareAnimation => 'پہلے اور بعد شیئر کریں';

  @override
  String progressShareAnimationText(int week) {
    return 'ثاف کے ساتھ میری جلد کی پیش رفت، ہفتہ $week';
  }

  @override
  String get progressShareAnimationFailed =>
      'اینیمیشن نہیں بن سکی۔ دوبارہ کوشش کریں۔';

  @override
  String get scanGhostHide => 'پچھلا اسکین چھپائیں';

  @override
  String get scanGhostShow => 'پچھلا اسکین دکھائیں';

  @override
  String get productAiDupeTitle => 'سستا متبادل تلاش کریں';

  @override
  String productAiDupeBody(String name) {
    return 'ثاف اے آئی پاکستان میں ملنے والی ایسی پروڈکٹس تلاش کرتا ہے جن کے اہم اجزا $name جیسے ہوں، اور ریویوز دیکھتا ہے۔ صرف پروڈکٹ کا نام اور آپ کی جلد کی قسم اور مسائل بھیجے جاتے ہیں (Groq کو، ثاف کے سرور کے ذریعے)۔';
  }

  @override
  String shelfUseBy(String date) {
    return '$date تک استعمال کریں';
  }

  @override
  String shelfRunsOut(String date) {
    return 'تقریباً $date تک ختم';
  }

  @override
  String get shelfOpenedQuestion => 'آپ نے اسے کب کھولا؟';

  @override
  String get shelfNotSet => 'ابھی نہیں بتایا';

  @override
  String shelfOpenedOn(String date) {
    return '$date کو کھولا';
  }

  @override
  String get shelfOpenedToday => 'آج کھولا';

  @override
  String get shelfChooseDate => 'تاریخ چنیں';

  @override
  String get shelfKeepsQuestion => 'کھلنے کے بعد کتنی دیر چلتی ہے؟';

  @override
  String get shelfKeepsHint => 'پیکٹ پر کھلے ڈبے کا نشان دیکھیں، جیسے “12M”۔';

  @override
  String shelfMonths(int months) {
    return '$months مہینے';
  }

  @override
  String get shelfLastsQuestion => 'ایک پیک تقریباً کتنی دیر چلتا ہے؟';

  @override
  String shelfWeeks(int weeks) {
    return '$weeks ہفتے';
  }

  @override
  String get shelfSave => 'محفوظ کریں';

  @override
  String get shelfFindCheaper => 'سستا متبادل تلاش کریں';

  @override
  String get shelfTitle => 'آپ کا شیلف';

  @override
  String get shelfOpen => 'اپنی پروڈکٹس دیکھیں';

  @override
  String shelfAlertExpired(String name) {
    return '$name کی استعمال کی مدت ختم ہو گئی: اسے بدلنے کا وقت ہے۔';
  }

  @override
  String shelfAlertExpiresSoon(String name, String date) {
    return '$name کو $date تک استعمال کر لیں۔';
  }

  @override
  String shelfAlertFinished(String name) {
    return '$name شاید ختم ہو گئی ہے: نئی لینے کا وقت؟';
  }

  @override
  String shelfAlertRunsOut(String name, String date) {
    return '$name تقریباً $date تک ختم ہو جائے گی۔';
  }

  @override
  String get ramadanAfterSehri => 'سحری کے بعد';

  @override
  String get ramadanAfterIftar => 'افطار کے بعد';

  @override
  String get ramadanTitle => 'رمضان میں جلد کی دیکھ بھال';

  @override
  String get ramadanTipWater =>
      'افطار اور سحری کے درمیان پانی پیئیں: پیاس سب سے پہلے جلد پر دکھتی ہے، بے رونقی اور کھنچاؤ کی صورت میں۔';

  @override
  String get ramadanTipSimple =>
      'روٹین سادہ رکھیں اور روزے میں تیز اجزا شروع نہ کریں۔';

  @override
  String get ramadanTipSunscreen =>
      'سحری کے بعد بھی سن اسکرین ضروری ہے، چاہے آپ گھر پر رہیں۔';

  @override
  String get ramadanSheetBody =>
      'آپ کا روٹین سحری کے بعد اور افطار کے بعد دکھایا جاتا ہے، اور ہوم پر روزے کے مطابق مشورے۔';

  @override
  String introTitle(String name) {
    return '$name آہستہ شروع';
  }

  @override
  String get introPatchTest =>
      'پیچ ٹیسٹ: 2 دن تک صبح شام تھوڑا سا کان کے پیچھے یا جبڑے پر لگائیں۔ ابھی چہرے پر نہیں۔';

  @override
  String get introTwiceAWeek =>
      'اسے ہفتے میں 2 راتیں استعمال کریں (مثلاً پیر اور جمعرات)، چہرہ دھونے کے بعد۔';

  @override
  String get introEveryOtherNight => 'اسے ایک رات چھوڑ کر استعمال کریں۔';

  @override
  String get introPaused =>
      '2 دن کا وقفہ کریں، پھر آہستہ آہستہ دوبارہ شروع کریں۔';

  @override
  String introStopped(String name) {
    return '$name کا استعمال بند کریں۔ ٹھنڈے پانی سے دھوئیں اور صرف نرم کلینزر اور موئسچرائزر لگائیں۔ اگر سوجن، چھالے ہوں یا یہ پھیلے تو ڈاکٹر سے ملیں۔';
  }

  @override
  String introDone(String name) {
    return '$name اب آپ کے روٹین کا حصہ ہے۔ لیبل کے مطابق استعمال کریں۔';
  }

  @override
  String get introAsk => 'آج کوئی ردعمل؟';

  @override
  String get introNone => 'نہیں';

  @override
  String get introMild => 'ہلکا';

  @override
  String get introStrong => 'شدید';

  @override
  String get introStart => 'اسے آہستہ شروع کریں';

  @override
  String introStarted(String name) {
    return '$name آہستہ شروع ہو گئی۔ آج کا قدم ہوم پر ہے۔';
  }

  @override
  String introTooClose(String name) {
    return '$name میں 4 ہفتے سے کم رہ گئے ہیں: ابھی نیا تیز جز شروع کرنے سے اس دن ردعمل ہو سکتا ہے۔';
  }

  @override
  String eventCountdown(String name, int days) {
    return '$name میں $days دن';
  }

  @override
  String eventToday(String name) {
    return '$name آج ہے!';
  }

  @override
  String get eventBuildRoutine =>
      'کافی وقت ہے: ابھی اپنا روٹین بنائیں، اور ہر نیا جز ایک ایک کر کے شامل کریں۔';

  @override
  String get eventLastNewProduct =>
      'اگر ایک اور نئی پروڈکٹ چاہیے تو ابھی شروع کریں۔ باقی سب ویسا ہی رکھیں۔';

  @override
  String get eventNoNewActives =>
      'اب کوئی نیا تیز جز نہیں: روٹین مستحکم رکھیں اور روزانہ سن اسکرین لگائیں۔';

  @override
  String get eventNothingNew =>
      'اب کچھ نیا نہیں: نئی پروڈکٹس، فیشل، پیل یا دانوں کے قریب تھریڈنگ نہیں۔';

  @override
  String get eventGentleWeek =>
      'نرم ہفتہ: پانی پیئیں، اچھی نیند لیں، نرمی سے چہرہ دھوئیں اور سن اسکرین لگائیں۔ کوئی تجربہ نہیں۔';

  @override
  String get eventTodayTip =>
      'نرمی سے چہرہ دھوئیں، موئسچرائزر اور سن اسکرین لگائیں، اور اپنا دن منائیں!';

  @override
  String get eventSheetBody =>
      'شادی، مہندی یا کوئی اور بڑا دن: ثاف اس سے پہلے ہفتہ وار آپ کی جلد کی دیکھ بھال کا منصوبہ بناتا ہے۔';

  @override
  String get eventNameLabel => 'کیا ہے؟';

  @override
  String get eventNameHint => 'مثلاً: میری شادی';

  @override
  String eventDateIs(String date) {
    return 'تاریخ: $date';
  }

  @override
  String get eventRemove => 'تقریب ہٹائیں';

  @override
  String get profileSectionLife => 'زندگی کے مواقع';

  @override
  String get profileRowRamadan => 'رمضان موڈ';

  @override
  String get profileRowEvent => 'کسی تقریب کی تیاری';
}
