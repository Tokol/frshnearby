import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../settings/presentation/settings_controller.dart';
import '../marketing_tokens.dart';

/// Three flag chips (GB / FI / SE) that drive the app-wide locale.
///
/// Writes through [settingsControllerProvider], the same state the prototype
/// settings screen uses, so a flag click re-localizes the whole app and is
/// persisted across reloads.
class LanguageFlagPicker extends ConsumerWidget {
  const LanguageFlagPicker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final selected =
        ref.watch(settingsControllerProvider).locale?.languageCode ?? 'en';

    final options = [
      (code: 'en', asset: 'assets/images/flags/gb.svg', name: l10n.englishLanguage),
      (code: 'fi', asset: 'assets/images/flags/fi.svg', name: l10n.finnishLanguage),
      (code: 'sv', asset: 'assets/images/flags/se.svg', name: l10n.swedishLanguage),
    ];

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final option in options)
          Padding(
            padding: const EdgeInsets.only(left: 6),
            child: _FlagChip(
              asset: option.asset,
              name: option.name,
              selected: option.code == selected,
              onTap: () => ref
                  .read(settingsControllerProvider.notifier)
                  .updateLocale(Locale(option.code)),
            ),
          ),
      ],
    );
  }
}

class _FlagChip extends StatelessWidget {
  const _FlagChip({
    required this.asset,
    required this.name,
    required this.selected,
    required this.onTap,
  });

  final String asset;
  final String name;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: name,
      child: Semantics(
        label: name,
        button: true,
        selected: selected,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(9),
          child: AnimatedScale(
            scale: selected ? 1.08 : 1.0,
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.all(2.5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(9),
                border: Border.all(
                  color: selected ? LandingColors.green : LandingColors.line,
                  width: selected ? 2 : 1.2,
                ),
                color: Colors.white,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: SvgPicture.asset(
                  asset,
                  width: 30,
                  height: 21,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
