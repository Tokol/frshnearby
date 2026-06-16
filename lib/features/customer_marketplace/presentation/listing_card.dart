import 'package:flutter/material.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../domain/customer_listing.dart';

class ListingCard extends StatelessWidget {
  const ListingCard({required this.listing, required this.onTap, super.key});

  final CustomerListing listing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final variantName = listing.variantName(locale);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                listing.productName(locale),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (variantName != null) ...[
                const SizedBox(height: 4),
                Text(variantName),
              ],
              const SizedBox(height: 12),
              Text(
                '${listing.listing.price.toStringAsFixed(2)} / ${listing.listing.unit}',
              ),
              const SizedBox(height: 8),
              Text(
                '${listing.distanceKm.toStringAsFixed(1)} ${l10n.kilometersAwayLabel}',
              ),
              const SizedBox(height: 4),
              _FarmRatingLine(
                farmName: listing.farmer.farmName,
                rating: listing.farmer.rating,
                reviewCount: listing.farmer.reviewCount,
              ),
              const SizedBox(height: 4),
              Text(
                '${l10n.approximateLocationLabel}: ${listing.farmer.approximateLocation}',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FarmRatingLine extends StatelessWidget {
  const _FarmRatingLine({
    required this.farmName,
    required this.rating,
    required this.reviewCount,
  });

  final String farmName;
  final double rating;
  final int reviewCount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Text(
            farmName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Icon(Icons.star_rounded, size: 16, color: Colors.amber.shade700),
        const SizedBox(width: 2),
        Text(
          reviewCount == 0 ? l10n.newFarmLabel : rating.toStringAsFixed(1),
          style: theme.textTheme.labelMedium,
        ),
      ],
    );
  }
}
