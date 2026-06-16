import 'package:flutter/material.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../shared/presentation/placeholder_tab_screen.dart';

class CustomerMessagesScreen extends StatelessWidget {
  const CustomerMessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return PlaceholderTabScreen(
      title: l10n.messagesTitle,
      message: l10n.messagesEmptyMessage,
      icon: Icons.chat_bubble_outline,
    );
  }
}
