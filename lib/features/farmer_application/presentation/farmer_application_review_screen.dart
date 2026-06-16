import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/widgets/app_button.dart';
import '../../auth/presentation/auth_controller.dart';
import '../domain/farmer_application.dart';
import 'farmer_application_controller.dart';

class FarmerApplicationReviewScreen extends ConsumerWidget {
  const FarmerApplicationReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final applicationState = ref.watch(farmerApplicationControllerProvider);
    final authState = ref.watch(authControllerProvider);
    final draft = applicationState.draft;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.farmerApplicationReviewTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              l10n.farmerApplicationReviewIntro,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            _ReviewRow(
              label: l10n.profileTypeLabel,
              value: _profileTypeLabel(l10n, draft.profileType),
            ),
            _ReviewRow(label: l10n.displayNameLabel, value: draft.displayName),
            _ReviewRow(label: l10n.farmNameLabel, value: draft.farmName),
            _ReviewRow(label: l10n.phoneLabel, value: draft.phone),
            _ReviewRow(label: l10n.emailLabel, value: draft.email),
            _ReviewRow(
              label: l10n.shortDescriptionLabel,
              value: draft.shortDescription,
            ),
            _ReviewRow(
              label: 'Farm pickup location',
              value: [
                draft.city,
                draft.country,
              ].where((value) => value.isNotEmpty).join(', '),
            ),
            const SizedBox(height: 24),
            AppButton(
              label: l10n.submitApplicationButton,
              icon: Icons.send_outlined,
              isLoading: authState.isLoading,
              onPressed: applicationState.canReview
                  ? () async {
                      await ref
                          .read(farmerApplicationControllerProvider.notifier)
                          .submit();
                      if (context.mounted) {
                        context.go(AppRoutes.farmerPendingReview);
                      }
                    }
                  : null,
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.go(AppRoutes.farmerLocation),
              child: Text(l10n.editLocationButton),
            ),
          ],
        ),
      ),
    );
  }

  String _profileTypeLabel(
    AppLocalizations l10n,
    FarmerProfileType profileType,
  ) {
    return switch (profileType) {
      FarmerProfileType.individual => l10n.profileTypeIndividual,
      FarmerProfileType.farm => l10n.profileTypeFarm,
      FarmerProfileType.cooperative => l10n.profileTypeCooperative,
    };
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelLarge),
          const SizedBox(height: 4),
          Text(value.isEmpty ? '-' : value),
        ],
      ),
    );
  }
}
