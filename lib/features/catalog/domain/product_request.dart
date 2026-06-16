class ProductRequest {
  const ProductRequest({
    required this.id,
    required this.requestedName,
    required this.locale,
    required this.farmerId,
    required this.createdAt,
    this.categoryId,
    this.notes,
  });

  final String id;
  final String requestedName;
  final String locale;
  final String farmerId;
  final DateTime createdAt;
  final String? categoryId;
  final String? notes;
}
