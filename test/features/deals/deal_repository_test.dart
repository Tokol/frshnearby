import 'package:flutter_test/flutter_test.dart';
import 'package:freshfarm/features/catalog/data/catalog_repository.dart';
import 'package:freshfarm/features/customer_marketplace/data/customer_marketplace_repository.dart';
import 'package:freshfarm/features/deals/data/deal_repository.dart';
import 'package:freshfarm/features/deals/domain/buy_again_result.dart';
import 'package:freshfarm/features/deals/domain/deal.dart';

void main() {
  group('MockDealRepository', () {
    test('starts chat and creates negotiating deal', () async {
      final marketplace = MockCustomerMarketplaceRepository(
        catalogRepository: MockCatalogRepository(),
      );
      final repository = MockDealRepository(marketplace: marketplace);

      final thread = await repository.startNegotiation(
        customerId: 'customer-1',
        listingId: 'public-listing-potato',
        locale: 'en',
        quantity: 2,
      );
      final deals = await repository.getCustomerDeals('customer-1');
      final messages = await repository.getMessages(thread.id);

      expect(thread.listingId, 'public-listing-potato');
      expect(deals.single.status, DealStatus.negotiating);
      expect(deals.single.quantity, 2);
      expect(messages, isNotEmpty);
    });

    test(
      'completed deal allows one rating and updates farmer rating',
      () async {
        final marketplace = MockCustomerMarketplaceRepository(
          catalogRepository: MockCatalogRepository(),
        );
        final repository = MockDealRepository(marketplace: marketplace);

        final thread = await repository.startNegotiation(
          customerId: 'customer-1',
          listingId: 'public-listing-potato',
          locale: 'en',
          quantity: 1,
        );
        final deal = (await repository.getDeal(thread.dealId))!;
        await repository.updateDealStatus(
          dealId: deal.id,
          status: DealStatus.completed,
        );

        final rating = await repository.submitRating(
          dealId: deal.id,
          stars: 5,
          tags: const ['Fresh'],
        );
        final farmer = await marketplace.getFarmerProfile(deal.farmerId);

        expect(rating.stars, 5);
        expect(farmer?.reviewCount, 125);
        expect(
          () => repository.submitRating(dealId: deal.id, stars: 4),
          throwsStateError,
        );
      },
    );

    test('buy again opens same active listing first', () async {
      final marketplace = MockCustomerMarketplaceRepository(
        catalogRepository: MockCatalogRepository(),
      );
      final repository = MockDealRepository(marketplace: marketplace);

      final thread = await repository.startNegotiation(
        customerId: 'customer-1',
        listingId: 'public-listing-honey',
        locale: 'en',
        quantity: 1,
      );
      final deal = (await repository.getDeal(thread.dealId))!;
      final result = await repository.buyAgain(deal: deal, locale: 'en');

      expect(result.type, BuyAgainResultType.sameListing);
      expect(result.listings.single.listing.id, 'public-listing-honey');
    });

    test('handling a request reduces the farmer pending count', () async {
      final marketplace = MockCustomerMarketplaceRepository(
        catalogRepository: MockCatalogRepository(),
      );
      final repository = MockDealRepository(marketplace: marketplace);

      final before = await repository.getFarmerDeals('farmer-1');
      final request = before.firstWhere(
        (deal) => deal.status == DealStatus.negotiating,
      );
      final beforeCount = before
          .where((deal) => deal.status == DealStatus.negotiating)
          .length;

      await repository.updateDealStatus(
        dealId: request.id,
        status: DealStatus.confirmed,
      );
      final after = await repository.getFarmerDeals('farmer-1');

      expect(
        after.where((deal) => deal.status == DealStatus.negotiating).length,
        beforeCount - 1,
      );
    });
  });
}
