import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/widgets/farm_avatar.dart';
import '../../customer_marketplace/domain/customer_listing.dart';
import '../../listings/domain/product_detail_labels.dart';
import 'cart_controller.dart';

/// Opens the unified farm buying sheet used across home and map explore.
///
/// [listing] is the product the customer tapped; [farmerListings] are the
/// other active listings from the same farm so the customer can build one
/// combined farm order in a single checkout.
Future<void> showFarmBuyingSheet(
  BuildContext context, {
  required CustomerListing listing,
  required List<CustomerListing> farmerListings,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    useSafeArea: true,
    builder: (context) {
      return FarmBuyingSheet(
        listing: listing,
        farmerListings: farmerListings,
      );
    },
  );
}

/// Resolves a stock image for a listing based on its product id.
String farmListingAsset(CustomerListing listing) {
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

/// Formats a quantity, dropping the decimal when the value is whole.
String formatListingQuantity(double value) {
  if (value == value.roundToDouble()) {
    return value.toStringAsFixed(0);
  }
  return value.toStringAsFixed(1);
}

/// Image that falls back to a placeholder tile when the asset is missing.
class FarmListingImage extends StatelessWidget {
  const FarmListingImage({
    required this.assetPath,
    this.fit = BoxFit.cover,
    super.key,
  });

  final String assetPath;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Image.asset(
      assetPath,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return DecoratedBox(
          decoration: BoxDecoration(color: colorScheme.surfaceContainerHighest),
          child: Icon(Icons.image_outlined, color: colorScheme.primary),
        );
      },
    );
  }
}

class FarmBuyingSheet extends ConsumerStatefulWidget {
  const FarmBuyingSheet({
    required this.listing,
    required this.farmerListings,
    super.key,
  });

  final CustomerListing listing;
  final List<CustomerListing> farmerListings;

  @override
  ConsumerState<FarmBuyingSheet> createState() => _FarmBuyingSheetState();
}

class _FarmBuyingSheetState extends ConsumerState<FarmBuyingSheet> {
  late Map<String, double> _quantities;

  @override
  void initState() {
    super.initState();
    _quantities = {
      widget.listing.listing.id: widget.listing.listing.quantity < 1
          ? widget.listing.listing.quantity
          : 1,
      for (final item in widget.farmerListings) item.listing.id: 0,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final listing = widget.listing;
    final variantName = listing.variantName(locale);
    final productName = variantName ?? listing.productName(locale);
    final detailLabels = productDetailLabels(listing.listing.categoryId);
    final date = listing.listing.harvestDate;
    final basketLines = _basketLines;
    final total = basketLines.fold<double>(
      0,
      (sum, item) => sum + item.listing.price * _quantityFor(item),
    );
    final selectedCount = basketLines.fold<int>(
      0,
      (sum, item) => sum + (_quantityFor(item) > 0 ? 1 : 0),
    );

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.88,
      minChildSize: 0.55,
      maxChildSize: 0.96,
      builder: (context, scrollController) {
        return ListView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: AspectRatio(
                aspectRatio: 1.55,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    FarmListingImage(assetPath: farmListingAsset(listing)),
                    PositionedDirectional(
                      top: 12,
                      start: 12,
                      child: _SheetPill(
                        icon: Icons.local_fire_department_rounded,
                        label: 'Hot sale',
                        background: theme.colorScheme.errorContainer,
                        foreground: theme.colorScheme.onErrorContainer,
                      ),
                    ),
                    PositionedDirectional(
                      end: 12,
                      bottom: 12,
                      child: _SheetPill(
                        icon: Icons.inventory_2_outlined,
                        label:
                            '${formatListingQuantity(listing.listing.quantity)} ${listing.listing.unit} left',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    productName,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${listing.listing.price.toStringAsFixed(2)} / ${listing.listing.unit}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              listing.listing.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _SheetPill(
                  icon: Icons.place_outlined,
                  label:
                      '${listing.distanceKm.toStringAsFixed(1)} ${l10n.kilometersAwayLabel}',
                ),
                _SheetPill(
                  icon: Icons.star_rounded,
                  label: listing.farmer.reviewCount == 0
                      ? l10n.newFarmLabel
                      : '${listing.farmer.rating.toStringAsFixed(1)} (${listing.farmer.reviewCount})',
                ),
                if (date != null)
                  _SheetPill(
                    icon: Icons.event_available_outlined,
                    label:
                        '${date.isAfter(DateTime.now()) ? detailLabels.futureDate : detailLabels.pastDate} ${DateFormat('d MMM').format(date)}',
                  ),
                if (listing.listing.deliveryEnabled)
                  const _SheetPill(
                    icon: Icons.local_shipping_outlined,
                    label: 'Delivery nearby',
                  ),
              ],
            ),
            const SizedBox(height: 18),
            _FarmerBuyingPanel(listing: listing),
            const SizedBox(height: 18),
            if (listing.listing.farmingMethod?.trim().isNotEmpty ?? false)
              _SheetDetail(
                icon: Icons.eco_outlined,
                label: detailLabels.method.replaceAll(' (optional)', ''),
                value: listing.listing.farmingMethod!,
              ),
            if (listing.listing.bestBeforeDate != null)
              _SheetDetail(
                icon: Icons.schedule_outlined,
                label: l10n.bestBeforeLabel,
                value: DateFormat(
                  'd MMM yyyy',
                ).format(listing.listing.bestBeforeDate!),
              ),
            if (listing.listing.storageInstructions?.trim().isNotEmpty ?? false)
              _SheetDetail(
                icon: Icons.kitchen_outlined,
                label: l10n.storageLabel,
                value: listing.listing.storageInstructions!,
              ),
            if (listing.listing.pickupNotes?.trim().isNotEmpty ?? false)
              _SheetDetail(
                icon: Icons.shopping_bag_outlined,
                label: 'Pickup',
                value: listing.listing.pickupNotes!,
              ),
            const SizedBox(height: 16),
            _UnifiedFarmBasketPanel(
              farmName: listing.farmer.farmName,
              lines: basketLines,
              quantities: _quantities,
              onChanged: _setQuantity,
            ),
            if (widget.farmerListings.isNotEmpty) ...[
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Complete this farm order',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  _SheetPill(
                    icon: Icons.shopping_basket_outlined,
                    label: '$selectedCount selected',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 184,
                child: ListView.separated(
                  primary: false,
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.farmerListings.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final item = widget.farmerListings[index];
                    return _FarmerShelfItem(
                      listing: item,
                      quantity: _quantityFor(item),
                      imagePath: farmListingAsset(item),
                      onChanged: (value) => _setQuantity(item, value),
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 20),
            _CheckoutSummaryBar(
              selectedCount: selectedCount,
              total: total,
              onAddAll: selectedCount == 0
                  ? null
                  : () {
                      final messenger = ScaffoldMessenger.of(context);
                      final router = GoRouter.of(context);
                      final cart = ref.read(cartControllerProvider.notifier);
                      for (final item in basketLines) {
                        final quantity = _quantityFor(item);
                        if (quantity > 0) {
                          cart.add(item, quantity);
                        }
                      }
                      Navigator.of(context).pop();
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            '$selectedCount farm item${selectedCount == 1 ? '' : 's'} added to basket',
                          ),
                          action: SnackBarAction(
                            label: 'Basket',
                            onPressed: () => router.go(AppRoutes.customerDeals),
                          ),
                        ),
                      );
                    },
            ),
          ],
        );
      },
    );
  }

  List<CustomerListing> get _basketLines => [
    widget.listing,
    ...widget.farmerListings,
  ];

  double _quantityFor(CustomerListing listing) =>
      _quantities[listing.listing.id] ?? 0;

  void _setQuantity(CustomerListing listing, double value) {
    final min = listing.listing.id == widget.listing.listing.id ? 1.0 : 0.0;
    final safeValue = value.clamp(min, listing.listing.quantity).toDouble();
    setState(() {
      _quantities = {..._quantities, listing.listing.id: safeValue};
    });
  }
}

class _FarmerBuyingPanel extends StatelessWidget {
  const _FarmerBuyingPanel({required this.listing});

  final CustomerListing listing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.of(context).pop();
        context.go(AppRoutes.farmerPublicProfile(listing.farmer.id));
      },
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              FarmAvatar(
                farmName: listing.farmer.farmName,
                radius: 24,
                photo: listing.farmer.profilePhotoPlaceholder,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      listing.farmer.farmName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${listing.farmer.approximateLocation} · ${listing.farmer.shortDescription}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Tooltip(
                message: l10n.viewFarmProfileButton,
                child: const Icon(Icons.chevron_right_rounded),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UnifiedFarmBasketPanel extends StatelessWidget {
  const _UnifiedFarmBasketPanel({
    required this.farmName,
    required this.lines,
    required this.quantities,
    required this.onChanged,
  });

  final String farmName;
  final List<CustomerListing> lines;
  final Map<String, double> quantities;
  final void Function(CustomerListing listing, double value) onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedLines = lines
        .where((item) => (quantities[item.listing.id] ?? 0) > 0)
        .toList();

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.shopping_basket_outlined,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Your $farmName basket',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (selectedLines.isEmpty)
              Text(
                'Choose quantities once, then add the whole farm order together.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              )
            else
              ...selectedLines.map((item) {
                final quantity = quantities[item.listing.id] ?? 0;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _FarmBasketLine(
                    listing: item,
                    quantity: quantity,
                    imagePath: farmListingAsset(item),
                    canRemove: item != lines.first,
                    onChanged: (value) => onChanged(item, value),
                  ),
                );
              }),
            const SizedBox(height: 2),
            Text(
              'One checkout, one pickup conversation, one farmer relationship.',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FarmBasketLine extends StatelessWidget {
  const _FarmBasketLine({
    required this.listing,
    required this.quantity,
    required this.imagePath,
    required this.canRemove,
    required this.onChanged,
  });

  final CustomerListing listing;
  final double quantity;
  final String imagePath;
  final bool canRemove;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final title = listing.variantName(locale) ?? listing.productName(locale);
    final lineTotal = listing.listing.price * quantity;
    final isAtLimit = quantity >= listing.listing.quantity;

    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox.square(
            dimension: 52,
            child: FarmListingImage(assetPath: imagePath),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${formatListingQuantity(quantity)} of ${formatListingQuantity(listing.listing.quantity)} ${listing.listing.unit} · ${lineTotal.toStringAsFixed(2)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isAtLimit
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                  fontWeight: isAtLimit ? FontWeight.w800 : null,
                ),
              ),
            ],
          ),
        ),
        _MiniQuantityStepper(
          quantity: quantity,
          min: canRemove ? 0 : 1,
          max: listing.listing.quantity,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _MiniQuantityStepper extends StatelessWidget {
  const _MiniQuantityStepper({
    required this.quantity,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final double quantity;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canDecrease = quantity > min;
    final canIncrease = quantity < max;
    final limitLabel = quantity >= max
        ? 'Maximum ${formatListingQuantity(max)} selected'
        : 'Increase up to ${formatListingQuantity(max)}';

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
                ? () => onChanged((quantity - 1).clamp(min, max).toDouble())
                : null,
            icon: const Icon(Icons.remove_rounded),
          ),
          SizedBox(
            width: 28,
            child: Text(
              formatListingQuantity(quantity),
              textAlign: TextAlign.center,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          IconButton(
            tooltip: limitLabel,
            visualDensity: VisualDensity.compact,
            iconSize: 18,
            onPressed: canIncrease
                ? () => onChanged((quantity + 1).clamp(min, max).toDouble())
                : null,
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
    );
  }
}

class _SheetDetail extends StatelessWidget {
  const _SheetDetail({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetPill extends StatelessWidget {
  const _SheetPill({
    required this.icon,
    required this.label,
    this.background,
    this.foreground,
  });

  final IconData icon;
  final String label;
  final Color? background;
  final Color? foreground;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = background ?? theme.colorScheme.surface;
    final fg = foreground ?? theme.colorScheme.onSurface;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: bg.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: fg),
            const SizedBox(width: 5),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: fg,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckoutSummaryBar extends StatelessWidget {
  const _CheckoutSummaryBar({
    required this.selectedCount,
    required this.total,
    required this.onAddAll,
  });

  final int selectedCount;
  final double total;
  final VoidCallback? onAddAll;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    selectedCount == 0
                        ? 'No items selected'
                        : '$selectedCount selected',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    total.toStringAsFixed(2),
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            FilledButton.icon(
              onPressed: onAddAll,
              icon: const Icon(Icons.add_shopping_cart_rounded),
              label: const Text('Add all'),
            ),
          ],
        ),
      ),
    );
  }
}

class _FarmerShelfItem extends StatelessWidget {
  const _FarmerShelfItem({
    required this.listing,
    required this.quantity,
    required this.imagePath,
    required this.onChanged,
  });

  final CustomerListing listing;
  final double quantity;
  final String imagePath;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final title = listing.variantName(locale) ?? listing.productName(locale);

    return SizedBox(
      width: 152,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: FarmListingImage(assetPath: imagePath),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${listing.listing.price.toStringAsFixed(2)} / ${listing.listing.unit}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${formatListingQuantity(listing.listing.quantity)} ${listing.listing.unit} available',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: quantity >= listing.listing.quantity
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Center(
                child: _MiniQuantityStepper(
                  quantity: quantity,
                  min: 0,
                  max: listing.listing.quantity,
                  onChanged: onChanged,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
