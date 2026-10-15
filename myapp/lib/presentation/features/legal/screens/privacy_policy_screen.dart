import 'package:flutter/material.dart';
import 'package:saaf/core/l10n/app_localizations.dart';
import 'package:saaf/core/router/saaf_route.dart';
import 'package:saaf/presentation/features/legal/widgets/legal_page.dart';

/// Privacy Policy (placeholder text until the document is published).
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) => LegalPage(
    route: SaafRoute.privacyPolicy,
    title: AppLocalizations.of(context).privacyPolicyTitle,
  );
}
