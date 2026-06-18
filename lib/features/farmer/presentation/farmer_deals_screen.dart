import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/utils/time_utils.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../deals/domain/deal.dart';
import '../../deals/presentation/deal_controller.dart';
import '../../social_feed/domain/feed_post.dart';
import '../../social_feed/presentation/social_feed_controller.dart';

class FarmerDealsScreen extends ConsumerStatefulWidget {
  const FarmerDealsScreen({super.key});

  @override
  ConsumerState<FarmerDealsScreen> createState() => _FarmerDealsScreenState();
}

class _FarmerDealsScreenState extends ConsumerState<FarmerDealsScreen> {
  int _selectedIndex = 0;
  _OrderBookView _selectedView = _OrderBookView.orders;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ordersAsync = ref.watch(farmerDealsProvider);
    final farmerId =
        ref.watch(authControllerProvider).user?.farmerProfile?.id ?? 'farmer-1';
    final feedState = ref.watch(socialFeedControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.orderBookTitle),
            Text(
              l10n.orderBookSubtitle,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
            ),
          ],
        ),
      ),
      body: ordersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(child: Text(l10n.ordersLoadError)),
        data: (orders) {
          final grouped = <String, List<Deal>>{};
          for (final order in orders) {
            grouped.putIfAbsent(order.orderGroupId, () => []).add(order);
          }
          final allGroups = grouped.values.toList();
          final filtered =
              allGroups.where((group) {
                final status = group.first.status;
                return switch (_selectedIndex) {
                  0 =>
                    status != DealStatus.completed &&
                        status != DealStatus.cancelled,
                  1 => status == DealStatus.negotiating,
                  2 =>
                    status == DealStatus.completed ||
                        status == DealStatus.cancelled,
                  _ => true,
                };
              }).toList()..sort(
                (a, b) => b.first.createdAt.compareTo(a.first.createdAt),
              );

          final productGroups = _ProductOrderGroup.fromOrders(filtered);
          final pendingOffers = _PendingFeedOffer.fromPosts(
            feedState.posts,
            farmerId,
          );

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 920),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                    child: _OrderTabs(
                      selectedIndex: _selectedIndex,
                      newCount: allGroups
                          .where(
                            (group) =>
                                group.first.status == DealStatus.negotiating,
                          )
                          .length,
                      pendingOfferCount: pendingOffers.length,
                      onSelected: (index) {
                        setState(() => _selectedIndex = index);
                      },
                    ),
                  ),
                  if (_selectedIndex != 3)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                      child: _OrderBookViewToggle(
                        selectedView: _selectedView,
                        onSelected: (view) {
                          setState(() => _selectedView = view);
                        },
                      ),
                    ),
                  Expanded(
                    child: _selectedIndex == 3
                        ? _PendingFeedOffersList(offers: pendingOffers)
                        : filtered.isEmpty
                        ? const _EmptyOrderBook()
                        : _selectedView == _OrderBookView.orders
                        ? ListView.separated(
                            padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                            itemCount: filtered.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 14),
                            itemBuilder: (context, index) {
                              return _OrderCard(
                                orders: filtered[index],
                                onOpen: () => context.push(
                                  AppRoutes.farmerOrderDetail(
                                    filtered[index].first.id,
                                  ),
                                ),
                              );
                            },
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                            itemCount: productGroups.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 14),
                            itemBuilder: (context, index) {
                              return _ProductOrderCard(
                                group: productGroups[index],
                                onOpenOrder: (order) => context.push(
                                  AppRoutes.farmerOrderDetail(order.id),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

enum _OrderBookView { orders, products }

class _OrderBookViewToggle extends StatelessWidget {
  const _OrderBookViewToggle({
    required this.selectedView,
    required this.onSelected,
  });

  final _OrderBookView selectedView;
  final ValueChanged<_OrderBookView> onSelected;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<_OrderBookView>(
      showSelectedIcon: false,
      selected: {selectedView},
      onSelectionChanged: (selection) => onSelected(selection.first),
      segments: const [
        ButtonSegment(
          value: _OrderBookView.orders,
          icon: Icon(Icons.receipt_long_outlined, size: 18),
          label: Text('Orders'),
        ),
        ButtonSegment(
          value: _OrderBookView.products,
          icon: Icon(Icons.inventory_2_outlined, size: 18),
          label: Text('Products'),
        ),
      ],
    );
  }
}

class _OrderTabs extends StatelessWidget {
  const _OrderTabs({
    required this.selectedIndex,
    required this.newCount,
    required this.pendingOfferCount,
    required this.onSelected,
  });

  final int selectedIndex;
  final int newCount;
  final int pendingOfferCount;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SegmentedButton<int>(
      showSelectedIcon: false,
      selected: {selectedIndex},
      onSelectionChanged: (selection) => onSelected(selection.first),
      segments: [
        ButtonSegment(value: 0, label: Text(l10n.activeLabel)),
        ButtonSegment(
          value: 1,
          label: Text(
            newCount > 0
                ? '${l10n.requestsLabel}  $newCount'
                : l10n.requestsLabel,
          ),
        ),
        ButtonSegment(value: 2, label: Text(l10n.historyLabel)),
        ButtonSegment(
          value: 3,
          label: Text(
            pendingOfferCount > 0
                ? 'Pending offers  $pendingOfferCount'
                : 'Pending offers',
          ),
        ),
      ],
    );
  }
}

class _PendingFeedOffer {
  const _PendingFeedOffer({required this.post, required this.offer});

  final FeedPost post;
  final FeedOffer offer;

  static List<_PendingFeedOffer> fromPosts(
    List<FeedPost> posts,
    String farmerId,
  ) {
    final result = <_PendingFeedOffer>[];
    for (final post in posts) {
      for (final offer in post.offers) {
        if (offer.authorId == farmerId &&
            offer.status == FeedOfferStatus.pending) {
          result.add(_PendingFeedOffer(post: post, offer: offer));
        }
      }
    }
    result.sort((a, b) => b.offer.createdAt.compareTo(a.offer.createdAt));
    return result;
  }
}

class _PendingFeedOffersList extends ConsumerWidget {
  const _PendingFeedOffersList({required this.offers});

  final List<_PendingFeedOffer> offers;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (offers.isEmpty) {
      return const _EmptyPendingOffers();
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
      itemCount: offers.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = offers[index];
        return _PendingFeedOfferCard(
          item: item,
          onOpenWall: () =>
              context.push('${AppRoutes.farmerCommunity}?post=${item.post.id}'),
          onCancel: () => ref
              .read(socialFeedControllerProvider.notifier)
              .cancelOffer(item.post.id, item.offer.id),
        );
      },
    );
  }
}

class _PendingFeedOfferCard extends StatelessWidget {
  const _PendingFeedOfferCard({
    required this.item,
    required this.onOpenWall,
    required this.onCancel,
  });

  final _PendingFeedOffer item;
  final VoidCallback onOpenWall;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final offer = item.offer;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.schedule_outlined),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Waiting for ${offer.targetCustomerName ?? 'customer'}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Chip(
                visualDensity: VisualDensity.compact,
                label: Text('Pending · ${formatPendingDuration(offer.createdAt)}'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            item.post.title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
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
            const SizedBox(height: 10),
            Text(
              'Customer asked: ${offer.sourceCommentText}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.tonalIcon(
                onPressed: onOpenWall,
                icon: const Icon(Icons.open_in_new_rounded),
                label: const Text('Open wall'),
              ),
              OutlinedButton.icon(
                onPressed: onCancel,
                icon: const Icon(Icons.cancel_outlined),
                label: const Text('Cancel offer'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyPendingOffers extends StatelessWidget {
  const _EmptyPendingOffers();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(28),
        child: Text('No pending offers waiting for customers.'),
      ),
    );
  }
}

class _ProductOrderGroup {
  const _ProductOrderGroup({
    required this.productId,
    required this.title,
    required this.unit,
    required this.orders,
  });

  final String productId;
  final String title;
  final String unit;
  final List<Deal> orders;

  double get totalQuantity =>
      orders.fold(0, (sum, order) => sum + order.quantity);

  double get totalValue =>
      orders.fold(0, (sum, order) => sum + order.quantity * order.price);

  DateTime get newestOrder => orders
      .map((order) => order.createdAt)
      .reduce((value, element) => value.isAfter(element) ? value : element);

  static List<_ProductOrderGroup> fromOrders(List<List<Deal>> orderGroups) {
    final byProduct = <String, List<Deal>>{};
    for (final group in orderGroups) {
      for (final order in group) {
        final key = '${order.productId}|${order.title}|${order.unit}';
        byProduct.putIfAbsent(key, () => []).add(order);
      }
    }

    final groups = byProduct.entries.map((entry) {
      final first = entry.value.first;
      return _ProductOrderGroup(
        productId: first.productId,
        title: first.title.split(' / ').first,
        unit: first.unit,
        orders: entry.value..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
      );
    }).toList();

    groups.sort((a, b) {
      final statusCompare = _productStatusRank(
        a.orders.first.status,
      ).compareTo(_productStatusRank(b.orders.first.status));
      if (statusCompare != 0) return statusCompare;
      return b.newestOrder.compareTo(a.newestOrder);
    });
    return groups;
  }

  static int _productStatusRank(DealStatus status) {
    return switch (status) {
      DealStatus.negotiating => 0,
      DealStatus.confirmed => 1,
      DealStatus.readyForPickup => 2,
      DealStatus.completed => 3,
      DealStatus.cancelled => 4,
    };
  }
}

class _ProductOrderCard extends StatelessWidget {
  const _ProductOrderCard({required this.group, required this.onOpenOrder});

  final _ProductOrderGroup group;
  final ValueChanged<Deal> onOpenOrder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final quantity = _formatQuantity(group.totalQuantity);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _ProductIcon(productId: group.productId),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${group.orders.length} ${group.orders.length == 1 ? 'order' : 'orders'}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$quantity ${group.unit}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    '€${group.totalValue.toStringAsFixed(2)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 8),
          ...group.orders.map((order) {
            final status = _statusStyle(order.status, theme);
            return InkWell(
              onTap: () => onOpenOrder(order),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _customerName(order.customerId),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            '${order.createdAt.day}.${order.createdAt.month}.${order.createdAt.year}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${_formatQuantity(order.quantity)} ${order.unit}',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: status.color.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        status.label,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: status.color,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.chevron_right_rounded),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  _StatusStyle _statusStyle(DealStatus status, ThemeData theme) {
    return switch (status) {
      DealStatus.negotiating => const _StatusStyle(
        'New request',
        Color(0xFFB36B18),
      ),
      DealStatus.confirmed => const _StatusStyle('Accepted', Color(0xFF315A87)),
      DealStatus.readyForPickup => const _StatusStyle(
        'Ready',
        Color(0xFF2F6B45),
      ),
      DealStatus.completed => const _StatusStyle(
        'Delivered',
        Color(0xFF667066),
      ),
      DealStatus.cancelled => _StatusStyle('Declined', theme.colorScheme.error),
    };
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.orders, required this.onOpen});

  final List<Deal> orders;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final order = orders.first;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final customer = _customerName(order.customerId);
    final status = _statusStyle(order.status, theme, l10n);
    final total = orders.fold<double>(
      0,
      (sum, item) => sum + item.quantity * item.price + item.deliveryFee,
    );
    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xFFE8EEE6),
                    foregroundColor: const Color(0xFF2F6B45),
                    child: Text(customer.substring(0, 1)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          customer,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          l10n.orderNumberLabel(
                            order.id.split('-').last.toUpperCase(),
                          ),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: status.color.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      status.label,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: status.color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F7F2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    _ProductIcon(productId: order.productId),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.productCountLabel(orders.length),
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            orders
                                .map((item) => item.title.split(' / ').first)
                                .join(' · '),
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '€${total.toStringAsFixed(2)}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Icon(
                    Icons.schedule_rounded,
                    size: 17,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      order.fulfillmentMethod == FulfillmentMethod.farmPickup
                          ? l10n.farmPickupLabel
                          : l10n.courierCollectionLabel,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                  Text(
                    '${order.createdAt.day}.${order.createdAt.month}.${order.createdAt.year}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    l10n.viewOrderLabel,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right_rounded),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  _StatusStyle _statusStyle(
    DealStatus status,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    return switch (status) {
      DealStatus.negotiating => _StatusStyle(
        l10n.newRequestStatus,
        const Color(0xFFB36B18),
      ),
      DealStatus.confirmed => _StatusStyle(
        l10n.acceptedStatus,
        const Color(0xFF315A87),
      ),
      DealStatus.readyForPickup => _StatusStyle(
        l10n.readyStatus,
        const Color(0xFF2F6B45),
      ),
      DealStatus.completed => _StatusStyle(
        l10n.deliveredStatus,
        const Color(0xFF667066),
      ),
      DealStatus.cancelled => _StatusStyle(
        l10n.declinedStatus,
        theme.colorScheme.error,
      ),
    };
  }
}

class _ProductIcon extends StatelessWidget {
  const _ProductIcon({required this.productId});

  final String productId;

  @override
  Widget build(BuildContext context) {
    final asset = switch (productId) {
      'product-potato' => 'assets/images/home/potatoes.png',
      'product-tomato' => 'assets/images/home/tomatoes.png',
      _ => 'assets/images/home/vegetables.png',
    };
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.asset(asset, width: 48, height: 48, fit: BoxFit.cover),
    );
  }
}

class _StatusStyle {
  const _StatusStyle(this.label, this.color);

  final String label;
  final Color color;
}

class _EmptyOrderBook extends StatelessWidget {
  const _EmptyOrderBook();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.receipt_long_outlined, size: 50),
            const SizedBox(height: 12),
            Text(l10n.noOrdersSectionMessage),
          ],
        ),
      ),
    );
  }
}

String _customerName(String customerId) {
  return switch (customerId) {
    'customer-emma' => 'Emma Wilson',
    'customer-liam' => 'Liam Korhonen',
    'customer-sofia' => 'Sofia Lind',
    'customer-aada' => 'Aada Virtanen',
    'customer-noah' => 'Noah Berg',
    'customer-olivia' => 'Olivia Martin',
    _ => 'FreshFarm customer',
  };
}

String _formatQuantity(double value) {
  return value.toStringAsFixed(value % 1 == 0 ? 0 : 1);
}
