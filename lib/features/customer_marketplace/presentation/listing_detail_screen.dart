import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/loading_state.dart';
import '../../deals/presentation/deal_controller.dart';
import '../../listings/domain/product_detail_labels.dart';
import 'customer_marketplace_controller.dart';

class ListingDetailScreen extends ConsumerWidget {
  const ListingDetailScreen({required this.listingId, super.key});

  final String listingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final listingAsync = ref.watch(
      customerListingProvider(
        ListingDetailQuery(listingId: listingId, locale: locale),
      ),
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.listingDetailTitle)),
      body: listingAsync.when(
        loading: () => LoadingState(message: l10n.loadingMessage),
        error: (_, _) => ErrorState(
          title: l10n.genericErrorTitle,
          message: l10n.genericErrorMessage,
        ),
        data: (listing) {
          if (listing == null) {
            return ErrorState(
              title: l10n.genericErrorTitle,
              message: l10n.listingNotFoundMessage,
            );
          }

          final variantName = listing.variantName(locale);
          final detailLabels = productDetailLabels(listing.listing.categoryId);
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                listing.productName(locale),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              if (variantName != null) ...[
                const SizedBox(height: 4),
                Text(variantName),
              ],
              const SizedBox(height: 24),
              _Detail(
                label: l10n.priceLabel,
                value: listing.listing.price.toStringAsFixed(2),
              ),
              _Detail(
                label: l10n.quantityLabel,
                value: '${listing.listing.quantity} ${listing.listing.unit}',
              ),
              _Detail(
                label: l10n.distanceLabel,
                value:
                    '${listing.distanceKm.toStringAsFixed(1)} ${l10n.kilometersAwayLabel}',
              ),
              if (listing.listing.description.isNotEmpty)
                _Detail(
                  label: l10n.listingDescriptionLabel,
                  value: listing.listing.description,
                ),
              if (listing.listing.farmingMethod?.trim().isNotEmpty ?? false)
                _Detail(
                  label: detailLabels.method.replaceAll(' (optional)', ''),
                  value: listing.listing.farmingMethod!,
                ),
              if (listing.listing.harvestDate != null)
                _Detail(
                  label: listing.listing.harvestDate!.isAfter(DateTime.now())
                      ? detailLabels.futureDate
                      : detailLabels.pastDate,
                  value: DateFormat(
                    'd MMM yyyy',
                  ).format(listing.listing.harvestDate!),
                ),
              if (listing.listing.bestBeforeDate != null)
                _Detail(
                  label: l10n.bestBeforeLabel,
                  value: DateFormat(
                    'd MMM yyyy',
                  ).format(listing.listing.bestBeforeDate!),
                ),
              if (listing.listing.storageInstructions?.trim().isNotEmpty ??
                  false)
                _Detail(
                  label: l10n.storageLabel,
                  value: listing.listing.storageInstructions!,
                ),
              const SizedBox(height: 16),
              _FarmTrustPanel(
                farmName: listing.farmer.farmName,
                location: listing.farmer.approximateLocation,
                rating: listing.farmer.rating,
                reviewCount: listing.farmer.reviewCount,
                onTap: () => context.go(
                  AppRoutes.farmerPublicProfile(listing.farmer.id),
                ),
              ),
              const SizedBox(height: 16),
              AppButton(
                label: l10n.chatButton,
                icon: Icons.chat_bubble_outline,
                onPressed: () async {
                  final thread = await ref
                      .read(dealControllerProvider.notifier)
                      .startChat(listingId: listingId, locale: locale);
                  if (context.mounted) {
                    context.go(AppRoutes.chatThread(thread.id));
                  }
                },
              ),
              const SizedBox(height: 12),
              Text(
                l10n.exactLocationAfterDealMessage,
                textAlign: TextAlign.center,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FarmTrustPanel extends StatelessWidget {
  const _FarmTrustPanel({
    required this.farmName,
    required this.location,
    required this.rating,
    required this.reviewCount,
    required this.onTap,
  });

  final String farmName;
  final String location;
  final double rating;
  final int reviewCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.farmRatingLabel, style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.star_rounded,
                  size: 22,
                  color: Colors.amber.shade700,
                ),
                const SizedBox(width: 6),
                Text(
                  reviewCount == 0
                      ? l10n.newFarmLabel
                      : rating.toStringAsFixed(1),
                  style: theme.textTheme.titleMedium,
                ),
                if (reviewCount > 0) ...[
                  const SizedBox(width: 6),
                  Text(
                    '($reviewCount ${l10n.farmReviewsLabel})',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            Text(farmName, style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(location),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: onTap,
              icon: const Icon(Icons.storefront_outlined),
              label: Text(l10n.viewFarmProfileButton),
            ),
          ],
        ),
      ),
    );
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
