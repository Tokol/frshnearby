import 'catalog_entity.dart';
import 'catalog_translation.dart';

class CatalogProduct extends CatalogEntity {
  const CatalogProduct({
    required super.id,
    required super.canonicalKey,
    required super.translations,
    required super.synonyms,
    required super.isActive,
    required this.categoryId,
  });

  final String categoryId;

  CatalogProduct copyWith({
    String? id,
    String? canonicalKey,
    Map<String, CatalogTranslation>? translations,
    List<String>? synonyms,
    bool? isActive,
    String? categoryId,
  }) {
    return CatalogProduct(
      id: id ?? this.id,
      canonicalKey: canonicalKey ?? this.canonicalKey,
      translations: translations ?? this.translations,
      synonyms: synonyms ?? this.synonyms,
      isActive: isActive ?? this.isActive,
      categoryId: categoryId ?? this.categoryId,
    );
  }
}
