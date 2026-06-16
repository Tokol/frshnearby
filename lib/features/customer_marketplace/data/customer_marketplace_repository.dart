import 'dart:math' as math;

import '../../auth/domain/farmer_profile.dart';
import '../../catalog/data/catalog_repository.dart';
import '../../catalog/domain/catalog_category.dart';
import '../../catalog/domain/catalog_product.dart';
import '../../catalog/domain/catalog_suggestion.dart';
import '../../catalog/domain/product_variant.dart';
import '../../listings/domain/listing.dart';
import '../domain/customer_listing.dart';
import '../domain/farmer_public_profile.dart';

abstract class CustomerMarketplaceRepository {
  Future<List<CustomerListing>> getNearbyActiveListings({
    required String locale,
    double customerLatitude = 63.0951,
    double customerLongitude = 21.6165,
  });

  Future<List<CustomerListing>> searchListings({
    required String query,
    required String locale,
    double customerLatitude = 63.0951,
    double customerLongitude = 21.6165,
  });

  Future<CustomerListing?> getListing({
    required String listingId,
    required String locale,
    double customerLatitude = 63.0951,
    double customerLongitude = 21.6165,
  });

  Future<FarmerPublicProfile?> getFarmerProfile(String farmerId);

  Future<void> recordFarmerRating({
    required String farmerId,
    required int stars,
  });

  Future<void> updateListingInventory({
    required String listingId,
    required double quantity,
    required ListingStatus status,
  });

  Future<void> replaceFarmerListings({
    required String farmerId,
    required List<Listing> listings,
  });

  Future<void> updateFarmerProfile(FarmerProfile profile);
}

class MockCustomerMarketplaceRepository
    implements CustomerMarketplaceRepository {
  MockCustomerMarketplaceRepository({
    required CatalogRepository catalogRepository,
    List<Listing>? sharedListings,
  }) : _catalogRepository = catalogRepository,
       _marketplaceListings = _withMarketplaceSeeds(sharedListings);

  final CatalogRepository _catalogRepository;
  // TODO(backend): Replace seeded farmers/listings with paginated marketplace API.
  final List<FarmerPublicProfile> _farmers = List.of(_seedFarmers);
  final List<Listing> _marketplaceListings;

  static List<Listing> _withMarketplaceSeeds(List<Listing>? sharedListings) {
    final listings = sharedListings ?? <Listing>[];
    final existingIds = listings.map((listing) => listing.id).toSet();
    listings.addAll(
      _seedListings.where((listing) => !existingIds.contains(listing.id)),
    );
    return listings;
  }

  @override
  Future<void> replaceFarmerListings({
    required String farmerId,
    required List<Listing> listings,
  }) async {
    if (identical(_marketplaceListings, listings)) return;
    _marketplaceListings.removeWhere(
      (listing) => listing.farmerId == farmerId,
    );
    _marketplaceListings.addAll(listings);
  }

  @override
  Future<void> updateFarmerProfile(FarmerProfile profile) async {
    final index = _farmers.indexWhere((farmer) => farmer.id == profile.id);
    if (index == -1) {
      return;
    }
    _farmers[index] = _farmers[index].copyWith(
      displayName: profile.displayName,
      farmName: profile.farmName,
      city: profile.city,
      country: profile.country,
      shortDescription: profile.shortDescription,
      profilePhotoPlaceholder: profile.profilePhotoPlaceholder,
      coverPhotoPlaceholder: profile.coverPhotoPlaceholder,
      pickupNote: profile.pickupNote,
      pickupAvailable: profile.pickupAvailable,
      pickupAtFarm: profile.pickupAtFarm,
      pickupAddress: profile.pickupAddress,
    );
  }

  @override
  Future<void> updateListingInventory({
    required String listingId,
    required double quantity,
    required ListingStatus status,
  }) async {
    final index = _marketplaceListings.indexWhere(
      (listing) => listing.id == listingId,
    );
    if (index == -1) {
      return;
    }
    _marketplaceListings[index] = _marketplaceListings[index].copyWith(
      quantity: quantity,
      status: status,
    );
  }

  @override
  Future<List<CustomerListing>> getNearbyActiveListings({
    required String locale,
    double customerLatitude = 63.0951,
    double customerLongitude = 21.6165,
  }) async {
    final listings = _visibleListings(
      customerLatitude: customerLatitude,
      customerLongitude: customerLongitude,
    );
    listings.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    return listings;
  }

  @override
  Future<List<CustomerListing>> searchListings({
    required String query,
    required String locale,
    double customerLatitude = 63.0951,
    double customerLongitude = 21.6165,
  }) async {
    final normalizedQuery = query.trim();
    final listings = await getNearbyActiveListings(
      locale: locale,
      customerLatitude: customerLatitude,
      customerLongitude: customerLongitude,
    );
    if (normalizedQuery.isEmpty) {
      return listings;
    }

    final suggestions = await _catalogRepository.searchSuggestions(
      query: normalizedQuery,
      locale: locale,
    );
    final categoryIds = <String>{};
    final productIds = <String>{};
    final variantIds = <String>{};

    for (final suggestion in suggestions) {
      switch (suggestion.type) {
        case CatalogSuggestionType.category:
          final category = suggestion.category;
          if (category != null) {
            categoryIds.add(category.id);
          }
        case CatalogSuggestionType.product:
          final product = suggestion.product;
          if (product != null) {
            productIds.add(product.id);
          }
        case CatalogSuggestionType.variant:
          final variant = suggestion.variant;
          final product = suggestion.product;
          if (variant != null) {
            variantIds.add(variant.id);
          }
          if (product != null) {
            productIds.add(product.id);
          }
      }
    }

    return listings.where((item) {
      return categoryIds.contains(item.listing.categoryId) ||
          productIds.contains(item.listing.productId) ||
          (item.listing.variantId != null &&
              variantIds.contains(item.listing.variantId));
    }).toList();
  }

  @override
  Future<CustomerListing?> getListing({
    required String listingId,
    required String locale,
    double customerLatitude = 63.0951,
    double customerLongitude = 21.6165,
  }) async {
    for (final listing in _visibleListings(
      customerLatitude: customerLatitude,
      customerLongitude: customerLongitude,
    )) {
      if (listing.listing.id == listingId) {
        return listing;
      }
    }
    return null;
  }

  @override
  Future<FarmerPublicProfile?> getFarmerProfile(String farmerId) async {
    for (final farmer in _farmers) {
      if (farmer.id == farmerId && farmer.isVerified) {
        return farmer;
      }
    }
    return null;
  }

  @override
  Future<void> recordFarmerRating({
    required String farmerId,
    required int stars,
  }) async {
    final index = _farmers.indexWhere((farmer) => farmer.id == farmerId);
    if (index == -1) {
      return;
    }

    final farmer = _farmers[index];
    final ratingTotal = farmer.rating * farmer.reviewCount + stars;
    final ratingCount = farmer.reviewCount + 1;
    _farmers[index] = farmer.copyWith(
      rating: ratingTotal / ratingCount,
      reviewCount: ratingCount,
    );
  }

  List<CustomerListing> _visibleListings({
    required double customerLatitude,
    required double customerLongitude,
  }) {
    final result = <CustomerListing>[];
    for (final listing in _marketplaceListings) {
      if (listing.status != ListingStatus.active) {
        continue;
      }

      final farmer = _farmerById(listing.farmerId);
      if (farmer == null || !farmer.isVerified) {
        continue;
      }

      final category = _categoryById(listing.categoryId);
      final product = _productById(listing.productId);
      if (category == null || product == null) {
        continue;
      }

      result.add(
        CustomerListing(
          listing: listing,
          farmer: farmer,
          category: category,
          product: product,
          variant: _variantById(listing.variantId),
          distanceKm: _distanceKm(
            customerLatitude,
            customerLongitude,
            listing.latitude,
            listing.longitude,
          ),
        ),
      );
    }
    return result;
  }

  FarmerPublicProfile? _farmerById(String id) {
    for (final farmer in _farmers) {
      if (farmer.id == id) {
        return farmer;
      }
    }
    return null;
  }

  CatalogCategory? _categoryById(String id) {
    for (final category in _catalogRepository.categories) {
      if (category.id == id) {
        return category;
      }
    }
    return null;
  }

  CatalogProduct? _productById(String id) {
    for (final product in _catalogRepository.products) {
      if (product.id == id) {
        return product;
      }
    }
    return null;
  }

  ProductVariant? _variantById(String? id) {
    if (id == null) {
      return null;
    }
    for (final variant in _catalogRepository.variants) {
      if (variant.id == id) {
        return variant;
      }
    }
    return null;
  }

  double _distanceKm(
    double fromLatitude,
    double fromLongitude,
    double toLatitude,
    double toLongitude,
  ) {
    const earthRadiusKm = 6371.0;
    final dLat = _degreesToRadians(toLatitude - fromLatitude);
    final dLon = _degreesToRadians(toLongitude - fromLongitude);
    final lat1 = _degreesToRadians(fromLatitude);
    final lat2 = _degreesToRadians(toLatitude);
    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) *
            math.cos(lat2) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    return earthRadiusKm * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  double _degreesToRadians(double degrees) => degrees * math.pi / 180;
}

const _seedFarmers = [
  FarmerPublicProfile(
    id: 'farmer-1',
    displayName: 'North Field Farm',
    farmName: 'North Field Farm',
    city: 'Vaasa',
    country: 'Finland',
    rating: 4.8,
    reviewCount: 124,
    status: FarmerVerificationStatus.verified,
    shortDescription: 'Seasonal vegetables and small-batch produce.',
  ),
  FarmerPublicProfile(
    id: 'farmer-2',
    displayName: 'Meadow Honey',
    farmName: 'Meadow Honey',
    city: 'Espoo',
    country: 'Finland',
    rating: 4.9,
    reviewCount: 72,
    status: FarmerVerificationStatus.verified,
    shortDescription: 'Local honey from small apiaries.',
  ),
  FarmerPublicProfile(
    id: 'farmer-pending',
    displayName: 'Pending Grower',
    farmName: 'Pending Grower',
    city: 'Vantaa',
    country: 'Finland',
    rating: 0,
    reviewCount: 0,
    status: FarmerVerificationStatus.pendingReview,
    shortDescription: 'Not visible until verified.',
  ),
];

final _seedListings = [
  Listing(
    id: 'public-listing-potato',
    farmerId: 'farmer-1',
    categoryId: 'category-vegetables',
    productId: 'product-potato',
    variantId: 'variant-new-potato',
    title: 'New potato',
    description: 'Fresh early potatoes from this week.',
    quantity: 25,
    unit: 'kg',
    price: 3.8,
    latitude: 63.0951,
    longitude: 21.6165,
    status: ListingStatus.active,
    createdAt: DateTime(2026, 6, 1),
    pickupNotes: 'Exact pickup location is shared after deal confirmation.',
  ),
  Listing(
    id: 'public-listing-tomato',
    farmerId: 'farmer-1',
    categoryId: 'category-vegetables',
    productId: 'product-tomato',
    variantId: 'variant-cherry-tomato',
    title: 'Cherry tomato',
    description: 'Sweet greenhouse cherry tomatoes.',
    quantity: 12,
    unit: 'kg',
    price: 6.5,
    latitude: 60.2055,
    longitude: 24.6559,
    status: ListingStatus.active,
    createdAt: DateTime(2026, 6, 2),
  ),
  Listing(
    id: 'public-listing-honey',
    farmerId: 'farmer-2',
    categoryId: 'category-honey',
    productId: 'product-honey',
    title: 'Honey',
    description: 'Raw local honey.',
    quantity: 18,
    unit: 'jar',
    price: 8.9,
    latitude: 60.2055,
    longitude: 24.6559,
    status: ListingStatus.active,
    createdAt: DateTime(2026, 6, 3),
  ),
  Listing(
    id: 'sold-out-apple',
    farmerId: 'farmer-1',
    categoryId: 'category-fruits',
    productId: 'product-apple',
    variantId: 'variant-red-apple',
    title: 'Red apple',
    description: 'Sold-out listing should not appear.',
    quantity: 0,
    unit: 'kg',
    price: 4,
    latitude: 63.0951,
    longitude: 21.6165,
    status: ListingStatus.soldOut,
    createdAt: DateTime(2026, 6, 4),
  ),
  Listing(
    id: 'hidden-unverified-carrot',
    farmerId: 'farmer-pending',
    categoryId: 'category-vegetables',
    productId: 'product-carrot',
    title: 'Carrot',
    description: 'Unverified farmer listing should not appear.',
    quantity: 10,
    unit: 'kg',
    price: 2,
    latitude: 60.2934,
    longitude: 25.0378,
    status: ListingStatus.active,
    createdAt: DateTime(2026, 6, 5),
  ),
];
