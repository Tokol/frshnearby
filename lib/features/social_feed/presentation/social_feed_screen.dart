import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/utils/device_image_picker.dart';
import '../../../core/widgets/app_image.dart';
import '../../../core/widgets/farm_avatar.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../customer/presentation/payment_authorization_controller.dart';
import '../../customer/presentation/followed_farms_controller.dart';
import '../../customer_marketplace/domain/customer_listing.dart';
import '../../customer_marketplace/presentation/customer_marketplace_controller.dart';
import '../../deals/domain/deal.dart';
import '../../deals/presentation/deal_controller.dart';
import '../domain/feed_post.dart';
import 'social_feed_controller.dart';

bool _canSeeOffer({
  required FeedOffer offer,
  required FeedActorType viewerType,
  required String viewerId,
  required String viewerName,
}) {
  if (viewerType == FeedActorType.farmer) return true;
  final targetId = offer.targetCustomerId;
  if (targetId != null && targetId.trim().isNotEmpty) {
    return targetId == viewerId || offer.authorId == viewerId;
  }
  final target = offer.targetCustomerName;
  if (target == null || target.trim().isEmpty) {
    return offer.actorType == FeedActorType.farmer ||
        _samePerson(offer.authorName, viewerName);
  }
  return _samePerson(target, viewerName) ||
      _samePerson(offer.authorName, viewerName);
}

bool _samePerson(String left, String right) {
  return left.trim().toLowerCase() == right.trim().toLowerCase();
}

List<({FeedPost post, FeedOffer offer})> visiblePendingFeedOffersForConsumer(
  List<FeedPost> posts, {
  required String viewerId,
  required String viewerName,
}) {
  final result = <({FeedPost post, FeedOffer offer})>[];
  for (final post in posts) {
    if (post.isOffersFinished) continue;
    for (final offer in post.offers) {
      if (offer.status != FeedOfferStatus.pending) continue;
      if (offer.actorType != FeedActorType.farmer) continue;
      if (!_canSeeOffer(
        offer: offer,
        viewerType: FeedActorType.consumer,
        viewerId: viewerId,
        viewerName: viewerName,
      )) {
        continue;
      }
      result.add((post: post, offer: offer));
    }
  }
  return result;
}

({double amount, String unit}) _quantityParts(String value) {
  final trimmed = value.trim();
  final match = RegExp(r'^(\d+(?:[\.,]\d+)?)\s*(.*)$').firstMatch(trimmed);
  if (match == null) {
    return (amount: 1, unit: trimmed.isEmpty ? 'item' : trimmed);
  }
  final amount = double.tryParse(match.group(1)!.replaceAll(',', '.')) ?? 1;
  final unit = match.group(2)?.trim();
  return (
    amount: amount <= 0 ? 1 : amount,
    unit: unit?.isEmpty ?? true ? 'item' : unit!,
  );
}

String _feedTimestamp(DateTime value) {
  final now = DateTime.now();
  final difference = now.difference(value);
  if (difference.inMinutes < 1) return 'Just now';
  if (difference.inHours < 1) return '${difference.inMinutes}m';
  if (difference.inHours < 24) return '${difference.inHours}h';
  final minute = value.minute.toString().padLeft(2, '0');
  return '${value.day}.${value.month}.${value.year} at ${value.hour}:$minute';
}

String _originalPostTimestamp(DateTime value) {
  final minute = value.minute.toString().padLeft(2, '0');
  return 'Originally posted ${value.day}.${value.month}.${value.year} at ${value.hour}:$minute';
}

Future<void> acceptFeedOfferFromPost({
  required BuildContext context,
  required WidgetRef ref,
  required FeedPost post,
  required FeedOffer offer,
}) async {
  final fulfillment = await _showFeedFulfillmentOptions(context);
  if (fulfillment == null || !context.mounted) return;
  final method = await _showFeedPaymentOptions(context);
  if (method == null || !context.mounted) return;
  final feedOrder = ref
      .read(socialFeedControllerProvider.notifier)
      .acceptOffer(post.id, offer.id);
  final quantity = _quantityParts(feedOrder.quantity);
  final deal = await ref
      .read(dealControllerProvider.notifier)
      .createFeedOfferDeal(
        farmerId: offer.actorType == FeedActorType.farmer
            ? offer.authorId
            : post.authorId,
        farmName: feedOrder.farmerName,
        postId: post.id,
        offerId: offer.id,
        title: feedOrder.title,
        quantity: quantity.amount,
        unit: quantity.unit,
        unitPrice: feedOrder.price / quantity.amount,
        note:
            'Accepted feed offer. ${fulfillment == FulfillmentMethod.farmPickup ? 'Pickup' : 'Delivery requested'}: ${feedOrder.dateLabel}. ${offer.note}',
        fulfillmentMethod: fulfillment,
      );
  ref.read(paymentAuthorizationProvider.notifier).authorize(deal.id, method);
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        'Accepted. ${paymentMethodLabel(method)} authorized and sent to farmer orders.',
      ),
    ),
  );
}

Future<FulfillmentMethod?> _showFeedFulfillmentOptions(BuildContext context) {
  return showModalBottomSheet<FulfillmentMethod>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose fulfillment',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            const Text('Delivery fee can be confirmed from distance later.'),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.storefront_outlined),
              title: const Text('Farm pickup'),
              subtitle: const Text('Use the pickup window from the farmer.'),
              onTap: () => Navigator.pop(context, FulfillmentMethod.farmPickup),
            ),
            ListTile(
              leading: const Icon(Icons.local_shipping_outlined),
              title: const Text('Delivery'),
              subtitle: const Text(
                'Courier/delivery details are added to the order.',
              ),
              onTap: () =>
                  Navigator.pop(context, FulfillmentMethod.courierDelivery),
            ),
          ],
        ),
      ),
    ),
  );
}

Future<CustomerPaymentMethod?> _showFeedPaymentOptions(BuildContext context) {
  return showModalBottomSheet<CustomerPaymentMethod>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.phone_iphone_rounded),
              title: const Text('MobilePay'),
              subtitle: const Text('Authorize payment'),
              onTap: () =>
                  Navigator.pop(context, CustomerPaymentMethod.mobilePay),
            ),
            ListTile(
              leading: const Icon(Icons.account_balance_wallet_outlined),
              title: const Text('Revolut'),
              subtitle: const Text('Authorize payment'),
              onTap: () =>
                  Navigator.pop(context, CustomerPaymentMethod.revolut),
            ),
            ListTile(
              leading: const Icon(Icons.credit_card_rounded),
              title: const Text('Card'),
              subtitle: const Text('Authorize payment'),
              onTap: () => Navigator.pop(context, CustomerPaymentMethod.card),
            ),
          ],
        ),
      ),
    ),
  );
}

class SocialFeedScreen extends ConsumerStatefulWidget {
  const SocialFeedScreen({
    required this.viewerType,
    this.openComposer = false,
    this.focusPostId,
    this.focusCommentId,
    super.key,
  });

  final FeedActorType viewerType;
  final bool openComposer;
  final String? focusPostId;
  final String? focusCommentId;

  @override
  ConsumerState<SocialFeedScreen> createState() => _SocialFeedScreenState();
}

class _SocialFeedScreenState extends ConsumerState<SocialFeedScreen> {
  bool _didOpenComposer = false;
  String? _lastMarkedFocusPostId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.openComposer &&
        widget.viewerType == FeedActorType.farmer &&
        !_didOpenComposer) {
      _didOpenComposer = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showCreatePostSheet();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(socialFeedControllerProvider);
    final isFarmer = widget.viewerType == FeedActorType.farmer;
    final viewerId = _viewerId();
    final viewerName = _viewerName();
    final viewerPhoto = _viewerPhoto();
    final followedFarmIds = ref.watch(followedFarmsProvider);
    var posts = isFarmer
        ? state.posts.where((post) => post.authorId == viewerId).toList()
        : state.posts
              .where((post) => followedFarmIds.contains(post.authorId))
              .toList();
    if (!isFarmer && widget.focusPostId != null) {
      final focusPostId = widget.focusPostId!;
      FeedPost? focusPost;
      for (final post in state.posts) {
        if (post.id == focusPostId) {
          focusPost = post;
          break;
        }
      }
      if (focusPost != null) {
        posts = [focusPost, ...posts.where((post) => post.id != focusPostId)];
      }
    }
    if (isFarmer && widget.focusPostId != null) {
      final focusPostId = widget.focusPostId!;
      posts = [
        ...posts.where((post) => post.id == focusPostId),
        ...posts.where((post) => post.id != focusPostId),
      ];
      if (_lastMarkedFocusPostId != focusPostId) {
        _lastMarkedFocusPostId = focusPostId;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          ref
              .read(socialFeedControllerProvider.notifier)
              .markPostNotificationsSeen(
                farmerId: viewerId,
                postId: focusPostId,
              );
        });
      }
    }

    if (!isFarmer) {
      return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              tooltip: 'Back to consumer',
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go(AppRoutes.customerHome);
                }
              },
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            title: const Text('Feed'),
            bottom: const TabBar(
              tabs: [
                Tab(text: 'Posts'),
                Tab(text: 'Following'),
              ],
            ),
          ),
          body: SafeArea(
            child: TabBarView(
              children: [
                _FeedPostsView(
                  posts: posts,
                  viewerType: widget.viewerType,
                  viewerId: viewerId,
                  viewerName: viewerName,
                  viewerPhoto: viewerPhoto,
                  orders: state.orders,
                  onCreatePost: _showCreatePostSheet,
                  focusPostId: widget.focusPostId,
                  focusCommentId: widget.focusCommentId,
                ),
                const _FollowingFarmsView(),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back to dashboard',
          onPressed: () => context.go(AppRoutes.farmerDashboard),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: Text(isFarmer ? 'Farm wall' : 'Feed'),
      ),
      body: SafeArea(
        child: _FeedPostsView(
          posts: posts,
          viewerType: widget.viewerType,
          viewerId: viewerId,
          viewerName: viewerName,
          viewerPhoto: viewerPhoto,
          orders: state.orders,
          onCreatePost: _showCreatePostSheet,
          focusPostId: widget.focusPostId,
          focusCommentId: widget.focusCommentId,
        ),
      ),
    );
  }

  String _viewerName() {
    final user = ref.read(authControllerProvider).user;
    if (widget.viewerType == FeedActorType.farmer) {
      return user?.farmerProfile?.farmName ?? 'FreshFarm';
    }
    return user?.name ?? 'Customer';
  }

  String _viewerId() {
    final user = ref.read(authControllerProvider).user;
    if (widget.viewerType == FeedActorType.farmer) {
      return user?.farmerProfile?.id ?? user?.id ?? 'farmer-feed-viewer';
    }
    return user?.id ?? 'customer-feed-viewer';
  }

  String? _viewerPhoto() {
    final user = ref.read(authControllerProvider).user;
    return user?.farmerProfile?.profilePhotoPlaceholder;
  }

  Future<void> _showCreatePostSheet() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => _CreatePostSheet(
          viewerId: _viewerId(),
          viewerName: _viewerName(),
          viewerPhoto: _viewerPhoto(),
        ),
      ),
    );
  }
}

class _FeedPostsView extends StatelessWidget {
  const _FeedPostsView({
    required this.posts,
    required this.viewerType,
    required this.viewerId,
    required this.viewerName,
    required this.viewerPhoto,
    required this.orders,
    required this.onCreatePost,
    this.focusPostId,
    this.focusCommentId,
  });

  final List<FeedPost> posts;
  final FeedActorType viewerType;
  final String viewerId;
  final String viewerName;
  final String? viewerPhoto;
  final List<FeedOrder> orders;
  final VoidCallback onCreatePost;
  final String? focusPostId;
  final String? focusCommentId;

  @override
  Widget build(BuildContext context) {
    final isFarmer = viewerType == FeedActorType.farmer;
    return ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
                  child: _FeedIntro(viewerType: viewerType),
                ),
              ),
              if (isFarmer)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
                    child: _CreatePostPrompt(
                      farmName: viewerName,
                      farmPhoto: viewerPhoto,
                      onTap: onCreatePost,
                    ),
                  ),
                ),
              if (orders.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
                    child: _OrderBookPanel(orders: orders),
                  ),
                ),
              SliverList.separated(
                itemCount: posts.length,
                separatorBuilder: (_, _) => const SizedBox(height: 22),
                itemBuilder: (context, index) => Padding(
                  padding: EdgeInsets.fromLTRB(
                    18,
                    index == 0 ? 2 : 0,
                    18,
                    index == posts.length - 1 ? 112 : 0,
                  ),
                  child: _FeedPostCard(
                    post: posts[index],
                    viewerType: viewerType,
                    viewerId: viewerId,
                    viewerName: viewerName,
                    authorPhoto: isFarmer ? viewerPhoto : null,
                    highlightCommentId: posts[index].id == focusPostId
                        ? focusCommentId
                        : null,
                  ),
                ),
              ),
              if (posts.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 10, 18, 112),
                    child: _EmptyFarmWall(
                      viewerType: viewerType,
                      onCreate: onCreatePost,
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

class _FollowingFarmsView extends ConsumerWidget {
  const _FollowingFarmsView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = Localizations.localeOf(context).languageCode;
    final listings = ref.watch(nearbyListingsProvider(locale));
    final followedFarmIds = ref.watch(followedFarmsProvider);
    final theme = Theme.of(context);

    return ColoredBox(
      color: theme.colorScheme.surfaceContainerLowest,
      child: listings.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const Center(child: Text('Could not load farms.')),
        data: (items) {
          final farmListings = <CustomerListing>[];
          final seen = <String>{};
          for (final listing in items) {
            if (!followedFarmIds.contains(listing.farmer.id)) continue;
            if (seen.add(listing.farmer.id)) farmListings.add(listing);
          }

          if (farmListings.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Follow farms from their profile pages to see them here.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 112),
            itemCount: farmListings.length,
            separatorBuilder: (_, _) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final listing = farmListings[index];
              final products = items
                  .where((item) => item.farmer.id == listing.farmer.id)
                  .take(3)
                  .toList();
              return _FollowingFarmCard(
                listing: listing,
                products: products,
                locale: locale,
              );
            },
          );
        },
      ),
    );
  }
}

class _FollowingFarmCard extends StatelessWidget {
  const _FollowingFarmCard({
    required this.listing,
    required this.products,
    required this.locale,
  });

  final CustomerListing listing;
  final List<CustomerListing> products;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final farmer = listing.farmer;
    return Card(
      margin: EdgeInsets.zero,
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(AppRoutes.farmerPublicProfile(farmer.id)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 118,
              width: double.infinity,
              child: AppImage(
                farmer.coverPhotoPlaceholder ??
                    'assets/images/home/hero_market.png',
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FarmAvatar(
                    farmName: farmer.farmName,
                    radius: 26,
                    photo: farmer.profilePhotoPlaceholder,
                  ),
                  const SizedBox(width: 12),
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
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded),
                ],
              ),
            ),
            if (products.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: products
                      .map(
                        (product) => Chip(
                          visualDensity: VisualDensity.compact,
                          label: Text(
                            '${product.productName(locale)} · ${_formatCompactQuantity(product.listing.quantity)} ${product.listing.unit}',
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

String _formatCompactQuantity(double value) {
  return value.toStringAsFixed(value % 1 == 0 ? 0 : 1);
}

class _CreatePostPrompt extends StatelessWidget {
  const _CreatePostPrompt({
    required this.farmName,
    required this.farmPhoto,
    required this.onTap,
  });

  final String farmName;
  final String? farmPhoto;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Row(
            children: [
              FarmAvatar(farmName: farmName, radius: 20, photo: farmPhoto),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Share something from your farm',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              IconButton.filled(
                tooltip: 'Create post',
                onPressed: onTap,
                icon: const Icon(Icons.add_rounded),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyFarmWall extends StatelessWidget {
  const _EmptyFarmWall({required this.viewerType, required this.onCreate});

  final FeedActorType viewerType;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isFarmer = viewerType == FeedActorType.farmer;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          Icon(Icons.feed_outlined, size: 34, color: theme.colorScheme.primary),
          const SizedBox(height: 8),
          Text(
            isFarmer ? 'Your farm wall is empty' : 'No farm updates yet',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isFarmer
                ? 'Add your first post with photos for customers to discover.'
                : 'Follow farms from their profile pages to see their posts here.',
            textAlign: TextAlign.center,
          ),
          if (isFarmer) ...[
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Create post'),
            ),
          ],
        ],
      ),
    );
  }
}

class CustomerActiveOffersStrip extends ConsumerWidget {
  const CustomerActiveOffersStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(socialFeedControllerProvider);
    final user = ref.watch(authControllerProvider).user;
    final offers = visiblePendingFeedOffersForConsumer(
      state.posts,
      viewerId: user?.id ?? 'customer-feed-viewer',
      viewerName: user?.name ?? 'Customer',
    );
    if (offers.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Active offers',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => context.go(AppRoutes.customerDeals),
                child: const Text('View all'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 118,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: offers.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final item = offers[index];
                return _ActiveOfferTile(post: item.post, offer: item.offer);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveOfferTile extends StatelessWidget {
  const _ActiveOfferTile({required this.post, required this.offer});

  final FeedPost post;
  final FeedOffer offer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () => context.go(AppRoutes.customerDeals),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 260,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.56),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Row(
          children: [
            FarmAvatar(farmName: post.authorName, radius: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    post.authorName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    offer.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${offer.quantity} · €${offer.price.toStringAsFixed(2)}',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }
}

class _FeedIntro extends StatelessWidget {
  const _FeedIntro({required this.viewerType});

  final FeedActorType viewerType;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          viewerType == FeedActorType.farmer
              ? 'Your farm page for products, pre-orders, and customer conversations.'
              : 'Comment, ask questions, and accept offers from farmers.',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _FeedPostCard extends ConsumerStatefulWidget {
  const _FeedPostCard({
    required this.post,
    required this.viewerType,
    required this.viewerId,
    required this.viewerName,
    required this.authorPhoto,
    this.highlightCommentId,
  });

  final FeedPost post;
  final FeedActorType viewerType;
  final String viewerId;
  final String viewerName;
  final String? authorPhoto;
  final String? highlightCommentId;

  @override
  ConsumerState<_FeedPostCard> createState() => _FeedPostCardState();
}

class _FeedPostCardState extends ConsumerState<_FeedPostCard> {
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final post = widget.post;
    final isOwner =
        widget.viewerType == FeedActorType.farmer &&
        post.authorId == widget.viewerId;
    final canComment = post.areCommentsEnabled && !post.isOffersFinished;
    final rootComments = post.comments
        .where((comment) => comment.parentCommentId == null)
        .toList();
    final looseOffers = post.offers
        .where(
          (offer) =>
              offer.sourceCommentId == null &&
              _canSeeOffer(
                offer: offer,
                viewerType: widget.viewerType,
                viewerId: widget.viewerId,
                viewerName: widget.viewerName,
              ),
        )
        .toList();
    final visibleOfferCount = post.offers
        .where(
          (offer) => _canSeeOffer(
            offer: offer,
            viewerType: widget.viewerType,
            viewerId: widget.viewerId,
            viewerName: widget.viewerName,
          ),
        )
        .length;
    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.12),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  customBorder: const CircleBorder(),
                  onTap: _openFarmProfile,
                  child: FarmAvatar(
                    farmName: post.authorName,
                    radius: 24,
                    photo: widget.authorPhoto,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: _openFarmProfile,
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 2,
                                ),
                                child: Text(
                                  post.authorName,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (isOwner)
                            PopupMenuButton<String>(
                              tooltip: 'Post options',
                              icon: const Icon(Icons.more_horiz_rounded),
                              onSelected: _handlePostOption,
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: post.isOffersFinished
                                      ? 'reopen-offers'
                                      : 'finish-offers',
                                  child: Text(
                                    post.isOffersFinished
                                        ? 'Reopen offers'
                                        : 'Mark offers finished',
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'delete-post',
                                  child: Text(
                                    'Delete post',
                                    style: TextStyle(
                                      color: theme.colorScheme.error,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _feedTimestamp(post.bumpedAt ?? post.createdAt),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (post.bumpedAt != null)
                        Text(
                          _originalPostTimestamp(post.createdAt),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (post.isOffersFinished ||
                (!post.areCommentsEnabled && !post.isOffersFinished)) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (post.isOffersFinished)
                    const Chip(
                      visualDensity: VisualDensity.compact,
                      label: Text('Offers finished'),
                    ),
                  if (!post.areCommentsEnabled && !post.isOffersFinished)
                    const Chip(
                      visualDensity: VisualDensity.compact,
                      label: Text('Comments off'),
                    ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            _PostPhotos(post: post),
            if (post.photos.isNotEmpty) const SizedBox(height: 14),
            Text(
              post.title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(post.description),
            const SizedBox(height: 14),
            Text(
              '${post.comments.length} comments · $visibleOfferCount offers',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (post.comments.isNotEmpty || post.offers.isNotEmpty) ...[
              const Divider(height: 26),
              ...rootComments.map(
                (comment) => _CommentThread(
                  post: post,
                  comment: comment,
                  viewerType: widget.viewerType,
                  viewerId: widget.viewerId,
                  viewerName: widget.viewerName,
                  highlightCommentId: widget.highlightCommentId,
                  onReply: _showReplySheet,
                  onCounter: (comment) => _showOfferSheet(comment: comment),
                  onReportComment: _reportComment,
                  onAcceptOffer: _acceptOffer,
                  onDeclineOffer: (offer) => ref
                      .read(socialFeedControllerProvider.notifier)
                      .declineOffer(post.id, offer.id),
                  onCancelOffer: (offer) => ref
                      .read(socialFeedControllerProvider.notifier)
                      .cancelOffer(post.id, offer.id),
                ),
              ),
              ...looseOffers.map(
                (offer) => Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: _OfferCard(
                    post: post,
                    offer: offer,
                    viewerType: widget.viewerType,
                    viewerId: widget.viewerId,
                    onAccept: () => _acceptOffer(offer),
                    onDecline: () => ref
                        .read(socialFeedControllerProvider.notifier)
                        .declineOffer(post.id, offer.id),
                    onCancel: () => ref
                        .read(socialFeedControllerProvider.notifier)
                        .cancelOffer(post.id, offer.id),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 14),
            if (canComment)
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      minLines: 1,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Write a comment...',
                        prefixIcon: Icon(Icons.chat_bubble_outline),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    tooltip: 'Send comment',
                    onPressed: _sendComment,
                    icon: const Icon(Icons.send_rounded),
                  ),
                ],
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  post.isOffersFinished
                      ? 'Offers are finished for this post.'
                      : 'Comments are closed by the farm.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _handlePostOption(String value) {
    final controller = ref.read(socialFeedControllerProvider.notifier);
    switch (value) {
      case 'finish-offers':
        controller.setOffersFinished(widget.post.id, true);
        break;
      case 'reopen-offers':
        controller.setOffersFinished(widget.post.id, false);
        controller.setCommentsEnabled(widget.post.id, true);
        break;
      case 'delete-post':
        controller.deletePost(widget.post.id);
        break;
    }
  }

  void _openFarmProfile() {
    final route = AppRoutes.farmerPublicProfile(widget.post.authorId);
    if (widget.viewerType == FeedActorType.farmer) {
      context.push('$route?preview=true');
      return;
    }
    context.push(route);
  }

  void _sendComment() {
    ref
        .read(socialFeedControllerProvider.notifier)
        .addComment(
          postId: widget.post.id,
          authorName: widget.viewerName,
          authorId: widget.viewerId,
          actorType: widget.viewerType,
          text: _commentController.text,
        );
    _commentController.clear();
  }

  void _reportComment(FeedComment comment) {
    ref
        .read(socialFeedControllerProvider.notifier)
        .reportComment(
          postId: widget.post.id,
          commentId: comment.id,
          reporterId: widget.viewerId,
        );
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Comment reported.')));
  }

  Future<void> _showReplySheet(FeedComment parent) async {
    final controller = TextEditingController();
    final reply = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          0,
          20,
          MediaQuery.viewInsetsOf(context).bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reply to ${parent.authorName}',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: controller,
              autofocus: true,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(hintText: 'Write a reply...'),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: () => Navigator.pop(context, controller.text),
                child: const Text('Reply'),
              ),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
    if (reply == null || reply.trim().isEmpty) return;
    ref
        .read(socialFeedControllerProvider.notifier)
        .addComment(
          postId: widget.post.id,
          authorName: widget.viewerName,
          authorId: widget.viewerId,
          actorType: widget.viewerType,
          text: reply,
          parentCommentId: parent.id,
        );
  }

  Future<void> _showOfferSheet({
    FeedOffer? countering,
    FeedComment? comment,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _OfferSheet(
        post: widget.post,
        countering: countering,
        comment: comment,
        viewerName: widget.viewerName,
        viewerId: widget.viewerId,
        viewerType: widget.viewerType,
      ),
    );
  }

  Future<void> _acceptOffer(FeedOffer offer) async {
    await acceptFeedOfferFromPost(
      context: context,
      ref: ref,
      post: widget.post,
      offer: offer,
    );
  }
}

class _PostPhotos extends StatelessWidget {
  const _PostPhotos({required this.post});

  final FeedPost post;

  @override
  Widget build(BuildContext context) {
    if (post.photos.isEmpty) return const SizedBox.shrink();
    final photos = post.photos;
    final visibleCount = photos.length > 5 ? 5 : photos.length;
    final radius = BorderRadius.circular(10);
    if (photos.length == 1) {
      return ClipRRect(
        borderRadius: radius,
        child: _PhotoTile(
          post: post,
          index: 0,
          height: 260,
          borderRadius: radius,
        ),
      );
    }
    return ClipRRect(
      borderRadius: radius,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final gap = 3.0;
          if (visibleCount == 2) {
            return SizedBox(
              height: 260,
              child: Row(
                children: [
                  Expanded(child: _PhotoTile(post: post, index: 0)),
                  SizedBox(width: gap),
                  Expanded(child: _PhotoTile(post: post, index: 1)),
                ],
              ),
            );
          }
          if (visibleCount == 3) {
            return SizedBox(
              height: 300,
              child: Row(
                children: [
                  Expanded(flex: 2, child: _PhotoTile(post: post, index: 0)),
                  SizedBox(width: gap),
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(child: _PhotoTile(post: post, index: 1)),
                        SizedBox(height: gap),
                        Expanded(child: _PhotoTile(post: post, index: 2)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
          final topHeight = width * 0.48;
          final bottomHeight = width * 0.34;
          return Column(
            children: [
              SizedBox(
                height: topHeight,
                child: Row(
                  children: [
                    Expanded(child: _PhotoTile(post: post, index: 0)),
                    SizedBox(width: gap),
                    Expanded(child: _PhotoTile(post: post, index: 1)),
                  ],
                ),
              ),
              SizedBox(height: gap),
              SizedBox(
                height: bottomHeight,
                child: Row(
                  children: [
                    for (var index = 2; index < visibleCount; index++) ...[
                      if (index > 2) SizedBox(width: gap),
                      Expanded(
                        child: _PhotoTile(
                          post: post,
                          index: index,
                          extraCount:
                              index == visibleCount - 1 && photos.length > 5
                              ? photos.length - visibleCount
                              : 0,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PhotoTile extends StatelessWidget {
  const _PhotoTile({
    required this.post,
    required this.index,
    this.height,
    this.borderRadius,
    this.extraCount = 0,
  });

  final FeedPost post;
  final int index;
  final double? height;
  final BorderRadius? borderRadius;
  final int extraCount;

  @override
  Widget build(BuildContext context) {
    final photos = post.photos;
    final image = Stack(
      fit: StackFit.expand,
      children: [
        AppImage(
          photos[index],
          fit: BoxFit.cover,
          width: double.infinity,
          height: height,
        ),
        if (extraCount > 0)
          Container(
            color: Colors.black.withValues(alpha: 0.42),
            alignment: Alignment.center,
            child: Text(
              '+$extraCount',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
      ],
    );
    return GestureDetector(
      onTap: () => _openPhotoViewer(context, post, index),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.zero,
        child: SizedBox(height: height, width: double.infinity, child: image),
      ),
    );
  }
}

void _openPhotoViewer(BuildContext context, FeedPost post, int initialIndex) {
  Navigator.of(context).push<void>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (context) =>
          _PostPhotoViewer(post: post, initialIndex: initialIndex),
    ),
  );
}

class _PostPhotoViewer extends StatefulWidget {
  const _PostPhotoViewer({required this.post, required this.initialIndex});

  final FeedPost post;
  final int initialIndex;

  @override
  State<_PostPhotoViewer> createState() => _PostPhotoViewerState();
}

class _PostPhotoViewerState extends State<_PostPhotoViewer> {
  late final ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_controller.hasClients) return;
      final headerExtent = 168.0;
      final itemExtent = MediaQuery.sizeOf(context).height * 0.72 + 14;
      _controller.jumpTo(
        (headerExtent + widget.initialIndex * itemExtent).clamp(
          0,
          _controller.position.maxScrollExtent,
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final photos = widget.post.photos;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Close',
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close_rounded),
        ),
      ),
      body: ListView(
        controller: _controller,
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 28),
        children: [
          Row(
            children: [
              FarmAvatar(farmName: widget.post.authorName, radius: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.post.authorName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      _feedTimestamp(
                        widget.post.bumpedAt ?? widget.post.createdAt,
                      ),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (widget.post.bumpedAt != null)
                      Text(
                        _originalPostTimestamp(widget.post.createdAt),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            widget.post.title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(widget.post.description),
          const SizedBox(height: 16),
          for (var index = 0; index < photos.length; index++) ...[
            InteractiveViewer(
              minScale: 1,
              maxScale: 4,
              child: Container(
                height: MediaQuery.sizeOf(context).height * 0.72,
                width: double.infinity,
                color: Colors.black,
                child: AppImage(photos[index], fit: BoxFit.contain),
              ),
            ),
            if (index < photos.length - 1) const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }
}

class _CommentThread extends StatelessWidget {
  const _CommentThread({
    required this.post,
    required this.comment,
    required this.viewerType,
    required this.viewerId,
    required this.viewerName,
    required this.highlightCommentId,
    required this.onReply,
    required this.onCounter,
    required this.onReportComment,
    required this.onAcceptOffer,
    required this.onDeclineOffer,
    required this.onCancelOffer,
  });

  final FeedPost post;
  final FeedComment comment;
  final FeedActorType viewerType;
  final String viewerId;
  final String viewerName;
  final String? highlightCommentId;
  final ValueChanged<FeedComment> onReply;
  final ValueChanged<FeedComment> onCounter;
  final ValueChanged<FeedComment> onReportComment;
  final ValueChanged<FeedOffer> onAcceptOffer;
  final ValueChanged<FeedOffer> onDeclineOffer;
  final ValueChanged<FeedOffer> onCancelOffer;

  @override
  Widget build(BuildContext context) {
    final replies = post.comments
        .where((reply) => reply.parentCommentId == comment.id)
        .toList();
    final offers = post.offers
        .where(
          (offer) =>
              offer.sourceCommentId == comment.id &&
              _canSeeOffer(
                offer: offer,
                viewerType: viewerType,
                viewerId: viewerId,
                viewerName: viewerName,
              ),
        )
        .toList();

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CommentBubble(
            comment: comment,
            highlight: comment.id == highlightCommentId,
            canReply: post.areCommentsEnabled && comment.authorId != viewerId,
            canReport: comment.authorId != viewerId,
            canCounter:
                !post.isOffersFinished &&
                viewerType == FeedActorType.farmer &&
                comment.actorType == FeedActorType.consumer,
            onReply: () => onReply(comment),
            onCounter: () => onCounter(comment),
            onReport: () => onReportComment(comment),
          ),
          if (replies.isNotEmpty || offers.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 28, top: 4),
              child: Column(
                children: [
                  ...replies.map(
                    (reply) => _CommentThread(
                      post: post,
                      comment: reply,
                      viewerType: viewerType,
                      viewerId: viewerId,
                      viewerName: viewerName,
                      highlightCommentId: highlightCommentId,
                      onReply: onReply,
                      onCounter: onCounter,
                      onReportComment: onReportComment,
                      onAcceptOffer: onAcceptOffer,
                      onDeclineOffer: onDeclineOffer,
                      onCancelOffer: onCancelOffer,
                    ),
                  ),
                  ...offers.map(
                    (offer) => Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: _OfferCard(
                        post: post,
                        offer: offer,
                        viewerType: viewerType,
                        viewerId: viewerId,
                        onAccept: () => onAcceptOffer(offer),
                        onDecline: () => onDeclineOffer(offer),
                        onCancel: () => onCancelOffer(offer),
                      ),
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

class _CommentBubble extends StatelessWidget {
  const _CommentBubble({
    required this.comment,
    required this.highlight,
    required this.canReply,
    required this.canReport,
    required this.canCounter,
    required this.onReply,
    required this.onCounter,
    required this.onReport,
  });

  final FeedComment comment;
  final bool highlight;
  final bool canReply;
  final bool canReport;
  final bool canCounter;
  final VoidCallback onReply;
  final VoidCallback onCounter;
  final VoidCallback onReport;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            comment.actorType == FeedActorType.farmer
                ? Icons.storefront_outlined
                : Icons.person_outline,
            size: 20,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: highlight
                    ? theme.colorScheme.primaryContainer.withValues(alpha: 0.55)
                    : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
                border: highlight
                    ? Border.all(color: theme.colorScheme.primary, width: 1.4)
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    comment.authorName,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(comment.text),
                  if (canReply || canCounter) ...[
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        if (canReply)
                          TextButton(
                            onPressed: onReply,
                            child: const Text('Reply'),
                          ),
                        if (canCounter)
                          TextButton.icon(
                            onPressed: onCounter,
                            icon: const Icon(
                              Icons.handshake_outlined,
                              size: 18,
                            ),
                            label: const Text('Make offer'),
                          ),
                        if (canReport)
                          PopupMenuButton<String>(
                            tooltip: 'Comment options',
                            onSelected: (_) => onReport(),
                            itemBuilder: (context) => const [
                              PopupMenuItem(
                                value: 'report',
                                child: Text('Report comment'),
                              ),
                            ],
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 8,
                              ),
                              child: Icon(Icons.more_horiz_rounded, size: 20),
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OfferCard extends StatelessWidget {
  const _OfferCard({
    required this.post,
    required this.offer,
    required this.viewerType,
    required this.viewerId,
    required this.onAccept,
    required this.onDecline,
    required this.onCancel,
  });

  final FeedPost post;
  final FeedOffer offer;
  final FeedActorType viewerType;
  final String viewerId;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canAct =
        !post.isOffersFinished &&
        offer.status == FeedOfferStatus.pending &&
        offer.actorType != viewerType;
    final canCancel =
        offer.status == FeedOfferStatus.pending && offer.authorId == viewerId;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEE),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8D8A8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.handshake_outlined, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${offer.authorName} offer',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              _OfferStatusChip(status: offer.status),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            offer.title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${offer.quantity} · €${offer.price.toStringAsFixed(2)} · ${offer.dateLabel}',
          ),
          if (offer.note.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(offer.note),
          ],
          if (offer.sourceCommentText != null) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Replying to ${offer.targetCustomerName ?? 'customer'}: ${offer.sourceCommentText}',
                style: theme.textTheme.bodySmall,
              ),
            ),
          ],
          if (canAct) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: onAccept,
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('Accept'),
                ),
                TextButton(onPressed: onDecline, child: const Text('Decline')),
              ],
            ),
          ] else if (canCancel) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onCancel,
              icon: const Icon(Icons.cancel_outlined),
              label: const Text('Cancel offer'),
            ),
          ],
        ],
      ),
    );
  }
}

class _OfferStatusChip extends StatelessWidget {
  const _OfferStatusChip({required this.status});

  final FeedOfferStatus status;

  @override
  Widget build(BuildContext context) {
    final label = switch (status) {
      FeedOfferStatus.pending => 'Pending',
      FeedOfferStatus.countered => 'Countered',
      FeedOfferStatus.accepted => 'Accepted',
      FeedOfferStatus.declined => 'Declined',
      FeedOfferStatus.cancelled => 'Cancelled',
    };
    return Chip(visualDensity: VisualDensity.compact, label: Text(label));
  }
}

class _OrderBookPanel extends StatelessWidget {
  const _OrderBookPanel({required this.orders});

  final List<FeedOrder> orders;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF5EA),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFC5DEC7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.receipt_long_outlined),
              const SizedBox(width: 8),
              Text(
                'Feed order book',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...orders
              .take(3)
              .map(
                (order) => Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${order.title} · ${order.quantity} · ${order.farmerName} ↔ ${order.consumerName}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '€${order.price.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

class _CreatePostSheet extends StatefulWidget {
  const _CreatePostSheet({
    required this.viewerId,
    required this.viewerName,
    required this.viewerPhoto,
  });

  final String viewerId;
  final String viewerName;
  final String? viewerPhoto;

  @override
  State<_CreatePostSheet> createState() => _CreatePostSheetState();
}

class _CreatePostSheetState extends State<_CreatePostSheet> {
  final _product = TextEditingController();
  final _description = TextEditingController();
  final List<String> _photos = [];

  @override
  void initState() {
    super.initState();
    _product.addListener(_refreshPostState);
    _description.addListener(_refreshPostState);
  }

  @override
  void dispose() {
    _product.removeListener(_refreshPostState);
    _description.removeListener(_refreshPostState);
    _product.dispose();
    _description.dispose();
    super.dispose();
  }

  bool get _canPost =>
      _product.text.trim().isNotEmpty || _description.text.trim().isNotEmpty;

  void _refreshPostState() => setState(() {});

  void _publish(WidgetRef ref) {
    if (!_canPost) return;
    final title = _product.text.trim().isEmpty
        ? _fallbackTitle(_description.text)
        : _product.text.trim();
    final description = _description.text.trim().isEmpty
        ? title
        : _description.text.trim();
    ref
        .read(socialFeedControllerProvider.notifier)
        .addPost(
          authorId: widget.viewerId,
          authorName: widget.viewerName,
          product: title,
          description: description,
          photos: _photos,
        );
    Navigator.pop(context);
  }

  String _fallbackTitle(String value) {
    final words = value.trim().split(RegExp(r'\s+'));
    if (words.isEmpty || words.first.isEmpty) return 'Farm update';
    return words.take(5).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) => Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: 'Close',
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close_rounded),
          ),
          title: const Text('New post'),
          centerTitle: true,
        ),
        body: SafeArea(
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              20,
              14,
              20,
              MediaQuery.viewInsetsOf(context).bottom + 24,
            ),
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        FarmAvatar(
                          farmName: widget.viewerName,
                          radius: 34,
                          photo: widget.viewerPhoto,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            widget.viewerName,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _product,
                      autofocus: true,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        hintText: 'Product or offer title',
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: _description,
                      minLines: 12,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.w400,
                          ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        hintText: 'Describe your product',
                        hintStyle: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w400,
                            ),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _PhotoPickerStrip(
                      photos: _photos,
                      onAdd: () async {
                        final images = await pickDeviceImages();
                        if (images.isNotEmpty && mounted) {
                          setState(() => _photos.addAll(images));
                        }
                      },
                      onRemove: (index) =>
                          setState(() => _photos.removeAt(index)),
                    ),
                    const SizedBox(height: 16),
                    _CreatePostActionBar(
                      canPost: _canPost,
                      onAddPhoto: () async {
                        final images = await pickDeviceImages();
                        if (images.isNotEmpty && mounted) {
                          setState(() => _photos.addAll(images));
                        }
                      },
                      onPost: () => _publish(ref),
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

class _CreatePostActionBar extends StatelessWidget {
  const _CreatePostActionBar({
    required this.canPost,
    required this.onAddPhoto,
    required this.onPost,
  });

  final bool canPost;
  final Future<void> Function() onAddPhoto;
  final VoidCallback onPost;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        OutlinedButton.icon(
          onPressed: onAddPhoto,
          icon: const Icon(Icons.image_outlined),
          label: const Text('Photo'),
        ),
        const Spacer(),
        FilledButton(
          onPressed: canPost ? onPost : null,
          child: const Text('Post'),
        ),
      ],
    );
  }
}

class _PhotoPickerStrip extends StatelessWidget {
  const _PhotoPickerStrip({
    required this.photos,
    required this.onAdd,
    required this.onRemove,
  });

  final List<String> photos;
  final Future<void> Function() onAdd;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (photos.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${photos.length} ${photos.length == 1 ? 'photo' : 'photos'}',
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 76,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: photos.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: AppImage(
                      photos[index],
                      fit: BoxFit.cover,
                      width: 76,
                      height: 76,
                    ),
                  ),
                  Positioned(
                    top: 5,
                    right: 5,
                    child: IconButton.filled(
                      visualDensity: VisualDensity.compact,
                      tooltip: 'Remove photo',
                      onPressed: () => onRemove(index),
                      icon: const Icon(Icons.close_rounded, size: 16),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _OfferSheet extends StatefulWidget {
  const _OfferSheet({
    required this.post,
    required this.viewerId,
    required this.viewerName,
    required this.viewerType,
    this.countering,
    this.comment,
  });

  final FeedPost post;
  final String viewerId;
  final String viewerName;
  final FeedActorType viewerType;
  final FeedOffer? countering;
  final FeedComment? comment;

  @override
  State<_OfferSheet> createState() => _OfferSheetState();
}

class _OfferSheetState extends State<_OfferSheet> {
  late final TextEditingController _quantity;
  late final TextEditingController _price;
  late final TextEditingController _date;
  final _note = TextEditingController();

  @override
  void initState() {
    super.initState();
    _quantity = TextEditingController();
    _price = TextEditingController();
    _date = TextEditingController();
  }

  @override
  void dispose() {
    _quantity.dispose();
    _price.dispose();
    _date.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          0,
          20,
          MediaQuery.viewInsetsOf(context).bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.countering == null ? 'Make offer' : 'Counter offer',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  widget.post.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _quantity,
                      decoration: const InputDecoration(
                        labelText: 'Quantity',
                        hintText: '2 kg',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _price,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Total price',
                        hintText: '10',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _date,
                decoration: const InputDecoration(
                  labelText: 'Pickup window',
                  hintText: 'Today 17:00-19:00',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _note,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Note',
                  hintText: 'Short message for the customer',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    final price = double.tryParse(
                      _price.text.trim().replaceAll(',', '.'),
                    );
                    if (_quantity.text.trim().isEmpty ||
                        _date.text.trim().isEmpty ||
                        price == null) {
                      return;
                    }
                    final controller = ref.read(
                      socialFeedControllerProvider.notifier,
                    );
                    if (widget.countering == null) {
                      controller.makeOffer(
                        postId: widget.post.id,
                        authorId: widget.viewerId,
                        authorName: widget.viewerName,
                        actorType: widget.viewerType,
                        title: widget.post.title,
                        quantity: _quantity.text,
                        price: price,
                        dateLabel: _date.text,
                        note: _note.text,
                        sourceCommentId: widget.comment?.id,
                        sourceCommentText: widget.comment?.text,
                        targetCustomerId: widget.comment?.authorId,
                        targetCustomerName: widget.comment?.authorName,
                      );
                    } else {
                      controller.counterOffer(
                        postId: widget.post.id,
                        offerId: widget.countering!.id,
                        authorId: widget.viewerId,
                        authorName: widget.viewerName,
                        actorType: widget.viewerType,
                        title: widget.post.title,
                        quantity: _quantity.text,
                        price: price,
                        dateLabel: _date.text,
                        note: _note.text,
                      );
                    }
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.handshake_outlined),
                  label: Text(
                    widget.countering == null
                        ? 'Send offer'
                        : 'Send counter offer',
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
