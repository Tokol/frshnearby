import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../deals/domain/deal.dart';
import '../../deals/presentation/deal_controller.dart';

class FarmerDealsScreen extends ConsumerStatefulWidget {
  const FarmerDealsScreen({super.key});

  @override
  ConsumerState<FarmerDealsScreen> createState() => _FarmerDealsScreenState();
}

class _FarmerDealsScreenState extends ConsumerState<FarmerDealsScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ordersAsync = ref.watch(farmerDealsProvider);
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
                      onSelected: (index) {
                        setState(() => _selectedIndex = index);
                      },
                    ),
                  ),
                  Expanded(
                    child: filtered.isEmpty
                        ? const _EmptyOrderBook()
                        : ListView.separated(
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

class _OrderTabs extends StatelessWidget {
  const _OrderTabs({
    required this.selectedIndex,
    required this.newCount,
    required this.onSelected,
  });

  final int selectedIndex;
  final int newCount;
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
      ],
    );
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
    final customer = switch (order.customerId) {
      'customer-emma' => 'Emma Wilson',
      'customer-liam' => 'Liam Korhonen',
      'customer-sofia' => 'Sofia Lind',
      _ => 'FreshFarm customer',
    };
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
