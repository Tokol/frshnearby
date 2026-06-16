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
import '../../../core/widgets/app_image.dart';
import '../../../core/widgets/farm_avatar.dart';
import '../../customer_marketplace/domain/customer_listing.dart';
import '../../customer_marketplace/presentation/customer_marketplace_controller.dart';
import '../../listings/domain/product_detail_labels.dart';
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

            final justHarvested = items.take(3).toList();
            final deals = items.reversed.take(3).toList();
            final followedListings = <CustomerListing>[];
            final addedFarmIds = <String>{};
            for (final listing in items) {
              final farmerId = listing.farmer.id;
              if (followedFarmIds.contains(farmerId) &&
                  addedFarmIds.add(farmerId)) {
                followedListings.add(listing);
              }
            }

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                    child: _HomeHeader(
                      locationLabel: l10n.currentLocationLabel,
                      location: locationState.displayLocation.displayName,
                      onProfileTap: () => context.go(AppRoutes.customerProfile),
                      onLocationTap: () => _showLocationSearch(),
                      onMapTap: () => context.go(AppRoutes.customerMap),
                      onNotificationsTap: () =>
                          context.go(AppRoutes.customerMessages),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: _HorizontalCategorySection(
                    categories: [
                      _HomeCategory(
                        label: l10n.categoryMeat,
                        emoji: '🥩',
                        emojiBackground: const Color(0xFFFFF4EE),
                        color: const Color(0xFFFFE0D6),
                      ),
                      _HomeCategory(
                        label: l10n.categoryFish,
                        emoji: '🐟',
                        emojiBackground: const Color(0xFFF1FBFF),
                        color: const Color(0xFFD9F1FF),
                      ),
                      _HomeCategory(
                        label: l10n.categoryBakery,
                        emoji: '🥖',
                        emojiBackground: const Color(0xFFFFF7E3),
                        color: const Color(0xFFFFE8B7),
                      ),
                      _HomeCategory(
                        label: l10n.categoryVegetables,
                        emoji: '🥦',
                        emojiBackground: const Color(0xFFF1FBEA),
                        color: const Color(0xFFDFF4D7),
                      ),
                      _HomeCategory(
                        label: l10n.categoryFruits,
                        emoji: '🍎',
                        emojiBackground: const Color(0xFFFFF3D8),
                        color: const Color(0xFFFFE2A8),
                      ),
                      _HomeCategory(
                        label: l10n.categoryDairy,
                        emoji: '🧈',
                        emojiBackground: const Color(0xFFF6F7FF),
                        color: const Color(0xFFE5E9FF),
                      ),
                      _HomeCategory(
                        label: l10n.categoryEggs,
                        emoji: '🥚',
                        emojiBackground: const Color(0xFFFFF9E8),
                        color: const Color(0xFFFFF1C8),
                      ),
                      _HomeCategory(
                        label: l10n.categoryHoney,
                        emoji: '🍯',
                        emojiBackground: const Color(0xFFFFF2CC),
                        color: const Color(0xFFFFE3A3),
                      ),
                      _HomeCategory(
                        label: l10n.categoryCheese,
                        emoji: '🧀',
                        emojiBackground: const Color(0xFFFFF8CF),
                        color: const Color(0xFFFFF0A8),
                      ),
                      _HomeCategory(
                        label: l10n.categoryMilk,
                        emoji: '🥛',
                        emojiBackground: const Color(0xFFF7FBFF),
                        color: const Color(0xFFEAF4FF),
                      ),
                      _HomeCategory(
                        label: l10n.categoryHerbs,
                        emoji: '🌿',
                        emojiBackground: const Color(0xFFF0FFF2),
                        color: const Color(0xFFDDF6DF),
                      ),
                      _HomeCategory(
                        label: l10n.categoryMushrooms,
                        emoji: '🍄',
                        emojiBackground: const Color(0xFFF5EFE8),
                        color: const Color(0xFFE8DED5),
                      ),
                      _HomeCategory(
                        label: l10n.categoryBerries,
                        emoji: '🫐',
                        emojiBackground: const Color(0xFFFFEFF7),
                        color: const Color(0xFFF4D8EA),
                      ),
                      _HomeCategory(
                        label: l10n.categoryFlowers,
                        emoji: '💐',
                        emojiBackground: const Color(0xFFFFF1F8),
                        color: const Color(0xFFFFE0EF),
                      ),
                      _HomeCategory(
                        label: l10n.categoryJuice,
                        emoji: '🧃',
                        emojiBackground: const Color(0xFFFFF0DF),
                        color: const Color(0xFFFFDDB5),
                      ),
                      _HomeCategory(
                        label: l10n.categoryPreserves,
                        emoji: '🫙',
                        emojiBackground: const Color(0xFFF2FAF4),
                        color: const Color(0xFFE4F0E8),
                      ),
                      _HomeCategory(
                        label: l10n.categoryGrains,
                        emoji: '🌾',
                        emojiBackground: const Color(0xFFFFF8EA),
                        color: const Color(0xFFFFEBC7),
                      ),
                      _HomeCategory(
                        label: l10n.categoryReadyMeals,
                        emoji: '🍲',
                        emojiBackground: const Color(0xFFF6F2FF),
                        color: const Color(0xFFE7E1FF),
                      ),
                      _HomeCategory(
                        label: l10n.categoryOrganic,
                        emoji: '🌱',
                        emojiBackground: const Color(0xFFF1FFE9),
                        color: const Color(0xFFD8F3C8),
                      ),
                    ],
                    onTap: () => context.go(AppRoutes.customerSearch),
                  ),
                ),
                SliverToBoxAdapter(
                  child: _ListingRail(
                    title: l10n.nearbyListingsTitle,
                    listings: items,
                    onSeeAll: () => context.go(AppRoutes.customerSearch),
                    onTap: (listing) => context.go(
                      AppRoutes.customerListingDetail(listing.listing.id),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: _FollowedFarmsSection(
                    farms: followedListings,
                    allListings: items,
                    onTap: (listing) => context.go(
                      AppRoutes.farmerPublicProfile(listing.farmer.id),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: _ListingRail(
                    title: l10n.homeJustHarvestedTitle,
                    listings: justHarvested,
                    onSeeAll: () => context.go(AppRoutes.customerSearch),
                    onTap: (listing) => context.go(
                      AppRoutes.customerListingDetail(listing.listing.id),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: _ListingRail(
                    title: l10n.homeDealsTodayTitle,
                    listings: deals,
                    onSeeAll: () => context.go(AppRoutes.customerSearch),
                    onTap: (listing) => context.go(
                      AppRoutes.customerListingDetail(listing.listing.id),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: _HeroMarketCard(
                      title: l10n.homeHeroTitle,
                      subtitle: l10n.homeHeroSubtitle,
                      buttonLabel: l10n.browseTodayPicks,
                      onPressed: () => context.go(AppRoutes.customerSearch),
                    ),
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
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.locationLabel,
    required this.location,
    required this.onProfileTap,
    required this.onLocationTap,
    required this.onMapTap,
    required this.onNotificationsTap,
  });

  final String locationLabel;
  final String location;
  final VoidCallback onProfileTap;
  final VoidCallback onLocationTap;
  final VoidCallback onMapTap;
  final VoidCallback onNotificationsTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _RoundHeaderButton(
              tooltip: AppLocalizations.of(context).profileTitle,
              icon: Icons.person_outline,
              onPressed: onProfileTap,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: onLocationTap,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 10,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.expand_more, size: 20),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            _RoundHeaderButton(
              tooltip: AppLocalizations.of(context).nearbyMapTooltip,
              icon: Icons.map_outlined,
              onPressed: onMapTap,
            ),
            const SizedBox(width: 8),
            _RoundHeaderButton(
              tooltip: locationLabel,
              icon: Icons.notifications_none_rounded,
              onPressed: onNotificationsTap,
            ),
          ],
        ),
      ],
    );
  }
}

class _RoundHeaderButton extends StatelessWidget {
  const _RoundHeaderButton({
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

    return Tooltip(
      message: tooltip,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Ink(
          height: 56,
          width: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.colorScheme.surfaceContainerHighest,
          ),
          child: Icon(icon, color: theme.colorScheme.onSurface),
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

class _HeroMarketCard extends StatelessWidget {
  const _HeroMarketCard({
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.onPressed,
  });

  final String title;
  final String subtitle;
  final String buttonLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _HomeImage(
              assetPath: 'assets/images/home/hero_market.png',
              fit: BoxFit.cover,
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.05),
                    Colors.black.withValues(alpha: 0.58),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 14),
                  FilledButton(onPressed: onPressed, child: Text(buttonLabel)),
                ],
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
  final VoidCallback onTap;

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
                  onTap: widget.onTap,
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

class _FollowedFarmsSection extends StatelessWidget {
  const _FollowedFarmsSection({
    required this.farms,
    required this.allListings,
    required this.onTap,
  });

  final List<CustomerListing> farms;
  final List<CustomerListing> allListings;
  final ValueChanged<CustomerListing> onTap;

  @override
  Widget build(BuildContext context) {
    if (farms.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: AppLocalizations.of(context).farmsYouFollowTitle),
        SizedBox(
          height: 218,
          child: ListView.separated(
            primary: false,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsetsDirectional.only(start: 20, end: 80),
            itemCount: farms.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final listing = farms[index];
              final products = allListings
                  .where((item) => item.farmer.id == listing.farmer.id)
                  .take(3)
                  .map((item) => item.productName('en'))
                  .join(' · ');
              return _FollowedFarmCard(
                listing: listing,
                products: products,
                onTap: () => onTap(listing),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _FollowedFarmCard extends StatelessWidget {
  const _FollowedFarmCard({
    required this.listing,
    required this.products,
    required this.onTap,
  });

  final CustomerListing listing;
  final String products;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final farmer = listing.farmer;
    final theme = Theme.of(context);
    return SizedBox(
      width: 300,
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 96,
                width: double.infinity,
                child: AppImage(
                  farmer.coverPhotoPlaceholder ??
                      'assets/images/home/hero_market.png',
                  fit: BoxFit.cover,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FarmAvatar(
                        farmName: farmer.farmName,
                        radius: 24,
                        photo: farmer.profilePhotoPlaceholder,
                      ),
                      const SizedBox(width: 11),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              farmer.farmName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${listing.distanceKm.toStringAsFixed(1)} km away',
                              style: theme.textTheme.bodySmall,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              products,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall,
                            ),
                            const Spacer(),
                            const Text(
                              'View farm',
                              style: TextStyle(fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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

class _HomeCategory {
  const _HomeCategory({
    required this.label,
    required this.emoji,
    required this.color,
    required this.emojiBackground,
  });

  final String label;
  final String emoji;
  final Color color;
  final Color emojiBackground;
}
