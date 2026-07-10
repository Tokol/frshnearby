import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../marketing_tokens.dart';

const _contactEmail = 'info@freshnearby.com';

class LandingFooter extends StatelessWidget {
  const LandingFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(color: LandingColors.line, height: 1),
        const SizedBox(height: 26),
        Image.asset(
          'assets/images/logo/frshnearby.png',
          height: 34,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 6),
        Text(
          l10n.landingFooterTagline,
          style: const TextStyle(
            color: LandingColors.muted,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 14),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => launchUrl(Uri.parse('mailto:$_contactEmail')),
            child: const Text(
              _contactEmail,
              style: TextStyle(
                color: LandingColors.muted,
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
                decorationColor: LandingColors.line,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.landingFooterCopyright,
          style: TextStyle(
            color: LandingColors.muted.withValues(alpha: 0.7),
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
