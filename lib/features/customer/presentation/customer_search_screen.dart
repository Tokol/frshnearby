import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/loading_state.dart';
import '../../customer_marketplace/presentation/customer_marketplace_controller.dart';
import '../../customer_marketplace/presentation/listing_card.dart';

class CustomerSearchScreen extends ConsumerStatefulWidget {
  const CustomerSearchScreen({super.key});

  @override
  ConsumerState<CustomerSearchScreen> createState() =>
      _CustomerSearchScreenState();
}

class _CustomerSearchScreenState extends ConsumerState<CustomerSearchScreen> {
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
    final locale = Localizations.localeOf(context).languageCode;
    final listings = ref.watch(
      searchListingsProvider(
        SearchListingsQuery(query: _query, locale: locale),
      ),
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.customerSearchTitle)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: l10n.searchListingsHint,
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
          Expanded(
            child: listings.when(
              loading: () => LoadingState(message: l10n.loadingMessage),
              error: (_, _) => ErrorState(
                title: l10n.genericErrorTitle,
                message: l10n.genericErrorMessage,
              ),
              data: (items) {
                if (items.isEmpty) {
                  return EmptyState(
                    title: l10n.noListingsFoundTitle,
                    message: l10n.noListingsFoundMessage,
                    icon: Icons.search_off_outlined,
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final listing = items[index];
                    return ListingCard(
                      listing: listing,
                      onTap: () => context.go(
                        AppRoutes.customerListingDetail(listing.listing.id),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
