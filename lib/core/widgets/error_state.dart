import 'package:flutter/material.dart';

import 'app_button.dart';

class ErrorState extends StatelessWidget {
  const ErrorState({
    required this.title,
    required this.message,
    this.actionLabel,
    this.onActionPressed,
    super.key,
  });

  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onActionPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            if (actionLabel != null && onActionPressed != null) ...[
              const SizedBox(height: 16),
              AppButton(label: actionLabel!, onPressed: onActionPressed),
            ],
          ],
        ),
      ),
    );
  }
}
