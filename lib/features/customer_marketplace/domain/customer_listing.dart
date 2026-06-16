import '../../catalog/domain/catalog_category.dart';
import '../../catalog/domain/catalog_product.dart';
import '../../catalog/domain/product_variant.dart';
import '../../listings/domain/listing.dart';
import 'farmer_public_profile.dart';

class CustomerListing {
  const CustomerListing({
    required this.listing,
    required this.farmer,
    required this.category,
    required this.product,
    required this.distanceKm,
    this.variant,
  });

  final Listing listing;
  final FarmerPublicProfile farmer;
  final CatalogCategory category;
  final CatalogProduct product;
  final ProductVariant? variant;
  final double distanceKm;

  String productName(String locale) => product.displayName(locale);

  String? variantName(String locale) => variant?.displayName(locale);
}
