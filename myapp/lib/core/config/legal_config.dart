/// Facts the Terms and Privacy Policy need that only the owner knows. Values come
/// from `--dart-define` (set in Codemagic) so nothing personal is committed.
///
///   --dart-define=SUPPORT_EMAIL=help@yourdomain
///   --dart-define=DELETION_URL=https://yourdomain/delete-account
///   --dart-define=LEGAL_REVIEWED=true     (only after a lawyer has reviewed)
///
/// Until [isReviewed] is true the in-app pages show a "draft" banner.
class LegalConfig {
  const LegalConfig({
    required this.operatorName,
    this.contactEmail = '',
    this.deletionUrl = '',
    this.isReviewed = false,
  });

  /// The shipped configuration.
  static const LegalConfig current = LegalConfig(
    operatorName: 'Saaf',
    contactEmail: String.fromEnvironment('SUPPORT_EMAIL'),
    // Our server's public page (backend/ai-proxy/src/web_pages.js) unless
    // Codemagic sets another (an empty DELETION_URL counts as not set).
    deletionUrl: _deletionUrl.length == 0 ? _ourDeletionPage : _deletionUrl,
    isReviewed: bool.fromEnvironment('LEGAL_REVIEWED'),
  );

  static const String _deletionUrl = String.fromEnvironment('DELETION_URL');
  static const String _ourDeletionPage =
      'https://saaf-ai.saafai.workers.dev/delete-account';

  /// Who the documents say "we" are.
  final String operatorName;

  /// Empty until the owner has a support address.
  final String contactEmail;

  /// Public web page where users can ask for their account to be deleted
  /// (required by Google Play). Empty until it exists.
  final String deletionUrl;

  /// True once the documents have been reviewed by a lawyer.
  final bool isReviewed;

  bool get hasContactEmail => contactEmail.isNotEmpty;
  bool get hasDeletionUrl => deletionUrl.isNotEmpty;
}
