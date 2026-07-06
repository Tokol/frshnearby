import 'package:flutter/material.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../marketing_tokens.dart';
import 'hover_lift.dart';
import 'language_flag_picker.dart';

/// Landing top bar: green wordmark, section links, flag picker, prototype CTA.
///
/// Uses a text wordmark instead of the logo asset — the logo (and its colors)
/// is being replaced, so the brand here leans on the green theme only.
class LandingTopBar extends StatelessWidget {
  const LandingTopBar({
    super.key,
    required this.onAbout,
    required this.onInterested,
    required this.onPrototype,
  });

  final VoidCallback onAbout;
  final VoidCallback onInterested;
  final VoidCallback onPrototype;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final showLinks = width >= 860;
    final compact = width < 560;

    return Row(
      children: [
        _Wordmark(compact: width < 460),
        const Spacer(),
        if (showLinks) ...[
          _NavLink(label: l10n.landingNavAbout, onTap: onAbout),
          _NavLink(label: l10n.landingNavInterested, onTap: onInterested),
          const SizedBox(width: 8),
        ],
        const LanguageFlagPicker(),
        SizedBox(width: compact ? 8 : 16),
        HoverLift(
          child: compact
              ? IconButton.filledTonal(
                  onPressed: onPrototype,
                  tooltip: l10n.landingNavPrototype,
                  style: IconButton.styleFrom(
                    backgroundColor: LandingColors.mist,
                    foregroundColor: LandingColors.green,
                  ),
                  icon: const Icon(Icons.play_arrow_rounded),
                )
              : FilledButton.tonalIcon(
                  onPressed: onPrototype,
                  style: FilledButton.styleFrom(
                    backgroundColor: LandingColors.mist,
                    foregroundColor: LandingColors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(fontWeight: FontWeight.w800),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  icon: const Icon(Icons.play_arrow_rounded, size: 20),
                  label: Text(l10n.landingNavPrototype),
                ),
        ),
      ],
    );
  }
}

class _Wordmark extends StatelessWidget {
  const _Wordmark({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: LandingColors.green,
            borderRadius: BorderRadius.circular(11),
          ),
          child: const Icon(Icons.eco_rounded, color: Colors.white, size: 22),
        ),
        const SizedBox(width: 10),
        Text.rich(
          TextSpan(
            children: [
              const TextSpan(
                text: 'FRSH',
                style: TextStyle(color: LandingColors.ink),
              ),
              if (!compact)
                const TextSpan(
                  text: ' NEARBY',
                  style: TextStyle(color: LandingColors.green),
                ),
            ],
          ),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }
}

class _NavLink extends StatelessWidget {
  const _NavLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: LandingColors.ink,
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      ),
      child: Text(label),
    );
  }
}
