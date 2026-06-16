import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/location/marketplace_location_controller.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/loading_state.dart';
import '../../customer_marketplace/domain/customer_listing.dart';
import '../../customer_marketplace/domain/farmer_public_profile.dart';
import '../../customer_marketplace/presentation/customer_marketplace_controller.dart';

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

            final farms = _farmMarkers(items);

            return Stack(
              children: [
                Positioned.fill(
                  child: _EmulatedFarmMap(
                    farms: farms,
                    locationName: locationState.displayLocation.displayName,
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
                  bottom: 20 + MediaQuery.paddingOf(context).bottom,
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

  List<_FarmMapMarker> _farmMarkers(List<CustomerListing> listings) {
    final byFarmer = <String, List<CustomerListing>>{};
    for (final listing in listings) {
      byFarmer.putIfAbsent(listing.farmer.id, () => []).add(listing);
    }

    final markers = <_FarmMapMarker>[];
    for (final entry in byFarmer.entries) {
      final farmListings = entry.value;
      farmListings.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
      markers.add(
        _FarmMapMarker(
          farmer: farmListings.first.farmer,
          distanceKm: farmListings.first.distanceKm,
          availableCount: farmListings.length,
          productPreview: farmListings
              .take(2)
              .map((item) => item.productName('en'))
              .join(', '),
          alignment: _markerAlignment(farmListings.first),
        ),
      );
    }
    markers.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    return markers;
  }

  Alignment _markerAlignment(CustomerListing listing) {
    const centerLatitude = 63.0951;
    const centerLongitude = 21.6165;
    final dx = ((listing.listing.longitude - centerLongitude) * 5.5).clamp(
      -0.76,
      0.76,
    );
    final dy = ((centerLatitude - listing.listing.latitude) * 9.0).clamp(
      -0.72,
      0.72,
    );

    if (dx.abs() < 0.08 && dy.abs() < 0.08) {
      return const Alignment(-0.44, -0.24);
    }
    return Alignment(dx.toDouble(), dy.toDouble());
  }

  void _showFarmPreview(BuildContext context, _FarmMapMarker farm) {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        final theme = Theme.of(context);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _FarmerAvatar(farmer: farm.farmer, size: 58),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            farm.farmer.farmName,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(farm.farmer.approximateLocation),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(farm.farmer.shortDescription),
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
                      label: l10n.freshPicksLabel(farm.availableCount),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  farm.productPreview,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      context.go(AppRoutes.farmerPublicProfile(farm.farmer.id));
                    },
                    icon: const Icon(Icons.storefront_outlined),
                    label: Text(l10n.openFarmLabel),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _EmulatedFarmMap extends StatelessWidget {
  const _EmulatedFarmMap({
    required this.farms,
    required this.locationName,
    required this.onFarmTap,
  });

  final List<_FarmMapMarker> farms;
  final String locationName;
  final ValueChanged<_FarmMapMarker> onFarmTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        return Stack(
          fit: StackFit.expand,
          children: [
            CustomPaint(painter: _FarmMapPainter(theme.colorScheme)),
            Align(
              alignment: const Alignment(0, 0.08),
              child: _UserPositionMarker(locationName: locationName),
            ),
            for (final farm in farms)
              Positioned(
                left: (farm.alignment.x + 1) * size.width / 2 - 48,
                top: (farm.alignment.y + 1) * size.height / 2 - 62,
                child: _FarmMarkerBubble(
                  farm: farm,
                  onTap: () => onFarmTap(farm),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _FarmMapPainter extends CustomPainter {
  const _FarmMapPainter(this.colors);

  final ColorScheme colors;

  @override
  void paint(Canvas canvas, Size size) {
    final background = Paint()..color = const Color(0xFFEAF3DF);
    canvas.drawRect(Offset.zero & size, background);

    final fieldPaint = Paint()..style = PaintingStyle.fill;
    final fields = [
      (const Color(0xFFD7EAC5), const Rect.fromLTWH(-40, 80, 210, 170), -0.2),
      (const Color(0xFFFFE7B8), const Rect.fromLTWH(210, 40, 260, 150), 0.12),
      (const Color(0xFFCFE7D2), const Rect.fromLTWH(40, 330, 230, 150), 0.22),
      (const Color(0xFFE7DCC6), const Rect.fromLTWH(260, 360, 240, 180), -0.18),
    ];

    for (final field in fields) {
      canvas.save();
      canvas.translate(size.width * 0.08, size.height * 0.02);
      canvas.rotate(field.$3);
      fieldPaint.color = field.$1;
      canvas.drawRRect(
        RRect.fromRectAndRadius(field.$2, const Radius.circular(28)),
        fieldPaint,
      );
      canvas.restore();
    }

    final roadPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.88)
      ..strokeWidth = 34
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final roadLine = Paint()
      ..color = const Color(0xFFC9B88C)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final road = Path()
      ..moveTo(-20, size.height * 0.68)
      ..cubicTo(
        size.width * 0.24,
        size.height * 0.56,
        size.width * 0.36,
        size.height * 0.36,
        size.width * 0.62,
        size.height * 0.42,
      )
      ..cubicTo(
        size.width * 0.88,
        size.height * 0.48,
        size.width * 0.78,
        size.height * 0.72,
        size.width + 20,
        size.height * 0.78,
      );
    canvas.drawPath(road, roadPaint);
    canvas.drawPath(road, roadLine);

    final waterPaint = Paint()..color = const Color(0xFFB9DDE7);
    final water = Path()
      ..moveTo(size.width * 0.76, -20)
      ..cubicTo(
        size.width * 0.94,
        size.height * 0.16,
        size.width * 0.88,
        size.height * 0.28,
        size.width + 20,
        size.height * 0.42,
      )
      ..lineTo(size.width + 20, -20)
      ..close();
    canvas.drawPath(water, waterPaint);

    final gridPaint = Paint()
      ..color = colors.outlineVariant.withValues(alpha: 0.35)
      ..strokeWidth = 1;
    for (var x = 40.0; x < size.width; x += 86) {
      canvas.drawLine(Offset(x, 0), Offset(x - 80, size.height), gridPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _FarmMapPainter oldDelegate) => false;
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
          DecoratedBox(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(7, 7, 7, 6),
              child: Column(
                children: [
                  _FarmerAvatar(farmer: farm.farmer, size: 46),
                  const SizedBox(height: 5),
                  SizedBox(
                    width: 82,
                    child: Text(
                      farm.farmer.farmName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star_rounded,
                        size: 14,
                        color: Colors.amber.shade700,
                      ),
                      Text(
                        farm.farmer.rating.toStringAsFixed(1),
                        style: theme.textTheme.labelSmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Icon(
            Icons.arrow_drop_down,
            color: theme.colorScheme.surface,
            size: 26,
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
          width: 74,
          height: 74,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.colorScheme.primary.withValues(alpha: 0.16),
          ),
          alignment: Alignment.center,
          child: Container(
            width: 48,
            height: 48,
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
            child: Text(
              locationName,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FarmerAvatar extends StatelessWidget {
  const _FarmerAvatar({required this.farmer, required this.size});

  final FarmerPublicProfile farmer;
  final double size;

  @override
  Widget build(BuildContext context) {
    final color = _avatarColor(farmer.id);
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: color,
      child: CircleAvatar(
        radius: size / 2 - 4,
        backgroundColor: Colors.white,
        child: Text(
          _initials(farmer.farmName),
          style: TextStyle(
            color: color,
            fontSize: math.max(13, size * 0.27),
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  Color _avatarColor(String seed) {
    const colors = [
      Color(0xFF2E7D32),
      Color(0xFFC65A2E),
      Color(0xFF26737A),
      Color(0xFF8B5A2B),
    ];
    return colors[seed.hashCode.abs() % colors.length];
  }

  String _initials(String value) {
    final parts = value.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) {
      return '?';
    }
    return parts.take(2).map((part) => part[0].toUpperCase()).join();
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
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
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
    required this.distanceKm,
    required this.availableCount,
    required this.productPreview,
    required this.alignment,
  });

  final FarmerPublicProfile farmer;
  final double distanceKm;
  final int availableCount;
  final String productPreview;
  final Alignment alignment;
}
