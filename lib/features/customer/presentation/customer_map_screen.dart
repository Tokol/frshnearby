import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/location/marketplace_location.dart';
import '../../../core/location/marketplace_location_controller.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/farm_avatar.dart';
import '../../../core/widgets/loading_state.dart';
import '../../catalog/presentation/category_visuals.dart';
import '../../customer_marketplace/domain/customer_listing.dart';
import '../../customer_marketplace/domain/farmer_public_profile.dart';
import '../../customer_marketplace/presentation/customer_marketplace_controller.dart';
import 'farm_buying_sheet.dart';
import 'followed_farms_controller.dart';

/// Basemap config. To switch to the real Mapbox cartoon style later, paste a
/// public token (and optionally a Studio style as `username/styleId`). While
/// [_mapboxToken] is empty the map renders a stylized OpenStreetMap basemap.
const _mapboxToken = '';
const _mapboxStyle = 'mapbox/streets-v12';
bool get _useMapbox => _mapboxToken.isNotEmpty;

/// Soft, desaturated, lightly-brightened tiles for a playful Snap-style base.
Widget _cartoonTileBuilder(
  BuildContext context,
  Widget tileWidget,
  TileImage tile,
) {
  const s = 0.78; // saturation
  const lr = 0.2126, lg = 0.7152, lb = 0.0722;
  const b = 12.0; // brightness lift
  final matrix = <double>[
    lr * (1 - s) + s, lg * (1 - s), lb * (1 - s), 0, b,
    lr * (1 - s), lg * (1 - s) + s, lb * (1 - s), 0, b,
    lr * (1 - s), lg * (1 - s), lb * (1 - s) + s, 0, b + 2,
    0, 0, 0, 1, 0,
  ];
  final tint = Theme.of(context).colorScheme.primary.withValues(alpha: 0.05);
  return ColorFiltered(
    colorFilter: ColorFilter.matrix(matrix),
    child: ColorFiltered(
      colorFilter: ColorFilter.mode(tint, BlendMode.overlay),
      child: tileWidget,
    ),
  );
}

class CustomerMapScreen extends ConsumerStatefulWidget {
  const CustomerMapScreen({super.key});

  @override
  ConsumerState<CustomerMapScreen> createState() => _CustomerMapScreenState();
}

class _CustomerMapScreenState extends ConsumerState<CustomerMapScreen> {
  final _mapController = MapController();
  final _pageController = PageController(viewportFraction: 0.86);

  String? _selectedCategoryId;
  bool _followingOnly = false;
  bool _deliveryOnly = false;

  /// Distance derived from the live map view; shrinks as you zoom in, grows as
  /// you zoom out. Filters both the markers and the carousel list.
  double _viewRadiusKm = 3;
  String? _selectedFarmId;

  /// Map-first by default (Snap-style). Toggles to the synced carousel list.
  bool _carouselMode = false;

  @override
  void dispose() {
    _mapController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final listings = ref.watch(nearbyListingsProvider(locale));
    final locationState = ref.watch(marketplaceLocationControllerProvider);
    final followed = ref.watch(followedFarmsProvider);

    return Scaffold(
      body: listings.when(
        loading: () => LoadingState(message: l10n.loadingMessage),
        error: (_, _) => ErrorState(
          title: l10n.genericErrorTitle,
          message: l10n.genericErrorMessage,
        ),
        data: (items) {
          if (items.isEmpty) {
            return SafeArea(
              child: EmptyState(
                title: l10n.customerHomeEmptyTitle,
                message: l10n.customerHomeEmptyMessage,
              ),
            );
          }

          final userLocation = locationState.displayLocation;
          final allFarms = _buildFarms(items, userLocation, locale);
          final categories = _categoryOptions(items, locale);
          final farms = allFarms.where((farm) {
            if (farm.distanceKm > _viewRadiusKm) return false;
            if (_selectedCategoryId != null &&
                !farm.categoryIds.contains(_selectedCategoryId)) {
              return false;
            }
            if (_deliveryOnly && !farm.hasDelivery) return false;
            if (_followingOnly && !followed.contains(farm.farmer.id)) {
              return false;
            }
            return true;
          }).toList();

          return SafeArea(
            child: Stack(
              children: [
                Positioned.fill(
                  child: _OpenFarmMap(
                    controller: _mapController,
                    farms: farms,
                    userLocation: userLocation,
                    radiusKm: _viewRadiusKm,
                    selectedFarmId: _selectedFarmId,
                    onFarmTap: (farm) => _onStickerTap(farms, farm),
                    onViewRadiusChanged: _onViewRadiusChanged,
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  child: _MapTopBar(
                    locationName: userLocation.displayName,
                    farmCount: farms.length,
                    categories: categories,
                    selectedCategoryId: _selectedCategoryId,
                    followingOnly: _followingOnly,
                    deliveryOnly: _deliveryOnly,
                    radiusKm: _viewRadiusKm,
                    onBack: () => context.go(AppRoutes.customerHome),
                    onSearch: () => context.push(AppRoutes.customerSearch),
                    onCategorySelected: (id) =>
                        _updateFilters(() => _selectedCategoryId = id),
                    onToggleFollowing: () =>
                        _updateFilters(() => _followingOnly = !_followingOnly),
                    onToggleDelivery: () =>
                        _updateFilters(() => _deliveryOnly = !_deliveryOnly),
                  ),
                ),
                Positioned(
                  right: 16,
                  bottom: (_carouselMode && farms.isNotEmpty) ? 212 : 24,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _MapCircleButton(
                        tooltip: _carouselMode ? 'Map view' : 'List view',
                        icon: _carouselMode
                            ? Icons.map_rounded
                            : Icons.view_agenda_rounded,
                        onPressed: () =>
                            setState(() => _carouselMode = !_carouselMode),
                      ),
                      const SizedBox(height: 12),
                      _MapCircleButton(
                        tooltip: l10n.customerHomeTab,
                        icon: Icons.my_location_rounded,
                        onPressed: () => _recenter(userLocation),
                      ),
                    ],
                  ),
                ),
                if (farms.isEmpty)
                  const Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: _NoFarmsCard(),
                  )
                else if (_carouselMode)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: _FarmCarousel(
                      controller: _pageController,
                      farms: farms,
                      followed: followed,
                      onPageChanged: (index) => _onCarouselPage(farms, index),
                      onCardTap: (farm) => _openFarm(farm),
                      onProductTap: _openProduct,
                      onToggleFollow: (farm) => ref
                          .read(followedFarmsProvider.notifier)
                          .toggle(farm.farmer.id),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _updateFilters(VoidCallback change) {
    setState(() {
      change();
      _selectedFarmId = null;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_pageController.hasClients) {
        _pageController.jumpToPage(0);
      }
    });
  }

  void _onStickerTap(List<_FarmMapMarker> farms, _FarmMapMarker farm) {
    if (_carouselMode) {
      _selectFarm(farms, farm);
      return;
    }
    setState(() => _selectedFarmId = farm.farmer.id);
    _mapController.move(farm.position, math.max(_mapController.camera.zoom, 14));
    _openFarm(farm);
  }

  void _selectFarm(List<_FarmMapMarker> farms, _FarmMapMarker farm) {
    final index = farms.indexWhere((item) => item.farmer.id == farm.farmer.id);
    if (index < 0) return;
    setState(() => _selectedFarmId = farm.farmer.id);
    _mapController.move(farm.position, math.max(_mapController.camera.zoom, 13));
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _onCarouselPage(List<_FarmMapMarker> farms, int index) {
    if (index < 0 || index >= farms.length) return;
    final farm = farms[index];
    setState(() => _selectedFarmId = farm.farmer.id);
    _mapController.move(farm.position, math.max(_mapController.camera.zoom, 13));
  }

  void _onViewRadiusChanged(double radiusKm) {
    if (!mounted) return;
    // Round so we only rebuild when the visible distance meaningfully changes,
    // not on every frame of a pinch/zoom gesture.
    final rounded = double.parse(radiusKm.clamp(0.3, 200).toStringAsFixed(1));
    if (rounded == _viewRadiusKm) return;
    setState(() => _viewRadiusKm = rounded);
  }

  void _recenter(MarketplaceLocation location) {
    _mapController.move(
      LatLng(location.latitude, location.longitude),
      14.5,
    );
  }

  void _openFarm(_FarmMapMarker farm) {
    final farmListings = farm.listings;
    if (farmListings.isEmpty) {
      context.go(AppRoutes.farmerPublicProfile(farm.farmer.id));
      return;
    }
    showFarmBuyingSheet(
      context,
      listing: farmListings.first,
      farmerListings: farmListings.skip(1).toList(),
    );
  }

  void _openProduct(_FarmMapMarker farm, CustomerListing listing) {
    final others = farm.listings
        .where((item) => item.listing.id != listing.listing.id)
        .toList();
    showFarmBuyingSheet(context, listing: listing, farmerListings: others);
  }

  List<_FarmMapMarker> _buildFarms(
    List<CustomerListing> listings,
    MarketplaceLocation userLocation,
    String locale,
  ) {
    final byFarmer = <String, List<CustomerListing>>{};
    for (final listing in listings) {
      byFarmer.putIfAbsent(listing.farmer.id, () => []).add(listing);
    }

    final farms = <_FarmMapMarker>[];
    for (final entry in byFarmer.entries) {
      final farmListings = [...entry.value]
        ..sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
      final nearest = farmListings.first;
      farms.add(
        _FarmMapMarker(
          farmer: nearest.farmer,
          position: LatLng(
            nearest.listing.latitude,
            nearest.listing.longitude,
          ),
          distanceKm: nearest.distanceKm,
          listings: farmListings,
          locale: locale,
          isEmulated: false,
        ),
      );
    }

    // Synthetic preview farms keep the map lively in the prototype, with
    // stable coordinates around the user and a clear "Sample" tag.
    final templates = byFarmer.values.map((items) => items.first).toList();
    if (templates.isNotEmpty) {
      const farmNames = [
        'Hilltop Greens',
        'Riverbend Farm',
        'Morning Plot',
        'Oak Lane Dairy',
        'Sun Yard Growers',
        'Field Basket',
        'Meadow Root Farm',
        'Harbor Herbs',
        'North Orchard',
        'Stone Barn Market',
      ];
      for (var i = 0; i < farmNames.length; i++) {
        final template = templates[i % templates.length];
        // Vary the shelf size (1-3 products) so stickers show real variety.
        final productCount = 1 + (i % 3);
        final picks = List.generate(
          productCount,
          (offset) => templates[(i + offset) % templates.length],
        );
        final seed =
            'sample-${userLocation.latitude}-${userLocation.longitude}-$i';
        final position = _nearbyPoint(userLocation, seed);
        farms.add(
          _FarmMapMarker(
            farmer: template.farmer.copyWith(
              id: 'sample-${template.farmer.id}-$i',
              displayName: farmNames[i],
              farmName: farmNames[i],
              city: userLocation.city,
              country: userLocation.country,
              shortDescription:
                  'Nearby farm preview based on your current map area.',
              rating: 4.4 + (i % 6) * 0.08,
              reviewCount: 12 + i * 7,
            ),
            position: position,
            distanceKm: _distanceKm(userLocation, position),
            listings: picks,
            locale: locale,
            isEmulated: true,
          ),
        );
      }
    }

    farms.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    return farms;
  }

  List<_CategoryOption> _categoryOptions(
    List<CustomerListing> listings,
    String locale,
  ) {
    final seen = <String, _CategoryOption>{};
    for (final listing in listings) {
      final id = listing.listing.categoryId;
      seen.putIfAbsent(
        id,
        () => _CategoryOption(
          id: id,
          label: listing.category.displayName(locale),
          emoji: categoryVisual(id).emoji,
        ),
      );
    }
    final options = seen.values.toList()
      ..sort((a, b) => a.label.compareTo(b.label));
    return options;
  }

  LatLng _nearbyPoint(MarketplaceLocation location, String seed) {
    final random = math.Random(seed.hashCode);
    final radiusKm = 0.4 + random.nextDouble() * 3.4;
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

  double _distanceKm(MarketplaceLocation location, LatLng point) {
    const distance = Distance();
    return distance.as(
      LengthUnit.Kilometer,
      LatLng(location.latitude, location.longitude),
      point,
    );
  }
}

class _OpenFarmMap extends StatelessWidget {
  const _OpenFarmMap({
    required this.controller,
    required this.farms,
    required this.userLocation,
    required this.radiusKm,
    required this.selectedFarmId,
    required this.onFarmTap,
    required this.onViewRadiusChanged,
  });

  final MapController controller;
  final List<_FarmMapMarker> farms;
  final MarketplaceLocation userLocation;
  final double radiusKm;
  final String? selectedFarmId;
  final ValueChanged<_FarmMapMarker> onFarmTap;
  final ValueChanged<double> onViewRadiusChanged;

  /// How far (km) the current map view reaches from its centre — used as the
  /// live distance shown in the chip and to filter farms to the visible area.
  double _radiusFromCamera(MapCamera camera) {
    final bounds = camera.visibleBounds;
    final center = camera.center;
    const distance = Distance();
    return distance.as(
      LengthUnit.Kilometer,
      center,
      LatLng(bounds.north, center.longitude),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final center = LatLng(userLocation.latitude, userLocation.longitude);

    return FlutterMap(
      mapController: controller,
      options: MapOptions(
        initialCenter: center,
        initialZoom: 14.5,
        minZoom: 3,
        maxZoom: 18,
        onMapReady: () => onViewRadiusChanged(_radiusFromCamera(controller.camera)),
        onPositionChanged: (camera, _) =>
            onViewRadiusChanged(_radiusFromCamera(camera)),
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
          urlTemplate: _useMapbox
              ? 'https://api.mapbox.com/styles/v1/$_mapboxStyle/tiles/256/{z}/{x}/{y}@2x?access_token=$_mapboxToken'
              : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.freshfarm.app',
          tileBuilder: _useMapbox ? null : _cartoonTileBuilder,
        ),
        CircleLayer(
          circles: [
            CircleMarker(
              point: center,
              radius: radiusKm * 1000,
              useRadiusInMeter: true,
              color: theme.colorScheme.primary.withValues(alpha: 0.08),
              borderColor: theme.colorScheme.primary.withValues(alpha: 0.20),
              borderStrokeWidth: 1.5,
            ),
          ],
        ),
        MarkerLayer(
          markers: [
            // The selected farm renders last so it sits on top of its neighbours.
            for (final farm in farms)
              if (farm.farmer.id != selectedFarmId)
                Marker(
                  point: farm.position,
                  width: 120,
                  height: 110,
                  alignment: Alignment.bottomCenter,
                  child: _FarmStickerMarker(
                    farm: farm,
                    selected: false,
                    onTap: () => onFarmTap(farm),
                  ),
                ),
            for (final farm in farms)
              if (farm.farmer.id == selectedFarmId)
                Marker(
                  point: farm.position,
                  width: 120,
                  height: 110,
                  alignment: Alignment.bottomCenter,
                  child: _FarmStickerMarker(
                    farm: farm,
                    selected: true,
                    onTap: () => onFarmTap(farm),
                  ),
                ),
            Marker(
              point: center,
              width: 150,
              height: 112,
              alignment: Alignment.center,
              child: _UserPositionMarker(
                locationName: userLocation.displayName,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _FarmStickerMarker extends StatelessWidget {
  const _FarmStickerMarker({
    required this.farm,
    required this.selected,
    required this.onTap,
  });

  final _FarmMapMarker farm;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dim = selected ? 56.0 : 46.0;
    final backDim = dim - 6;
    final photos = farm.listings.take(3).toList();
    final count = farm.listings.length;

    Widget photoTile(
      int index,
      double size, {
      Color? borderColor,
      double borderWidth = 2.5,
    }) {
      final asset = index < photos.length
          ? farmListingAsset(photos[index])
          : null;
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: borderColor ?? Colors.white,
            width: borderWidth,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(13),
          child: asset == null
              ? const ColoredBox(color: Color(0x11000000))
              : FarmListingImage(assetPath: asset),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // Fanned product photos behind the hero signal a farm's variety.
              if (photos.length >= 3)
                Transform.translate(
                  offset: const Offset(15, 3),
                  child: Transform.rotate(
                    angle: 0.18,
                    child: photoTile(2, backDim),
                  ),
                ),
              if (photos.length >= 2)
                Transform.translate(
                  offset: const Offset(-15, 3),
                  child: Transform.rotate(
                    angle: -0.18,
                    child: photoTile(1, backDim),
                  ),
                ),
              photoTile(
                0,
                dim,
                borderColor: selected ? theme.colorScheme.primary : Colors.white,
                borderWidth: selected ? 3 : 2.5,
              ),
              Positioned(
                left: -6,
                bottom: -6,
                child: FarmAvatar(
                  farmName: farm.farmer.farmName,
                  radius: 12,
                  photo: farm.farmer.profilePhotoPlaceholder,
                  borderWidth: 2,
                ),
              ),
              if (count > 1)
                Positioned(
                  right: -6,
                  bottom: -6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Text(
                      '$count',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              if (farm.isHotSale)
                Positioned(
                  right: -7,
                  top: -7,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.local_fire_department_rounded,
                      size: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          CustomPaint(
            size: const Size(14, 8),
            painter: _MarkerTailPainter(
              color: selected ? theme.colorScheme.primary : Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _MarkerTailPainter extends CustomPainter {
  _MarkerTailPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = ui.Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_MarkerTailPainter oldDelegate) =>
      oldDelegate.color != color;
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

class _MapTopBar extends StatelessWidget {
  const _MapTopBar({
    required this.locationName,
    required this.farmCount,
    required this.categories,
    required this.selectedCategoryId,
    required this.followingOnly,
    required this.deliveryOnly,
    required this.radiusKm,
    required this.onBack,
    required this.onSearch,
    required this.onCategorySelected,
    required this.onToggleFollowing,
    required this.onToggleDelivery,
  });

  final String locationName;
  final int farmCount;
  final List<_CategoryOption> categories;
  final String? selectedCategoryId;
  final bool followingOnly;
  final bool deliveryOnly;
  final double radiusKm;
  final VoidCallback onBack;
  final VoidCallback onSearch;
  final ValueChanged<String?> onCategorySelected;
  final VoidCallback onToggleFollowing;
  final VoidCallback onToggleDelivery;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(
            children: [
              _MapCircleButton(
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                icon: Icons.arrow_back,
                onPressed: onBack,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withValues(alpha: 0.96),
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 8, 8, 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.place_outlined,
                          size: 18,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '$farmCount farms nearby',
                                style: theme.textTheme.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w900,
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
                        IconButton(
                          tooltip: AppLocalizations.of(context).customerSearchTab,
                          onPressed: onSearch,
                          icon: const Icon(Icons.manage_search_rounded),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 38,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _ChipShell(
                selected: true,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.near_me_outlined, size: 15),
                    const SizedBox(width: 6),
                    Text(
                      radiusKm >= 10
                          ? '${radiusKm.toStringAsFixed(0)} km'
                          : '${radiusKm.toStringAsFixed(1)} km',
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: 'Following',
                icon: Icons.favorite_rounded,
                selected: followingOnly,
                onTap: onToggleFollowing,
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: 'Delivery',
                icon: Icons.local_shipping_outlined,
                selected: deliveryOnly,
                onTap: onToggleDelivery,
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: 'All food',
                selected: selectedCategoryId == null,
                onTap: () => onCategorySelected(null),
              ),
              for (final category in categories) ...[
                const SizedBox(width: 8),
                _FilterChip(
                  label: '${category.emoji} ${category.label}',
                  selected: selectedCategoryId == category.id,
                  onTap: () => onCategorySelected(category.id),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: _ChipShell(
        selected: selected,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 15),
              const SizedBox(width: 6),
            ],
            Text(label),
          ],
        ),
      ),
    );
  }
}

class _ChipShell extends StatelessWidget {
  const _ChipShell({required this.child, required this.selected});

  final Widget child;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: selected
            ? theme.colorScheme.primary
            : theme.colorScheme.surface.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: selected
              ? theme.colorScheme.primary
              : theme.colorScheme.outlineVariant,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: DefaultTextStyle.merge(
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: selected
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurface,
          ),
          child: IconTheme.merge(
            data: IconThemeData(
              color: selected
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurface,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _FarmCarousel extends StatelessWidget {
  const _FarmCarousel({
    required this.controller,
    required this.farms,
    required this.followed,
    required this.onPageChanged,
    required this.onCardTap,
    required this.onProductTap,
    required this.onToggleFollow,
  });

  final PageController controller;
  final List<_FarmMapMarker> farms;
  final Set<String> followed;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<_FarmMapMarker> onCardTap;
  final void Function(_FarmMapMarker farm, CustomerListing listing) onProductTap;
  final ValueChanged<_FarmMapMarker> onToggleFollow;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    // Cap the whole carousel so pages stay close together (with a small peek)
    // on wide/desktop screens instead of leaving a large gap between cards.
    return Align(
      alignment: Alignment.bottomLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: SizedBox(
          height: 196 + bottomInset,
          child: PageView.builder(
            controller: controller,
            onPageChanged: onPageChanged,
            padEnds: false,
            itemCount: farms.length,
            itemBuilder: (context, index) {
              final farm = farms[index];
              return Padding(
                padding: EdgeInsets.fromLTRB(12, 6, 4, 12 + bottomInset),
                child: _FarmCard(
                  farm: farm,
                  followed: followed.contains(farm.farmer.id),
                  onTap: () => onCardTap(farm),
                  onProductTap: (listing) => onProductTap(farm, listing),
                  onToggleFollow: () => onToggleFollow(farm),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _FarmCard extends StatelessWidget {
  const _FarmCard({
    required this.farm,
    required this.followed,
    required this.onTap,
    required this.onProductTap,
    required this.onToggleFollow,
  });

  final _FarmMapMarker farm;
  final bool followed;
  final VoidCallback onTap;
  final ValueChanged<CustomerListing> onProductTap;
  final VoidCallback onToggleFollow;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final listings = farm.listings;
    // Show up to 4 slots; if there are more, the last slot is a "+N" overflow.
    final hasOverflow = listings.length > 4;
    final shownCount = hasOverflow ? 3 : listings.length;
    final shown = listings.take(shownCount).toList();
    final overflow = listings.length - shownCount;

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(20),
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.2),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  FarmAvatar(
                    farmName: farm.farmer.farmName,
                    radius: 18,
                    photo: farm.farmer.profilePhotoPlaceholder,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          farm.farmer.farmName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              Icons.star_rounded,
                              size: 14,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              farm.farmer.reviewCount == 0
                                  ? 'New'
                                  : farm.farmer.rating.toStringAsFixed(1),
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.near_me_outlined,
                              size: 13,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${farm.distanceKm.toStringAsFixed(1)} km',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (farm.hasDelivery) ...[
                              const SizedBox(width: 8),
                              Icon(
                                Icons.local_shipping_outlined,
                                size: 14,
                                color: theme.colorScheme.primary,
                              ),
                            ],
                            if (farm.isEmulated) ...[
                              const SizedBox(width: 6),
                              _MiniTag(label: 'Sample'),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  InkResponse(
                    onTap: onToggleFollow,
                    radius: 22,
                    child: Icon(
                      followed
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      size: 22,
                      color: followed
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (listings.length == 1)
                _SingleProductRow(
                  listing: listings.first,
                  locale: farm.locale,
                  onTap: () => onProductTap(listings.first),
                )
              else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < shown.length; i++) ...[
                      if (i > 0) const SizedBox(width: 8),
                      Expanded(
                        child: _ProductThumb(
                          listing: shown[i],
                          locale: farm.locale,
                          onTap: () => onProductTap(shown[i]),
                        ),
                      ),
                    ],
                    if (hasOverflow) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: _MoreThumb(count: overflow, onTap: onTap),
                      ),
                    ],
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SingleProductRow extends StatelessWidget {
  const _SingleProductRow({
    required this.listing,
    required this.locale,
    required this.onTap,
  });

  final CustomerListing listing;
  final String locale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = listing.variantName(locale) ?? listing.productName(locale);
    final item = listing.listing;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              width: 88,
              height: 88,
              child: FarmListingImage(assetPath: farmListingAsset(listing)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.price.toStringAsFixed(2)} / ${item.unit}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${formatListingQuantity(item.quantity)} ${item.unit} available',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: theme.colorScheme.primary,
          ),
        ],
      ),
    );
  }
}

class _ProductThumb extends StatelessWidget {
  const _ProductThumb({
    required this.listing,
    required this.locale,
    required this.onTap,
  });

  final CustomerListing listing;
  final String locale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = listing.variantName(locale) ?? listing.productName(locale);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 64,
              width: double.infinity,
              child: FarmListingImage(assetPath: farmListingAsset(listing)),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            '${listing.listing.price.toStringAsFixed(2)}/${listing.listing.unit}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _MoreThumb extends StatelessWidget {
  const _MoreThumb({required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 64,
            width: double.infinity,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  '+$count',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'more',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniTag extends StatelessWidget {
  const _MiniTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        child: Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _NoFarmsCard extends StatelessWidget {
  const _NoFarmsCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + bottomInset),
      child: Material(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        elevation: 6,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.travel_explore_rounded,
                  color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'No farms match these filters',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      'Try widening the radius or clearing a filter.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
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

class _CategoryOption {
  const _CategoryOption({
    required this.id,
    required this.label,
    required this.emoji,
  });

  final String id;
  final String label;
  final String emoji;
}

class _FarmMapMarker {
  _FarmMapMarker({
    required this.farmer,
    required this.position,
    required this.distanceKm,
    required this.listings,
    required this.locale,
    required this.isEmulated,
  });

  final FarmerPublicProfile farmer;
  final LatLng position;
  final double distanceKm;
  final List<CustomerListing> listings;
  final String locale;
  final bool isEmulated;

  Set<String> get categoryIds =>
      listings.map((item) => item.listing.categoryId).toSet();

  bool get hasDelivery =>
      listings.any((item) => item.listing.deliveryEnabled);

  double get minPrice => listings.isEmpty
      ? 0
      : listings
            .map((item) => item.listing.price)
            .reduce((a, b) => a < b ? a : b);

  /// Running low on stock reads as an active "hot sale" in the prototype.
  bool get isHotSale =>
      listings.any((item) => item.listing.quantity <= 8);
}
