import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/widgets/app_image.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/farm_avatar.dart';
import '../../../core/widgets/loading_state.dart';
import '../../customer_marketplace/domain/customer_listing.dart';
import '../../customer_marketplace/presentation/customer_marketplace_controller.dart';
import 'cart_controller.dart';

class CustomerSearchScreen extends ConsumerStatefulWidget {
  const CustomerSearchScreen({super.key});

  @override
  ConsumerState<CustomerSearchScreen> createState() =>
      _CustomerSearchScreenState();
}

class _CustomerSearchScreenState extends ConsumerState<CustomerSearchScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final listings = ref.watch(
      searchListingsProvider(
        SearchListingsQuery(query: _query, locale: locale),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
          icon: const Icon(Icons.close_rounded),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.customerHome);
            }
          },
        ),
        title: Text(l10n.customerSearchTitle),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                labelText: l10n.searchListingsHint,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        tooltip: MaterialLocalizations.of(
                          context,
                        ).deleteButtonTooltip,
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      ),
              ),
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
          Expanded(
            child: listings.when(
              loading: () => LoadingState(message: l10n.loadingMessage),
              error: (_, _) => ErrorState(
                title: l10n.genericErrorTitle,
                message: l10n.genericErrorMessage,
              ),
              data: (items) {
                if (items.isEmpty) {
                  return EmptyState(
                    title: l10n.noListingsFoundTitle,
                    message: l10n.noListingsFoundMessage,
                    icon: Icons.search_off_outlined,
                  );
                }

                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  children: [
                    _SearchSalesHeader(
                      query: _query,
                      resultCount: items.length,
                    ),
                    const SizedBox(height: 12),
                    for (final listing in items) ...[
                      _SearchSalesCard(
                        listing: listing,
                        onAdd: () {
                          ref
                              .read(cartControllerProvider.notifier)
                              .add(listing, 1);
                          final name =
                              listing.variantName(locale) ??
                              listing.productName(locale);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('$name added to basket'),
                              action: SnackBarAction(
                                label: 'Basket',
                                onPressed: () =>
                                    context.go(AppRoutes.customerDeals),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 14),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchSalesHeader extends StatelessWidget {
  const _SearchSalesHeader({required this.query, required this.resultCount});

  final String query;
  final int resultCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = query.trim().isEmpty ? 'Hot sales near you' : 'Best matches';
    final subtitle = query.trim().isEmpty
        ? 'Fresh offers mapped from nearby farmers'
        : '$resultCount farmer offer${resultCount == 1 ? '' : 's'} found';

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(
              Icons.local_fire_department_rounded,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            _SearchPill(
              icon: Icons.shopping_basket_outlined,
              label: '$resultCount',
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchSalesCard extends StatelessWidget {
  const _SearchSalesCard({required this.listing, required this.onAdd});

  final CustomerListing listing;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final item = listing.listing;
    final title = listing.variantName(locale) ?? listing.productName(locale);
    final isHotSale =
        item.categoryId == 'category-meat' ||
        item.deliveryEnabled ||
        item.quantity <= 10;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                children: [
                  AppImage(
                    _assetForListing(listing),
                    width: 116,
                    height: 132,
                    fit: BoxFit.cover,
                  ),
                  if (isHotSale)
                    PositionedDirectional(
                      start: 7,
                      top: 7,
                      child: _ImageBadge(label: 'Hot'),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        item.price.toStringAsFixed(2),
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    item.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _SearchPill(
                        icon: Icons.inventory_2_outlined,
                        label:
                            '${_formatQuantity(item.quantity)} ${item.unit} left',
                      ),
                      _SearchPill(
                        icon: Icons.place_outlined,
                        label:
                            '${listing.distanceKm.toStringAsFixed(1)} ${l10n.kilometersAwayLabel}',
                      ),
                      if (item.deliveryEnabled)
                        const _SearchPill(
                          icon: Icons.local_shipping_outlined,
                          label: 'Delivery',
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      FarmAvatar(
                        farmName: listing.farmer.farmName,
                        radius: 14,
                        photo: listing.farmer.profilePhotoPlaceholder,
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          listing.farmer.farmName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.star_rounded,
                        size: 16,
                        color: Colors.amber.shade700,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        listing.farmer.reviewCount == 0
                            ? l10n.newFarmLabel
                            : listing.farmer.rating.toStringAsFixed(1),
                        style: theme.textTheme.labelMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: onAdd,
                      icon: const Icon(Icons.add_shopping_cart_rounded),
                      label: Text('Add 1 ${item.unit}'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _assetForListing(CustomerListing listing) {
    switch (listing.listing.productId) {
      case 'product-lamb':
      case 'product-beef':
      case 'product-pork':
      case 'product-minced-meat':
        return 'assets/images/home/meat_hot_sale.png';
      case 'product-potato':
        return 'assets/images/home/potatoes.png';
      case 'product-tomato':
        return 'assets/images/home/tomatoes.png';
      case 'product-honey':
        return 'assets/images/home/honey_jar.png';
      case 'product-apple':
        return 'assets/images/home/fruits.png';
      case 'product-egg':
        return 'assets/images/home/eggs.png';
      default:
        return listing.listing.photoPlaceholder ??
            'assets/images/home/vegetables.png';
    }
  }
}

class _SearchPill extends StatelessWidget {
  const _SearchPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14),
            const SizedBox(width: 4),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageBadge extends StatelessWidget {
  const _ImageBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onErrorContainer,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

String _formatQuantity(double value) {
  if (value == value.roundToDouble()) {
    return value.toStringAsFixed(0);
  }
  return value.toStringAsFixed(1);
}
