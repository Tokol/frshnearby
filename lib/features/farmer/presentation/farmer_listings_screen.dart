import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/widgets/loading_state.dart';
import '../../../core/widgets/app_image.dart';
import '../../listings/domain/listing.dart';
import '../../listings/presentation/listing_controller.dart';

class FarmerListingsScreen extends ConsumerWidget {
  const FarmerListingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(listingControllerProvider);
    final listings = state.listings;
    final activeCount = listings
        .where((listing) => listing.quantity > 0)
        .length;

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Products'),
            Text(
              'Inventory and pricing',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Add product',
            onPressed: () => context.go(AppRoutes.createListing),
            icon: const Icon(Icons.add_circle_outline_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: state.isLoading
          ? const LoadingState(message: 'Loading your products...')
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 920),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                  children: [
                    _InventorySummary(
                      totalCount: listings.length,
                      activeCount: activeCount,
                      totalKg: listings
                          .where((listing) => listing.unit == 'kg')
                          .fold(0, (sum, listing) => sum + listing.quantity),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Your listings',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ),
                        const _FilterChip(),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...listings.map(
                      (listing) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _ProductCard(
                          listing: listing,
                          onTap: () =>
                              context.go(AppRoutes.previewListing(listing.id)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go(AppRoutes.createListing),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add product'),
      ),
    );
  }
}

class _InventorySummary extends StatelessWidget {
  const _InventorySummary({
    required this.totalCount,
    required this.activeCount,
    required this.totalKg,
  });

  final int totalCount;
  final int activeCount;
  final double totalKg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF0EBDD),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'This week\'s inventory',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 5),
                Text(
                  'Keep quantities current so customers can order confidently.',
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${totalKg.toStringAsFixed(1)} kg',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text('$activeCount of $totalCount available'),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.tune_rounded, size: 17),
          SizedBox(width: 6),
          Text('All'),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.listing, required this.onTap});

  final Listing listing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final available = listing.quantity > 0;
    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(17),
                child: AppImage(
                  listing.photoPlaceholder ??
                      'assets/images/home/vegetables.png',
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            listing.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        PopupMenuButton<String>(
                          padding: EdgeInsets.zero,
                          onSelected: (value) {
                            if (value == 'edit') {
                              context.go(AppRoutes.editListing(listing.id));
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text('Edit'),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (listing.variantId != null)
                      Text(
                        'Variety included',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    if (listing.description.trim().isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        listing.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                    if (listing.farmingMethod?.trim().isNotEmpty ?? false) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.eco_outlined, size: 15),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              listing.farmingMethod!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.labelMedium,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 10),
                    if (!available) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Sold out',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          '€${listing.price.toStringAsFixed(2)} / ${listing.unit}',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${listing.quantity.toStringAsFixed(listing.quantity % 1 == 0 ? 0 : 1)} ${listing.unit} left',
                          style: theme.textTheme.labelLarge,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
