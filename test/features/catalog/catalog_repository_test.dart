import 'package:flutter_test/flutter_test.dart';
import 'package:freshfarm/features/catalog/data/catalog_repository.dart';
import 'package:freshfarm/features/catalog/domain/catalog_suggestion.dart';

void main() {
  group('MockCatalogRepository', () {
    test('matches Finnish translations', () async {
      final repository = MockCatalogRepository();

      final suggestions = await repository.searchSuggestions(
        query: 'peruna',
        locale: 'fi',
      );

      expect(suggestions.map((suggestion) => suggestion.displayName), [
        'Peruna',
        'Uusi peruna',
      ]);
    });

    test('matches Swedish translations', () async {
      final repository = MockCatalogRepository();

      final suggestions = await repository.searchSuggestions(
        query: 'äpp',
        locale: 'sv',
      );

      expect(suggestions.map((suggestion) => suggestion.displayName), [
        'Äpple',
        'Rött äpple',
      ]);
    });

    test('matches synonyms without AI', () async {
      final repository = MockCatalogRepository();

      final suggestions = await repository.searchSuggestions(
        query: 'spud',
        locale: 'en',
      );

      expect(suggestions.single.type, CatalogSuggestionType.product);
      expect(suggestions.single.displayName, 'Potato');
    });

    test('returns no suggestions for blank query', () async {
      final repository = MockCatalogRepository();

      final suggestions = await repository.searchSuggestions(
        query: '   ',
        locale: 'en',
      );

      expect(suggestions, isEmpty);
    });

    test('stores product requests separately from catalog data', () async {
      final repository = MockCatalogRepository();

      final request = await repository.submitProductRequest(
        requestedName: 'Rhubarb',
        locale: 'en',
        farmerId: 'farmer-1',
        notes: 'Seasonal spring product',
      );

      expect(request.requestedName, 'Rhubarb');
      expect(repository.productRequests, [request]);
      expect(
        repository.products.any((product) => product.canonicalKey == 'rhubarb'),
        isFalse,
      );
    });
  });
}
