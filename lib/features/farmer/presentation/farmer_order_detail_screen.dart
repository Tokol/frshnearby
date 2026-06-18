import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../deals/domain/deal.dart';
import '../../deals/domain/review_rating.dart';
import '../../deals/presentation/deal_controller.dart';

Deal _paidFeedOfferOrder(Deal order) {
  final isFeedOffer =
      order.listingId.startsWith('feed-post-') ||
      order.productId.startsWith('feed-offer-');
  if (!isFeedOffer || order.status != DealStatus.negotiating) {
    return order;
  }
  final hasAcceptedUpdate = order.statusUpdates.any(
    (update) => update.status == DealStatus.confirmed,
  );
  return order.copyWith(
    status: DealStatus.confirmed,
    statusUpdates: hasAcceptedUpdate
        ? order.statusUpdates
        : [
            ...order.statusUpdates,
            DealStatusUpdate(
              status: DealStatus.confirmed,
              timestamp: order.createdAt,
              note: 'Payment received from accepted feed offer.',
            ),
          ],
  );
}

class FarmerOrderDetailScreen extends ConsumerWidget {
  const FarmerOrderDetailScreen({required this.orderId, super.key});

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final orders = ref.watch(farmerDealsProvider).valueOrNull ?? const <Deal>[];
    final order = orders.where((item) => item.id == orderId).firstOrNull;
    if (order == null) {
      return Scaffold(body: Center(child: Text(l10n.orderNotFoundMessage)));
    }
    final statusOrder = _paidFeedOfferOrder(order);
    final orderItems = orders
        .where((item) => item.orderGroupId == order.orderGroupId)
        .toList();
    final rating = ref
        .read(dealControllerProvider.notifier)
        .ratingForDeal(order.id);
    final customer = _customerFor(order.customerId);
    final customerOrders = orders
        .where((item) => item.customerId == order.customerId)
        .toList();
    final customerOrderCount = customerOrders
        .map((item) => item.orderGroupId)
        .toSet()
        .length;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.orderDetailsTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 120),
        children: [
          _CustomerCard(customer: customer, orderCount: customerOrderCount),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _ContactButton(
                  icon: Icons.call_outlined,
                  label: l10n.callLabel,
                  onTap: () => _launch('tel:${customer.phone}'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ContactButton(
                  icon: Icons.sms_outlined,
                  label: l10n.textLabel,
                  onTap: () => _launch('sms:${customer.phone}'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ContactButton(
                  icon: Icons.mail_outline_rounded,
                  label: l10n.emailLabel,
                  onTap: () => _launch('mailto:${customer.email}'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _Title(l10n.orderLabel),
          const SizedBox(height: 10),
          _OrderSummary(orders: orderItems),
          const SizedBox(height: 24),
          _Title(
            order.fulfillmentMethod == FulfillmentMethod.farmPickup
                ? l10n.customerPickupLabel
                : l10n.courierCollectionLabel,
          ),
          const SizedBox(height: 10),
          _InfoCard(
            icon: order.fulfillmentMethod == FulfillmentMethod.farmPickup
                ? Icons.location_on_outlined
                : Icons.local_shipping_outlined,
            title: order.fulfillmentMethod == FulfillmentMethod.farmPickup
                ? l10n.customerWillCollectLabel
                : l10n.courierWillCollectLabel,
            body: order.fulfillmentMethod == FulfillmentMethod.farmPickup
                ? l10n.preparePickupMessage
                : l10n.prepareCourierMessage,
          ),
          const SizedBox(height: 24),
          _Title(l10n.statusLabel),
          const SizedBox(height: 10),
          _StatusTimeline(order: statusOrder),
          if (statusOrder.status == DealStatus.completed) ...[
            const SizedBox(height: 16),
            _FarmerReviewCard(rating: rating),
          ],
          const SizedBox(height: 24),
          if (statusOrder.status == DealStatus.negotiating)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => ref
                        .read(dealControllerProvider.notifier)
                        .updateOrderGroupStatus(
                          orderItems,
                          DealStatus.cancelled,
                        ),
                    child: Text(l10n.declineLabel),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: FilledButton.icon(
                    onPressed: () async {
                      final result = await _showStatusNoteSheet(
                        context,
                        title: l10n.acceptOrderLabel,
                        actionLabel: l10n.acceptLabel,
                        suggestions: const [
                          'Ready today',
                          'Ready tomorrow',
                          'Please call on arrival',
                        ],
                      );
                      if (result == null) return;
                      await ref
                          .read(dealControllerProvider.notifier)
                          .acceptFarmerOrderGroup(orderItems, note: result);
                    },
                    icon: const Icon(Icons.check_rounded),
                    label: Text(l10n.acceptRequestLabel),
                  ),
                ),
              ],
            ),
          if (statusOrder.status == DealStatus.confirmed)
            FilledButton.icon(
              onPressed: () async {
                final isPickup =
                    order.fulfillmentMethod == FulfillmentMethod.farmPickup;
                final result = await _showStatusNoteSheet(
                  context,
                  title: isPickup ? 'Ready for pickup' : 'Ready for courier',
                  actionLabel: 'Mark ready',
                  suggestions: isPickup
                      ? const [
                          'Bring your own bag',
                          'Call on arrival',
                          'Collect from the farm gate',
                        ]
                      : const ['Keep refrigerated', 'Fragile', 'Keep upright'],
                );
                if (result == null) return;
                await ref
                    .read(dealControllerProvider.notifier)
                    .updateOrderGroupStatus(
                      orderItems,
                      DealStatus.readyForPickup,
                      note: result,
                    );
              },
              icon: const Icon(Icons.inventory_2_outlined),
              label: Text(
                order.fulfillmentMethod == FulfillmentMethod.farmPickup
                    ? 'Mark ready for pickup'
                    : 'Mark ready for courier',
              ),
            ),
          if (statusOrder.status == DealStatus.readyForPickup)
            FilledButton.icon(
              onPressed: () async {
                final result = await _showStatusNoteSheet(
                  context,
                  title: order.fulfillmentMethod == FulfillmentMethod.farmPickup
                      ? 'Order collected'
                      : 'Courier collected order',
                  actionLabel: 'Complete order',
                  suggestions: const [],
                );
                if (result == null) return;
                await ref
                    .read(dealControllerProvider.notifier)
                    .updateOrderGroupStatus(
                      orderItems,
                      DealStatus.completed,
                      note: result,
                    );
              },
              icon: const Icon(Icons.done_all_rounded),
              label: Text(
                order.fulfillmentMethod == FulfillmentMethod.farmPickup
                    ? 'Mark collected'
                    : 'Mark collected by courier',
              ),
            ),
          const SizedBox(height: 28),
          _Title(l10n.customerHistoryLabel),
          const SizedBox(height: 10),
          ...customerOrders.map(
            (item) => ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(item.title),
              subtitle: Text('${item.quantity} ${item.unit}'),
              trailing: Text(
                '€${(item.quantity * item.price).toStringAsFixed(2)}',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launch(String value) async {
    final uri = Uri.parse(value);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

Future<String?> _showStatusNoteSheet(
  BuildContext context, {
  required String title,
  required String actionLabel,
  required List<String> suggestions,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => _StatusNoteSheet(
      title: title,
      actionLabel: actionLabel,
      suggestions: suggestions,
    ),
  );
}

class _StatusNoteSheet extends StatefulWidget {
  const _StatusNoteSheet({
    required this.title,
    required this.actionLabel,
    required this.suggestions,
  });

  final String title;
  final String actionLabel;
  final List<String> suggestions;

  @override
  State<_StatusNoteSheet> createState() => _StatusNoteSheetState();
}

class _StatusNoteSheetState extends State<_StatusNoteSheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          0,
          20,
          MediaQuery.viewInsetsOf(context).bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            if (widget.suggestions.isNotEmpty) ...[
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.suggestions.map((suggestion) {
                  return ActionChip(
                    label: Text(suggestion),
                    onPressed: () {
                      setState(() => _controller.text = suggestion);
                    },
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 14),
            TextField(
              controller: _controller,
              maxLines: 2,
              maxLength: 120,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).addOptionalNoteLabel,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () =>
                    Navigator.pop(context, _controller.text.trim()),
                child: Text(widget.actionLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Customer {
  const _Customer(this.name, this.phone, this.email, this.location);
  final String name;
  final String phone;
  final String email;
  final String location;
}

_Customer _customerFor(String id) => switch (id) {
  'customer-emma' => const _Customer(
    'Emma Wilson',
    '+358401112233',
    'emma@example.com',
    'Vaasa',
  ),
  'customer-liam' => const _Customer(
    'Liam Korhonen',
    '+358442223344',
    'liam@example.com',
    'Mustasaari',
  ),
  'customer-sofia' => const _Customer(
    'Sofia Lind',
    '+358503334455',
    'sofia@example.com',
    'Vaasa',
  ),
  _ => const _Customer(
    'FreshFarm customer',
    '+358400000000',
    'customer@example.com',
    'Ostrobothnia',
  ),
};

class _CustomerCard extends StatelessWidget {
  const _CustomerCard({required this.customer, required this.orderCount});
  final _Customer customer;
  final int orderCount;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          CircleAvatar(radius: 30, child: Text(customer.name.substring(0, 1))),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customer.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${customer.location}  •  ${AppLocalizations.of(context).customerOrderCountLabel(orderCount)}',
                ),
                const SizedBox(height: 3),
                Text(customer.phone),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _ContactButton extends StatelessWidget {
  const _ContactButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
    onPressed: onTap,
    icon: Icon(icon, size: 19),
    label: Text(label),
  );
}

class _Title extends StatelessWidget {
  const _Title(this.value);
  final String value;
  @override
  Widget build(BuildContext context) => Text(
    value,
    style: Theme.of(
      context,
    ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
  );
}

class _OrderSummary extends StatelessWidget {
  const _OrderSummary({required this.orders});
  final List<Deal> orders;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          ...orders.map(
            (order) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          '${order.quantity} ${order.unit} · €${order.price.toStringAsFixed(2)} / ${order.unit}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '€${(order.quantity * order.price).toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
          const Divider(),
          _Row(
            'Total',
            '€${orders.fold<double>(0, (sum, order) => sum + order.quantity * order.price + order.deliveryFee).toStringAsFixed(2)}',
            bold: true,
          ),
        ],
      ),
    ),
  );
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value, {this.bold = false});
  final String label;
  final String value;
  final bool bold;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(
      children: [
        Expanded(child: Text(label)),
        Text(
          value,
          style: TextStyle(
            fontWeight: bold ? FontWeight.w900 : FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.body,
  });
  final IconData icon;
  final String title;
  final String body;
  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      contentPadding: const EdgeInsets.all(14),
      leading: Icon(icon, color: const Color(0xFF2F6B45)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
      subtitle: Text(body),
    ),
  );
}

class _StatusTimeline extends StatelessWidget {
  const _StatusTimeline({required this.order});

  final Deal order;

  @override
  Widget build(BuildContext context) {
    final current = switch (order.status) {
      DealStatus.negotiating => 0,
      DealStatus.confirmed => 1,
      DealStatus.readyForPickup => 2,
      DealStatus.completed => 3,
      DealStatus.cancelled => -1,
    };
    final l10n = AppLocalizations.of(context);
    final labels = [
      l10n.requestedStatus,
      l10n.acceptedStatus,
      l10n.readyStatus,
      l10n.deliveredStatus,
    ];
    final notes = <DealStatus, String>{};
    final timestamps = <DealStatus, DateTime>{
      DealStatus.negotiating: order.createdAt,
    };
    for (final update in order.statusUpdates) {
      final note = update.note;
      if (note != null && note.isNotEmpty) notes[update.status] = note;
      timestamps[update.status] = update.timestamp;
    }
    if (order.completedAt != null) {
      timestamps[DealStatus.completed] = order.completedAt!;
    }
    const statuses = [
      DealStatus.negotiating,
      DealStatus.confirmed,
      DealStatus.readyForPickup,
      DealStatus.completed,
    ];
    final activeColor = Theme.of(context).colorScheme.primary;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: List.generate(labels.length, (index) {
            final reached = current >= index;
            final isCurrent = current == index;
            final note = notes[statuses[index]];
            final timestamp = timestamps[statuses[index]];
            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: 24,
                    child: Column(
                      children: [
                        Icon(
                          index < current
                              ? Icons.check_circle_rounded
                              : isCurrent
                              ? Icons.radio_button_checked_rounded
                              : Icons.radio_button_unchecked_rounded,
                          size: 21,
                          color: reached
                              ? activeColor
                              : Theme.of(context).colorScheme.outlineVariant,
                        ),
                        if (index < labels.length - 1)
                          Expanded(
                            child: Container(
                              width: 2,
                              color: index < current
                                  ? activeColor
                                  : Theme.of(
                                      context,
                                    ).colorScheme.outlineVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        bottom: index == labels.length - 1 ? 0 : 16,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            labels[index],
                            style: TextStyle(
                              fontWeight: isCurrent
                                  ? FontWeight.w900
                                  : FontWeight.w600,
                              color: reached
                                  ? Theme.of(context).colorScheme.onSurface
                                  : Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant
                                        .withValues(alpha: 0.55),
                            ),
                          ),
                          if (timestamp != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              _formatStatusTimestamp(context, timestamp),
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                          if (note != null) ...[
                            const SizedBox(height: 5),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.notes_rounded, size: 15),
                                  const SizedBox(width: 6),
                                  Expanded(child: Text(note)),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _FarmerReviewCard extends StatelessWidget {
  const _FarmerReviewCard({required this.rating});

  final ReviewRating? rating;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final value = rating;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.customerReviewLabel,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            if (value == null)
              Text(l10n.noReviewYetLabel)
            else ...[
              Row(
                children: [
                  ...List.generate(
                    5,
                    (index) => Icon(
                      index < value.stars ? Icons.star : Icons.star_border,
                      size: 20,
                      color: const Color(0xFFE09A24),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatStatusTimestamp(context, value.createdAt),
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                l10n.verifiedCustomerLabel,
                style: Theme.of(context).textTheme.labelMedium,
              ),
              if (value.text?.trim().isNotEmpty ?? false) ...[
                const SizedBox(height: 8),
                Text(value.text!),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

String _formatStatusTimestamp(BuildContext context, DateTime value) {
  final localizations = MaterialLocalizations.of(context);
  return '${localizations.formatShortDate(value)} · '
      '${localizations.formatTimeOfDay(TimeOfDay.fromDateTime(value))}';
}
