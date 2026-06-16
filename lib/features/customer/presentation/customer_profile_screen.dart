import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/widgets/app_button.dart';
import '../../auth/domain/farmer_profile.dart';
import '../../auth/presentation/auth_controller.dart';

class CustomerProfileScreen extends ConsumerWidget {
  const CustomerProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final authState = ref.watch(authControllerProvider);
    final user = authState.user;
    final farmerStatus = user?.farmerProfile?.status;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profileTitle),
        actions: [
          IconButton(
            tooltip: l10n.settingsTitle,
            onPressed: () => context.go(AppRoutes.settings),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            user?.name ?? l10n.profileGuestName,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 4),
          Text(user?.email ?? l10n.profileGuestEmail),
          const SizedBox(height: 32),
          if (authState.canAccessFarmerMode)
            AppButton(
              label: l10n.switchToFarmerButton,
              icon: Icons.storefront,
              onPressed: () => context.go(AppRoutes.farmerDashboard),
            )
          else if (authState.canApplyAsFarmer)
            AppButton(
              label: l10n.applyAsFarmerButton,
              icon: Icons.agriculture_outlined,
              onPressed: () => context.go(AppRoutes.applyAsFarmer),
            )
          else if (farmerStatus == FarmerVerificationStatus.pendingReview)
            _StatusPanel(
              title: l10n.farmerPendingTitle,
              message: l10n.farmerPendingMessage,
              icon: Icons.hourglass_top,
            )
          else if (farmerStatus == FarmerVerificationStatus.rejected)
            _StatusPanel(
              title: l10n.farmerRejectedTitle,
              message: l10n.farmerRejectedMessage,
              icon: Icons.cancel_outlined,
            )
          else if (farmerStatus == FarmerVerificationStatus.suspended)
            _StatusPanel(
              title: l10n.farmerSuspendedTitle,
              message: l10n.farmerSuspendedMessage,
              icon: Icons.block,
            ),
        ],
      ),
    );
  }
}

class _StatusPanel extends StatelessWidget {
  const _StatusPanel({
    required this.title,
    required this.message,
    required this.icon,
  });

  final String title;
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(message),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
