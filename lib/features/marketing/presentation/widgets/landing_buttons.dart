import 'package:flutter/material.dart';

import '../marketing_tokens.dart';
import 'hover_lift.dart';

class LandingPrimaryButton extends StatelessWidget {
  const LandingPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return HoverLift(
      child: FilledButton.icon(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: LandingColors.green,
          foregroundColor: Colors.white,
          minimumSize: const Size(168, 54),
          padding: const EdgeInsets.symmetric(horizontal: 22),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
        ),
        icon: icon != null ? Icon(icon, size: 19) : const SizedBox.shrink(),
        label: Text(label),
      ),
    );
  }
}

class LandingSecondaryButton extends StatelessWidget {
  const LandingSecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return HoverLift(
      child: OutlinedButton.icon(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: LandingColors.ink,
          backgroundColor: Colors.white.withValues(alpha: 0.7),
          side: const BorderSide(color: LandingColors.ink, width: 1.4),
          minimumSize: const Size(160, 54),
          padding: const EdgeInsets.symmetric(horizontal: 22),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
        ),
        icon: icon != null ? Icon(icon, size: 19) : const SizedBox.shrink(),
        label: Text(label),
      ),
    );
  }
}
