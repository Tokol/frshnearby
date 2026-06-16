import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/router/app_routes.dart';
import '../../deals/domain/deal.dart';
import '../../deals/presentation/deal_controller.dart';
import '../../customer/presentation/cart_controller.dart';

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
    if (mode == AppShellMode.customer) {
      return Scaffold(
        body: Column(
          children: [
            _PrototypeViewSwitcher(mode: mode),
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(child: navigationShell),
                  if (navigationShell.currentIndex != 3)
                    _CustomerFloatingActions(navigationShell: navigationShell),
                ],
              ),
            ),
          ],
        ),
      );
    }

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
            ? _customerDestinations(context)
            : _farmerDestinations(context, ref),
      ),
    );
  }

  List<NavigationDestination> _customerDestinations(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return [
      NavigationDestination(
        icon: const Icon(Icons.home_outlined),
        selectedIcon: const Icon(Icons.home),
        label: l10n.customerHomeTab,
      ),
      NavigationDestination(
        icon: const Icon(Icons.search_outlined),
        selectedIcon: const Icon(Icons.search),
        label: l10n.customerSearchTab,
      ),
      NavigationDestination(
        icon: const Icon(Icons.chat_bubble_outline),
        selectedIcon: const Icon(Icons.chat_bubble),
        label: l10n.messagesTab,
      ),
      NavigationDestination(
        icon: const Icon(Icons.local_offer_outlined),
        selectedIcon: const Icon(Icons.local_offer),
        label: l10n.dealsTab,
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

class _CustomerFloatingActions extends ConsumerWidget {
  const _CustomerFloatingActions({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final cartCount = ref.watch(cartControllerProvider).length;

    return Positioned(
      left: 0,
      right: 0,
      bottom: MediaQuery.paddingOf(context).bottom + 16,
      child: Center(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FilledButton.icon(
                  onPressed: () {
                    navigationShell.goBranch(
                      1,
                      initialLocation: navigationShell.currentIndex == 1,
                    );
                  },
                  icon: const Icon(Icons.manage_search_rounded),
                  label: Text(l10n.customerSearchTab),
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  tooltip: l10n.cartLabel,
                  onPressed: () {
                    navigationShell.goBranch(
                      3,
                      initialLocation: navigationShell.currentIndex == 3,
                    );
                  },
                  icon: Badge(
                    isLabelVisible: cartCount > 0,
                    label: Text('$cartCount'),
                    child: const Icon(Icons.shopping_bag_outlined),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
