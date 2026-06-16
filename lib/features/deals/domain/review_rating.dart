class ReviewRating {
  const ReviewRating({
    required this.id,
    required this.dealId,
    required this.customerId,
    required this.farmerId,
    required this.stars,
    required this.createdAt,
    this.tags = const [],
    this.text,
  });

  final String id;
  final String dealId;
  final String customerId;
  final String farmerId;
  final int stars;
  final List<String> tags;
  final String? text;
  final DateTime createdAt;
}
