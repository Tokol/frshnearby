import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../marketing_tokens.dart';

/// Animated illustrated farm backdrop: gradient sky, breathing sun with halo
/// rings, gliding birds, drifting clouds, rolling hills with furrow lines, a
/// slowly turning windmill, a barn silhouette, and golden wheat swaying along
/// the front hill.
///
/// One repeating [AnimationController] drives the whole scene; the painter
/// listens to it via `repaint`, so there are no rebuilds per frame.
class FarmScene extends StatefulWidget {
  const FarmScene({super.key});

  @override
  State<FarmScene> createState() => _FarmSceneState();
}

class _FarmSceneState extends State<FarmScene>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Stalk> _stalks;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    );
    final random = math.Random(7);
    _stalks = List.generate(20, (i) {
      return _Stalk(
        x: (i + 0.2 + random.nextDouble() * 0.6) / 20,
        phase: random.nextDouble() * math.pi * 2,
        height: 0.7 + random.nextDouble() * 0.5,
      );
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_started) {
      _started = true;
      if (!MediaQuery.disableAnimationsOf(context)) {
        _controller.repeat();
      }
    }
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
        painter: _FarmPainter(animation: _controller, stalks: _stalks),
        size: Size.infinite,
      ),
    );
  }
}

class _Stalk {
  const _Stalk({required this.x, required this.phase, required this.height});

  final double x;
  final double phase;
  final double height;
}

class _Cloud {
  const _Cloud({
    required this.y,
    required this.start,
    required this.speed,
    required this.scale,
    required this.opacity,
  });

  final double y;
  final double start;
  final double speed;
  final double scale;
  final double opacity;
}

const _clouds = [
  _Cloud(y: 0.16, start: 0.10, speed: 1.0, scale: 1.0, opacity: 0.9),
  _Cloud(y: 0.30, start: 0.55, speed: 0.6, scale: 0.72, opacity: 0.7),
  _Cloud(y: 0.10, start: 0.80, speed: 1.5, scale: 0.55, opacity: 0.55),
];

class _FarmPainter extends CustomPainter {
  _FarmPainter({required this.animation, required this.stalks})
    : super(repaint: animation);

  final Animation<double> animation;
  final List<_Stalk> stalks;

  @override
  void paint(Canvas canvas, Size size) {
    final t = animation.value;
    final w = size.width;
    final h = size.height;
    final rect = Offset.zero & size;

    // Sky.
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFDFDF6), Color(0xFFE9F2E0)],
        ).createShader(rect),
    );

    _paintSun(canvas, w, h, t);
    _paintBirds(canvas, w, h, t);
    _paintClouds(canvas, w, h, t);
    _paintHills(canvas, w, h);
    _paintWindmill(canvas, w, h, t);
    _paintBarn(canvas, w, h);
    _paintWheat(canvas, w, h, t);
  }

  void _paintSun(Canvas canvas, double w, double h, double t) {
    final center = Offset(w * 0.62, h * 0.18);
    final breath = 1 + 0.035 * math.sin(t * 2 * math.pi);
    final radius = math.min(w, h) * 0.075 * breath;

    canvas.drawCircle(
      center,
      radius * 3.0,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFF6DE8D).withValues(alpha: 0.5),
            const Color(0xFFF6DE8D).withValues(alpha: 0),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius * 3.0)),
    );
    // Thin halo rings breathing with the sun.
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawCircle(
      center,
      radius * 1.6,
      ring..color = const Color(0xFFE9CD7A).withValues(alpha: 0.5),
    );
    canvas.drawCircle(
      center,
      radius * 2.2,
      ring..color = const Color(0xFFE9CD7A).withValues(alpha: 0.25),
    );
    canvas.drawCircle(center, radius, Paint()..color = const Color(0xFFF3CE6B));
  }

  void _paintBirds(Canvas canvas, double w, double h, double t) {
    // A few distant birds gliding slowly right to left.
    final paint = Paint()
      ..color = const Color(0xFF2C4636).withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < 3; i++) {
      final travel = w * 1.3;
      final x =
          travel - ((t * 1.4 * travel + i * travel * 0.37) % travel) - w * 0.15;
      final y = h * (0.10 + i * 0.05) + math.sin(t * 2 * math.pi * 4 + i) * 3;
      final s = 5.0 + i * 1.5;
      final flap = 1 + 0.25 * math.sin(t * 2 * math.pi * 10 + i * 2);
      canvas.drawPath(
        Path()
          ..moveTo(x - s, y)
          ..quadraticBezierTo(x - s * 0.4, y - s * 0.55 * flap, x, y)
          ..quadraticBezierTo(x + s * 0.4, y - s * 0.55 * flap, x + s, y),
        paint,
      );
    }
  }

  void _paintClouds(Canvas canvas, double w, double h, double t) {
    for (final cloud in _clouds) {
      final cw = w * 0.22 * cloud.scale;
      final ch = h * 0.05 * cloud.scale;
      final travel = w + cw * 2;
      final x = (cloud.start * travel + t * cloud.speed * travel) % travel - cw;
      final y = h * cloud.y;
      final paint = Paint()
        ..color = Colors.white.withValues(alpha: cloud.opacity);

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(x, y + ch * 0.55),
            width: cw,
            height: ch,
          ),
          Radius.circular(ch),
        ),
        paint,
      );
      canvas.drawCircle(Offset(x - cw * 0.22, y), ch * 0.85, paint);
      canvas.drawCircle(Offset(x + cw * 0.05, y - ch * 0.35), ch * 1.05, paint);
      canvas.drawCircle(Offset(x + cw * 0.28, y), ch * 0.8, paint);
    }
  }

  Path _hillPath(double w, double h, double baseY, double lift, double shift) {
    return Path()
      ..moveTo(0, h * (baseY + shift * 0.4))
      ..quadraticBezierTo(w * 0.25, h * (baseY - lift), w * 0.52, h * baseY)
      ..quadraticBezierTo(
        w * 0.78,
        h * (baseY + lift * 0.9),
        w,
        h * (baseY - shift),
      )
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
  }

  void _paintHills(Canvas canvas, double w, double h) {
    canvas.drawPath(
      _hillPath(w, h, 0.66, 0.05, 0.03),
      Paint()..color = const Color(0xFFD5E6CB),
    );
    canvas.drawPath(
      _hillPath(w, h, 0.76, 0.07, -0.02),
      Paint()..color = const Color(0xFF9CC49A),
    );

    final front = _hillPath(w, h, 0.87, 0.06, 0.02);
    canvas.drawPath(front, Paint()..color = const Color(0xFF2F6B45));

    // Furrow lines following the front hill contour.
    final furrow = Paint()
      ..color = const Color(0xFF265C3A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    for (var i = 1; i <= 3; i++) {
      final y = 0.87 + i * 0.035;
      canvas.drawPath(
        Path()
          ..moveTo(0, h * (y + 0.008))
          ..quadraticBezierTo(w * 0.25, h * (y - 0.05), w * 0.52, h * y)
          ..quadraticBezierTo(w * 0.78, h * (y + 0.05), w, h * (y - 0.015)),
        furrow,
      );
    }
  }

  void _paintWindmill(Canvas canvas, double w, double h, double t) {
    final isNarrow = w < 620;
    final base = Offset(
      w * (isNarrow ? 0.68 : 0.545),
      h * (isNarrow ? 0.86 : 0.745),
    );
    final hub = Offset(base.dx, base.dy - h * (isNarrow ? 0.09 : 0.125));
    final paint = Paint()
      ..color = LandingColors.deepGreen
      ..strokeWidth = math.max(2.2, h * (isNarrow ? 0.005 : 0.007))
      ..strokeCap = StrokeCap.round;

    // Tapered tower.
    final towerHalfWidth = math.max(3.0, w * (isNarrow ? 0.007 : 0.010));
    final hubHalfWidth = math.max(1.5, w * (isNarrow ? 0.0028 : 0.0035));
    canvas.drawPath(
      Path()
        ..moveTo(base.dx - towerHalfWidth, base.dy)
        ..lineTo(hub.dx - hubHalfWidth, hub.dy)
        ..lineTo(hub.dx + hubHalfWidth, hub.dy)
        ..lineTo(base.dx + towerHalfWidth, base.dy)
        ..close(),
      Paint()..color = LandingColors.deepGreen,
    );

    canvas.save();
    canvas.translate(hub.dx, hub.dy);
    canvas.rotate(t * 2 * math.pi * 2); // two turns per loop — slow and calm
    final bladeLength = h * (isNarrow ? 0.052 : 0.072);
    for (var i = 0; i < 3; i++) {
      canvas.rotate(2 * math.pi / 3);
      canvas.drawLine(Offset.zero, Offset(0, -bladeLength), paint);
      canvas.drawLine(
        Offset(0, -bladeLength),
        Offset(w * 0.008, -bladeLength * 0.55),
        paint,
      );
    }
    canvas.restore();
    canvas.drawCircle(hub, math.max(3, h * 0.008), paint);
  }

  void _paintBarn(Canvas canvas, double w, double h) {
    final isNarrow = w < 620;
    final cx = w * (isNarrow ? 0.86 : 0.86);
    final baseY = h * 0.87;
    final unit = math.min(w, h);
    final bw = unit * (isNarrow ? 0.060 : 0.052);
    final bh = bw * 0.82;
    final paint = Paint()..color = LandingColors.deepGreen;

    canvas.drawRect(Rect.fromLTWH(cx - bw / 2, baseY - bh, bw, bh), paint);
    canvas.drawPath(
      Path()
        ..moveTo(cx - bw * 0.62, baseY - bh)
        ..lineTo(cx, baseY - bh - h * 0.032)
        ..lineTo(cx + bw * 0.62, baseY - bh)
        ..close(),
      paint,
    );
    // Door.
    canvas.drawRect(
      Rect.fromLTWH(cx - bw * 0.14, baseY - bh * 0.55, bw * 0.28, bh * 0.55),
      Paint()..color = const Color(0xFF9CC49A),
    );
  }

  void _paintWheat(Canvas canvas, double w, double h, double t) {
    final isNarrow = w < 560;
    final count = isNarrow ? 14 : stalks.length;
    final stroke = Paint()
      ..color = const Color(0xFFE9CD7A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isNarrow ? 2.1 : 2.4
      ..strokeCap = StrokeCap.round;
    final head = Paint()..color = const Color(0xFFEFD98F);

    for (var i = 0; i < count; i++) {
      final stalk = stalks[i];
      final baseX = stalk.x * w;
      final baseY = h * (0.955 + 0.03 * math.sin(stalk.phase));
      final length = h * (isNarrow ? 0.065 : 0.075) * stalk.height;
      final sway = math.sin(t * 2 * math.pi * 3 + stalk.phase) * length * 0.16;
      final tip = Offset(baseX + sway, baseY - length);

      canvas.drawPath(
        Path()
          ..moveTo(baseX, baseY)
          ..quadraticBezierTo(
            baseX + sway * 0.3,
            baseY - length * 0.55,
            tip.dx,
            tip.dy,
          ),
        stroke,
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: tip.translate(sway * 0.08, -length * 0.06),
          width: 5,
          height: length * 0.28,
        ),
        head,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _FarmPainter oldDelegate) =>
      oldDelegate.stalks != stalks;
}
