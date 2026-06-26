import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/location/marketplace_location.dart';
import '../../../core/location/marketplace_location_controller.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/loading_state.dart';
import '../../../core/widgets/farm_avatar.dart';
import '../../customer_marketplace/domain/customer_listing.dart';
import '../../customer_marketplace/presentation/customer_marketplace_controller.dart';
import '../../listings/domain/product_detail_labels.dart';
import '../../social_feed/presentation/social_feed_screen.dart';
import 'cart_controller.dart';
import 'followed_farms_controller.dart';

class CustomerHomeScreen extends ConsumerStatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  ConsumerState<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends ConsumerState<CustomerHomeScreen> {
  bool _isLocationSheetOpen = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final listings = ref.watch(nearbyListingsProvider(locale));
    final locationState = ref.watch(marketplaceLocationControllerProvider);
    final followedFarmIds = ref.watch(followedFarmsProvider);

    ref.listen(marketplaceLocationControllerProvider, (previous, next) {
      _maybeShowLocationConfirmation(next);
    });
    _maybeShowLocationConfirmation(locationState);

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

            final followedProducts = items
                .where((item) => followedFarmIds.contains(item.farmer.id))
                .toList();
            final meatProducts = items
                .where((item) => item.listing.categoryId == 'category-meat')
                .toList();
            return CustomScrollView(
              slivers: [
                const SliverToBoxAdapter(child: SizedBox(height: 12)),
                const SliverToBoxAdapter(child: CustomerActiveOffersStrip()),
                SliverToBoxAdapter(
                  child: _HomeMapToggleCard(
                    location: locationState.displayLocation.displayName,
                    onOpenMap: () => context.go(AppRoutes.customerMap),
                    onOpenSearch: () => context.go(AppRoutes.customerSearch),
                  ),
                ),
                SliverToBoxAdapter(
                  child: _HorizontalCategorySection(
                    categories: [
                      _HomeCategory(
                        categoryId: 'category-meat',
                        label: l10n.categoryMeat,
                        emoji: '🥩',
                        emojiBackground: const Color(0xFFFFF4EE),
                        color: const Color(0xFFFFE0D6),
                      ),
                      _HomeCategory(
                        categoryId: 'category-fish',
                        label: l10n.categoryFish,
                        emoji: '🐟',
                        emojiBackground: const Color(0xFFF1FBFF),
                        color: const Color(0xFFD9F1FF),
                      ),
                      _HomeCategory(
                        categoryId: 'category-bakery',
                        label: l10n.categoryBakery,
                        emoji: '🥖',
                        emojiBackground: const Color(0xFFFFF7E3),
                        color: const Color(0xFFFFE8B7),
                      ),
                      _HomeCategory(
                        categoryId: 'category-vegetables',
                        label: l10n.categoryVegetables,
                        emoji: '🥦',
                        emojiBackground: const Color(0xFFF1FBEA),
                        color: const Color(0xFFDFF4D7),
                      ),
                      _HomeCategory(
                        categoryId: 'category-fruits',
                        label: l10n.categoryFruits,
                        emoji: '🍎',
                        emojiBackground: const Color(0xFFFFF3D8),
                        color: const Color(0xFFFFE2A8),
                      ),
                      _HomeCategory(
                        categoryId: 'category-dairy',
                        label: l10n.categoryDairy,
                        emoji: '🧈',
                        emojiBackground: const Color(0xFFF6F7FF),
                        color: const Color(0xFFE5E9FF),
                      ),
                      _HomeCategory(
                        categoryId: 'category-eggs',
                        label: l10n.categoryEggs,
                        emoji: '🥚',
                        emojiBackground: const Color(0xFFFFF9E8),
                        color: const Color(0xFFFFF1C8),
                      ),
                      _HomeCategory(
                        categoryId: 'category-honey',
                        label: l10n.categoryHoney,
                        emoji: '🍯',
                        emojiBackground: const Color(0xFFFFF2CC),
                        color: const Color(0xFFFFE3A3),
                      ),
                      _HomeCategory(
                        categoryId: 'category-cheese',
                        label: l10n.categoryCheese,
                        emoji: '🧀',
                        emojiBackground: const Color(0xFFFFF8CF),
                        color: const Color(0xFFFFF0A8),
                      ),
                      _HomeCategory(
                        categoryId: 'category-milk',
                        label: l10n.categoryMilk,
                        emoji: '🥛',
                        emojiBackground: const Color(0xFFF7FBFF),
                        color: const Color(0xFFEAF4FF),
                      ),
                      _HomeCategory(
                        categoryId: 'category-herbs',
                        label: l10n.categoryHerbs,
                        emoji: '🌿',
                        emojiBackground: const Color(0xFFF0FFF2),
                        color: const Color(0xFFDDF6DF),
                      ),
                      _HomeCategory(
                        categoryId: 'category-mushrooms',
                        label: l10n.categoryMushrooms,
                        emoji: '🍄',
                        emojiBackground: const Color(0xFFF5EFE8),
                        color: const Color(0xFFE8DED5),
                      ),
                      _HomeCategory(
                        categoryId: 'category-berries',
                        label: l10n.categoryBerries,
                        emoji: '🫐',
                        emojiBackground: const Color(0xFFFFEFF7),
                        color: const Color(0xFFF4D8EA),
                      ),
                      _HomeCategory(
                        categoryId: 'category-flowers',
                        label: l10n.categoryFlowers,
                        emoji: '💐',
                        emojiBackground: const Color(0xFFFFF1F8),
                        color: const Color(0xFFFFE0EF),
                      ),
                      _HomeCategory(
                        categoryId: 'category-drinks',
                        label: l10n.categoryJuice,
                        emoji: '🧃',
                        emojiBackground: const Color(0xFFFFF0DF),
                        color: const Color(0xFFFFDDB5),
                      ),
                      _HomeCategory(
                        categoryId: 'category-preserves',
                        label: l10n.categoryPreserves,
                        emoji: '🫙',
                        emojiBackground: const Color(0xFFF2FAF4),
                        color: const Color(0xFFE4F0E8),
                      ),
                      _HomeCategory(
                        categoryId: 'category-grains',
                        label: l10n.categoryGrains,
                        emoji: '🌾',
                        emojiBackground: const Color(0xFFFFF8EA),
                        color: const Color(0xFFFFEBC7),
                      ),
                      _HomeCategory(
                        categoryId: 'category-prepared-food',
                        label: l10n.categoryReadyMeals,
                        emoji: '🍲',
                        emojiBackground: const Color(0xFFF6F2FF),
                        color: const Color(0xFFE7E1FF),
                      ),
                      _HomeCategory(
                        categoryId: 'category-organic',
                        label: l10n.categoryOrganic,
                        emoji: '🌱',
                        emojiBackground: const Color(0xFFF1FFE9),
                        color: const Color(0xFFD8F3C8),
                      ),
                    ],
                    onTap: (category) {
                      if (category.categoryId == 'category-meat' &&
                          meatProducts.isNotEmpty) {
                        _showBuyingSheet(meatProducts.first, items);
                        return;
                      }
                      context.go(AppRoutes.customerSearch);
                    },
                  ),
                ),
                SliverToBoxAdapter(
                  child: _ListingRail(
                    title: 'Hot sales near you',
                    listings: items,
                    onSeeAll: () => context.go(AppRoutes.customerSearch),
                    onTap: (listing) => _showBuyingSheet(listing, items),
                  ),
                ),
                if (followedProducts.isNotEmpty)
                  SliverToBoxAdapter(
                    child: _ListingRail(
                      title: 'From farms you follow',
                      listings: followedProducts,
                      onSeeAll: () => context.go(AppRoutes.customerCommunity),
                      onTap: (listing) => _showBuyingSheet(listing, items),
                    ),
                  ),
                SliverToBoxAdapter(
                  child: _UpcomingNearYouSection(
                    events: const [
                      _UpcomingEvent(
                        title: 'Saturday farm market',
                        farmName: 'North Field Farm',
                        timeLabel: 'Sat 10:00-14:00',
                        locationLabel: 'Vaasa market square',
                        icon: Icons.storefront_outlined,
                      ),
                      _UpcomingEvent(
                        title: 'Strawberry picking weekend',
                        farmName: 'Berry Hill Farm',
                        timeLabel: 'Tomorrow',
                        locationLabel: '7.4 km away',
                        icon: Icons.event_available_outlined,
                      ),
                      _UpcomingEvent(
                        title: 'Fresh bread pickup',
                        farmName: 'North Bakery Farm',
                        timeLabel: 'Today 17:00',
                        locationLabel: 'Palosaari pickup',
                        icon: Icons.bakery_dining_outlined,
                      ),
                    ],
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 112)),
              ],
            );
          },
        ),
      ),
    );
  }

  void _maybeShowLocationConfirmation(MarketplaceLocationState state) {
    if (!state.shouldConfirmDetectedLocation || _isLocationSheetOpen) {
      return;
    }

    _isLocationSheetOpen = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _showLocationConfirmation(state.displayLocation);
      }
    });
  }

  Future<void> _showLocationConfirmation(MarketplaceLocation location) async {
    final l10n = AppLocalizations.of(context);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 36,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.confirmLocationTitle,
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.confirmLocationMessage(location.displayName),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () async {
                      await ref
                          .read(marketplaceLocationControllerProvider.notifier)
                          .confirmDetectedLocation();
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                    child: Text(l10n.useThisLocationButton),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      ref
                          .read(marketplaceLocationControllerProvider.notifier)
                          .markConfirmationAsked();
                      Navigator.of(context).pop();
                      _showLocationSearch();
                    },
                    child: Text(l10n.enterAnotherLocationButton),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (mounted) {
      _isLocationSheetOpen = false;
      final currentState = ref.read(marketplaceLocationControllerProvider);
      if (currentState.shouldConfirmDetectedLocation) {
        ref
            .read(marketplaceLocationControllerProvider.notifier)
            .markConfirmationAsked();
      }
    }
  }

  Future<void> _showLocationSearch() async {
    _isLocationSheetOpen = true;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => const _LocationSearchSheet(),
    );
    if (mounted) {
      _isLocationSheetOpen = false;
    }
  }

  Future<void> _showBuyingSheet(
    CustomerListing listing,
    List<CustomerListing> allListings,
  ) {
    final farmerListings = allListings
        .where(
          (item) =>
              item.farmer.id == listing.farmer.id &&
              item.listing.id != listing.listing.id,
        )
        .toList();

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (context) {
        return _HotSaleBuyingSheet(
          listing: listing,
          farmerListings: farmerListings,
        );
      },
    );
  }
}

class _HomeMapToggleCard extends StatelessWidget {
  const _HomeMapToggleCard({
    required this.location,
    required this.onOpenMap,
    required this.onOpenSearch,
  });

  final String location;
  final VoidCallback onOpenMap;
  final VoidCallback onOpenSearch;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                SegmentedButton<int>(
                  segments: const [
                    ButtonSegment(
                      value: 0,
                      icon: Icon(Icons.view_agenda_outlined, size: 18),
                      label: Text('List'),
                    ),
                    ButtonSegment(
                      value: 1,
                      icon: Icon(Icons.map_outlined, size: 18),
                      label: Text('Map'),
                    ),
                  ],
                  selected: const {0},
                  showSelectedIcon: false,
                  style: const ButtonStyle(
                    visualDensity: VisualDensity.compact,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onSelectionChanged: (value) {
                    if (value.first == 1) onOpenMap();
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Browse nearby farms as cards, or switch to the map when distance matters.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                TextButton.icon(
                  onPressed: onOpenSearch,
                  icon: const Icon(Icons.search_rounded),
                  label: const Text('Browse'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationSearchSheet extends ConsumerStatefulWidget {
  const _LocationSearchSheet();

  @override
  ConsumerState<_LocationSearchSheet> createState() =>
      _LocationSearchSheetState();
}

class _LocationSearchSheetState extends ConsumerState<_LocationSearchSheet> {
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
    final controller = ref.read(marketplaceLocationControllerProvider.notifier);
    final suggestions = controller.searchSuggestions(_query);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          bottom: MediaQuery.viewInsetsOf(context).bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.locationSearchTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: l10n.locationSearchHint,
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: (value) => setState(() => _query = value),
            ),
            const SizedBox(height: 16),
            if (suggestions.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(child: Text(l10n.noLocationResultsTitle)),
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: suggestions.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final location = suggestions[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.location_city_outlined),
                      title: Text(location.city),
                      subtitle: Text('${location.region}, ${location.country}'),
                      onTap: () async {
                        await ref
                            .read(
                              marketplaceLocationControllerProvider.notifier,
                            )
                            .selectLocation(location);
                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _HorizontalCategorySection extends StatefulWidget {
  const _HorizontalCategorySection({
    required this.categories,
    required this.onTap,
  });

  final List<_HomeCategory> categories;
  final ValueChanged<_HomeCategory> onTap;

  @override
  State<_HorizontalCategorySection> createState() =>
      _HorizontalCategorySectionState();
}

class _HorizontalCategorySectionState
    extends State<_HorizontalCategorySection> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final railHeight = _homeCategoryRailHeight(context);
    final imageHeight = _homeCategoryImageHeight(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: railHeight,
          child: Listener(
            onPointerSignal: _handlePointerSignal,
            child: ListView.separated(
              controller: _scrollController,
              primary: false,
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsetsDirectional.only(start: 20, end: 160),
              scrollDirection: Axis.horizontal,
              itemCount: widget.categories.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final category = widget.categories[index];
                return _CategoryTile(
                  category: category,
                  imageHeight: imageHeight,
                  onTap: () => widget.onTap(category),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  void _handlePointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent || !_scrollController.hasClients) {
      return;
    }

    final delta = event.scrollDelta.dx.abs() > event.scrollDelta.dy.abs()
        ? event.scrollDelta.dx
        : event.scrollDelta.dy;

    if (delta == 0) {
      return;
    }

    GestureBinding.instance.pointerSignalResolver.register(event, (_) {
      final position = _scrollController.position;
      final target = (position.pixels + delta).clamp(
        position.minScrollExtent,
        position.maxScrollExtent,
      );
      _scrollController.jumpTo(target.toDouble());
    });
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.category,
    required this.imageHeight,
    required this.onTap,
  });

  final _HomeCategory category;
  final double imageHeight;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: SizedBox(
        width: 118,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: category.color,
                borderRadius: BorderRadius.circular(22),
              ),
              child: SizedBox(
                height: imageHeight,
                width: 118,
                child: Center(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: category.emojiBackground,
                      shape: BoxShape.circle,
                    ),
                    child: SizedBox.square(
                      dimension: 62,
                      child: Center(
                        child: Text(
                          category.emoji,
                          style: const TextStyle(
                            fontSize: 34,
                            height: 1,
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              category.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelLarge,
            ),
          ],
        ),
      ),
    );
  }
}

double _homeCategoryRailHeight(BuildContext context) {
  final textScale = MediaQuery.textScalerOf(context).scale(1);
  final extraHeight = ((textScale - 1) * 56).clamp(0, 56).toDouble();
  return 142 + extraHeight;
}

double _homeCategoryImageHeight(BuildContext context) {
  final textScale = MediaQuery.textScalerOf(context).scale(1);
  final compactAmount = ((textScale - 1) * 18).clamp(0, 14).toDouble();
  return 88 - compactAmount;
}

class _ListingRail extends StatelessWidget {
  const _ListingRail({
    required this.title,
    required this.listings,
    required this.onSeeAll,
    required this.onTap,
  });

  final String title;
  final List<CustomerListing> listings;
  final VoidCallback onSeeAll;
  final ValueChanged<CustomerListing> onTap;

  @override
  Widget build(BuildContext context) {
    if (listings.isEmpty) {
      return const SizedBox.shrink();
    }

    final railHeight = _homeListingRailHeight(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: title, action: onSeeAll),
        SizedBox(
          height: railHeight,
          child: ListView.separated(
            primary: false,
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsetsDirectional.only(start: 20, end: 120),
            scrollDirection: Axis.horizontal,
            itemCount: listings.length,
            separatorBuilder: (_, _) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final listing = listings[index];
              return _HomeListingCard(
                listing: listing,
                imageHeight: _homeListingImageHeight(context),
                onTap: () => onTap(listing),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _HomeListingCard extends StatelessWidget {
  const _HomeListingCard({
    required this.listing,
    required this.imageHeight,
    required this.onTap,
  });

  final CustomerListing listing;
  final double imageHeight;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final variantName = listing.variantName(locale);
    final detailLabels = productDetailLabels(listing.listing.categoryId);

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: SizedBox(
        width: 324,
        child: Card(
          margin: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          elevation: 0,
          color: theme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: theme.colorScheme.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  SizedBox(
                    height: imageHeight,
                    width: double.infinity,
                    child: _HomeImage(assetPath: _assetForListing(listing)),
                  ),
                  PositionedDirectional(
                    top: 12,
                    start: 12,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        child: Text(
                          '${listing.listing.price.toStringAsFixed(2)} / ${listing.listing.unit}',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onSecondaryContainer,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      variantName ?? listing.productName(locale),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (listing.listing.harvestDate != null) ...[
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined, size: 14),
                          const SizedBox(width: 5),
                          Text(
                            '${listing.listing.harvestDate!.isAfter(DateTime.now()) ? detailLabels.futureDate : detailLabels.pastDate} ${DateFormat('d MMM').format(listing.listing.harvestDate!)}',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 4),
                    InkWell(
                      onTap: () => context.go(
                        AppRoutes.farmerPublicProfile(listing.farmer.id),
                      ),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          children: [
                            FarmAvatar(
                              farmName: listing.farmer.farmName,
                              radius: 12,
                              photo: listing.farmer.profilePhotoPlaceholder,
                            ),
                            const SizedBox(width: 7),
                            Expanded(
                              child: Text(
                                listing.farmer.farmName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const Icon(Icons.chevron_right_rounded, size: 18),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const _DottedDivider(),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _ListingMetaChip(
                            icon: Icons.location_on_outlined,
                            label:
                                '${listing.distanceKm.toStringAsFixed(1)} ${l10n.kilometersAwayLabel}',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _ListingMetaChip(
                            icon: Icons.star_rounded,
                            iconColor: Colors.amber.shade700,
                            label: listing.farmer.reviewCount == 0
                                ? l10n.newFarmLabel
                                : listing.farmer.rating.toStringAsFixed(1),
                          ),
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

  String _assetForListing(CustomerListing listing) {
    switch (listing.listing.productId) {
      case 'product-potato':
        return 'assets/images/home/potatoes.png';
      case 'product-tomato':
        return 'assets/images/home/tomatoes.png';
      case 'product-honey':
        return 'assets/images/home/honey_jar.png';
      case 'product-lamb':
      case 'product-beef':
      case 'product-pork':
      case 'product-minced-meat':
        return 'assets/images/home/meat_hot_sale.png';
      case 'product-apple':
        return 'assets/images/home/fruits.png';
      case 'product-egg':
        return 'assets/images/home/eggs.png';
      default:
        return 'assets/images/home/vegetables.png';
    }
  }
}

double _homeListingRailHeight(BuildContext context) {
  final textScale = MediaQuery.textScalerOf(context).scale(1);
  final extraHeight = ((textScale - 1) * 96).clamp(0, 96).toDouble();
  return 316 + extraHeight;
}

double _homeListingImageHeight(BuildContext context) {
  final textScale = MediaQuery.textScalerOf(context).scale(1);
  final compactAmount = ((textScale - 1) * 24).clamp(0, 18).toDouble();
  return 154 - compactAmount;
}

class _ListingMetaChip extends StatelessWidget {
  const _ListingMetaChip({
    required this.icon,
    required this.label,
    this.iconColor,
  });

  final IconData icon;
  final String label;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 17,
          color: iconColor ?? theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _DottedDivider extends StatelessWidget {
  const _DottedDivider();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.outlineVariant;

    return SizedBox(
      height: 1,
      child: LayoutBuilder(
        builder: (context, constraints) {
          const dashWidth = 4.0;
          const dashGap = 4.0;
          final dashCount = (constraints.maxWidth / (dashWidth + dashGap))
              .floor();

          return Row(
            children: List.generate(dashCount, (_) {
              return Padding(
                padding: const EdgeInsetsDirectional.only(end: dashGap),
                child: SizedBox(
                  width: dashWidth,
                  height: 1,
                  child: DecoratedBox(decoration: BoxDecoration(color: color)),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.action});

  final String title;
  final VoidCallback? action;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          if (action != null)
            FilledButton.tonal(
              onPressed: action,
              child: Text(l10n.seeAllButton),
            ),
        ],
      ),
    );
  }
}

class _HomeImage extends StatelessWidget {
  const _HomeImage({required this.assetPath, this.fit = BoxFit.cover});

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

class _HotSaleBuyingSheet extends ConsumerStatefulWidget {
  const _HotSaleBuyingSheet({
    required this.listing,
    required this.farmerListings,
  });

  final CustomerListing listing;
  final List<CustomerListing> farmerListings;

  @override
  ConsumerState<_HotSaleBuyingSheet> createState() =>
      _HotSaleBuyingSheetState();
}

class _HotSaleBuyingSheetState extends ConsumerState<_HotSaleBuyingSheet> {
  late double _quantity;

  @override
  void initState() {
    super.initState();
    _quantity = widget.listing.listing.quantity < 1
        ? widget.listing.listing.quantity
        : 1;
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
    final total = listing.listing.price * _quantity;

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
                    _HomeImage(assetPath: _assetForListing(listing)),
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
                            '${_formatQuantity(listing.listing.quantity)} ${listing.listing.unit} left',
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
            const SizedBox(height: 12),
            _QuantityStepper(
              quantity: _quantity,
              unit: listing.listing.unit,
              max: listing.listing.quantity,
              onChanged: (value) => setState(() => _quantity = value),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      final messenger = ScaffoldMessenger.of(context);
                      final router = GoRouter.of(context);
                      ref
                          .read(cartControllerProvider.notifier)
                          .add(listing, _quantity);
                      Navigator.of(context).pop();
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            '$productName added to basket (${_formatQuantity(_quantity)} ${listing.listing.unit})',
                          ),
                          action: SnackBarAction(
                            label: 'Basket',
                            onPressed: () => router.go(AppRoutes.customerDeals),
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add_shopping_cart_rounded),
                    label: Text('Add ${total.toStringAsFixed(2)}'),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton.filledTonal(
                  tooltip: l10n.listingDetailTitle,
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.go(
                      AppRoutes.customerListingDetail(listing.listing.id),
                    );
                  },
                  icon: const Icon(Icons.open_in_new_rounded),
                ),
              ],
            ),
            if (widget.farmerListings.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                'More from ${listing.farmer.farmName}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 168,
                child: ListView.separated(
                  primary: false,
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.farmerListings.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final item = widget.farmerListings[index];
                    return _FarmerShelfItem(
                      listing: item,
                      onTap: () {
                        ref.read(cartControllerProvider.notifier).add(item, 1);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${item.variantName(locale) ?? item.productName(locale)} added to basket',
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  String _assetForListing(CustomerListing listing) {
    switch (listing.listing.productId) {
      case 'product-lamb':
      case 'product-beef':
      case 'product-pork':
      case 'product-minced-meat':
        return 'assets/images/home/meat_hot_sale.png';
      case 'product-egg':
        return 'assets/images/home/eggs.png';
      case 'product-milk':
        return 'assets/images/home/honey.png';
      case 'product-honey':
        return 'assets/images/home/honey_jar.png';
      case 'product-tomato':
        return 'assets/images/home/tomatoes.png';
      case 'product-potato':
        return 'assets/images/home/potatoes.png';
      default:
        return 'assets/images/home/vegetables.png';
    }
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

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({
    required this.quantity,
    required this.unit,
    required this.max,
    required this.onChanged,
  });

  final double quantity;
  final String unit;
  final double max;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canDecrease = quantity > 1;
    final canIncrease = quantity < max;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Quantity',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            IconButton(
              tooltip: 'Decrease',
              onPressed: canDecrease ? () => onChanged(quantity - 1) : null,
              icon: const Icon(Icons.remove_rounded),
            ),
            SizedBox(
              width: 88,
              child: Text(
                '${_formatQuantity(quantity)} $unit',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            IconButton(
              tooltip: 'Increase',
              onPressed: canIncrease ? () => onChanged(quantity + 1) : null,
              icon: const Icon(Icons.add_rounded),
            ),
          ],
        ),
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

class _FarmerShelfItem extends StatelessWidget {
  const _FarmerShelfItem({required this.listing, required this.onTap});

  final CustomerListing listing;
  final VoidCallback onTap;

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
                  child: _HomeImage(
                    assetPath: _assetForShelfListing(listing),
                    fit: BoxFit.cover,
                  ),
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
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${listing.listing.price.toStringAsFixed(2)} / ${listing.listing.unit}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  IconButton.filledTonal(
                    tooltip: 'Add to basket',
                    iconSize: 17,
                    visualDensity: VisualDensity.compact,
                    onPressed: onTap,
                    icon: const Icon(Icons.add_rounded),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _assetForShelfListing(CustomerListing listing) {
    switch (listing.listing.productId) {
      case 'product-egg':
        return 'assets/images/home/eggs.png';
      case 'product-honey':
        return 'assets/images/home/honey_jar.png';
      case 'product-tomato':
        return 'assets/images/home/tomatoes.png';
      case 'product-potato':
        return 'assets/images/home/potatoes.png';
      case 'product-lamb':
      case 'product-beef':
        return 'assets/images/home/meat_hot_sale.png';
      default:
        return 'assets/images/home/vegetables.png';
    }
  }
}

class _UpcomingEvent {
  const _UpcomingEvent({
    required this.title,
    required this.farmName,
    required this.timeLabel,
    required this.locationLabel,
    required this.icon,
  });

  final String title;
  final String farmName;
  final String timeLabel;
  final String locationLabel;
  final IconData icon;
}

class _UpcomingNearYouSection extends StatelessWidget {
  const _UpcomingNearYouSection({required this.events});

  final List<_UpcomingEvent> events;

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(title: 'Upcoming near you'),
        SizedBox(
          height: 172,
          child: ListView.separated(
            primary: false,
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsetsDirectional.only(start: 20, end: 80),
            scrollDirection: Axis.horizontal,
            itemCount: events.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return _UpcomingEventCard(event: events[index]);
            },
          ),
        ),
      ],
    );
  }
}

class _UpcomingEventCard extends StatelessWidget {
  const _UpcomingEventCard({required this.event});

  final _UpcomingEvent event;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 282,
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: theme.colorScheme.secondaryContainer,
                    child: Icon(
                      event.icon,
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
                  ),
                  const Spacer(),
                  Chip(
                    visualDensity: VisualDensity.compact,
                    label: Text(event.timeLabel),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                event.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                event.farmName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium,
              ),
              const Spacer(),
              Row(
                children: [
                  Icon(
                    Icons.place_outlined,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      event.locationLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeCategory {
  const _HomeCategory({
    required this.categoryId,
    required this.label,
    required this.emoji,
    required this.color,
    required this.emojiBackground,
  });

  final String categoryId;
  final String label;
  final String emoji;
  final Color color;
  final Color emojiBackground;
}

String _formatQuantity(double value) {
  if (value == value.roundToDouble()) {
    return value.toStringAsFixed(0);
  }
  return value.toStringAsFixed(1);
}
