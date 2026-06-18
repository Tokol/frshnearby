import '../../customer_marketplace/data/customer_marketplace_repository.dart';
import '../domain/buy_again_result.dart';
import '../domain/chat_message.dart';
import '../domain/chat_thread.dart';
import '../domain/deal.dart';
import '../domain/review_rating.dart';

abstract class DealRepository {
  Future<ChatThread> startNegotiation({
    required String customerId,
    required String listingId,
    required String locale,
    required double quantity,
    String? orderGroupId,
    FulfillmentMethod fulfillmentMethod = FulfillmentMethod.farmPickup,
    double deliveryFee = 0,
    double? deliveryDistanceKm,
  });

  Future<Deal> createFeedOfferDeal({
    required String customerId,
    required String farmerId,
    required String farmName,
    required String postId,
    required String offerId,
    required String title,
    required double quantity,
    required String unit,
    required double unitPrice,
    required String note,
  });

  Future<List<ChatThread>> getThreads(String customerId);

  Future<List<ChatMessage>> getMessages(String threadId);

  Future<ChatMessage> sendMessage({
    required String threadId,
    required String senderId,
    required ChatSenderType senderType,
    required String text,
  });

  Future<List<Deal>> getCustomerDeals(String customerId);

  Future<List<Deal>> getFarmerDeals(String farmerId);

  Future<Deal?> getDeal(String dealId);

  Future<Deal> updateDealStatus({
    required String dealId,
    required DealStatus status,
    String? note,
  });

  Future<BuyAgainResult> buyAgain({required Deal deal, required String locale});

  Future<ReviewRating> submitRating({
    required String dealId,
    required int stars,
    List<String> tags,
    String? text,
  });

  ReviewRating? ratingForDeal(String dealId);
}

class MockDealRepository implements DealRepository {
  MockDealRepository({required CustomerMarketplaceRepository marketplace})
    : _marketplace = marketplace;

  final CustomerMarketplaceRepository _marketplace;
  // TODO(backend): Replace in-memory chat, deal, and rating state with APIs.
  final List<ChatThread> _threads = List.of(_seedThreads);
  final List<ChatMessage> _messages = List.of(_seedMessages);
  final List<Deal> _deals = List.of(_seedDeals);
  final List<ReviewRating> _ratings = List.of(_seedRatings);

  @override
  Future<ChatThread> startNegotiation({
    required String customerId,
    required String listingId,
    required String locale,
    required double quantity,
    String? orderGroupId,
    FulfillmentMethod fulfillmentMethod = FulfillmentMethod.farmPickup,
    double deliveryFee = 0,
    double? deliveryDistanceKm,
  }) async {
    final listing = await _marketplace.getListing(
      listingId: listingId,
      locale: locale,
    );
    if (listing == null) {
      throw StateError('Listing is not available.');
    }
    if (quantity <= 0 || quantity > listing.listing.quantity) {
      throw StateError('Requested quantity is not available.');
    }

    final dealId = 'deal-${_deals.length + 1}';
    final threadId = 'thread-${_threads.length + 1}';
    final now = DateTime.now();
    final thread = ChatThread(
      id: threadId,
      customerId: customerId,
      farmerId: listing.farmer.id,
      listingId: listingId,
      dealId: dealId,
      createdAt: now,
    );
    final deal = Deal(
      id: dealId,
      threadId: threadId,
      customerId: customerId,
      farmerId: listing.farmer.id,
      listingId: listingId,
      productId: listing.listing.productId,
      title: listing.variantName(locale) ?? listing.productName(locale),
      quantity: quantity,
      unit: listing.listing.unit,
      price: listing.listing.price,
      status: DealStatus.negotiating,
      createdAt: now,
      orderGroupId: orderGroupId,
      farmName: listing.farmer.farmName,
      fulfillmentMethod: fulfillmentMethod,
      deliveryFee: deliveryFee,
      deliveryDistanceKm: deliveryDistanceKm,
      statusUpdates: [
        DealStatusUpdate(status: DealStatus.negotiating, timestamp: now),
      ],
    );
    _threads.add(thread);
    _deals.add(deal);
    _messages.add(
      ChatMessage(
        id: 'message-${_messages.length + 1}',
        threadId: threadId,
        senderId: 'system',
        senderType: ChatSenderType.farmer,
        text: 'Negotiation started.',
        createdAt: now,
      ),
    );
    return thread;
  }

  @override
  Future<Deal> createFeedOfferDeal({
    required String customerId,
    required String farmerId,
    required String farmName,
    required String postId,
    required String offerId,
    required String title,
    required double quantity,
    required String unit,
    required double unitPrice,
    required String note,
  }) async {
    final dealId = 'feed-deal-${_deals.length + 1}';
    final threadId = 'feed-thread-${_threads.length + 1}';
    final now = DateTime.now();
    final listingId = 'feed-post-$postId';
    final thread = ChatThread(
      id: threadId,
      customerId: customerId,
      farmerId: farmerId,
      listingId: listingId,
      dealId: dealId,
      createdAt: now,
    );
    final deal = Deal(
      id: dealId,
      threadId: threadId,
      customerId: customerId,
      farmerId: farmerId,
      listingId: listingId,
      productId: 'feed-offer-$offerId',
      title: title,
      quantity: quantity,
      unit: unit,
      price: unitPrice,
      status: DealStatus.confirmed,
      createdAt: now,
      farmName: farmName,
      statusUpdates: [
        DealStatusUpdate(status: DealStatus.negotiating, timestamp: now),
        DealStatusUpdate(
          status: DealStatus.confirmed,
          timestamp: now,
          note: note.trim().isEmpty
              ? 'Paid feed offer accepted from farm wall.'
              : note.trim(),
        ),
      ],
    );
    _threads.add(thread);
    _deals.add(deal);
    _messages.add(
      ChatMessage(
        id: 'message-${_messages.length + 1}',
        threadId: threadId,
        senderId: 'system',
        senderType: ChatSenderType.customer,
        text: 'Feed offer accepted. Payment authorized.',
        createdAt: now,
      ),
    );
    return deal;
  }

  @override
  Future<List<ChatThread>> getThreads(String customerId) async {
    return _threads.where((thread) => thread.customerId == customerId).toList();
  }

  @override
  Future<List<ChatMessage>> getMessages(String threadId) async {
    return _messages.where((message) => message.threadId == threadId).toList();
  }

  @override
  Future<ChatMessage> sendMessage({
    required String threadId,
    required String senderId,
    required ChatSenderType senderType,
    required String text,
  }) async {
    final message = ChatMessage(
      id: 'message-${_messages.length + 1}',
      threadId: threadId,
      senderId: senderId,
      senderType: senderType,
      text: text,
      createdAt: DateTime.now(),
    );
    _messages.add(message);
    return message;
  }

  @override
  Future<List<Deal>> getCustomerDeals(String customerId) async {
    return _deals.where((deal) => deal.customerId == customerId).toList();
  }

  @override
  Future<List<Deal>> getFarmerDeals(String farmerId) async {
    return _deals.where((deal) => deal.farmerId == farmerId).toList();
  }

  @override
  Future<Deal?> getDeal(String dealId) async {
    return _deals.where((deal) => deal.id == dealId).firstOrNull;
  }

  @override
  Future<Deal> updateDealStatus({
    required String dealId,
    required DealStatus status,
    String? note,
  }) async {
    final index = _deals.indexWhere((deal) => deal.id == dealId);
    if (index == -1) {
      throw StateError('Deal not found.');
    }
    final current = _deals[index];
    final updatedDeal = current.copyWith(
      status: status,
      completedAt: status == DealStatus.completed ? DateTime.now() : null,
      statusUpdates: [
        ...current.statusUpdates,
        DealStatusUpdate(
          status: status,
          timestamp: DateTime.now(),
          note: note?.trim().isEmpty ?? true ? null : note!.trim(),
        ),
      ],
    );
    _deals[index] = updatedDeal;
    return updatedDeal;
  }

  @override
  Future<BuyAgainResult> buyAgain({
    required Deal deal,
    required String locale,
  }) async {
    final sameListing = await _marketplace.getListing(
      listingId: deal.listingId,
      locale: locale,
    );
    if (sameListing != null) {
      return BuyAgainResult(
        type: BuyAgainResultType.sameListing,
        listings: [sameListing],
      );
    }

    final nearby = await _marketplace.getNearbyActiveListings(locale: locale);
    final sameFarmerSameProduct = nearby
        .where(
          (listing) =>
              listing.farmer.id == deal.farmerId &&
              listing.listing.productId == deal.productId,
        )
        .toList();
    if (sameFarmerSameProduct.isNotEmpty) {
      return BuyAgainResult(
        type: BuyAgainResultType.sameFarmerSameProduct,
        listings: sameFarmerSameProduct,
      );
    }

    final similar = nearby
        .where((listing) => listing.listing.productId == deal.productId)
        .toList();
    return BuyAgainResult(
      type: BuyAgainResultType.similarNearby,
      listings: similar.isEmpty ? nearby : similar,
    );
  }

  @override
  Future<ReviewRating> submitRating({
    required String dealId,
    required int stars,
    List<String> tags = const [],
    String? text,
  }) async {
    final deal = await getDeal(dealId);
    if (deal == null || deal.status != DealStatus.completed) {
      throw StateError('Only completed deals can be rated.');
    }
    if (ratingForDeal(dealId) != null) {
      throw StateError('This deal already has a rating.');
    }
    if (stars < 1 || stars > 5) {
      throw StateError('Rating must be between 1 and 5.');
    }

    final rating = ReviewRating(
      id: 'rating-${_ratings.length + 1}',
      dealId: dealId,
      customerId: deal.customerId,
      farmerId: deal.farmerId,
      stars: stars,
      tags: tags,
      text: text,
      createdAt: DateTime.now(),
    );
    _ratings.add(rating);
    await _marketplace.recordFarmerRating(
      farmerId: deal.farmerId,
      stars: stars,
    );
    return rating;
  }

  @override
  ReviewRating? ratingForDeal(String dealId) {
    for (final rating in _ratings) {
      if (rating.dealId == dealId) {
        return rating;
      }
    }
    return null;
  }
}

final _seedThreads = [
  ChatThread(
    id: 'seed-thread-1',
    customerId: 'user-customer-1',
    farmerId: 'farmer-1',
    listingId: 'public-listing-potato',
    dealId: 'seed-deal-completed-unrated',
    createdAt: DateTime(2026, 6, 6),
  ),
  ChatThread(
    id: 'seed-thread-2',
    customerId: 'user-customer-1',
    farmerId: 'farmer-2',
    listingId: 'public-listing-honey',
    dealId: 'seed-deal-completed-rated',
    createdAt: DateTime(2026, 6, 7),
  ),
];

final _seedMessages = [
  ChatMessage(
    id: 'seed-message-1',
    threadId: 'seed-thread-1',
    senderId: 'user-customer-1',
    senderType: ChatSenderType.customer,
    text: 'Can I pick this up tomorrow?',
    createdAt: DateTime(2026, 6, 6, 12),
  ),
  ChatMessage(
    id: 'seed-message-2',
    threadId: 'seed-thread-1',
    senderId: 'farmer-1',
    senderType: ChatSenderType.farmer,
    text: 'Yes, afternoon works well.',
    createdAt: DateTime(2026, 6, 6, 12, 10),
  ),
];

final _seedDeals = [
  Deal(
    id: 'seed-order-requested',
    threadId: 'seed-thread-order-1',
    customerId: 'customer-emma',
    farmerId: 'farmer-1',
    listingId: 'public-listing-potato',
    productId: 'product-potato',
    title: 'New potatoes',
    quantity: 8,
    unit: 'kg',
    price: 3.8,
    status: DealStatus.negotiating,
    createdAt: DateTime(2026, 6, 12, 9, 20),
  ),
  Deal(
    id: 'seed-order-confirmed',
    threadId: 'seed-thread-order-2',
    customerId: 'customer-liam',
    farmerId: 'farmer-1',
    listingId: 'public-listing-tomato',
    productId: 'product-tomato',
    title: 'Cherry tomatoes',
    quantity: 3,
    unit: 'kg',
    price: 6.5,
    status: DealStatus.confirmed,
    createdAt: DateTime(2026, 6, 11, 14, 5),
  ),
  Deal(
    id: 'seed-order-ready',
    threadId: 'seed-thread-order-3',
    customerId: 'customer-sofia',
    farmerId: 'farmer-1',
    listingId: 'farmer-listing-carrot',
    productId: 'product-carrot',
    title: 'Bunched carrots',
    quantity: 2.5,
    unit: 'kg',
    price: 4.2,
    status: DealStatus.readyForPickup,
    createdAt: DateTime(2026, 6, 10, 16, 40),
  ),
  Deal(
    id: 'seed-deal-completed-unrated',
    threadId: 'seed-thread-1',
    customerId: 'user-customer-1',
    farmerId: 'farmer-1',
    listingId: 'public-listing-potato',
    productId: 'product-potato',
    title: 'New potato',
    quantity: 5,
    unit: 'kg',
    price: 3.8,
    status: DealStatus.completed,
    createdAt: DateTime(2026, 6, 6),
    completedAt: DateTime(2026, 6, 6, 18),
  ),
  Deal(
    id: 'seed-sale-tomatoes',
    threadId: 'seed-thread-sale-2',
    customerId: 'customer-aada',
    farmerId: 'farmer-1',
    listingId: 'public-listing-tomato',
    productId: 'product-tomato',
    title: 'Cherry tomatoes',
    quantity: 4,
    unit: 'kg',
    price: 6.5,
    status: DealStatus.completed,
    createdAt: DateTime(2026, 6, 3),
    completedAt: DateTime(2026, 6, 4, 16),
  ),
  Deal(
    id: 'seed-sale-carrots',
    threadId: 'seed-thread-sale-3',
    customerId: 'customer-noah',
    farmerId: 'farmer-1',
    listingId: 'farmer-listing-carrot',
    productId: 'product-carrot',
    title: 'Bunched carrots',
    quantity: 6,
    unit: 'kg',
    price: 4.2,
    status: DealStatus.completed,
    createdAt: DateTime(2026, 6, 8),
    completedAt: DateTime(2026, 6, 9, 17),
  ),
  Deal(
    id: 'seed-sale-potatoes-large',
    threadId: 'seed-thread-sale-4',
    customerId: 'customer-olivia',
    farmerId: 'farmer-1',
    listingId: 'public-listing-potato',
    productId: 'product-potato',
    title: 'New potatoes',
    quantity: 12,
    unit: 'kg',
    price: 3.8,
    status: DealStatus.completed,
    createdAt: DateTime(2026, 6, 10),
    completedAt: DateTime(2026, 6, 11, 15),
  ),
  Deal(
    id: 'seed-deal-completed-rated',
    threadId: 'seed-thread-2',
    customerId: 'user-customer-1',
    farmerId: 'farmer-2',
    listingId: 'public-listing-honey',
    productId: 'product-honey',
    title: 'Honey',
    quantity: 2,
    unit: 'jar',
    price: 8.9,
    status: DealStatus.completed,
    createdAt: DateTime(2026, 6, 7),
    completedAt: DateTime(2026, 6, 7, 16),
  ),
];

final _seedRatings = [
  ReviewRating(
    id: 'seed-rating-1',
    dealId: 'seed-deal-completed-rated',
    customerId: 'user-customer-1',
    farmerId: 'farmer-2',
    stars: 5,
    tags: const ['Fresh'],
    text: 'Lovely honey.',
    createdAt: DateTime(2026, 6, 7, 18),
  ),
];
