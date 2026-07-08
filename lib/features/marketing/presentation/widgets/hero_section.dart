import 'package:flutter/material.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../marketing_tokens.dart';
import 'europe_map_card.dart';
import 'farm_scene.dart';
import 'landing_buttons.dart';

/// Hero: staggered headline over the animated farm scene, with the Europe map
/// card floating beside it on wide layouts (or stacked below on narrow ones).
class HeroSection extends StatefulWidget {
  const HeroSection({
    super.key,
    required this.onJoin,
    required this.onPrototype,
  });

  final VoidCallback onJoin;
  final VoidCallback onPrototype;

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entrance;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..forward();
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  Widget _staggered(int index, Widget child) {
    final animation = CurvedAnimation(
      parent: _entrance,
      curve: Interval(
        (index * 0.12).clamp(0.0, 0.6),
        (index * 0.12 + 0.5).clamp(0.0, 1.0),
        curve: Curves.easeOutCubic,
      ),
    );
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.14),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isWide = width >= 1000;
        final isNarrow = width < 720;

        final copy = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _staggered(
              0,
              Text(
                l10n.landingHeroTitle,
                style: TextStyle(
                  color: LandingColors.ink,
                  fontSize: isNarrow ? 40 : (isWide ? 64 : 52),
                  fontWeight: FontWeight.w900,
                  height: 1.0,
                  letterSpacing: -1,
                ),
              ),
            ),
            const SizedBox(height: 18),
            _staggered(
              1,
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Text(
                  l10n.landingHeroSubtitle,
                  style: const TextStyle(
                    color: LandingColors.muted,
                    fontSize: 17,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 26),
            _staggered(
              2,
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  LandingPrimaryButton(
                    label: l10n.landingHeroPrimaryCta,
                    icon: Icons.eco_rounded,
                    onPressed: widget.onJoin,
                  ),
                  LandingSecondaryButton(
                    label: l10n.landingHeroSecondaryCta,
                    icon: Icons.play_arrow_rounded,
                    onPressed: widget.onPrototype,
                  ),
                ],
              ),
            ),
          ],
        );

        final scene = ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: SizedBox(
            height: isWide ? 600 : (isNarrow ? 520 : 560),
            width: double.infinity,
            child: Stack(
              children: [
                const Positioned.fill(child: FarmScene()),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isNarrow ? 24 : 48,
                    vertical: isNarrow ? 32 : 48,
                  ),
                  child: isWide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(flex: 11, child: copy),
                            const SizedBox(width: 36),
                            Expanded(
                              flex: 8,
                              child: _staggered(
                                2,
                                const Align(
                                  alignment: Alignment.topCenter,
                                  child: EuropeMapCard(),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Align(
                          alignment: Alignment.centerLeft,
                          child: copy,
                        ),
                ),
              ],
            ),
          ),
        );

        if (isWide) return scene;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            scene,
            const SizedBox(height: 20),
            _staggered(3, const EuropeMapCard()),
          ],
        );
      },
    );
  }
}
