import 'package:flutter_test/flutter_test.dart';
import 'package:freshfarm/features/customer_marketplace/data/customer_marketplace_repository.dart';
import 'package:freshfarm/features/catalog/data/catalog_repository.dart';
import 'package:freshfarm/features/listings/domain/listing.dart';
import 'package:freshfarm/features/auth/domain/farmer_profile.dart';
import 'package:freshfarm/features/farmer_application/domain/farmer_application.dart';

void main() {
  group('MockCustomerMarketplaceRepository', () {
    test('returns only active listings from verified farmers', () async {
      final repository = MockCustomerMarketplaceRepository(
        catalogRepository: MockCatalogRepository(),
      );

      final listings = await repository.getNearbyActiveListings(locale: 'en');

      expect(listings.map((item) => item.listing.id), [
        'public-listing-potato',
        'public-listing-tomato',
        'public-listing-honey',
      ]);
      expect(listings.every((item) => item.farmer.isVerified), isTrue);
    });

    test('searches Finnish product translations', () async {
      final repository = MockCustomerMarketplaceRepository(
        catalogRepository: MockCatalogRepository(),
      );

      final listings = await repository.searchListings(
        query: 'peruna',
        locale: 'fi',
      );

      expect(listings.single.listing.id, 'public-listing-potato');
    });

    test('searches Swedish variant translations', () async {
      final repository = MockCustomerMarketplaceRepository(
        catalogRepository: MockCatalogRepository(),
      );

      final listings = await repository.searchListings(
        query: 'körsbär',
        locale: 'sv',
      );

      expect(listings.single.listing.id, 'public-listing-tomato');
    });

    test('searches catalog synonyms', () async {
      final repository = MockCustomerMarketplaceRepository(
        catalogRepository: MockCatalogRepository(),
      );

      final listings = await repository.searchListings(
        query: 'raw honey',
        locale: 'en',
      );

      expect(listings.single.listing.id, 'public-listing-honey');
    });

    test('does not expose hidden listing details', () async {
      final repository = MockCustomerMarketplaceRepository(
        catalogRepository: MockCatalogRepository(),
      );

      final listing = await repository.getListing(
        listingId: 'hidden-unverified-carrot',
        locale: 'en',
      );

      expect(listing, isNull);
    });

    test('shows updated inventory to customers after acceptance', () async {
      final repository = MockCustomerMarketplaceRepository(
        catalogRepository: MockCatalogRepository(),
      );

      await repository.updateListingInventory(
        listingId: 'public-listing-potato',
        quantity: 17,
        status: ListingStatus.active,
      );
      final listing = await repository.getListing(
        listingId: 'public-listing-potato',
        locale: 'en',
      );

      expect(listing?.listing.quantity, 17);
    });

    test('shows updated farm appearance on the public profile', () async {
      final repository = MockCustomerMarketplaceRepository(
        catalogRepository: MockCatalogRepository(),
      );

      await repository.updateFarmerProfile(
        const FarmerProfile(
          id: 'farmer-1',
          farmName: 'Vaasa Harvest Farm',
          status: FarmerVerificationStatus.verified,
          profileType: FarmerProfileType.farm,
          displayName: 'Vaasa Harvest Farm',
          shortDescription: 'Fresh produce from our family fields.',
          city: 'Vaasa',
          country: 'Finland',
          profilePhotoPlaceholder: 'assets/images/home/potatoes.png',
          coverPhotoPlaceholder: 'assets/images/home/tomatoes.png',
          pickupNote: 'Collect from the red farm gate.',
        ),
      );
      final profile = await repository.getFarmerProfile('farmer-1');

      expect(profile?.farmName, 'Vaasa Harvest Farm');
      expect(profile?.profilePhotoPlaceholder, contains('potatoes'));
      expect(profile?.pickupNote, 'Collect from the red farm gate.');
    });
  });
}
