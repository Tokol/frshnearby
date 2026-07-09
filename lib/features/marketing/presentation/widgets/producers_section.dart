import 'package:flutter/material.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../marketing_tokens.dart';
import 'hover_lift.dart';

/// "For producers": four feature cards for food producers.
class ProducersSection extends StatelessWidget {
  const ProducersSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final cards = [
      _FeatureCard(
        icon: Icons.campaign_rounded,
        title: l10n.landingProducer1Title,
        text: l10n.landingProducer1Body,
      ),
      _FeatureCard(
        icon: Icons.receipt_long_rounded,
        title: l10n.landingProducer2Title,
        text: l10n.landingProducer2Body,
      ),
      _FeatureCard(
        icon: Icons.map_rounded,
        title: l10n.landingProducer3Title,
        text: l10n.landingProducer3Body,
      ),
      _FeatureCard(
        icon: Icons.summarize_rounded,
        title: l10n.landingProducer4Title,
        text: l10n.landingProducer4Body,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeading(title: l10n.landingProducersTitle),
        const SizedBox(height: 24),
        _FeatureCards(cards: cards),
      ],
    );
  }
}

class _FeatureCards extends StatelessWidget {
  const _FeatureCards({required this.cards});

  final List<Widget> cards;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 760) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final card in cards) ...[card, const SizedBox(height: 14)],
            ],
          );
        }
        // Two rows of two cards each.
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var row = 0; row < cards.length; row += 2) ...[
              if (row > 0) const SizedBox(height: 16),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: cards[row]),
                    const SizedBox(width: 16),
                    Expanded(child: cards[row + 1]),
                  ],
                ),
              ),
            ],
          ],
        );
      },
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
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: LandingColors.ink,
              fontSize: 32,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
        ),
      ],
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
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
