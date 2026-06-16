import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/widgets/app_button.dart';
import '../../auth/presentation/auth_controller.dart';
import 'settings_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settingsState = ref.watch(settingsControllerProvider);
    final selectedLanguageCode =
        settingsState.locale?.languageCode ??
        Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            l10n.languageLabel,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          SegmentedButton<String>(
            segments: [
              ButtonSegment(value: 'en', label: Text(l10n.englishLanguage)),
              ButtonSegment(value: 'fi', label: Text(l10n.finnishLanguage)),
              ButtonSegment(value: 'sv', label: Text(l10n.swedishLanguage)),
            ],
            selected: {selectedLanguageCode},
            onSelectionChanged: (selection) {
              final languageCode = selection.first;
              ref
                  .read(settingsControllerProvider.notifier)
                  .updateLocale(Locale(languageCode));
            },
          ),
          const SizedBox(height: 32),
          AppButton(
            label: l10n.signOutButton,
            icon: Icons.logout,
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).signOut();
              if (context.mounted) {
                context.go(AppRoutes.customerHome);
              }
            },
          ),
        ],
      ),
    );
  }
}
