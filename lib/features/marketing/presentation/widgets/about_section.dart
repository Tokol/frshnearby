import 'package:flutter/material.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../marketing_tokens.dart';
import 'europe_map_card.dart';

/// "About us": mission text beside the Europe map card.
class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;
        final story = _AboutStory(
          title: l10n.landingAboutTitle,
          body: l10n.landingAboutBody,
        );
        const map = _AboutMap();

        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(flex: 11, child: story),
              const SizedBox(width: 42),
              Expanded(flex: 8, child: map),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            story,
            const SizedBox(height: 22),
            map,
          ],
        );
      },
    );
  }
}

class _AboutStory extends StatelessWidget {
  const _AboutStory({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeading(title: title),
        const SizedBox(height: 18),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Text(
            body,
            style: const TextStyle(
              color: LandingColors.muted,
              fontSize: 16,
              height: 1.65,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _AboutMap extends StatelessWidget {
  const _AboutMap();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: const EuropeMapCard(),
      ),
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

