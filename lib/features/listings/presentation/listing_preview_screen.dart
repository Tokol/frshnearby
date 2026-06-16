import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_confirmation_dialog.dart';
import '../../../core/widgets/error_state.dart';
import '../../auth/presentation/auth_controller.dart';
import '../domain/product_detail_labels.dart';
import 'listing_controller.dart';

class ListingPreviewScreen extends ConsumerWidget {
  const ListingPreviewScreen({required this.listingId, super.key});

  final String listingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    ref.watch(listingControllerProvider);
    final authState = ref.watch(authControllerProvider);
    final profile = authState.user?.farmerProfile;
    final listing = ref
        .read(listingControllerProvider.notifier)
        .listingById(listingId);

    if (!authState.canAccessFarmerMode) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.listingPreviewTitle)),
        body: ErrorState(
          title: l10n.unauthorizedTitle,
          message: l10n.verifiedFarmerRequiredMessage,
        ),
      );
    }

    if (listing == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.listingPreviewTitle)),
        body: ErrorState(
          title: l10n.genericErrorTitle,
          message: l10n.listingNotFoundMessage,
        ),
      );
    }
    final detailLabels = productDetailLabels(listing.categoryId);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.listingPreviewTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _PhotoPreview(label: l10n.listingPhotoPlaceholderLabel),
            const SizedBox(height: 24),
            Text(
              listing.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            _Detail(
              label: l10n.availableNowLabel,
              value: '${_formatQuantity(listing.quantity)} ${listing.unit}',
            ),
            _Detail(
              label: l10n.customerPriceLabel,
              value: '€${listing.price.toStringAsFixed(2)} per ${listing.unit}',
            ),
            _Detail(
              label: l10n.farmPickupLocationLabel,
              value: [profile?.city, profile?.country]
                  .whereType<String>()
                  .where((value) => value.isNotEmpty)
                  .join(', '),
            ),
            if (listing.description.isNotEmpty)
              _Detail(
                label: l10n.listingDescriptionLabel,
                value: listing.description,
              ),
            if (listing.farmingMethod?.isNotEmpty ?? false)
              _Detail(
                label: detailLabels.method.replaceAll(' (optional)', ''),
                value: listing.farmingMethod!,
              ),
            if (listing.harvestDate != null)
              _Detail(
                label: listing.harvestDate!.isAfter(DateTime.now())
                    ? detailLabels.futureDate
                    : detailLabels.pastDate,
                value: DateFormat('d MMM yyyy').format(listing.harvestDate!),
              ),
            if (listing.bestBeforeDate != null)
              _Detail(
                label: l10n.bestBeforeLabel,
                value: DateFormat('d MMM yyyy').format(listing.bestBeforeDate!),
              ),
            if (listing.storageInstructions?.trim().isNotEmpty ?? false)
              _Detail(
                label: l10n.storageLabel,
                value: listing.storageInstructions!,
              ),
            const SizedBox(height: 24),
            AppButton(
              label: l10n.editListingButton,
              icon: Icons.edit_outlined,
              onPressed: () => context.go(AppRoutes.editListing(listing.id)),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () async {
                final confirmed = await showAppConfirmationDialog(
                  context: context,
                  title: l10n.confirmArchiveListingTitle,
                  message: l10n.confirmArchiveListingMessage,
                  confirmLabel: l10n.archiveListingButton,
                );
                if (!confirmed) {
                  return;
                }
                await ref
                    .read(listingControllerProvider.notifier)
                    .archiveListing(listing.id);
                if (context.mounted) {
                  context.go(AppRoutes.farmerDashboard);
                }
              },
              icon: const Icon(Icons.archive_outlined),
              label: Text(l10n.archiveListingButton),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatQuantity(double value) {
    return value.toStringAsFixed(value % 1 == 0 ? 0 : 1);
  }
}

class _Detail extends StatelessWidget {
  const _Detail({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 2),
          Text(value),
        ],
      ),
    );
  }
}

class _PhotoPreview extends StatelessWidget {
  const _PhotoPreview({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: SizedBox(
        height: 180,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.image_outlined, color: theme.colorScheme.primary),
              const SizedBox(height: 8),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }
}
