import '../domain/catalog_category.dart';
import '../domain/catalog_entity.dart';
import '../domain/catalog_product.dart';
import '../domain/catalog_suggestion.dart';
import '../domain/product_request.dart';
import '../domain/product_variant.dart';
import 'product_dictionary.dart';

abstract class CatalogRepository {
  List<CatalogCategory> get categories;

  List<CatalogProduct> get products;

  List<ProductVariant> get variants;

  Future<List<CatalogSuggestion>> searchSuggestions({
    required String query,
    required String locale,
  });

  Future<ProductRequest> submitProductRequest({
    required String requestedName,
    required String locale,
    required String farmerId,
    String? categoryId,
    String? notes,
  });
}

class MockCatalogRepository implements CatalogRepository {
  MockCatalogRepository();

  // TODO(backend): Replace the dictionary with an admin-managed catalog API.
  final List<ProductRequest> _productRequests = [];

  @override
  List<CatalogCategory> get categories => productDictionaryCategories;

  @override
  List<CatalogProduct> get products => productDictionaryProducts;

  @override
  List<ProductVariant> get variants => productDictionaryVariants;

  List<ProductRequest> get productRequests =>
      List.unmodifiable(_productRequests);

  @override
  Future<List<CatalogSuggestion>> searchSuggestions({
    required String query,
    required String locale,
  }) async {
    final normalizedQuery = _normalize(query);
    if (normalizedQuery.isEmpty) return [];

    final matchingCategoryIds = productDictionaryCategories
        .where((category) => _matches(category, normalizedQuery))
        .map((category) => category.id)
        .toSet();

    final suggestions = <CatalogSuggestion>[
      for (final category in productDictionaryCategories)
        if (_matches(category, normalizedQuery))
          CatalogSuggestion(
            id: category.id,
            type: CatalogSuggestionType.category,
            canonicalKey: category.canonicalKey,
            displayName: category.displayName(locale),
            category: category,
          ),
      for (final product in productDictionaryProducts)
        if (_matches(product, normalizedQuery) ||
            matchingCategoryIds.contains(product.categoryId))
          CatalogSuggestion(
            id: product.id,
            type: CatalogSuggestionType.product,
            canonicalKey: product.canonicalKey,
            displayName: product.displayName(locale),
            product: product,
          ),
      for (final variant in productDictionaryVariants)
        if (_matches(variant, normalizedQuery))
          CatalogSuggestion(
            id: variant.id,
            type: CatalogSuggestionType.variant,
            canonicalKey: variant.canonicalKey,
            displayName: variant.displayName(locale),
            product: _productById(variant.productId),
            variant: variant,
          ),
    ];

    suggestions.sort((a, b) {
      final typeOrder = a.type.index.compareTo(b.type.index);
      return typeOrder != 0
          ? typeOrder
          : a.displayName.compareTo(b.displayName);
    });
    return suggestions;
  }

  @override
  Future<ProductRequest> submitProductRequest({
    required String requestedName,
    required String locale,
    required String farmerId,
    String? categoryId,
    String? notes,
  }) async {
    final request = ProductRequest(
      id: 'product-request-${_productRequests.length + 1}',
      requestedName: requestedName,
      locale: locale,
      farmerId: farmerId,
      categoryId: categoryId,
      notes: notes,
      createdAt: DateTime.now(),
    );
    _productRequests.add(request);
    return request;
  }

  bool _matches(CatalogEntity entity, String normalizedQuery) {
    return entity.isActive &&
        entity.searchableTerms().any(
          (term) => _normalize(term).contains(normalizedQuery),
        );
  }

  String _normalize(String value) => value.trim().toLowerCase();

  CatalogProduct? _productById(String id) {
    for (final product in productDictionaryProducts) {
      if (product.id == id) return product;
    }
    return null;
  }
}
