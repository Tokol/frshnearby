import 'catalog_entity.dart';
import 'catalog_translation.dart';

class CatalogCategory extends CatalogEntity {
  const CatalogCategory({
    required super.id,
    required super.canonicalKey,
    required super.translations,
    required super.synonyms,
    required super.isActive,
  });

  CatalogCategory copyWith({
    String? id,
    String? canonicalKey,
    Map<String, CatalogTranslation>? translations,
    List<String>? synonyms,
    bool? isActive,
  }) {
    return CatalogCategory(
      id: id ?? this.id,
      canonicalKey: canonicalKey ?? this.canonicalKey,
      translations: translations ?? this.translations,
      synonyms: synonyms ?? this.synonyms,
      isActive: isActive ?? this.isActive,
    );
  }
}
