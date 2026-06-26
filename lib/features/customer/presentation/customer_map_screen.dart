import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/location/marketplace_location.dart';
import '../../../core/location/marketplace_location_controller.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/widgets/app_image.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/farm_avatar.dart';
import '../../../core/widgets/loading_state.dart';
import '../../customer_marketplace/domain/customer_listing.dart';
import '../../customer_marketplace/domain/farmer_public_profile.dart';
import '../../customer_marketplace/presentation/customer_marketplace_controller.dart';
import 'cart_controller.dart';
import 'followed_farms_controller.dart';

class CustomerMapScreen extends ConsumerWidget {
  const CustomerMapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final listings = ref.watch(nearbyListingsProvider(locale));
    final locationState = ref.watch(marketplaceLocationControllerProvider);

    return Scaffold(
      body: SafeArea(
        child: listings.when(
          loading: () => LoadingState(message: l10n.loadingMessage),
          error: (_, _) => ErrorState(
            title: l10n.genericErrorTitle,
            message: l10n.genericErrorMessage,
          ),
          data: (items) {
            if (items.isEmpty) {
              return EmptyState(
                title: l10n.customerHomeEmptyTitle,
                message: l10n.customerHomeEmptyMessage,
              );
            }

            final userLocation = locationState.displayLocation;
            final farms = _farmMarkers(items, userLocation);
            final bottomPadding = MediaQuery.paddingOf(context).bottom;

            return Stack(
              children: [
                Positioned.fill(
                  child: _OpenFarmMap(
                    farms: farms,
                    userLocation: userLocation,
                    onFarmTap: (farm) => _showFarmPreview(context, farm),
                  ),
                ),
                Positioned(
                  left: 16,
                  top: 12,
                  child: _MapCircleButton(
                    tooltip: MaterialLocalizations.of(
                      context,
                    ).backButtonTooltip,
                    icon: Icons.arrow_back,
                    onPressed: () => context.go(AppRoutes.customerHome),
                  ),
                ),
                Positioned(
                  right: 16,
                  top: 12,
                  child: _MapCircleButton(
                    tooltip: l10n.customerSearchTab,
                    icon: Icons.manage_search_rounded,
                    onPressed: () => context.go(AppRoutes.customerSearch),
                  ),
                ),
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: bottomPadding,
                  child: _MapSummaryBar(
                    locationName: locationState.displayLocation.displayName,
                    farmCount: farms.length,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<_FarmMapMarker> _farmMarkers(
    List<CustomerListing> listings,
    MarketplaceLocation userLocation,
  ) {
    final byFarmer = <String, List<CustomerListing>>{};
    for (final listing in listings) {
      byFarmer.putIfAbsent(listing.farmer.id, () => []).add(listing);
    }

    final markers = <_FarmMapMarker>[];
    for (final entry in byFarmer.entries) {
      final farmListings = entry.value;
      farmListings.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
      final position = _nearbyPoint(userLocation, farmListings.first.farmer.id);
      markers.add(
        _FarmMapMarker(
          farmer: farmListings.first.farmer,
          position: position,
          distanceKm: _distanceKm(userLocation, position),
          hotSales: farmListings.take(4).map(_hotSaleFromListing).toList(),
          isEmulated: false,
        ),
      );
    }

    final templates = byFarmer.values.map((items) => items.first).toList();
    if (templates.isNotEmpty) {
      final farmNames = [
        'Hilltop Greens',
        'Riverbend Farm',
        'Morning Plot',
        'Oak Lane Dairy',
        'Sun Yard Growers',
        'Field Basket',
        'Meadow Root Farm',
        'Harbor Herbs',
        'North Orchard',
        'Small Gate Farm',
        'Fresh Acre',
        'Stone Barn Market',
      ];
      final productLabels = [
        'Nearby today',
        'Fresh stock',
        'Hot sales',
        'Pickup ready',
      ];
      for (var i = 0; i < 8; i++) {
        final template = templates[i % templates.length];
        final sales = List.generate(2, (offset) {
          final item = templates[(i + offset) % templates.length];
          return _hotSaleFromListing(item);
        });
        final seed =
            'emulated-${userLocation.latitude}-${userLocation.longitude}-$i';
        final position = _nearbyPoint(userLocation, seed, minKm: 0.2);
        markers.add(
          _FarmMapMarker(
            farmer: template.farmer.copyWith(
              id: 'emulated-${template.farmer.id}-$i',
              displayName: farmNames[i % farmNames.length],
              farmName: farmNames[i % farmNames.length],
              city: userLocation.city,
              country: userLocation.country,
              shortDescription:
                  'Nearby farm preview based on your current map area.',
              rating: 4.4 + (i % 6) * 0.08,
              reviewCount: 12 + i * 7,
            ),
            position: position,
            distanceKm: _distanceKm(userLocation, position),
            hotSales: sales,
            label: productLabels[i % productLabels.length],
            isEmulated: true,
          ),
        );
      }
    }
    markers.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    return markers;
  }

  LatLng _nearbyPoint(
    MarketplaceLocation location,
    String seed, {
    double minKm = 0.12,
  }) {
    final random = math.Random(seed.hashCode);
    final radiusKm = minKm + random.nextDouble() * 2.6;
    final bearing = random.nextDouble() * math.pi * 2;
    final latOffset = math.cos(bearing) * radiusKm / 111.0;
    final lonScale =
        111.0 * math.cos(location.latitude * math.pi / 180).abs().clamp(0.2, 1);
    final lonOffset = math.sin(bearing) * radiusKm / lonScale;
    return LatLng(
      location.latitude + latOffset,
      location.longitude + lonOffset,
    );
  }

  _MapHotSale _hotSaleFromListing(CustomerListing listing) {
    final item = listing.listing;
    return _MapHotSale(
      listing: listing,
      name: listing.variantName('en') ?? listing.productName('en'),
      priceLabel: '${item.price.toStringAsFixed(2)} / ${item.unit}',
      stockLabel: '${_formatQuantity(item.quantity)} ${item.unit} left',
      assetPath: _assetForListing(listing),
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

  double _distanceKm(MarketplaceLocation location, LatLng point) {
    const distance = Distance();
    return distance.as(
      LengthUnit.Kilometer,
      LatLng(location.latitude, location.longitude),
      point,
    );
  }

  void _showFarmPreview(BuildContext context, _FarmMapMarker farm) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _FarmMapPreviewSheet(farm: farm),
    );
  }
}

class _FarmMapPreviewSheet extends ConsumerStatefulWidget {
  const _FarmMapPreviewSheet({required this.farm});

  final _FarmMapMarker farm;

  @override
  ConsumerState<_FarmMapPreviewSheet> createState() =>
      _FarmMapPreviewSheetState();
}

class _FarmMapPreviewSheetState extends ConsumerState<_FarmMapPreviewSheet> {
  late Map<String, double> _quantities;

  @override
  void initState() {
    super.initState();
    _quantities = {
      for (final sale in widget.farm.hotSales)
        if (sale.listing != null) sale.listing!.listing.id: 0,
    };
  }

  double _quantityFor(_MapHotSale sale) {
    final listing = sale.listing;
    if (listing == null) return 0;
    return _quantities[listing.listing.id] ?? 0;
  }

  void _setQuantity(_MapHotSale sale, double quantity) {
    final listing = sale.listing;
    if (listing == null) return;
    setState(() {
      _quantities[listing.listing.id] = quantity
          .clamp(0, listing.listing.quantity)
          .toDouble();
    });
  }

  List<_MapHotSale> get _selectedSales => widget.farm.hotSales
      .where((sale) => sale.listing != null && _quantityFor(sale) > 0)
      .toList();

  double get _total => _selectedSales.fold<double>(
    0,
    (sum, sale) => sum + sale.listing!.listing.price * _quantityFor(sale),
  );

  String get _farmPageFarmerId {
    for (final sale in widget.farm.hotSales) {
      final listing = sale.listing;
      if (listing != null) return listing.farmer.id;
    }
    return widget.farm.farmer.id;
  }

  void _addSelectionToCart() {
    final selectedSales = _selectedSales;
    if (selectedSales.isEmpty) return;
    final cart = ref.read(cartControllerProvider.notifier);
    for (final sale in selectedSales) {
      cart.add(sale.listing!, _quantityFor(sale));
    }
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${selectedSales.length} farm picks added - ${_total.toStringAsFixed(2)}',
        ),
        action: SnackBarAction(
          label: 'Basket',
          onPressed: () => context.go(AppRoutes.customerDeals),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final farm = widget.farm;
    final followed = ref.watch(followedFarmsProvider).contains(farm.farmer.id);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.62,
      minChildSize: 0.42,
      maxChildSize: 0.84,
      builder: (context, scrollController) {
        return SafeArea(
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            children: [
              Row(
                children: [
                  FarmAvatar(
                    farmName: farm.farmer.farmName,
                    radius: 30,
                    photo: farm.farmer.profilePhotoPlaceholder,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          farm.farmer.farmName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          farm.farmer.approximateLocation,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton.filledTonal(
                    tooltip: followed ? 'Following' : 'Follow farm',
                    onPressed: () => ref
                        .read(followedFarmsProvider.notifier)
                        .toggle(farm.farmer.id),
                    icon: Icon(
                      followed ? Icons.favorite : Icons.favorite_border,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                farm.farmer.shortDescription,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _MapInfoChip(
                    icon: Icons.star_rounded,
                    label: farm.farmer.rating.toStringAsFixed(1),
                  ),
                  _MapInfoChip(
                    icon: Icons.near_me_outlined,
                    label: '${farm.distanceKm.toStringAsFixed(1)} km',
                  ),
                  _MapInfoChip(
                    icon: Icons.shopping_basket_outlined,
                    label: l10n.freshPicksLabel(farm.hotSales.length),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Available now',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Text(
                    'Choose quantities',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              for (final sale in farm.hotSales) ...[
                _FarmPreviewSaleRow(
                  sale: sale,
                  quantity: _quantityFor(sale),
                  onChanged: sale.listing == null
                      ? null
                      : (quantity) => _setQuantity(sale, quantity),
                ),
                const SizedBox(height: 10),
              ],
              _MapOrderSummary(
                selectedCount: _selectedSales.length,
                total: _total,
                onAdd: _selectedSales.isEmpty ? null : _addSelectionToCart,
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.go(AppRoutes.farmerPublicProfile(_farmPageFarmerId));
                },
                icon: const Icon(Icons.storefront_outlined),
                label: Text(farm.isEmulated ? 'View farm' : l10n.openFarmLabel),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FarmPreviewSaleRow extends StatelessWidget {
  const _FarmPreviewSaleRow({
    required this.sale,
    required this.quantity,
    required this.onChanged,
  });

  final _MapHotSale sale;
  final double quantity;
  final ValueChanged<double>? onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final listing = sale.listing;
    final maxQuantity = listing?.listing.quantity ?? 0;
    final unit = listing?.listing.unit ?? '';
    final lineTotal = (listing?.listing.price ?? 0) * quantity;
    final selected = quantity > 0;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: selected
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.28)
            : theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: selected
              ? theme.colorScheme.primary.withValues(alpha: 0.38)
              : theme.colorScheme.outlineVariant,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: AppImage(
                sale.assetPath,
                width: 72,
                height: 72,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sale.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    sale.priceLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    selected
                        ? '${_formatQuantity(quantity)} of ${_formatQuantity(maxQuantity)} $unit - ${lineTotal.toStringAsFixed(2)}'
                        : sale.stockLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: selected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                      fontWeight: selected ? FontWeight.w800 : null,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _MapQuantityStepper(
              quantity: quantity,
              max: maxQuantity,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}

class _MapOrderSummary extends StatelessWidget {
  const _MapOrderSummary({
    required this.selectedCount,
    required this.total,
    required this.onAdd,
  });

  final int selectedCount;
  final double total;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasSelection = selectedCount > 0;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Row(
          children: [
            Icon(
              hasSelection
                  ? Icons.shopping_basket_rounded
                  : Icons.shopping_basket_outlined,
              color: hasSelection
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasSelection ? '$selectedCount selected' : 'Select items',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    hasSelection
                        ? 'Total ${total.toStringAsFixed(2)}'
                        : 'Choose quantities before adding',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_shopping_cart_rounded),
              label: const Text('Add to cart'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapQuantityStepper extends StatelessWidget {
  const _MapQuantityStepper({
    required this.quantity,
    required this.max,
    required this.onChanged,
  });

  final double quantity;
  final double max;
  final ValueChanged<double>? onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canChange = onChanged != null && max > 0;
    final canDecrease = canChange && quantity > 0;
    final canIncrease = canChange && quantity < max;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Decrease',
            visualDensity: VisualDensity.compact,
            iconSize: 18,
            onPressed: canDecrease
                ? () => onChanged!((quantity - 1).clamp(0, max).toDouble())
                : null,
            icon: const Icon(Icons.remove_rounded),
          ),
          SizedBox(
            width: 30,
            child: Text(
              _formatQuantity(quantity),
              textAlign: TextAlign.center,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          IconButton(
            tooltip: quantity >= max
                ? 'Maximum ${_formatQuantity(max)} selected'
                : 'Increase',
            visualDensity: VisualDensity.compact,
            iconSize: 18,
            onPressed: canIncrease
                ? () => onChanged!((quantity + 1).clamp(0, max).toDouble())
                : null,
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
    );
  }
}

class _OpenFarmMap extends StatelessWidget {
  const _OpenFarmMap({
    required this.farms,
    required this.userLocation,
    required this.onFarmTap,
  });

  final List<_FarmMapMarker> farms;
  final MarketplaceLocation userLocation;
  final ValueChanged<_FarmMapMarker> onFarmTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final center = LatLng(userLocation.latitude, userLocation.longitude);

    return FlutterMap(
      options: MapOptions(
        initialCenter: center,
        initialZoom: 13.0,
        interactionOptions: const InteractionOptions(
          flags:
              InteractiveFlag.drag |
              InteractiveFlag.pinchZoom |
              InteractiveFlag.doubleTapZoom |
              InteractiveFlag.flingAnimation,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.freshfarm.app',
          tileBuilder: (context, tileWidget, tile) {
            return ColorFiltered(
              colorFilter: ColorFilter.mode(
                theme.colorScheme.primary.withValues(alpha: 0.04),
                BlendMode.overlay,
              ),
              child: tileWidget,
            );
          },
        ),
        CircleLayer(
          circles: [
            CircleMarker(
              point: center,
              radius: 1200,
              useRadiusInMeter: true,
              color: theme.colorScheme.primary.withValues(alpha: 0.10),
              borderColor: theme.colorScheme.primary.withValues(alpha: 0.18),
              borderStrokeWidth: 1.5,
            ),
          ],
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: center,
              width: 150,
              height: 112,
              alignment: Alignment.center,
              child: _UserPositionMarker(
                locationName: userLocation.displayName,
              ),
            ),
            for (final farm in farms)
              Marker(
                point: farm.position,
                width: 74,
                height: 86,
                alignment: Alignment.topCenter,
                child: Transform.translate(
                  offset: const Offset(0, -8),
                  child: _FarmMarkerBubble(
                    farm: farm,
                    onTap: () => onFarmTap(farm),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _FarmMarkerBubble extends StatelessWidget {
  const _FarmMarkerBubble({required this.farm, required this.onTap});

  final _FarmMapMarker farm;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 18),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.18),
                        blurRadius: 14,
                        offset: const Offset(0, 7),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
                    child: Text(
                      '${farm.hotSales.length}',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ),
              FarmAvatar(
                farmName: farm.farmer.farmName,
                radius: 21,
                photo: farm.farmer.profilePhotoPlaceholder,
                borderWidth: 3,
              ),
            ],
          ),
          const SizedBox(height: 3),
          DecoratedBox(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withValues(alpha: 0.94),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              child: Text(
                farm.farmer.farmName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UserPositionMarker extends StatelessWidget {
  const _UserPositionMarker({required this.locationName});

  final String locationName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.colorScheme.primary.withValues(alpha: 0.16),
          ),
          alignment: Alignment.center,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.primary,
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.28),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(Icons.person, color: Colors.white),
          ),
        ),
        const SizedBox(height: 6),
        DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withValues(alpha: 0.94),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 124),
              child: Text(
                locationName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MapCircleButton extends StatelessWidget {
  const _MapCircleButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: IconButton.filled(
        tooltip: tooltip,
        onPressed: onPressed,
        style: IconButton.styleFrom(
          backgroundColor: theme.colorScheme.surface,
          foregroundColor: theme.colorScheme.onSurface,
          fixedSize: const Size.square(48),
        ),
        icon: Icon(icon),
      ),
    );
  }
}

class _MapSummaryBar extends StatelessWidget {
  const _MapSummaryBar({required this.locationName, required this.farmCount});

  final String locationName;
  final int farmCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.96),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
        child: Row(
          children: [
            Icon(Icons.map_outlined, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$farmCount nearby farms',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    locationName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.touch_app_outlined, size: 20),
          ],
        ),
      ),
    );
  }
}

class _MapInfoChip extends StatelessWidget {
  const _MapInfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16),
            const SizedBox(width: 6),
            Text(label),
          ],
        ),
      ),
    );
  }
}

class _FarmMapMarker {
  const _FarmMapMarker({
    required this.farmer,
    required this.position,
    required this.distanceKm,
    required this.hotSales,
    required this.isEmulated,
    this.label,
  });

  final FarmerPublicProfile farmer;
  final LatLng position;
  final double distanceKm;
  final List<_MapHotSale> hotSales;
  final bool isEmulated;
  final String? label;
}

class _MapHotSale {
  const _MapHotSale({
    required this.name,
    required this.priceLabel,
    required this.stockLabel,
    required this.assetPath,
    this.listing,
  });

  final CustomerListing? listing;
  final String name;
  final String priceLabel;
  final String stockLabel;
  final String assetPath;
}

String _formatQuantity(double value) {
  if (value == value.roundToDouble()) {
    return value.toStringAsFixed(0);
  }
  return value.toStringAsFixed(1);
}
