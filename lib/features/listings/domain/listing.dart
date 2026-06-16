enum ListingStatus { draft, active, soldOut, expired }

class Listing {
  const Listing({
    required this.id,
    required this.farmerId,
    required this.categoryId,
    required this.productId,
    required this.title,
    required this.description,
    required this.quantity,
    required this.unit,
    required this.price,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.createdAt,
    this.variantId,
    this.photoPlaceholder,
    this.harvestDate,
    this.farmingMethod,
    this.bestBeforeDate,
    this.storageInstructions,
    this.pickupNotes,
    this.deliveryEnabled = false,
  });

  final String id;
  final String farmerId;
  final String categoryId;
  final String productId;
  final String? variantId;
  final String title;
  final String description;
  final double quantity;
  final String unit;
  final double price;
  final double latitude;
  final double longitude;
  final ListingStatus status;
  final DateTime createdAt;
  final String? photoPlaceholder;
  final DateTime? harvestDate;
  final String? farmingMethod;
  final DateTime? bestBeforeDate;
  final String? storageInstructions;
  final String? pickupNotes;
  final bool deliveryEnabled;

  Listing copyWith({
    String? id,
    String? farmerId,
    String? categoryId,
    String? productId,
    String? variantId,
    String? title,
    String? description,
    double? quantity,
    String? unit,
    double? price,
    double? latitude,
    double? longitude,
    ListingStatus? status,
    DateTime? createdAt,
    String? photoPlaceholder,
    DateTime? harvestDate,
    String? farmingMethod,
    DateTime? bestBeforeDate,
    String? storageInstructions,
    String? pickupNotes,
    bool? deliveryEnabled,
    bool clearHarvestDate = false,
    bool clearBestBeforeDate = false,
  }) {
    return Listing(
      id: id ?? this.id,
      farmerId: farmerId ?? this.farmerId,
      categoryId: categoryId ?? this.categoryId,
      productId: productId ?? this.productId,
      variantId: variantId ?? this.variantId,
      title: title ?? this.title,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      price: price ?? this.price,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      photoPlaceholder: photoPlaceholder ?? this.photoPlaceholder,
      harvestDate: clearHarvestDate ? null : harvestDate ?? this.harvestDate,
      farmingMethod: farmingMethod ?? this.farmingMethod,
      bestBeforeDate: clearBestBeforeDate
          ? null
          : bestBeforeDate ?? this.bestBeforeDate,
      storageInstructions:
          storageInstructions ?? this.storageInstructions,
      pickupNotes: pickupNotes ?? this.pickupNotes,
      deliveryEnabled: deliveryEnabled ?? this.deliveryEnabled,
    );
  }
}
