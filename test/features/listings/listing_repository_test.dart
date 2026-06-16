import 'package:flutter_test/flutter_test.dart';
import 'package:freshfarm/features/catalog/data/catalog_repository.dart';
import 'package:freshfarm/features/listings/data/listing_repository.dart';
import 'package:freshfarm/features/listings/domain/listing.dart';
import 'package:freshfarm/features/listings/domain/listing_draft.dart';

void main() {
  test('creates listing with selected product catalog ids', () async {
    final catalogRepository = MockCatalogRepository();
    final listingRepository = MockListingRepository();
    final suggestion = (await catalogRepository.searchSuggestions(
      query: 'peruna',
      locale: 'fi',
    )).firstWhere((item) => item.product != null);

    final listing = await listingRepository.createListing(
      farmerId: 'farmer-1',
      draft: ListingDraft(
        catalogSuggestion: suggestion,
        quantity: 10,
        unit: 'kg',
        price: 3.5,
        latitude: 60.1699,
        longitude: 24.9384,
      ),
    );

    expect(listing.categoryId, 'category-vegetables');
    expect(listing.productId, 'product-potato');
    expect(listing.variantId, isNull);
    expect(listing.title, 'Peruna / Potato / Potatis');
    expect(listing.status, ListingStatus.active);
  });

  test('creates listing with selected variant id', () async {
    final catalogRepository = MockCatalogRepository();
    final listingRepository = MockListingRepository();
    final suggestion = (await catalogRepository.searchSuggestions(
      query: 'nypotatis',
      locale: 'sv',
    )).firstWhere((item) => item.variant != null);

    final listing = await listingRepository.createListing(
      farmerId: 'farmer-1',
      draft: ListingDraft(
        catalogSuggestion: suggestion,
        quantity: 4,
        unit: 'kg',
        price: 5,
        latitude: 60.1699,
        longitude: 24.9384,
      ),
    );

    expect(listing.categoryId, 'category-vegetables');
    expect(listing.productId, 'product-potato');
    expect(listing.variantId, 'variant-new-potato');
    expect(listing.title, 'Uusi peruna / New potato / Nypotatis');
  });
}
