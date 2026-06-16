import 'catalog_translation.dart';

abstract class CatalogEntity {
  const CatalogEntity({
    required this.id,
    required this.canonicalKey,
    required this.translations,
    required this.synonyms,
    required this.isActive,
  });

  final String id;
  final String canonicalKey;
  final Map<String, CatalogTranslation> translations;
  final List<String> synonyms;
  final bool isActive;

  String displayName(String locale) {
    return translations[locale]?.displayName ??
        translations['en']?.displayName ??
        canonicalKey;
  }

  Iterable<String> searchableTerms() sync* {
    yield canonicalKey;
    for (final translation in translations.values) {
      yield translation.displayName;
    }
    yield* synonyms;
  }
}
