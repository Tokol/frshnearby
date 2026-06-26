import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/router/app_routes.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../deals/domain/deal.dart';
import '../../deals/presentation/deal_controller.dart';
import '../../customer/presentation/cart_controller.dart';
import '../../social_feed/presentation/social_feed_controller.dart';
import '../../social_feed/presentation/social_feed_screen.dart';

enum AppShellMode { customer, farmer }

class AppShell extends ConsumerWidget {
  const AppShell({
    required this.navigationShell,
    required this.mode,
    super.key,
  });

  final StatefulNavigationShell navigationShell;
  final AppShellMode mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Column(
        children: [
          _PrototypeViewSwitcher(mode: mode),
          Expanded(child: navigationShell),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: mode == AppShellMode.customer
            ? _customerDestinations(context, ref)
            : _farmerDestinations(context, ref),
      ),
    );
  }

  List<NavigationDestination> _customerDestinations(
    BuildContext context,
    WidgetRef ref,
  ) {
    final l10n = AppLocalizations.of(context);
    final cartCount = ref.watch(cartControllerProvider).length;
    final user = ref.watch(authControllerProvider).user;
    final feed = ref.watch(socialFeedControllerProvider);
    final dealState = ref.watch(dealControllerProvider);
    final offerCount = visiblePendingFeedOffersForConsumer(
      feed.posts,
      viewerId: user?.id ?? 'customer-feed-viewer',
      viewerName: user?.name ?? 'Customer',
    ).length;
    final activeOrderCount = dealState.deals
        .where(
          (deal) =>
              deal.status == DealStatus.negotiating ||
              deal.status == DealStatus.confirmed ||
              deal.status == DealStatus.readyForPickup,
        )
        .map((deal) => deal.orderGroupId)
        .toSet()
        .length;
    final orderBadgeCount = cartCount + offerCount + activeOrderCount;

    return [
      const NavigationDestination(
        icon: Icon(Icons.map_outlined),
        selectedIcon: Icon(Icons.map_rounded),
        label: 'Explore',
      ),
      NavigationDestination(
        icon: const Icon(Icons.home_outlined),
        selectedIcon: const Icon(Icons.home),
        label: l10n.customerHomeTab,
      ),
      NavigationDestination(
        icon: const Icon(Icons.dynamic_feed_outlined),
        selectedIcon: const Icon(Icons.dynamic_feed_rounded),
        label: 'Feed',
      ),
      NavigationDestination(
        icon: Badge(
          isLabelVisible: orderBadgeCount > 0,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          label: Text('$orderBadgeCount'),
          child: const Icon(Icons.receipt_long_outlined),
        ),
        selectedIcon: Badge(
          isLabelVisible: orderBadgeCount > 0,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          label: Text('$orderBadgeCount'),
          child: const Icon(Icons.receipt_long),
        ),
        label: l10n.ordersTitle,
      ),
      NavigationDestination(
        icon: const Icon(Icons.person_outline),
        selectedIcon: const Icon(Icons.person),
        label: l10n.profileTab,
      ),
    ];
  }

  List<NavigationDestination> _farmerDestinations(
    BuildContext context,
    WidgetRef ref,
  ) {
    final l10n = AppLocalizations.of(context);
    final activeOrderCount =
        ref
            .watch(farmerDealsProvider)
            .valueOrNull
            ?.where(
              (order) =>
                  order.status == DealStatus.negotiating ||
                  order.status == DealStatus.confirmed ||
                  order.status == DealStatus.readyForPickup,
            )
            .map((order) => order.orderGroupId)
            .toSet()
            .length ??
        0;

    return [
      NavigationDestination(
        icon: const Icon(Icons.home_outlined),
        selectedIcon: const Icon(Icons.home_rounded),
        label: l10n.homeTabLabel,
      ),
      NavigationDestination(
        icon: Badge(
          isLabelVisible: activeOrderCount > 0,
          label: Text('$activeOrderCount'),
          child: const Icon(Icons.receipt_long_outlined),
        ),
        selectedIcon: Badge(
          isLabelVisible: activeOrderCount > 0,
          label: Text('$activeOrderCount'),
          child: const Icon(Icons.receipt_long_rounded),
        ),
        label: l10n.ordersTitle,
      ),
      NavigationDestination(
        icon: const Icon(Icons.insights_outlined),
        selectedIcon: const Icon(Icons.insights_rounded),
        label: l10n.insightsTabLabel,
      ),
    ];
  }
}

class _PrototypeViewSwitcher extends StatelessWidget {
  const _PrototypeViewSwitcher({required this.mode});

  final AppShellMode mode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainerLow,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 5, 12, 7),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                l10n.prototypeViewLabel,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 10),
              SegmentedButton<AppShellMode>(
                segments: [
                  ButtonSegment(
                    value: AppShellMode.farmer,
                    icon: const Icon(Icons.storefront_outlined, size: 16),
                    label: Text(l10n.farmerModeLabel),
                  ),
                  ButtonSegment(
                    value: AppShellMode.customer,
                    icon: const Icon(Icons.shopping_bag_outlined, size: 16),
                    label: Text(l10n.consumerModeLabel),
                  ),
                ],
                selected: {mode},
                showSelectedIcon: false,
                style: const ButtonStyle(
                  visualDensity: VisualDensity.compact,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onSelectionChanged: (selection) {
                  final selected = selection.first;
                  if (selected == mode) return;
                  context.go(
                    selected == AppShellMode.farmer
                        ? AppRoutes.farmerDashboard
                        : AppRoutes.customerHome,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
