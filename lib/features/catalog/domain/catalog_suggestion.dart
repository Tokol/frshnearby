import 'catalog_category.dart';
import 'catalog_product.dart';
import 'product_variant.dart';

enum CatalogSuggestionType { category, product, variant }

class CatalogSuggestion {
  const CatalogSuggestion({
    required this.id,
    required this.type,
    required this.canonicalKey,
    required this.displayName,
    this.category,
    this.product,
    this.variant,
  });

  final String id;
  final CatalogSuggestionType type;
  final String canonicalKey;
  final String displayName;
  final CatalogCategory? category;
  final CatalogProduct? product;
  final ProductVariant? variant;
}
