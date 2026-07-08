import 'package:flutter/material.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../marketing_tokens.dart';
import 'landing_buttons.dart';
import 'privacy_policy_dialog.dart';

/// Stable role values so the dropdown survives a mid-session locale switch
/// (localized display labels are resolved at build time).
enum EarlyAccessRole { consumer, farmer, restaurant }

extension EarlyAccessRoleLabel on EarlyAccessRole {
  String label(AppLocalizations l10n) => switch (this) {
    EarlyAccessRole.consumer => l10n.landingRoleConsumer,
    EarlyAccessRole.farmer => l10n.landingRoleFarmer,
    EarlyAccessRole.restaurant => l10n.landingRoleRestaurant,
  };
}

/// "Interested?" — restyled early-access form (email / role / country /
/// message). Swaps to a thank-you card on submit via [AnimatedSwitcher].
class InterestedSection extends StatelessWidget {
  const InterestedSection({
    super.key,
    required this.emailController,
    required this.countryController,
    required this.phoneController,
    required this.messageController,
    required this.role,
    required this.consentAccepted,
    required this.submitted,
    required this.onRoleChanged,
    required this.onConsentChanged,
    required this.onSubmit,
  });

  final TextEditingController emailController;
  final TextEditingController countryController;
  final TextEditingController phoneController;
  final TextEditingController messageController;
  final EarlyAccessRole role;
  final bool consentAccepted;
  final bool submitted;
  final ValueChanged<EarlyAccessRole?> onRoleChanged;
  final ValueChanged<bool?> onConsentChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: LandingColors.line),
        boxShadow: [
          BoxShadow(
            color: LandingColors.ink.withValues(alpha: 0.05),
            blurRadius: 30,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      padding: const EdgeInsets.all(28),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        switchInCurve: Curves.easeOutCubic,
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: SizeTransition(
            sizeFactor: animation,
            axisAlignment: -1,
            child: child,
          ),
        ),
        child: submitted
            ? _ThanksCard(
                key: const ValueKey('thanks'),
                message: l10n.landingFormThanks,
              )
            : _FormBody(
                key: const ValueKey('form'),
                emailController: emailController,
                countryController: countryController,
                phoneController: phoneController,
                messageController: messageController,
                role: role,
                consentAccepted: consentAccepted,
                onRoleChanged: onRoleChanged,
                onConsentChanged: onConsentChanged,
                onSubmit: onSubmit,
              ),
      ),
    );
  }
}

class _FormBody extends StatelessWidget {
  const _FormBody({
    super.key,
    required this.emailController,
    required this.countryController,
    required this.phoneController,
    required this.messageController,
    required this.role,
    required this.consentAccepted,
    required this.onRoleChanged,
    required this.onConsentChanged,
    required this.onSubmit,
  });

  final TextEditingController emailController;
  final TextEditingController countryController;
  final TextEditingController phoneController;
  final TextEditingController messageController;
  final EarlyAccessRole role;
  final bool consentAccepted;
  final ValueChanged<EarlyAccessRole?> onRoleChanged;
  final ValueChanged<bool?> onConsentChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final email = TextField(
      controller: emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: _inputDecoration(l10n.emailLabel),
    );
    final roleField = DropdownButtonFormField<EarlyAccessRole>(
      initialValue: role,
      items: [
        for (final value in EarlyAccessRole.values)
          DropdownMenuItem(value: value, child: Text(value.label(l10n))),
      ],
      onChanged: onRoleChanged,
      decoration: _inputDecoration(l10n.landingFormRoleLabel),
    );
    final country = TextField(
      controller: countryController,
      decoration: _inputDecoration(l10n.countryLabel),
    );
    final phone = TextField(
      controller: phoneController,
      keyboardType: TextInputType.phone,
      decoration: _inputDecoration(l10n.landingFormPhoneLabel),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.landingInterestedTitle,
          style: const TextStyle(
            color: LandingColors.ink,
            fontSize: 32,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.landingInterestedSubtitle,
          style: const TextStyle(
            color: LandingColors.muted,
            fontSize: 15,
            height: 1.5,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, constraints) {
            final twoColumns = constraints.maxWidth >= 680;
            if (!twoColumns) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  email,
                  const SizedBox(height: 14),
                  roleField,
                  const SizedBox(height: 14),
                  country,
                  const SizedBox(height: 14),
                  phone,
                ],
              );
            }
            return Column(
              children: [
                Row(
                  children: [
                    Expanded(child: email),
                    const SizedBox(width: 14),
                    Expanded(child: roleField),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(child: country),
                    const SizedBox(width: 14),
                    Expanded(child: phone),
                  ],
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 14),
        TextField(
          controller: messageController,
          minLines: 3,
          maxLines: 5,
          decoration: _inputDecoration(l10n.landingFormMessageLabel),
        ),
        const SizedBox(height: 16),
        _ConsentToggle(
          value: consentAccepted,
          label: l10n.landingFormConsentLabel,
          onChanged: onConsentChanged,
        ),
        const SizedBox(height: 20),
        Align(
          alignment: Alignment.centerLeft,
          child: LandingPrimaryButton(
            label: l10n.landingFormSubmit,
            icon: Icons.arrow_forward_rounded,
            onPressed: consentAccepted ? onSubmit : null,
          ),
        ),
      ],
    );
  }
}

class _ConsentToggle extends StatelessWidget {
  const _ConsentToggle({
    required this.value,
    required this.label,
    required this.onChanged,
  });

  final bool value;
  final String label;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    final linkLabel = privacyPolicyLinkLabel(context);

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 32,
              height: 32,
              child: Checkbox(
                value: value,
                onChanged: onChanged,
                activeColor: LandingColors.green,
                side: const BorderSide(color: LandingColors.green, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text.rich(
                  TextSpan(
                    children: _consentLabelSpans(
                      context: context,
                      label: label,
                      linkLabel: linkLabel,
                    ),
                  ),
                  style: const TextStyle(
                    color: LandingColors.muted,
                    fontSize: 13,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

List<InlineSpan> _consentLabelSpans({
  required BuildContext context,
  required String label,
  required String linkLabel,
}) {
  final linkStart = label.toLowerCase().indexOf(linkLabel.toLowerCase());
  if (linkStart == -1) {
    return [
      TextSpan(text: '$label '),
      _privacyPolicyLinkSpan(context, linkLabel),
    ];
  }

  final linkEnd = linkStart + linkLabel.length;
  return [
    TextSpan(text: label.substring(0, linkStart)),
    _privacyPolicyLinkSpan(context, label.substring(linkStart, linkEnd)),
    TextSpan(text: label.substring(linkEnd)),
  ];
}

InlineSpan _privacyPolicyLinkSpan(BuildContext context, String label) {
  return WidgetSpan(
    alignment: PlaceholderAlignment.baseline,
    baseline: TextBaseline.alphabetic,
    child: InkWell(
      borderRadius: BorderRadius.circular(4),
      onTap: () => showPrivacyPolicyDialog(context),
      child: Text(
        label,
        style: const TextStyle(
          color: LandingColors.green,
          fontSize: 13,
          height: 1.45,
          fontWeight: FontWeight.w800,
          decoration: TextDecoration.underline,
          decorationColor: LandingColors.green,
        ),
      ),
    ),
  );
}

class _ThanksCard extends StatelessWidget {
  const _ThanksCard({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: const BoxDecoration(
            color: LandingColors.mist,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_rounded,
            color: LandingColors.green,
            size: 30,
          ),
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Text(
            message,
            style: const TextStyle(
              color: LandingColors.ink,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

InputDecoration _inputDecoration(String label) {
  return InputDecoration(
    labelText: label,
    filled: true,
    fillColor: const Color(0xFFFBFCF7),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: LandingColors.line),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: LandingColors.line),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: LandingColors.green, width: 1.6),
    ),
  );
}
