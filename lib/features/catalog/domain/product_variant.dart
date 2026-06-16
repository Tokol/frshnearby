import 'catalog_entity.dart';
import 'catalog_translation.dart';

class ProductVariant extends CatalogEntity {
  const ProductVariant({
    required super.id,
    required super.canonicalKey,
    required super.translations,
    required super.synonyms,
    required super.isActive,
    required this.productId,
  });

  final String productId;

  ProductVariant copyWith({
    String? id,
    String? canonicalKey,
    Map<String, CatalogTranslation>? translations,
    List<String>? synonyms,
    bool? isActive,
    String? productId,
  }) {
    return ProductVariant(
      id: id ?? this.id,
      canonicalKey: canonicalKey ?? this.canonicalKey,
      translations: translations ?? this.translations,
      synonyms: synonyms ?? this.synonyms,
      isActive: isActive ?? this.isActive,
      productId: productId ?? this.productId,
    );
  }
}
