import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/widgets/app_button.dart';

class FarmerPendingReviewScreen extends StatelessWidget {
  const FarmerPendingReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.farmerPendingTitle)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.hourglass_top,
                size: 56,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.farmerPendingTitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(l10n.farmerPendingMessage, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              AppButton(
                label: l10n.backToCustomerModeButton,
                icon: Icons.home_outlined,
                onPressed: () => context.go(AppRoutes.customerHome),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
