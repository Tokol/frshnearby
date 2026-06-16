import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../domain/customer_listing.dart';

final nearbyListingsProvider =
    FutureProvider.family<List<CustomerListing>, String>((ref, locale) {
      final repository = ref.watch(customerMarketplaceRepositoryProvider);
      return repository.getNearbyActiveListings(locale: locale);
    });

final searchListingsProvider =
    FutureProvider.family<List<CustomerListing>, SearchListingsQuery>((
      ref,
      query,
    ) {
      final repository = ref.watch(customerMarketplaceRepositoryProvider);
      return repository.searchListings(
        query: query.query,
        locale: query.locale,
      );
    });

final customerListingProvider =
    FutureProvider.family<CustomerListing?, ListingDetailQuery>((ref, query) {
      final repository = ref.watch(customerMarketplaceRepositoryProvider);
      return repository.getListing(
        listingId: query.listingId,
        locale: query.locale,
      );
    });

final farmerPublicProfileProvider = FutureProvider.family((
  ref,
  String farmerId,
) {
  final repository = ref.watch(customerMarketplaceRepositoryProvider);
  return repository.getFarmerProfile(farmerId);
});

class SearchListingsQuery {
  const SearchListingsQuery({required this.query, required this.locale});

  final String query;
  final String locale;

  @override
  bool operator ==(Object other) {
    return other is SearchListingsQuery &&
        other.query == query &&
        other.locale == locale;
  }

  @override
  int get hashCode => Object.hash(query, locale);
}

class ListingDetailQuery {
  const ListingDetailQuery({required this.listingId, required this.locale});

  final String listingId;
  final String locale;

  @override
  bool operator ==(Object other) {
    return other is ListingDetailQuery &&
        other.listingId == listingId &&
        other.locale == locale;
  }

  @override
  int get hashCode => Object.hash(listingId, locale);
}
