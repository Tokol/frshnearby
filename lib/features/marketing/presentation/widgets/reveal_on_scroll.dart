import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Fades and slides its child in the first time it scrolls into view.
///
/// One-way latch: once revealed it never animates again, so it costs nothing
/// after the entrance. Also checks once after the first frame so content that
/// is already above the fold reveals without any scrolling.
class RevealOnScroll extends StatefulWidget {
  const RevealOnScroll({
    super.key,
    required this.child,
    this.delay = Duration.zero,
  });

  final Widget child;
  final Duration delay;

  @override
  State<RevealOnScroll> createState() => _RevealOnScrollState();
}

class _RevealOnScrollState extends State<RevealOnScroll> {
  bool _revealed = false;
  ScrollPosition? _position;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final position = Scrollable.maybeOf(context)?.position;
    if (!identical(position, _position)) {
      _position?.removeListener(_check);
      _position = position;
      if (!_revealed) _position?.addListener(_check);
    }
    SchedulerBinding.instance.addPostFrameCallback((_) => _check());
  }

  @override
  void dispose() {
    _position?.removeListener(_check);
    super.dispose();
  }

  void _check() {
    if (_revealed || !mounted) return;
    final box = context.findRenderObject();
    if (box is! RenderBox || !box.attached || !box.hasSize) return;
    final top = box.localToGlobal(Offset.zero).dy;
    final viewport = MediaQuery.sizeOf(context).height;
    if (top < viewport * 0.88) {
      _position?.removeListener(_check);
      setState(() => _revealed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: _revealed ? 1 : 0),
      duration: Duration(milliseconds: 620 + widget.delay.inMilliseconds),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 26 * (1 - value)),
          child: child,
        ),
      ),
      child: widget.child,
    );
  }
}
