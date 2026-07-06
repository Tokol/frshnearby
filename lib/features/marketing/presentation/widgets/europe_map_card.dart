import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../marketing_tokens.dart';

/// Europe map with Finland highlighted and a pulsing marker over Vaasa.
///
/// The SVG viewBox is 1000x684 and Vaasa sits at (650, 235); the marker is
/// positioned with an [Alignment] inside a matching [AspectRatio], so the
/// mapping stays exact at every width.
class EuropeMapCard extends StatelessWidget {
  const EuropeMapCard({super.key, this.showCaption = true});

  final bool showCaption;

  static const _vaasa = Alignment(650 / 1000 * 2 - 1, 235 / 684 * 2 - 1);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Semantics(
      label: l10n.landingMapBadge,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.86),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: LandingColors.line),
          boxShadow: [
            BoxShadow(
              color: LandingColors.ink.withValues(alpha: 0.07),
              blurRadius: 28,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1000 / 684,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: SvgPicture.asset(
                      'assets/images/europe_clean.svg',
                      fit: BoxFit.fill,
                      placeholderBuilder: (context) => const SizedBox.expand(),
                      errorBuilder: (context, error, stackTrace) =>
                          SvgPicture.asset(
                            'assets/images/europe_frsh_map.svg',
                            fit: BoxFit.fill,
                          ),
                    ),
                  ),
                  const Align(
                    alignment: _vaasa,
                    child: PulsingMarker(size: 46),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.place_rounded,
                  size: 18,
                  color: LandingColors.green,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    l10n.landingMapBadge,
                    style: const TextStyle(
                      color: LandingColors.ink,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            if (showCaption) ...[
              const SizedBox(height: 2),
              Padding(
                padding: const EdgeInsets.only(left: 24),
                child: Text(
                  l10n.landingMapCaption,
                  style: const TextStyle(
                    color: LandingColors.muted,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Solid green dot with two expanding, fading rings.
class PulsingMarker extends StatefulWidget {
  const PulsingMarker({super.key, this.size = 46});

  final double size;

  @override
  State<PulsingMarker> createState() => _PulsingMarkerState();
}

class _PulsingMarkerState extends State<PulsingMarker>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        size: Size.square(widget.size),
        painter: _PulsePainter(animation: _controller),
      ),
    );
  }
}

class _PulsePainter extends CustomPainter {
  _PulsePainter({required this.animation}) : super(repaint: animation);

  final Animation<double> animation;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final maxRadius = size.shortestSide / 2;

    for (final phase in const [0.0, 0.5]) {
      final t = (animation.value + phase) % 1.0;
      canvas.drawCircle(
        center,
        maxRadius * (0.25 + 0.75 * t),
        Paint()
          ..color = LandingColors.green.withValues(
            alpha: (1 - t) * 0.35,
          )
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(1.5, maxRadius * 0.10 * (1 - t)),
      );
    }

    canvas.drawCircle(
      center,
      maxRadius * 0.22,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      center,
      maxRadius * 0.16,
      Paint()..color = LandingColors.green,
    );
  }

  @override
  bool shouldRepaint(covariant _PulsePainter oldDelegate) => false;
}
