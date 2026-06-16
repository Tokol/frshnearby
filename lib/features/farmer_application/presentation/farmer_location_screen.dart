import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/widgets/app_button.dart';
import 'farmer_application_controller.dart';

class FarmerLocationScreen extends ConsumerStatefulWidget {
  const FarmerLocationScreen({super.key});

  @override
  ConsumerState<FarmerLocationScreen> createState() =>
      _FarmerLocationScreenState();
}

class _FarmerLocationScreenState extends ConsumerState<FarmerLocationScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(farmerApplicationControllerProvider);
    final draft = state.draft;
    final hasLocation = draft.latitude != null && draft.longitude != null;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.farmerLocationTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              'Where can customers find your farm?',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              'We use your phone location to set the pickup area. Coordinates stay behind the scenes.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            _MapPlaceholder(
              title: hasLocation
                  ? '${draft.city}, ${draft.country}'
                  : l10n.mapPlaceholderTitle,
              message: hasLocation
                  ? 'Farm location confirmed'
                  : 'Your farm area will appear here after you allow location access.',
              confirmed: hasLocation,
            ),
            const SizedBox(height: 20),
            AppButton(
              label: hasLocation
                  ? 'Update current location'
                  : l10n.useCurrentLocationButton,
              icon: Icons.my_location,
              isLoading: state.isLoadingLocation,
              onPressed: () => ref
                  .read(farmerApplicationControllerProvider.notifier)
                  .requestAndUseCurrentLocation(),
            ),
            if (state.locationPermissionDenied) ...[
              const SizedBox(height: 12),
              Text(
                l10n.locationPermissionDeniedMessage,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 24),
            AppButton(
              label: l10n.confirmLocationButton,
              icon: Icons.arrow_forward_rounded,
              onPressed: hasLocation
                  ? () => context.go(AppRoutes.farmerApplicationReview)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _MapPlaceholder extends StatelessWidget {
  const _MapPlaceholder({
    required this.title,
    required this.message,
    required this.confirmed,
  });

  final String title;
  final String message;
  final bool confirmed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: SizedBox(
        height: 180,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  confirmed ? Icons.location_on_rounded : Icons.map_outlined,
                  color: theme.colorScheme.primary,
                  size: 34,
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(message, textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
