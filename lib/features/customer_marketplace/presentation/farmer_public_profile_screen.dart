import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/widgets/farm_avatar.dart';
import '../../../core/widgets/app_image.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/loading_state.dart';
import '../../customer/presentation/cart_controller.dart';
import '../../customer/presentation/followed_farms_controller.dart';
import '../../listings/domain/product_detail_labels.dart';
import '../../social_feed/domain/feed_post.dart';
import '../../social_feed/presentation/social_feed_controller.dart';
import '../domain/customer_listing.dart';
import '../domain/farmer_public_profile.dart';
import 'customer_marketplace_controller.dart';

class FarmerPublicProfileScreen extends ConsumerStatefulWidget {
  const FarmerPublicProfileScreen({
    required this.farmerId,
    this.preview = false,
    super.key,
  });

  final String farmerId;
  final bool preview;

  @override
  ConsumerState<FarmerPublicProfileScreen> createState() =>
      _FarmerPublicProfileScreenState();
}

class _FarmerPublicProfileScreenState
    extends ConsumerState<FarmerPublicProfileScreen> {
  final Map<String, double> _selectedQuantities = {};
  bool _addingToCart = false;
  bool _cartPreviouslyHadItems = false;
  bool _restoredCartSelection = false;
  int _selectedSection = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final farmerAsync = ref.watch(farmerPublicProfileProvider(widget.farmerId));
    final listingsAsync = ref.watch(nearbyListingsProvider(locale));
    final feedState = ref.watch(socialFeedControllerProvider);
    final cartItems = ref.watch(cartControllerProvider);
    final isFollowing = ref.watch(
      followedFarmsProvider.select((ids) => ids.contains(widget.farmerId)),
    );

    if (!_restoredCartSelection) {
      _restoredCartSelection = true;
      for (final item in cartItems) {
        if (item.listing.farmer.id == widget.farmerId) {
          _selectedQuantities[item.listing.listing.id] = item.quantity;
        }
      }
    }
    if (_cartPreviouslyHadItems && cartItems.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && ref.read(cartControllerProvider).isEmpty) {
          setState(_selectedQuantities.clear);
        }
      });
    }
    _cartPreviouslyHadItems = cartItems.isNotEmpty;

    return Scaffold(
      body: farmerAsync.when(
        loading: () => LoadingState(message: l10n.loadingFarmMessage),
        error: (_, _) => ErrorState(
          title: l10n.farmOpenErrorTitle,
          message: l10n.genericErrorMessage,
        ),
        data: (farmer) {
          if (farmer == null) {
            return ErrorState(
              title: l10n.farmNotFoundTitle,
              message: l10n.farmerNotFoundMessage,
            );
          }
          final listings =
              listingsAsync.valueOrNull
                  ?.where((item) => item.farmer.id == widget.farmerId)
                  .toList() ??
              const <CustomerListing>[];
          final nearestListing = listings.isEmpty ? null : listings.first;
          final farmPosts = feedState.posts
              .where(
                (post) =>
                    post.authorId == farmer.id ||
                    post.authorName == farmer.farmName,
              )
              .toList();

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 230,
                pinned: true,
                leading: IconButton.filledTonal(
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go(
                        widget.preview
                            ? AppRoutes.farmerDashboard
                            : AppRoutes.customerHome,
                      );
                    }
                  },
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                actions: [
                  IconButton.filledTonal(
                    tooltip: l10n.shareFarmTooltip,
                    onPressed: () => SharePlus.instance.share(
                      ShareParams(
                        subject: farmer.farmName,
                        text:
                            'Order fresh produce from ${farmer.farmName}: https://freshfarm.app/${farmer.id}',
                      ),
                    ),
                    icon: const Icon(Icons.ios_share_rounded),
                  ),
                  const SizedBox(width: 12),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      AppImage(
                        farmer.coverPhotoPlaceholder ??
                            'assets/images/home/hero_market.png',
                        fit: BoxFit.cover,
                      ),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Color(0xCC142119)],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 820),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        20,
                        0,
                        20,
                        _selectedQuantities.isEmpty ? 36 : 130,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              FarmAvatar(
                                farmName: farmer.farmName,
                                radius: 34,
                                photo: farmer.profilePhotoPlaceholder,
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      farmer.farmName,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w900,
                                          ),
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        Text(
                                          nearestListing == null
                                              ? 'Distance unavailable'
                                              : '${nearestListing.distanceKm.toStringAsFixed(1)} km away',
                                        ),
                                        if (nearestListing != null) ...[
                                          const SizedBox(width: 10),
                                          InkWell(
                                            onTap: () => _openDirections(
                                              nearestListing.listing.latitude,
                                              nearestListing.listing.longitude,
                                            ),
                                            child: const Text(
                                              'Directions',
                                              style: TextStyle(
                                                color: Color(0xFF2F6B45),
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              _FollowButton(
                                isFollowing: isFollowing,
                                onPressed: widget.preview
                                    ? null
                                    : _toggleFollow,
                              ),
                            ],
                          ),
                          if (widget.preview) ...[
                            const SizedBox(height: 14),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.secondaryContainer,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.visibility_outlined, size: 18),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Farm page preview',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          if (farmer.pickupAvailable &&
                              (farmer.pickupNote?.trim().isNotEmpty ??
                                  false)) ...[
                            const SizedBox(height: 10),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.info_outline_rounded,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Pickup note: ${farmer.pickupNote!}',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 18),
                          Text(
                            farmer.shortDescription,
                            style: Theme.of(
                              context,
                            ).textTheme.bodyLarge?.copyWith(height: 1.4),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(
                                farmer.pickupAvailable
                                    ? Icons.storefront_outlined
                                    : Icons.local_shipping_outlined,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                farmer.pickupAvailable
                                    ? 'Farm pickup available · Courier delivery available'
                                    : 'Courier delivery available',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          _FarmProfileTabs(
                            selected: _selectedSection,
                            onChanged: (value) =>
                                setState(() => _selectedSection = value),
                          ),
                          const SizedBox(height: 18),
                          if (_selectedSection == 0) ...[
                            Row(
                              children: [
                                Text(
                                  'Hot sales',
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(fontWeight: FontWeight.w900),
                                ),
                                const Spacer(),
                                Text(l10n.availableCountLabel(listings.length)),
                              ],
                            ),
                            const SizedBox(height: 14),
                            if (listingsAsync.isLoading)
                              const LinearProgressIndicator()
                            else if (listings.isEmpty)
                              const _NoProduceCard()
                            else
                              ...listings.map(
                                (listing) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _OrderProductCard(
                                    listing: listing,
                                    locale: locale,
                                    selected:
                                        !widget.preview &&
                                        _selectedQuantities.containsKey(
                                          listing.listing.id,
                                        ),
                                    quantity:
                                        _selectedQuantities[listing
                                            .listing
                                            .id] ??
                                        0,
                                    onDecrease: widget.preview
                                        ? null
                                        : () => _decreaseQuantity(listing),
                                    onIncrease: widget.preview
                                        ? null
                                        : () => _increaseQuantity(listing),
                                  ),
                                ),
                              ),
                          ] else if (_selectedSection == 1)
                            _FarmWallSection(posts: farmPosts)
                          else
                            _FarmAboutSection(
                              farmer: farmer,
                              nearestListing: nearestListing,
                              onDirections: nearestListing == null
                                  ? null
                                  : () => _openDirections(
                                      nearestListing.listing.latitude,
                                      nearestListing.listing.longitude,
                                    ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: widget.preview
          ? null
          : _buildOrderBar(listingsAsync.valueOrNull),
    );
  }

  Widget? _buildOrderBar(List<CustomerListing>? allListings) {
    final l10n = AppLocalizations.of(context);
    final listings = allListings
        ?.where((item) => item.farmer.id == widget.farmerId)
        .toList();
    final selected = (listings ?? const <CustomerListing>[])
        .where((listing) => _selectedQuantities.containsKey(listing.listing.id))
        .toList();
    if (selected.isEmpty) return null;
    final total = selected.fold<double>(0, (sum, listing) {
      return sum +
          listing.listing.price *
              (_selectedQuantities[listing.listing.id] ?? 1);
    });
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: const [
            BoxShadow(color: Color(0x22000000), blurRadius: 18),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${selected.length} ${selected.length == 1 ? 'product' : 'products'} selected',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    '€${total.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            FilledButton(
              onPressed: _addingToCart ? null : () => _addToCart(selected),
              child: _addingToCart
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.addToCartLabel),
            ),
          ],
        ),
      ),
    );
  }

  void _addToCart(List<CustomerListing> listings) {
    setState(() => _addingToCart = true);
    final cart = ref.read(cartControllerProvider.notifier);
    for (final listing in listings) {
      cart.set(listing, _selectedQuantities[listing.listing.id] ?? 1);
    }
    HapticFeedback.mediumImpact();
    setState(() => _addingToCart = false);
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context).addedToCartMessage(listings.length),
        ),
        action: SnackBarAction(
          label: AppLocalizations.of(context).viewCartLabel,
          onPressed: () => context.go(AppRoutes.customerDeals),
        ),
      ),
    );
  }

  void _increaseQuantity(CustomerListing listing) {
    final available = listing.listing.quantity;
    final current = _selectedQuantities[listing.listing.id] ?? 0;
    if (current >= available) {
      HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Only ${_formatQuantity(available)} ${listing.listing.unit} available.',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }
    HapticFeedback.selectionClick();
    setState(() {
      _selectedQuantities[listing.listing.id] = (current + 1)
          .clamp(1, available)
          .toDouble();
    });
  }

  void _decreaseQuantity(CustomerListing listing) {
    final id = listing.listing.id;
    final current = _selectedQuantities[id] ?? 0;
    if (current <= 0) return;
    HapticFeedback.selectionClick();
    setState(() {
      if (current <= 1) {
        _selectedQuantities.remove(id);
        ref.read(cartControllerProvider.notifier).remove(id);
      } else {
        _selectedQuantities[id] = current - 1;
      }
    });
  }

  void _toggleFollow() {
    HapticFeedback.selectionClick();
    ref.read(followedFarmsProvider.notifier).toggle(widget.farmerId);
    final nowFollowing = ref
        .read(followedFarmsProvider)
        .contains(widget.farmerId);
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          nowFollowing
              ? 'Following this farm. You will see its new produce.'
              : 'You are no longer following this farm.',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _openDirections(double latitude, double longitude) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  static String _formatQuantity(double value) =>
      value.toStringAsFixed(value % 1 == 0 ? 0 : 1);
}

class _FollowButton extends StatelessWidget {
  const _FollowButton({required this.isFollowing, required this.onPressed});

  final bool isFollowing;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (isFollowing) {
      return OutlinedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.check_rounded, size: 18),
        label: Text(l10n.followingLabel),
      );
    }
    return FilledButton.tonal(
      onPressed: onPressed,
      child: Text(l10n.followLabel),
    );
  }
}

class _FarmProfileTabs extends StatelessWidget {
  const _FarmProfileTabs({required this.selected, required this.onChanged});

  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<int>(
      showSelectedIcon: false,
      segments: const [
        ButtonSegment(
          value: 0,
          icon: Icon(Icons.storefront_outlined),
          label: Text('Hot sales'),
        ),
        ButtonSegment(
          value: 1,
          icon: Icon(Icons.dynamic_feed_outlined),
          label: Text('Feed'),
        ),
        ButtonSegment(
          value: 2,
          icon: Icon(Icons.info_outline_rounded),
          label: Text('Info'),
        ),
      ],
      selected: {selected},
      onSelectionChanged: (values) => onChanged(values.first),
    );
  }
}

class _FarmWallSection extends StatelessWidget {
  const _FarmWallSection({required this.posts});

  final List<FeedPost> posts;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (posts.isEmpty) {
      return const _QuietInfoCard(
        icon: Icons.dynamic_feed_outlined,
        title: 'No wall posts yet',
        body: 'New farm updates, pre-orders, and photo posts will appear here.',
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Farm feed',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 12),
        ...posts.map(
          (post) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Material(
              color: theme.colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () =>
                    context.push(AppRoutes.customerCommunityPost(post.id)),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          FarmAvatar(farmName: post.authorName, radius: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              post.authorName,
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          Text(
                            _compactDate(post.createdAt),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        post.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(post.description),
                      if (post.photos.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: AppImage(
                            post.photos.first,
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        if (post.photos.length > 1) ...[
                          const SizedBox(height: 6),
                          Text(
                            '+${post.photos.length - 1} more photos',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ],
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${post.comments.length} comments · ${post.offers.length} offers',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.mode_comment_outlined,
                            size: 18,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Open and comment',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  static String _compactDate(DateTime value) {
    final now = DateTime.now();
    final diff = now.difference(value);
    if (diff.inHours < 1) return '${diff.inMinutes.clamp(1, 59)}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${value.day}.${value.month}.${value.year}';
  }
}

class _FarmAboutSection extends StatelessWidget {
  const _FarmAboutSection({
    required this.farmer,
    required this.nearestListing,
    required this.onDirections,
  });

  final FarmerPublicProfile farmer;
  final CustomerListing? nearestListing;
  final VoidCallback? onDirections;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _QuietInfoCard(
          icon: Icons.eco_outlined,
          title: 'About ${farmer.farmName}',
          body: farmer.shortDescription,
        ),
        const SizedBox(height: 12),
        _QuietInfoCard(
          icon: farmer.pickupAvailable
              ? Icons.storefront_outlined
              : Icons.local_shipping_outlined,
          title: 'Pickup and delivery',
          body: farmer.pickupAvailable
              ? farmer.pickupNote ??
                    'Farm pickup and courier delivery are available.'
              : 'Courier delivery is available.',
        ),
        const SizedBox(height: 12),
        _QuietInfoCard(
          icon: Icons.place_outlined,
          title: farmer.approximateLocation,
          body: nearestListing == null
              ? 'Distance is unavailable.'
              : '${nearestListing!.distanceKm.toStringAsFixed(1)} km away.',
          actionLabel: nearestListing == null ? null : 'Directions',
          onAction: onDirections,
        ),
        const SizedBox(height: 12),
        _QuietInfoCard(
          icon: Icons.star_rounded,
          title: farmer.reviewCount == 0
              ? 'New farm'
              : '${farmer.rating.toStringAsFixed(1)} rating',
          body: '${farmer.reviewCount} customer reviews',
        ),
      ],
    );
  }
}

class _QuietInfoCard extends StatelessWidget {
  const _QuietInfoCard({
    required this.icon,
    required this.title,
    required this.body,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String body;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(body),
                if (actionLabel != null && onAction != null) ...[
                  const SizedBox(height: 8),
                  TextButton(onPressed: onAction, child: Text(actionLabel!)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderProductCard extends StatelessWidget {
  const _OrderProductCard({
    required this.listing,
    required this.locale,
    required this.selected,
    required this.quantity,
    required this.onDecrease,
    required this.onIncrease,
  });

  final CustomerListing listing;
  final String locale;
  final bool selected;
  final double quantity;
  final VoidCallback? onDecrease;
  final VoidCallback? onIncrease;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final item = listing.listing;
    final detailLabels = productDetailLabels(item.categoryId);
    final asset = switch (item.productId) {
      'product-potato' => 'assets/images/home/potatoes.png',
      'product-tomato' => 'assets/images/home/tomatoes.png',
      _ => item.photoPlaceholder ?? 'assets/images/home/vegetables.png',
    };
    return Material(
      color: selected
          ? theme.colorScheme.primaryContainer.withValues(alpha: 0.32)
          : theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: selected
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: AppImage(
                    asset,
                    width: 78,
                    height: 78,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        listing.variantName(locale) ??
                            listing.productName(locale),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '€${item.price.toStringAsFixed(2)} per ${item.unit}',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: const Color(0xFF2F6B45),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        '${_FarmerPublicProfileScreenState._formatQuantity(item.quantity)} ${item.unit} available',
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(height: 7),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          if (listing.farmer.pickupAvailable)
                            const _SmallFulfillmentLabel(
                              icon: Icons.storefront_outlined,
                              text: 'Pickup',
                            ),
                          const _SmallFulfillmentLabel(
                            icon: Icons.local_shipping_outlined,
                            text: 'Delivery',
                          ),
                        ],
                      ),
                      if (item.description.trim().isNotEmpty) ...[
                        const SizedBox(height: 7),
                        Text(
                          item.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                      if (item.farmingMethod?.trim().isNotEmpty ?? false) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.eco_outlined, size: 15),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                item.farmingMethod!,
                                style: theme.textTheme.labelMedium,
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (item.harvestDate != null) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today_outlined, size: 14),
                            const SizedBox(width: 5),
                            Text(
                              '${item.harvestDate!.isAfter(DateTime.now()) ? detailLabels.futureDate : detailLabels.pastDate} ${DateFormat('d MMM').format(item.harvestDate!)}',
                              style: theme.textTheme.labelMedium,
                            ),
                          ],
                        ),
                      ],
                      if (item.bestBeforeDate != null) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(
                              Icons.event_available_outlined,
                              size: 14,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'Best before ${DateFormat('d MMM').format(item.bestBeforeDate!)}',
                              style: theme.textTheme.labelMedium,
                            ),
                          ],
                        ),
                      ],
                      if (item.storageInstructions?.trim().isNotEmpty ??
                          false) ...[
                        const SizedBox(height: 6),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.ac_unit_outlined, size: 14),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                item.storageInstructions!,
                                style: theme.textTheme.labelMedium,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  AppLocalizations.of(context).quantityLabel,
                  style: theme.textTheme.labelLarge,
                ),
                const Spacer(),
                IconButton.filledTonal(
                  key: ValueKey('customer-decrease-${item.id}'),
                  onPressed: quantity <= 0 ? null : onDecrease,
                  icon: const Icon(Icons.remove_rounded),
                ),
                SizedBox(
                  width: 78,
                  child: Text(
                    '${_FarmerPublicProfileScreenState._formatQuantity(quantity)} ${item.unit}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
                IconButton.filledTonal(
                  key: ValueKey('customer-increase-${item.id}'),
                  tooltip: quantity >= item.quantity
                      ? 'Maximum available quantity selected'
                      : 'Add one ${item.unit}',
                  onPressed: onIncrease,
                  icon: const Icon(Icons.add_rounded),
                ),
              ],
            ),
            if (selected) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    '${_FarmerPublicProfileScreenState._formatQuantity(quantity)} ${item.unit} × €${item.price.toStringAsFixed(2)}',
                    style: theme.textTheme.bodySmall,
                  ),
                  const Spacer(),
                  Text(
                    '€${(quantity * item.price).toStringAsFixed(2)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SmallFulfillmentLabel extends StatelessWidget {
  const _SmallFulfillmentLabel({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13),
          const SizedBox(width: 4),
          Text(text, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}

class _NoProduceCard extends StatelessWidget {
  const _NoProduceCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(AppLocalizations.of(context).nextHarvestMessage),
    );
  }
}
