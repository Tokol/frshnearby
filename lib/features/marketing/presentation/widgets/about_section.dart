import 'package:flutter/material.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../marketing_tokens.dart';
import 'hover_lift.dart';

/// "About us": mission text plus three value cards.
class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final cards = [
      _ValueCard(
        icon: Icons.location_on_rounded,
        title: l10n.landingValue1Title,
        text: l10n.landingValue1Body,
      ),
      _ValueCard(
        icon: Icons.agriculture_rounded,
        title: l10n.landingValue2Title,
        text: l10n.landingValue2Body,
      ),
      _ValueCard(
        icon: Icons.groups_rounded,
        title: l10n.landingValue3Title,
        text: l10n.landingValue3Body,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeading(title: l10n.landingAboutTitle),
        const SizedBox(height: 18),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Text(
            l10n.landingAboutBody,
            style: const TextStyle(
              color: LandingColors.muted,
              fontSize: 16,
              height: 1.65,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 28),
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 760) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final card in cards) ...[
                    card,
                    const SizedBox(height: 14),
                  ],
                ],
              );
            }
            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < cards.length; i++) ...[
                    if (i > 0) const SizedBox(width: 16),
                    Expanded(child: cards[i]),
                  ],
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 4,
          decoration: BoxDecoration(
            color: LandingColors.green,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            color: LandingColors.ink,
            fontSize: 32,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}

class _ValueCard extends StatelessWidget {
  const _ValueCard({
    required this.icon,
    required this.title,
    required this.text,
  });

  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return HoverLift(
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: LandingColors.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: LandingColors.mist,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: LandingColors.green, size: 24),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                color: LandingColors.ink,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              text,
              style: const TextStyle(
                color: LandingColors.muted,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
