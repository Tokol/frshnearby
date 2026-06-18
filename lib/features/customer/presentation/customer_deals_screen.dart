import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../deals/presentation/deal_controller.dart';
import '../../deals/domain/deal.dart';
import '../../deals/domain/review_rating.dart';
import '../../../core/widgets/app_image.dart';
import '../../../core/widgets/farm_avatar.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../social_feed/domain/feed_post.dart';
import '../../social_feed/presentation/social_feed_controller.dart';
import '../../social_feed/presentation/social_feed_screen.dart';
import 'cart_controller.dart';
import 'fulfillment_controller.dart';
import 'payment_authorization_controller.dart';
import '../../../core/l10n/generated/app_localizations.dart';

class CustomerDealsScreen extends ConsumerStatefulWidget {
  const CustomerDealsScreen({super.key});

  @override
  ConsumerState<CustomerDealsScreen> createState() =>
      _CustomerDealsScreenState();
}

class _CustomerDealsScreenState extends ConsumerState<CustomerDealsScreen> {
  bool _checkingOut = false;
  int _section = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final items = ref.watch(cartControllerProvider);
    final dealState = ref.watch(dealControllerProvider);
    final feedState = ref.watch(socialFeedControllerProvider);
    final user = ref.watch(authControllerProvider).user;
    final activeOffers = visiblePendingFeedOffersForConsumer(
      feedState.posts,
      viewerId: user?.id ?? 'customer-feed-viewer',
      viewerName: user?.name ?? 'Customer',
    );
    final orderCount = dealState.deals
        .map((order) => order.orderGroupId)
        .toSet()
        .length;
    final fulfillment = ref.watch(fulfillmentControllerProvider);
    final subtotal = items.fold<double>(0, (sum, item) => sum + item.total);
    final pickupAvailable =
        items.isNotEmpty && items.first.listing.farmer.pickupAvailable;
    final distanceKm = items.isEmpty ? 0.0 : items.first.listing.distanceKm;
    final weightKg = items.fold<double>(0, (sum, item) => sum + item.quantity);
    final selectedMethod =
        !pickupAvailable && fulfillment.method == FulfillmentMethod.farmPickup
        ? FulfillmentMethod.courierDelivery
        : fulfillment.method;
    final deliveryFee = selectedMethod == FulfillmentMethod.courierDelivery
        ? courierDeliveryFee(distanceKm: distanceKm, weightKg: weightKg)
        : 0.0;
    final total = subtotal + deliveryFee;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.ordersTitle)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: SegmentedButton<int>(
              segments: [
                ButtonSegment(
                  value: 0,
                  icon: const Icon(Icons.local_offer_outlined),
                  label: Text(
                    activeOffers.isEmpty
                        ? 'Offers'
                        : 'Offers (${activeOffers.length})',
                  ),
                ),
                ButtonSegment(
                  value: 1,
                  icon: const Icon(Icons.shopping_bag_outlined),
                  label: Text(
                    items.isEmpty
                        ? l10n.cartLabel
                        : '${l10n.cartLabel} (${items.length})',
                  ),
                ),
                ButtonSegment(
                  value: 2,
                  icon: const Icon(Icons.receipt_long_outlined),
                  label: Text(
                    orderCount == 0
                        ? l10n.myOrdersLabel
                        : '${l10n.myOrdersLabel} ($orderCount)',
                  ),
                ),
              ],
              selected: {_section},
              showSelectedIcon: false,
              onSelectionChanged: (value) {
                setState(() => _section = value.first);
              },
            ),
          ),
          Expanded(
            child: switch (_section) {
              0 => _FeedOffersList(offers: activeOffers),
              1 =>
                items.isEmpty
                    ? const _EmptyCart()
                    : ListView(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 140),
                        children: [
                          ...items.map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _CartItemCard(item: item),
                            ),
                          ),
                          const SizedBox(height: 8),
                          _FulfillmentCard(
                            pickupAvailable: pickupAvailable,
                            selected: selectedMethod,
                            distanceKm: distanceKm,
                            weightKg: weightKg,
                            deliveryFee: deliveryFee,
                            onSelected: (method) => ref
                                .read(fulfillmentControllerProvider.notifier)
                                .select(method),
                          ),
                          const SizedBox(height: 12),
                          _Bill(
                            items: items,
                            subtotal: subtotal,
                            deliveryFee: deliveryFee,
                            total: total,
                          ),
                        ],
                      ),
              _ => _OrdersList(state: dealState),
            },
          ),
        ],
      ),
      bottomNavigationBar: _section != 1 || items.isEmpty
          ? null
          : SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
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
                          Text(l10n.totalLabel),
                          Text(
                            '€${total.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                          const Text(
                            'Authorized now · charged after acceptance',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    FilledButton(
                      onPressed: _checkingOut ? null : _showPaymentOptions,
                      child: _checkingOut
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(l10n.payAndRequestLabel),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _showPaymentOptions() async {
    final l10n = AppLocalizations.of(context);
    final method = await showModalBottomSheet<CustomerPaymentMethod>(
      context: context,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.payAndRequestLabel,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text(l10n.paymentAuthorizationInfo),
            const SizedBox(height: 16),
            _PaymentTile(
              icon: Icons.phone_iphone_rounded,
              title: 'MobilePay',
              subtitle: l10n.authorizeWithLabel('MobilePay'),
              onTap: () =>
                  Navigator.pop(context, CustomerPaymentMethod.mobilePay),
            ),
            _PaymentTile(
              icon: Icons.currency_exchange_rounded,
              title: 'Revolut',
              subtitle: l10n.authorizeWithLabel('Revolut'),
              onTap: () =>
                  Navigator.pop(context, CustomerPaymentMethod.revolut),
            ),
            _PaymentTile(
              icon: Icons.credit_card_rounded,
              title: l10n.cardLabel,
              subtitle: l10n.authorizeCardLabel,
              onTap: () => Navigator.pop(context, CustomerPaymentMethod.card),
            ),
          ],
        ),
      ),
    );
    if (method != null) await _checkout(method);
  }

  Future<void> _checkout(CustomerPaymentMethod method) async {
    final l10n = AppLocalizations.of(context);
    final items = List<CartItem>.of(ref.read(cartControllerProvider));
    if (items.isEmpty) return;
    final fulfillment = ref.read(fulfillmentControllerProvider);
    final pickupAvailable = items.first.listing.farmer.pickupAvailable;
    final selectedMethod =
        !pickupAvailable && fulfillment.method == FulfillmentMethod.farmPickup
        ? FulfillmentMethod.courierDelivery
        : fulfillment.method;
    final distanceKm = items.first.listing.distanceKm;
    final weightKg = items.fold<double>(0, (sum, item) => sum + item.quantity);
    final subtotal = items.fold<double>(0, (sum, item) => sum + item.total);
    final deliveryFee = selectedMethod == FulfillmentMethod.courierDelivery
        ? courierDeliveryFee(distanceKm: distanceKm, weightKg: weightKg)
        : 0.0;
    final orderGroupId = 'order-${DateTime.now().microsecondsSinceEpoch}';
    setState(() => _checkingOut = true);
    try {
      for (final item in items) {
        final allocatedDeliveryFee = subtotal == 0
            ? 0.0
            : deliveryFee * (item.total / subtotal);
        final thread = await ref
            .read(dealControllerProvider.notifier)
            .startChat(
              listingId: item.listing.listing.id,
              locale: Localizations.localeOf(context).languageCode,
              quantity: item.quantity,
              orderGroupId: orderGroupId,
              fulfillmentMethod: selectedMethod,
              deliveryFee: allocatedDeliveryFee,
              deliveryDistanceKm:
                  selectedMethod == FulfillmentMethod.courierDelivery
                  ? distanceKm
                  : null,
            );
        ref
            .read(paymentAuthorizationProvider.notifier)
            .authorize(thread.dealId, method);
      }
      ref.read(cartControllerProvider.notifier).clear();
      ref.read(fulfillmentControllerProvider.notifier).reset();
      HapticFeedback.mediumImpact();
      if (!mounted) return;
      setState(() => _section = 2);
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          icon: const Icon(Icons.check_circle_rounded, size: 42),
          title: Text(l10n.requestSentLabel),
          content: Text(
            l10n.requestSentPaymentMessage(paymentMethodLabel(method)),
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.doneLabel),
            ),
          ],
        ),
      );
    } finally {
      if (mounted) setState(() => _checkingOut = false);
    }
  }
}

class _FeedOffersList extends ConsumerWidget {
  const _FeedOffersList({required this.offers});

  final List<({FeedPost post, FeedOffer offer})> offers;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (offers.isEmpty) return const _EmptyOffers();

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      itemCount: offers.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = offers[index];
        return _FeedOfferDecisionCard(post: item.post, offer: item.offer);
      },
    );
  }
}

class _FeedOfferDecisionCard extends ConsumerWidget {
  const _FeedOfferDecisionCard({required this.post, required this.offer});

  final FeedPost post;
  final FeedOffer offer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FarmAvatar(farmName: post.authorName, radius: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.authorName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      'Offer from farmer',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '€${offer.price.toStringAsFixed(2)}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            offer.title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text('${offer.quantity} · ${offer.dateLabel}'),
          if (offer.note.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(offer.note),
          ],
          if (offer.sourceCommentText != null) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                offer.sourceCommentText!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => ref
                      .read(socialFeedControllerProvider.notifier)
                      .declineOffer(post.id, offer.id),
                  child: const Text('Decline'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => acceptFeedOfferFromPost(
                    context: context,
                    ref: ref,
                    post: post,
                    offer: offer,
                  ),
                  icon: const Icon(Icons.lock_outline_rounded),
                  label: const Text('Pay'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OrdersList extends ConsumerWidget {
  const _OrdersList({required this.state});

  final DealState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (state.isLoading && state.deals.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.deals.isEmpty) {
      return const _EmptyOrders();
    }
    final authorizations = ref.watch(paymentAuthorizationProvider);
    final grouped = <String, List<Deal>>{};
    for (final order in state.deals) {
      grouped.putIfAbsent(order.orderGroupId, () => []).add(order);
    }
    final orders = grouped.values.toList()
      ..sort((a, b) => b.first.createdAt.compareTo(a.first.createdAt));
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      itemCount: orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final order = orders[index];
        return _OrderCard(
          orders: order,
          authorization: authorizations[order.first.id],
        );
      },
    );
  }
}

class _OrderCard extends ConsumerWidget {
  const _OrderCard({required this.orders, required this.authorization});

  final List<Deal> orders;
  final PaymentAuthorization? authorization;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final order = orders.first;
    final rating = ref
        .read(dealControllerProvider.notifier)
        .ratingForDeal(order.id);
    final cancelled = order.status == DealStatus.cancelled;
    final productTotal = orders.fold<double>(
      0,
      (sum, item) => sum + item.price * item.quantity,
    );
    final deliveryFee = orders.fold<double>(
      0,
      (sum, item) => sum + item.deliveryFee,
    );
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: cancelled
              ? Theme.of(context).colorScheme.error.withValues(alpha: 0.35)
              : Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.farmName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(l10n.productCountLabel(orders.length)),
                  ],
                ),
              ),
              Text(
                '€${(productTotal + deliveryFee).toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: orders.map((item) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text('${_format(item.quantity)} ${item.unit}'),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Icon(
                order.fulfillmentMethod == FulfillmentMethod.farmPickup
                    ? Icons.storefront_outlined
                    : Icons.local_shipping_outlined,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  order.fulfillmentMethod == FulfillmentMethod.farmPickup
                      ? '${l10n.farmPickupLabel} · ${l10n.freeLabel}'
                      : '${l10n.courierDeliveryLabel} · €${deliveryFee.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (cancelled)
            _CancelledStatus(authorization: authorization)
          else ...[
            _OrderTimeline(order: order),
            const SizedBox(height: 14),
            Row(
              children: [
                const Icon(Icons.lock_outline_rounded, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(_paymentStatus(l10n, order, authorization)),
                ),
              ],
            ),
            if (order.status == DealStatus.completed) ...[
              const SizedBox(height: 14),
              _OrderReview(
                rating: rating,
                onRate: rating == null
                    ? () => context.push(AppRoutes.rateDeal(order.id))
                    : null,
              ),
            ],
          ],
        ],
      ),
    );
  }

  String _paymentStatus(
    AppLocalizations l10n,
    Deal order,
    PaymentAuthorization? authorization,
  ) {
    final method = authorization == null
        ? 'Payment'
        : paymentMethodLabel(authorization!.method);
    if (order.status == DealStatus.negotiating) {
      return l10n.paymentAuthorizedLabel(method);
    }
    return l10n.paymentChargedLabel(method);
  }
}

class _OrderTimeline extends StatelessWidget {
  const _OrderTimeline({required this.order});

  final Deal order;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final labels = [
      l10n.requestedStatus,
      l10n.acceptedStatus,
      l10n.readyStatus,
      l10n.deliveredStatus,
    ];
    final progress = switch (order.status) {
      DealStatus.negotiating => 0,
      DealStatus.confirmed => 1,
      DealStatus.readyForPickup => 2,
      DealStatus.completed => 3,
      DealStatus.cancelled => -1,
    };
    final activeColor = Theme.of(context).colorScheme.primary;
    final notes = <int, String>{};
    final timestamps = <int, DateTime>{0: order.createdAt};
    for (final update in order.statusUpdates) {
      final note = update.note;
      final index = switch (update.status) {
        DealStatus.negotiating => 0,
        DealStatus.confirmed => 1,
        DealStatus.readyForPickup => 2,
        DealStatus.completed => 3,
        DealStatus.cancelled => -1,
      };
      if (index >= 0) {
        timestamps[index] = update.timestamp;
        if (note != null && note.isNotEmpty) notes[index] = note;
      }
    }
    if (order.completedAt != null) timestamps[3] = order.completedAt!;
    return Column(
      children: List.generate(labels.length, (index) {
        final reached = index <= progress;
        final current = index == progress;
        final note = notes[index];
        final timestamp = timestamps[index];
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 28,
                child: Column(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: reached ? activeColor : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: reached
                              ? activeColor
                              : Theme.of(context).colorScheme.outlineVariant,
                          width: 2,
                        ),
                      ),
                      child: index < progress
                          ? const Icon(
                              Icons.check_rounded,
                              size: 13,
                              color: Colors.white,
                            )
                          : current
                          ? const Center(
                              child: CircleAvatar(
                                radius: 3,
                                backgroundColor: Colors.white,
                              ),
                            )
                          : null,
                    ),
                    if (index < labels.length - 1)
                      Expanded(
                        child: Container(
                          width: 2,
                          color: index < progress
                              ? activeColor
                              : Theme.of(context).colorScheme.outlineVariant,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
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
                          fontWeight: current
                              ? FontWeight.w900
                              : FontWeight.w600,
                          color: reached
                              ? Theme.of(context).colorScheme.onSurface
                              : Theme.of(context).colorScheme.onSurfaceVariant
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
                        const SizedBox(height: 4),
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
    );
  }
}

class _OrderReview extends StatelessWidget {
  const _OrderReview({required this.rating, this.onRate});

  final ReviewRating? rating;
  final VoidCallback? onRate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final value = rating;
    if (value == null) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: onRate,
          icon: const Icon(Icons.star_outline_rounded),
          label: Text(l10n.writeReviewLabel),
        ),
      );
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.reviewSubmittedLabel,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 5),
          Row(
            children: List.generate(
              5,
              (index) => Icon(
                index < value.stars ? Icons.star : Icons.star_border,
                size: 18,
                color: const Color(0xFFE09A24),
              ),
            ),
          ),
          if (value.text?.trim().isNotEmpty ?? false) ...[
            const SizedBox(height: 6),
            Text(value.text!),
          ],
        ],
      ),
    );
  }
}

class _CancelledStatus extends StatelessWidget {
  const _CancelledStatus({required this.authorization});

  final PaymentAuthorization? authorization;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        Icon(Icons.cancel_outlined, color: Theme.of(context).colorScheme.error),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            authorization == null
                ? l10n.declinedByFarmerLabel
                : l10n.declinedPaymentReleasedLabel,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
      ],
    );
  }
}

class _CartItemCard extends ConsumerWidget {
  const _CartItemCard({required this.item});

  final CartItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final listing = item.listing.listing;
    final controller = ref.read(cartControllerProvider.notifier);
    final image =
        listing.photoPlaceholder ??
        switch (listing.productId) {
          'product-potato' => 'assets/images/home/potatoes.png',
          'product-tomato' => 'assets/images/home/tomatoes.png',
          _ => 'assets/images/home/vegetables.png',
        };
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: AppImage(
                  image,
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.listing.variantName(locale) ??
                          item.listing.productName(locale),
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    Text(item.listing.farmer.farmName),
                    Text(
                      '€${listing.price.toStringAsFixed(2)} per ${listing.unit}',
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: l10n.removeTooltip,
                onPressed: () => controller.remove(listing.id),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              IconButton.filledTonal(
                onPressed: item.quantity <= 1
                    ? null
                    : () => controller.updateQuantity(
                        listing.id,
                        item.quantity - 1,
                      ),
                icon: const Icon(Icons.remove_rounded),
              ),
              SizedBox(
                width: 84,
                child: Text(
                  '${_format(item.quantity)} ${listing.unit}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
              IconButton.filledTonal(
                onPressed: () {
                  if (item.quantity >= listing.quantity) {
                    HapticFeedback.mediumImpact();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          l10n.onlyQuantityAvailableMessage(
                            _format(listing.quantity),
                            listing.unit,
                          ),
                        ),
                      ),
                    );
                    return;
                  }
                  controller.updateQuantity(listing.id, item.quantity + 1);
                },
                icon: const Icon(Icons.add_rounded),
              ),
              const Spacer(),
              Text(
                '€${item.total.toStringAsFixed(2)}',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FulfillmentCard extends StatelessWidget {
  const _FulfillmentCard({
    required this.pickupAvailable,
    required this.selected,
    required this.distanceKm,
    required this.weightKg,
    required this.deliveryFee,
    required this.onSelected,
  });

  final bool pickupAvailable;
  final FulfillmentMethod selected;
  final double distanceKm;
  final double weightKg;
  final double deliveryFee;
  final ValueChanged<FulfillmentMethod> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.fulfilmentQuestion,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          if (pickupAvailable)
            _FulfillmentOption(
              icon: Icons.storefront_outlined,
              title: l10n.pickupAtFarmLabel,
              subtitle: l10n.pickupLocationAfterAcceptance,
              selected: selected == FulfillmentMethod.farmPickup,
              onTap: () => onSelected(FulfillmentMethod.farmPickup),
            ),
          if (pickupAvailable) const SizedBox(height: 8),
          _FulfillmentOption(
            icon: Icons.local_shipping_outlined,
            title: l10n.courierDeliveryLabel,
            subtitle:
                '${distanceKm.toStringAsFixed(1)} km · ${_format(weightKg)} kg · €${deliveryFee.toStringAsFixed(2)}',
            selected: selected == FulfillmentMethod.courierDelivery,
            onTap: () => onSelected(FulfillmentMethod.courierDelivery),
          ),
          if (selected == FulfillmentMethod.courierDelivery) ...[
            const SizedBox(height: 12),
            Text(
              '€${courierBaseFee.toStringAsFixed(2)} base + €${courierRatePerKm.toStringAsFixed(2)}/km',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 3),
            Text(
              'Weight fee: €${courierWeightSurcharge(weightKg).toStringAsFixed(0)} · First 5 kg included, then €3 per additional 10 kg',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}

class _FulfillmentOption extends StatelessWidget {
  const _FulfillmentOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? Theme.of(context).colorScheme.primaryContainer
          : Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Icon(icon),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Icon(selected ? Icons.check_circle : Icons.circle_outlined),
            ],
          ),
        ),
      ),
    );
  }
}

class _Bill extends StatelessWidget {
  const _Bill({
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
  });

  final List<CartItem> items;
  final double subtotal;
  final double deliveryFee;
  final double total;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.billTitle,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 14),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${item.listing.productName(locale)} · ${_format(item.quantity)} ${item.listing.listing.unit}',
                    ),
                  ),
                  Text('€${item.total.toStringAsFixed(2)}'),
                ],
              ),
            ),
          ),
          const Divider(),
          Row(
            children: [
              Expanded(child: Text(l10n.productsLabel)),
              Text('€${subtotal.toStringAsFixed(2)}'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  deliveryFee == 0 ? l10n.farmPickupLabel : l10n.courierLabel,
                ),
              ),
              Text(
                deliveryFee == 0
                    ? l10n.freeLabel
                    : '€${deliveryFee.toStringAsFixed(2)}',
              ),
            ],
          ),
          const Divider(),
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.totalLabel,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              Text(
                '€${total.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PaymentTile extends StatelessWidget {
  const _PaymentTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(child: Icon(icon)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.shopping_bag_outlined, size: 52),
            const SizedBox(height: 14),
            Text(
              l10n.cartEmptyTitle,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text(l10n.cartEmptyMessage),
          ],
        ),
      ),
    );
  }
}

class _EmptyOffers extends StatelessWidget {
  const _EmptyOffers();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.local_offer_outlined, size: 52),
            const SizedBox(height: 14),
            const Text(
              'No active offers',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text(
              'When a farmer replies with an offer, it will appear here for quick payment.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyOrders extends StatelessWidget {
  const _EmptyOrders();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.receipt_long_outlined, size: 52),
            const SizedBox(height: 14),
            Text(
              l10n.ordersEmptyTitle,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text(l10n.ordersEmptyMessage),
          ],
        ),
      ),
    );
  }
}

String _format(double value) => value.toStringAsFixed(value % 1 == 0 ? 0 : 1);

String _formatStatusTimestamp(BuildContext context, DateTime value) {
  final localizations = MaterialLocalizations.of(context);
  return '${localizations.formatShortDate(value)} · '
      '${localizations.formatTimeOfDay(TimeOfDay.fromDateTime(value))}';
}
