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
  String get legalPlaceholderBody =>
      'مکمل متن صاف کے جاری ہونے سے پہلے یہاں شائع کیا جائے گا۔';

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
}
