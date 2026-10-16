import 'package:flutter/material.dart';
import 'package:saaf/core/config/legal_config.dart';
import 'package:saaf/core/l10n/app_localizations.dart';
import 'package:saaf/core/legal/legal_documents.dart';
import 'package:saaf/core/router/saaf_route.dart';
import 'package:saaf/presentation/features/legal/widgets/legal_page.dart';

/// Terms of Use (draft until LegalConfig.isReviewed).
class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) => LegalPage(
    route: SaafRoute.terms,
    title: AppLocalizations.of(context).termsTitle,
    document: LegalDocuments.terms(LegalConfig.current),
  );
}
