import '../../catalog/domain/catalog_suggestion.dart';
import 'listing.dart';

class ListingDraft {
  const ListingDraft({
    this.catalogSuggestion,
    this.quantity,
    this.unit = '',
    this.price,
    this.latitude,
    this.longitude,
    this.description = '',
    this.photoPlaceholder,
    this.harvestDate,
    this.farmingMethod,
    this.bestBeforeDate,
    this.storageInstructions,
    this.pickupNotes,
    this.deliveryEnabled = false,
  });

  final CatalogSuggestion? catalogSuggestion;
  final double? quantity;
  final String unit;
  final double? price;
  final double? latitude;
  final double? longitude;
  final String description;
  final String? photoPlaceholder;
  final DateTime? harvestDate;
  final String? farmingMethod;
  final DateTime? bestBeforeDate;
  final String? storageInstructions;
  final String? pickupNotes;
  final bool deliveryEnabled;

  bool get canSave {
    final suggestion = catalogSuggestion;
    return suggestion != null &&
        (suggestion.product != null || suggestion.variant != null) &&
        quantity != null &&
        unit.trim().isNotEmpty &&
        price != null &&
        latitude != null &&
        longitude != null;
  }

  ListingDraft copyWith({
    CatalogSuggestion? catalogSuggestion,
    double? quantity,
    String? unit,
    double? price,
    double? latitude,
    double? longitude,
    String? description,
    String? photoPlaceholder,
    DateTime? harvestDate,
    String? farmingMethod,
    DateTime? bestBeforeDate,
    String? storageInstructions,
    String? pickupNotes,
    bool? deliveryEnabled,
  }) {
    return ListingDraft(
      catalogSuggestion: catalogSuggestion ?? this.catalogSuggestion,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      price: price ?? this.price,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      description: description ?? this.description,
      photoPlaceholder: photoPlaceholder ?? this.photoPlaceholder,
      harvestDate: harvestDate ?? this.harvestDate,
      farmingMethod: farmingMethod ?? this.farmingMethod,
      bestBeforeDate: bestBeforeDate ?? this.bestBeforeDate,
      storageInstructions: storageInstructions ?? this.storageInstructions,
      pickupNotes: pickupNotes ?? this.pickupNotes,
      deliveryEnabled: deliveryEnabled ?? this.deliveryEnabled,
    );
  }

  Listing toListing({
    required String id,
    required String farmerId,
    required DateTime createdAt,
    ListingStatus status = ListingStatus.active,
  }) {
    final suggestion = catalogSuggestion;
    final quantityValue = quantity;
    final priceValue = price;
    final latitudeValue = latitude;
    final longitudeValue = longitude;
    if (suggestion == null ||
        quantityValue == null ||
        priceValue == null ||
        latitudeValue == null ||
        longitudeValue == null) {
      throw StateError('Required listing fields are missing.');
    }

    final categoryId = suggestion.product?.categoryId;
    final productId = suggestion.product?.id ?? suggestion.variant?.productId;
    if (categoryId == null || productId == null) {
      throw StateError('A product or variant selection is required.');
    }

    return Listing(
      id: id,
      farmerId: farmerId,
      categoryId: categoryId,
      productId: productId,
      variantId: suggestion.variant?.id,
      title: suggestion.displayName,
      description: description.trim(),
      quantity: quantityValue,
      unit: unit.trim(),
      price: priceValue,
      latitude: latitudeValue,
      longitude: longitudeValue,
      status: status,
      createdAt: createdAt,
      photoPlaceholder: photoPlaceholder,
      harvestDate: harvestDate,
      farmingMethod: farmingMethod?.trim(),
      bestBeforeDate: bestBeforeDate,
      storageInstructions: storageInstructions?.trim(),
      pickupNotes: pickupNotes?.trim(),
      deliveryEnabled: deliveryEnabled,
    );
  }
}
