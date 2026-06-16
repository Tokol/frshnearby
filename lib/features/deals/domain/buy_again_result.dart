import '../../customer_marketplace/domain/customer_listing.dart';

enum BuyAgainResultType { sameListing, sameFarmerSameProduct, similarNearby }

class BuyAgainResult {
  const BuyAgainResult({required this.type, required this.listings});

  final BuyAgainResultType type;
  final List<CustomerListing> listings;
}
