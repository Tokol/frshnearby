import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/widgets/farm_avatar.dart';
import '../../../core/widgets/app_image.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../deals/domain/deal.dart';
import '../../deals/presentation/deal_controller.dart';
import '../../listings/domain/listing.dart';
import '../../listings/presentation/listing_controller.dart';
import '../../listings/presentation/listing_form_components.dart';
import '../../social_feed/domain/feed_post.dart';
import '../../social_feed/presentation/social_feed_controller.dart';

class FarmerDashboardScreen extends ConsumerWidget {
  const FarmerDashboardScreen({super.key});

  static const farmUrl = 'frshnearby/northfieldfarm';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final profile = ref.watch(authControllerProvider).user?.farmerProfile;
    final farmerId = profile?.id ?? 'farmer-1';
    final feedState = ref.watch(socialFeedControllerProvider);
    final unreadWallNotifications = feedState.notifications
        .where((item) => item.farmerId == farmerId && !item.seen)
        .length;
    final pendingFeedOfferCount = feedState.posts.fold<int>(
      0,
      (count, post) =>
          count +
          post.offers
              .where(
                (offer) =>
                    offer.authorId == farmerId &&
                    offer.status == FeedOfferStatus.pending,
              )
              .length,
    );
    final listings = ref.watch(listingControllerProvider).listings;
    final orders = ref.watch(farmerDealsProvider).valueOrNull ?? const <Deal>[];
    final active = orders
        .where(
          (order) =>
              order.status == DealStatus.negotiating ||
              order.status == DealStatus.confirmed ||
              order.status == DealStatus.readyForPickup,
        )
        .map((order) => order.orderGroupId)
        .toSet();
    final now = DateTime.now();
    final delivered = orders.where((order) {
      if (order.status != DealStatus.completed) return false;
      final date = order.completedAt ?? order.createdAt;
      return date.year == now.year && date.month == now.month;
    }).toList();
    final sales = delivered.fold<double>(
      0,
      (sum, order) => sum + order.quantity * order.price,
    );
    final allTimeSales = orders
        .where((order) => order.status == DealStatus.completed)
        .fold<double>(0, (sum, order) => sum + order.quantity * order.price);

    return Scaffold(
      appBar: AppBar(
        title: InkWell(
          onTap: () => context.push(AppRoutes.editFarmProfile),
          borderRadius: BorderRadius.circular(30),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FarmAvatar(
                  farmName: profile?.farmName ?? 'FreshFarm',
                  radius: 19,
                  photo: profile?.profilePhotoPlaceholder,
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile?.farmName ?? 'FreshFarm',
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${profile?.city ?? 'Vaasa'}, ${profile?.country ?? 'Finland'}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Farm wall',
            onPressed: () => context.go(AppRoutes.farmerCommunity),
            icon: Badge(
              isLabelVisible: unreadWallNotifications > 0,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              label: Text('$unreadWallNotifications'),
              child: const Icon(Icons.post_add_outlined),
            ),
          ),
          IconButton(
            tooltip: 'Notifications',
            onPressed: () => _showFarmWallNotifications(
              context: context,
              ref: ref,
              farmerId: farmerId,
            ),
            icon: Badge(
              isLabelVisible: unreadWallNotifications > 0,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              label: Text('$unreadWallNotifications'),
              child: const Icon(Icons.notifications_none_rounded),
            ),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 110),
        children: [
          Text(
            l10n.dashboardGreeting,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.dashboardIntro,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (pendingFeedOfferCount > 0) ...[
            const SizedBox(height: 14),
            _PendingOffersNotice(
              count: pendingFeedOfferCount,
              onTap: () => context.go(AppRoutes.farmerDeals),
            ),
          ],
          const SizedBox(height: 20),
          _FarmLinkCard(
            onPreview: () => context.push(
              '${AppRoutes.farmerPublicProfile(profile?.id ?? 'farmer-1')}?preview=true',
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  value: '${active.length}',
                  label: l10n.activeOrdersLabel,
                  icon: Icons.local_shipping_outlined,
                  color: const Color(0xFF315A87),
                  onTap: () => context.go(AppRoutes.farmerDeals),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MetricCard(
                  value: '€${sales.toStringAsFixed(0)}',
                  label: l10n.salesThisMonthLabel,
                  detail: l10n.allTimeSalesLabel(
                    allTimeSales.toStringAsFixed(0),
                  ),
                  icon: Icons.trending_up_rounded,
                  color: const Color(0xFF2F6B45),
                  onTap: () => context.go(AppRoutes.farmerInsights),
                ),
              ),
            ],
          ),
          const SizedBox(height: 26),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Hot Sale',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: () => context.push(AppRoutes.createListing),
                icon: const Icon(Icons.add_rounded),
                label: Text(l10n.addProductButton),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (listings.isEmpty)
            _EmptyCard(l10n.noProductsMessage)
          else
            ...listings.map(
              (listing) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _DashboardProductCard(
                  listing: listing,
                  onEdit: () => context.push(AppRoutes.editListing(listing.id)),
                  onDecrease: () => _adjustQuantity(
                    context: context,
                    ref: ref,
                    listing: listing,
                    quantity: listing.quantity - _stepFor(listing.unit),
                  ),
                  onIncrease: () => _adjustQuantity(
                    context: context,
                    ref: ref,
                    listing: listing,
                    quantity: listing.quantity + _stepFor(listing.unit),
                  ),
                  onQuantityTap: () => _showStockSheet(
                    context: context,
                    ref: ref,
                    listing: listing,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  static double _stepFor(String unit) {
    return switch (unit.toLowerCase()) {
      'g' || 'gm' || 'gram' || 'grams' => 100,
      _ => 1,
    };
  }

  Future<void> _adjustQuantity({
    required BuildContext context,
    required WidgetRef ref,
    required Listing listing,
    required double quantity,
    String? unit,
  }) async {
    final previousQuantity = listing.quantity;
    await ref
        .read(listingControllerProvider.notifier)
        .updateQuantity(
          listingId: listing.id,
          quantity: quantity,
          unit: unit ?? listing.unit,
        );
    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${listing.title}: ${_formatQuantity(quantity < 0 ? 0 : quantity)} ${listing.unit}',
        ),
        action: SnackBarAction(
          label: AppLocalizations.of(context).undoLabel,
          onPressed: () => ref
              .read(listingControllerProvider.notifier)
              .updateQuantity(
                listingId: listing.id,
                quantity: previousQuantity,
              ),
        ),
      ),
    );
  }

  Future<void> _showStockSheet({
    required BuildContext context,
    required WidgetRef ref,
    required Listing listing,
  }) async {
    final controller = TextEditingController();
    final result = await showModalBottomSheet<({double amount, String unit})>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        var selectedUnit = listing.unit;
        return StatefulBuilder(
          builder: (context, setSheetState) => Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              4,
              20,
              MediaQuery.viewInsetsOf(context).bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Update ${listing.title}',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                Text(
                  'Currently ${_formatQuantity(listing.quantity)} ${listing.unit}. Add newly harvested or restocked quantity.',
                ),
                const SizedBox(height: 18),
                SellingUnitField(
                  value: selectedUnit,
                  onChanged: (unit) => setSheetState(() {
                    selectedUnit = unit;
                  }),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: controller,
                  autofocus: true,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).quantityToAddLabel,
                    suffixText: selectedUnit,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      final value = double.tryParse(
                        controller.text.trim().replaceAll(',', '.'),
                      );
                      final unit = selectedUnit.trim();
                      if (value != null && value > 0 && unit.isNotEmpty) {
                        Navigator.of(context).pop((amount: value, unit: unit));
                      }
                    },
                    child: Text(AppLocalizations.of(context).addToStockLabel),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    controller.dispose();
    if (result == null || !context.mounted) {
      return;
    }
    await _adjustQuantity(
      context: context,
      ref: ref,
      listing: listing,
      quantity: listing.quantity + result.amount,
      unit: result.unit,
    );
  }

  void _showFarmWallNotifications({
    required BuildContext context,
    required WidgetRef ref,
    required String farmerId,
  }) {
    Navigator.of(context).push<void>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => _FarmWallNotificationsScreen(farmerId: farmerId),
      ),
    );
  }

  static String _formatQuantity(double value) {
    return value.toStringAsFixed(value % 1 == 0 ? 0 : 1);
  }
}

class _FarmWallNotificationsScreen extends ConsumerWidget {
  const _FarmWallNotificationsScreen({required this.farmerId});

  final String farmerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref
        .watch(socialFeedControllerProvider)
        .notifications
        .where((item) => item.farmerId == farmerId)
        .toList();
    final unreadCount = notifications.where((item) => !item.seen).length;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Close',
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close_rounded),
        ),
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: unreadCount == 0
                ? null
                : () => ref
                      .read(socialFeedControllerProvider.notifier)
                      .markAllNotificationsSeen(farmerId),
            child: const Text('Mark all read'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: notifications.isEmpty
          ? const _EmptyFarmWallNotifications()
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 28),
              itemCount: notifications.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return _FarmWallNotificationTile(
                  notification: notification,
                  onTap: () {
                    ref
                        .read(socialFeedControllerProvider.notifier)
                        .markNotificationSeen(notification.id);
                    Navigator.pop(context);
                    context.go(
                      '${AppRoutes.farmerCommunity}?post=${notification.postId}&comment=${notification.commentId}',
                    );
                  },
                );
              },
            ),
    );
  }
}

class _EmptyFarmWallNotifications extends StatelessWidget {
  const _EmptyFarmWallNotifications();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.notifications_none_rounded,
              size: 54,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 14),
            Text(
              'No notifications yet',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Customer comments on your farm wall will appear here.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FarmWallNotificationTile extends StatelessWidget {
  const _FarmWallNotificationTile({
    required this.notification,
    required this.onTap,
  });

  final FeedNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final initial = notification.actorName.trim().isEmpty
        ? '?'
        : notification.actorName.trim().characters.first.toUpperCase();
    return Material(
      color: notification.seen
          ? theme.colorScheme.surface
          : theme.colorScheme.primaryContainer.withValues(alpha: 0.28),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: notification.seen
                    ? theme.colorScheme.surfaceContainerHighest
                    : theme.colorScheme.primary,
                child: Text(
                  initial,
                  style: TextStyle(
                    color: notification.seen
                        ? theme.colorScheme.onSurfaceVariant
                        : theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: notification.actorName,
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                          const TextSpan(text: ' commented on '),
                          TextSpan(
                            text: notification.postTitle,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      notification.text,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _notificationAge(notification.createdAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: notification.seen
                            ? theme.colorScheme.onSurfaceVariant
                            : theme.colorScheme.primary,
                        fontWeight: notification.seen
                            ? FontWeight.w500
                            : FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              if (!notification.seen) ...[
                const SizedBox(width: 10),
                Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsets.only(top: 20),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

String _notificationAge(DateTime value) {
  final difference = DateTime.now().difference(value);
  if (difference.inMinutes < 1) return 'now';
  if (difference.inHours < 1) return '${difference.inMinutes}m';
  if (difference.inHours < 24) return '${difference.inHours}h';
  return '${value.day}.${value.month}';
}

class _PendingOffersNotice extends StatelessWidget {
  const _PendingOffersNotice({required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.tertiaryContainer.withValues(alpha: 0.58),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: theme.colorScheme.tertiary,
                child: Icon(
                  Icons.handshake_outlined,
                  color: theme.colorScheme.onTertiary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  count == 1
                      ? '1 pending offer is waiting for a customer'
                      : '$count pending offers are waiting for customers',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class _FarmLinkCard extends StatelessWidget {
  const _FarmLinkCard({required this.onPreview});
  final VoidCallback onPreview;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF285C3C),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.yourFarmPageLabel,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            FarmerDashboardScreen.farmUrl,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onPreview,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white54),
                  ),
                  icon: const Icon(Icons.visibility_outlined),
                  label: Text(l10n.previewLabel),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                tooltip: l10n.copyLinkTooltip,
                onPressed: () async {
                  await Clipboard.setData(
                    const ClipboardData(text: FarmerDashboardScreen.farmUrl),
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.farmLinkCopiedMessage)),
                    );
                  }
                },
                icon: const Icon(Icons.copy_rounded),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                tooltip: l10n.shareLinkTooltip,
                onPressed: () => SharePlus.instance.share(
                  ShareParams(
                    subject: 'North Field Farm, Vaasa',
                    text:
                        'Order fresh produce from North Field Farm in Vaasa:\n${FarmerDashboardScreen.farmUrl}',
                  ),
                ),
                icon: const Icon(Icons.ios_share_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    this.detail,
  });
  final String value;
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 21),
              const SizedBox(height: 13),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(label, style: Theme.of(context).textTheme.bodySmall),
              if (detail != null) ...[
                const SizedBox(height: 3),
                Text(
                  detail!,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardProductCard extends StatelessWidget {
  const _DashboardProductCard({
    required this.listing,
    required this.onEdit,
    required this.onDecrease,
    required this.onIncrease,
    required this.onQuantityTap,
  });

  final Listing listing;
  final VoidCallback onEdit;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;
  final VoidCallback onQuantityTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final available = listing.quantity > 0;
    final now = DateTime.now();
    final bestBefore = listing.bestBeforeDate;
    final bestBeforeSoon =
        bestBefore != null &&
        !bestBefore.isBefore(DateTime(now.year, now.month, now.day)) &&
        bestBefore.difference(DateTime(now.year, now.month, now.day)).inDays <=
            3;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: AppImage(
                  listing.photoPlaceholder ??
                      'assets/images/home/vegetables.png',
                  width: 68,
                  height: 68,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      listing.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '€${listing.price.toStringAsFixed(2)} / ${listing.unit}',
                      style: theme.textTheme.bodySmall,
                    ),
                    if (listing.description.trim().isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Text(
                        listing.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                    if (listing.farmingMethod?.trim().isNotEmpty ?? false) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.info_outline_rounded, size: 14),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              listing.farmingMethod!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.labelSmall,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (listing.harvestDate != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined, size: 13),
                          const SizedBox(width: 4),
                          Text(
                            'Produced ${DateFormat('d MMM').format(listing.harvestDate!)}',
                            style: theme.textTheme.labelSmall,
                          ),
                        ],
                      ),
                    ],
                    if (bestBeforeSoon) ...[
                      const SizedBox(height: 5),
                      Text(
                        'Best before soon · ${DateFormat('d MMM').format(bestBefore)}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: const Color(0xFF9A5B13),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                    if (!available) ...[
                      const SizedBox(height: 7),
                      Text(
                        'Sold out',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              TextButton(onPressed: onEdit, child: Text(l10n.manageLabel)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Text(l10n.quantityLabel, style: theme.textTheme.labelLarge),
              const Spacer(),
              _QuantityButton(
                controlKey: ValueKey('decrease-${listing.id}'),
                icon: Icons.remove_rounded,
                onPressed: listing.quantity <= 0 ? null : onDecrease,
              ),
              const SizedBox(width: 8),
              InkWell(
                key: ValueKey('quantity-${listing.id}'),
                onTap: onQuantityTap,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  constraints: const BoxConstraints(minWidth: 88),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F3EC),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${FarmerDashboardScreen._formatQuantity(listing.quantity)} ${listing.unit}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _QuantityButton(
                controlKey: ValueKey('increase-${listing.id}'),
                icon: Icons.add_rounded,
                onPressed: onIncrease,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  const _QuantityButton({
    required this.controlKey,
    required this.icon,
    required this.onPressed,
  });

  final Key controlKey;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      key: controlKey,
      onPressed: onPressed,
      icon: Icon(icon),
      style: IconButton.styleFrom(minimumSize: const Size(46, 46)),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard(this.message);
  final String message;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
    ),
    child: Text(message),
  );
}
