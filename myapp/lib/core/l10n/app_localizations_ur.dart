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
  String get notFoundTitle => 'صفحہ نہیں ملا';

  @override
  String get notFoundBody => 'ہمیں یہ صفحہ نہیں مل سکا۔';

  @override
  String get goToStart => 'شروع پر جائیں';

  @override
  String get fieldValid => 'درست';
}
