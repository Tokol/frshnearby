import 'package:flutter/material.dart';

/// Gives its child a gentle lift (scale + translate) on mouse hover.
class HoverLift extends StatefulWidget {
  const HoverLift({super.key, required this.child, this.scale = 1.02});

  final Widget child;
  final double scale;

  @override
  State<HoverLift> createState() => _HoverLiftState();
}

class _HoverLiftState extends State<HoverLift> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        scale: _hovered ? widget.scale : 1.0,
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        child: AnimatedSlide(
          offset: _hovered ? const Offset(0, -0.008) : Offset.zero,
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          child: widget.child,
        ),
      ),
    );
  }
}
