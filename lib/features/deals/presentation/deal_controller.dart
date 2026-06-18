import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../listings/presentation/listing_controller.dart';
import '../domain/buy_again_result.dart';
import '../domain/chat_message.dart';
import '../domain/chat_thread.dart';
import '../domain/deal.dart';
import '../domain/review_rating.dart';

final dealControllerProvider = StateNotifierProvider<DealController, DealState>(
  (ref) {
    return DealController(ref)..loadDeals();
  },
);

final chatMessagesProvider = FutureProvider.family<List<ChatMessage>, String>((
  ref,
  threadId,
) {
  return ref.watch(dealRepositoryProvider).getMessages(threadId);
});

final farmerDealsProvider = FutureProvider<List<Deal>>((ref) {
  final farmerId = ref.watch(authControllerProvider).user?.farmerProfile?.id;
  if (farmerId == null) {
    return const <Deal>[];
  }
  return ref.watch(dealRepositoryProvider).getFarmerDeals(farmerId);
});

class DealState {
  const DealState({
    this.deals = const [],
    this.isLoading = false,
    this.isSaving = false,
    this.buyAgainResult,
  });

  final List<Deal> deals;
  final bool isLoading;
  final bool isSaving;
  final BuyAgainResult? buyAgainResult;

  List<Deal> get completedDeals =>
      deals.where((deal) => deal.status == DealStatus.completed).toList();

  DealState copyWith({
    List<Deal>? deals,
    bool? isLoading,
    bool? isSaving,
    BuyAgainResult? buyAgainResult,
    bool clearBuyAgainResult = false,
  }) {
    return DealState(
      deals: deals ?? this.deals,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      buyAgainResult: clearBuyAgainResult
          ? null
          : buyAgainResult ?? this.buyAgainResult,
    );
  }
}

class DealController extends StateNotifier<DealState> {
  DealController(this._ref) : super(const DealState());

  final Ref _ref;

  Future<void> loadDeals() async {
    final customerId = _customerId;
    if (customerId == null) {
      return;
    }
    state = state.copyWith(isLoading: true);
    final deals = await _ref
        .read(dealRepositoryProvider)
        .getCustomerDeals(customerId);
    state = state.copyWith(deals: deals, isLoading: false);
  }

  Future<ChatThread> startChat({
    required String listingId,
    required String locale,
    double quantity = 1,
    String? orderGroupId,
    FulfillmentMethod fulfillmentMethod = FulfillmentMethod.farmPickup,
    double deliveryFee = 0,
    double? deliveryDistanceKm,
  }) async {
    final customerId = _customerId;
    if (customerId == null) {
      throw StateError('Customer is required.');
    }
    final thread = await _ref
        .read(dealRepositoryProvider)
        .startNegotiation(
          customerId: customerId,
          listingId: listingId,
          locale: locale,
          quantity: quantity,
          orderGroupId:
              orderGroupId ?? 'order-${DateTime.now().microsecondsSinceEpoch}',
          fulfillmentMethod: fulfillmentMethod,
          deliveryFee: deliveryFee,
          deliveryDistanceKm: deliveryDistanceKm,
        );
    await loadDeals();
    _ref.invalidate(farmerDealsProvider);
    return thread;
  }

  Future<Deal> createFeedOfferDeal({
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
    final customerId = _customerId;
    if (customerId == null) {
      throw StateError('Customer is required.');
    }
    final deal = await _ref
        .read(dealRepositoryProvider)
        .createFeedOfferDeal(
          customerId: customerId,
          farmerId: farmerId,
          farmName: farmName,
          postId: postId,
          offerId: offerId,
          title: title,
          quantity: quantity,
          unit: unit,
          unitPrice: unitPrice,
          note: note,
        );
    await loadDeals();
    _ref.invalidate(farmerDealsProvider);
    return deal;
  }

  Future<void> sendMessage({
    required String threadId,
    required String text,
  }) async {
    final customerId = _customerId;
    if (customerId == null || text.trim().isEmpty) {
      return;
    }
    await _ref
        .read(dealRepositoryProvider)
        .sendMessage(
          threadId: threadId,
          senderId: customerId,
          senderType: ChatSenderType.customer,
          text: text.trim(),
        );
    _ref.invalidate(chatMessagesProvider(threadId));
  }

  Future<void> updateDealStatus(
    String dealId,
    DealStatus status, {
    String? note,
  }) async {
    state = state.copyWith(isSaving: true);
    await _ref
        .read(dealRepositoryProvider)
        .updateDealStatus(dealId: dealId, status: status, note: note);
    _ref.invalidate(farmerDealsProvider);
    await loadDeals();
    state = state.copyWith(isSaving: false);
  }

  Future<void> acceptFarmerOrder(Deal order, {String? note}) async {
    if (order.status != DealStatus.negotiating) {
      return;
    }

    final listingController = _ref.read(listingControllerProvider.notifier);
    final listing = listingController.listingById(order.listingId);
    if (listing == null || listing.quantity < order.quantity) {
      throw StateError('There is not enough stock for this order.');
    }

    final remainingQuantity = listing.quantity - order.quantity;
    await listingController.updateQuantity(
      listingId: listing.id,
      quantity: remainingQuantity,
    );
    await updateDealStatus(order.id, DealStatus.confirmed, note: note);
  }

  Future<void> updateOrderGroupStatus(
    List<Deal> orders,
    DealStatus status, {
    String? note,
  }) async {
    for (final order in orders) {
      await updateDealStatus(order.id, status, note: note);
    }
  }

  Future<void> acceptFarmerOrderGroup(List<Deal> orders, {String? note}) async {
    final listingController = _ref.read(listingControllerProvider.notifier);
    for (final order in orders) {
      final listing = listingController.listingById(order.listingId);
      if (listing == null || listing.quantity < order.quantity) {
        throw StateError('There is not enough stock for ${order.title}.');
      }
    }
    for (final order in orders) {
      final listing = listingController.listingById(order.listingId)!;
      await listingController.updateQuantity(
        listingId: listing.id,
        quantity: listing.quantity - order.quantity,
      );
    }
    await updateOrderGroupStatus(orders, DealStatus.confirmed, note: note);
  }

  Future<void> buyAgain(Deal deal, String locale) async {
    final result = await _ref
        .read(dealRepositoryProvider)
        .buyAgain(deal: deal, locale: locale);
    state = state.copyWith(buyAgainResult: result);
  }

  void clearBuyAgainResult() {
    state = state.copyWith(clearBuyAgainResult: true);
  }

  Future<ReviewRating> submitRating({
    required String dealId,
    required int stars,
    List<String> tags = const [],
    String? text,
  }) async {
    final rating = await _ref
        .read(dealRepositoryProvider)
        .submitRating(dealId: dealId, stars: stars, tags: tags, text: text);
    await loadDeals();
    _ref.invalidate(farmerDealsProvider);
    return rating;
  }

  ReviewRating? ratingForDeal(String dealId) {
    return _ref.read(dealRepositoryProvider).ratingForDeal(dealId);
  }

  bool canRate(Deal deal) {
    return deal.status == DealStatus.completed &&
        _ref.read(dealRepositoryProvider).ratingForDeal(deal.id) == null;
  }

  String? get _customerId => _ref.read(authControllerProvider).user?.id;
}
