import '../domain/listing.dart';
import '../domain/listing_draft.dart';

abstract class ListingRepository {
  Future<List<Listing>> getFarmerListings(String farmerId);

  Future<Listing?> getListing(String id);

  Future<Listing> createListing({
    required String farmerId,
    required ListingDraft draft,
  });

  Future<Listing> updateListing(Listing listing);

  Future<void> archiveListing(String listingId);
}

class MockListingRepository implements ListingRepository {
  MockListingRepository() : _listings = List.of(_seedFarmerListings);

  // TODO(backend): Replace in-memory farmer listings with listing API endpoints.
  final List<Listing> _listings;

  List<Listing> get sharedListings => _listings;

  @override
  Future<List<Listing>> getFarmerListings(String farmerId) async {
    return _listings.where((listing) => listing.farmerId == farmerId).toList();
  }

  @override
  Future<Listing?> getListing(String id) async {
    return _listings.where((listing) => listing.id == id).firstOrNull;
  }

  @override
  Future<Listing> createListing({
    required String farmerId,
    required ListingDraft draft,
  }) async {
    final listing = draft.toListing(
      id: 'listing-${_listings.length + 1}',
      farmerId: farmerId,
      createdAt: DateTime.now(),
    );
    _listings.add(listing);
    return listing;
  }

  @override
  Future<Listing> updateListing(Listing listing) async {
    final index = _listings.indexWhere((item) => item.id == listing.id);
    if (index == -1) {
      throw StateError('Listing not found.');
    }
    _listings[index] = listing;
    return listing;
  }

  @override
  Future<void> archiveListing(String listingId) async {
    _listings.removeWhere((listing) => listing.id == listingId);
  }
}

final _seedFarmerListings = [
  Listing(
    id: 'public-listing-potato',
    farmerId: 'farmer-1',
    categoryId: 'category-vegetables',
    productId: 'product-potato',
    variantId: 'variant-new-potato',
    title: 'New potatoes',
    description: 'Freshly lifted, washed new potatoes from this week.',
    quantity: 25,
    unit: 'kg',
    price: 3.8,
    latitude: 63.0951,
    longitude: 21.6165,
    status: ListingStatus.active,
    createdAt: DateTime(2026, 6, 1),
    photoPlaceholder: 'assets/images/home/potatoes.png',
    harvestDate: DateTime(2026, 6, 10),
    farmingMethod: 'Pesticide-free',
    pickupNotes: 'Farm gate pickup. Bring your own bag if possible.',
  ),
  Listing(
    id: 'public-listing-tomato',
    farmerId: 'farmer-1',
    categoryId: 'category-vegetables',
    productId: 'product-tomato',
    variantId: 'variant-cherry-tomato',
    title: 'Cherry tomatoes',
    description: 'Sweet greenhouse tomatoes, picked every morning.',
    quantity: 12,
    unit: 'kg',
    price: 6.5,
    latitude: 63.0951,
    longitude: 21.6165,
    status: ListingStatus.active,
    createdAt: DateTime(2026, 6, 2),
    photoPlaceholder: 'assets/images/home/tomatoes.png',
    harvestDate: DateTime(2026, 6, 12),
    farmingMethod: 'Greenhouse grown',
    deliveryEnabled: true,
  ),
  Listing(
    id: 'farmer-listing-carrot',
    farmerId: 'farmer-1',
    categoryId: 'category-vegetables',
    productId: 'product-carrot',
    title: 'Bunched carrots',
    description: 'Tender early carrots with tops, sold by weight.',
    quantity: 6.5,
    unit: 'kg',
    price: 4.2,
    latitude: 63.0951,
    longitude: 21.6165,
    status: ListingStatus.active,
    createdAt: DateTime(2026, 6, 8),
    photoPlaceholder: 'assets/images/home/vegetables.png',
    harvestDate: DateTime(2026, 6, 11),
    farmingMethod: 'Open field',
  ),
  Listing(
    id: 'sold-out-apple',
    farmerId: 'farmer-1',
    categoryId: 'category-fruits',
    productId: 'product-apple',
    variantId: 'variant-red-apple',
    title: 'Red apples',
    description: 'Crisp apples from cold storage.',
    quantity: 0,
    unit: 'kg',
    price: 4,
    latitude: 63.0951,
    longitude: 21.6165,
    status: ListingStatus.soldOut,
    createdAt: DateTime(2026, 6, 4),
    photoPlaceholder: 'assets/images/home/fruits.png',
  ),
];
