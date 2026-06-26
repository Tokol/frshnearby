import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/data/auth_repository.dart';
import '../../features/catalog/data/catalog_repository.dart';
import '../../features/customer_marketplace/data/customer_marketplace_repository.dart';
import '../../features/deals/data/deal_repository.dart';
import '../../features/listings/data/listing_repository.dart';
import '../location/device_location_service.dart';
import '../network/api_client.dart';
import '../storage/local_storage_service.dart';

final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  throw UnimplementedError('LocalStorageService must be overridden in main.');
});

final apiClientProvider = Provider<ApiClient>((ref) {
  throw UnimplementedError('ApiClient must be overridden in main.');
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return MockAuthRepository(
    localStorageService: ref.watch(localStorageServiceProvider),
    apiClient: ref.watch(apiClientProvider),
  );
});

final catalogRepositoryProvider = Provider<CatalogRepository>((ref) {
  return MockCatalogRepository();
});

final locationServiceProvider = Provider<LocationService>((ref) {
  return const MockLocationService();
});

final listingRepositoryProvider = Provider<ListingRepository>((ref) {
  return MockListingRepository();
});

final customerMarketplaceRepositoryProvider =
    Provider<CustomerMarketplaceRepository>((ref) {
      final listingRepository = ref.watch(listingRepositoryProvider);
      return MockCustomerMarketplaceRepository(
        catalogRepository: ref.watch(catalogRepositoryProvider),
        sharedListings: listingRepository is MockListingRepository
            ? listingRepository.sharedListings
            : null,
      );
    });

final dealRepositoryProvider = Provider<DealRepository>((ref) {
  return MockDealRepository(
    marketplace: ref.watch(customerMarketplaceRepositoryProvider),
  );
});
