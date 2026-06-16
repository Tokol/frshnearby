import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';

Future<bool> showAppConfirmationDialog({
  required BuildContext context,
  required String title,
  required String message,
  String? confirmLabel,
}) async {
  final l10n = AppLocalizations.of(context);
  final result = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancelButton),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmLabel ?? l10n.confirmButton),
          ),
        ],
      );
    },
  );
  return result ?? false;
}
