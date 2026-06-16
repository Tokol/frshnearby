class ChatThread {
  const ChatThread({
    required this.id,
    required this.customerId,
    required this.farmerId,
    required this.listingId,
    required this.dealId,
    required this.createdAt,
  });

  final String id;
  final String customerId;
  final String farmerId;
  final String listingId;
  final String dealId;
  final DateTime createdAt;
}
