enum DealStatus { negotiating, confirmed, readyForPickup, completed, cancelled }

enum FulfillmentMethod { farmPickup, courierDelivery }

class DealStatusUpdate {
  const DealStatusUpdate({
    required this.status,
    required this.timestamp,
    this.note,
  });

  final DealStatus status;
  final DateTime timestamp;
  final String? note;
}

class Deal {
  const Deal({
    required this.id,
    required this.threadId,
    required this.customerId,
    required this.farmerId,
    required this.listingId,
    required this.productId,
    required this.title,
    required this.quantity,
    required this.unit,
    required this.price,
    required this.status,
    required this.createdAt,
    String? orderGroupId,
    this.farmName = 'Farm order',
    this.completedAt,
    this.fulfillmentMethod = FulfillmentMethod.farmPickup,
    this.deliveryFee = 0,
    this.deliveryDistanceKm,
    this.statusUpdates = const [],
  }) : orderGroupId = orderGroupId ?? id;

  final String id;
  final String threadId;
  final String customerId;
  final String farmerId;
  final String listingId;
  final String productId;
  final String title;
  final double quantity;
  final String unit;
  final double price;
  final DealStatus status;
  final DateTime createdAt;
  final String orderGroupId;
  final String farmName;
  final DateTime? completedAt;
  final FulfillmentMethod fulfillmentMethod;
  final double deliveryFee;
  final double? deliveryDistanceKm;
  final List<DealStatusUpdate> statusUpdates;

  Deal copyWith({
    DealStatus? status,
    DateTime? completedAt,
    List<DealStatusUpdate>? statusUpdates,
  }) {
    return Deal(
      id: id,
      threadId: threadId,
      customerId: customerId,
      farmerId: farmerId,
      listingId: listingId,
      productId: productId,
      title: title,
      quantity: quantity,
      unit: unit,
      price: price,
      status: status ?? this.status,
      createdAt: createdAt,
      orderGroupId: orderGroupId,
      farmName: farmName,
      completedAt: completedAt ?? this.completedAt,
      fulfillmentMethod: fulfillmentMethod,
      deliveryFee: deliveryFee,
      deliveryDistanceKm: deliveryDistanceKm,
      statusUpdates: statusUpdates ?? this.statusUpdates,
    );
  }
}
