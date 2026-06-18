import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/feed_post.dart';

final socialFeedControllerProvider =
    StateNotifierProvider<SocialFeedController, SocialFeedState>(
      (ref) => SocialFeedController(),
    );

class SocialFeedState {
  const SocialFeedState({
    required this.posts,
    required this.orders,
    List<FeedNotification>? notifications,
  }) : _notifications = notifications;

  final List<FeedPost> posts;
  final List<FeedOrder> orders;
  final List<FeedNotification>? _notifications;
  List<FeedNotification> get notifications =>
      _notifications ?? const <FeedNotification>[];

  SocialFeedState copyWith({
    List<FeedPost>? posts,
    List<FeedOrder>? orders,
    List<FeedNotification>? notifications,
  }) {
    return SocialFeedState(
      posts: posts ?? this.posts,
      orders: orders ?? this.orders,
      notifications: notifications ?? this.notifications,
    );
  }
}

class SocialFeedController extends StateNotifier<SocialFeedState> {
  SocialFeedController()
    : super(SocialFeedState(posts: _seedPosts, orders: const []));

  void addPost({
    required String authorId,
    required String authorName,
    required String product,
    required String description,
    List<String> photos = const [],
  }) {
    final now = DateTime.now();
    final trimmedProduct = product.trim();
    final trimmedDescription = description.trim();
    final post = FeedPost(
      id: 'post-${now.microsecondsSinceEpoch}',
      authorId: authorId,
      type: FeedPostType.sellNow,
      authorName: authorName,
      actorType: FeedActorType.farmer,
      title: trimmedProduct,
      description: trimmedDescription,
      location: 'Farm wall',
      dateLabel: 'Pre-order from comments',
      acceptsPreOrders: true,
      photos: photos,
      photoEmoji: '🥬',
      createdAt: now,
      comments: const [],
      offers: const [],
    );
    state = state.copyWith(posts: [post, ...state.posts]);
  }

  void addComment({
    required String postId,
    required String authorName,
    required String authorId,
    required FeedActorType actorType,
    required String text,
    String? parentCommentId,
  }) {
    if (text.trim().isEmpty) return;
    final post = state.posts.firstWhere((post) => post.id == postId);
    if (!post.areCommentsEnabled || post.isOffersFinished) return;
    final now = DateTime.now();
    final comment = FeedComment(
      id: 'comment-${now.microsecondsSinceEpoch}',
      authorName: authorName,
      authorId: authorId,
      actorType: actorType,
      text: text.trim(),
      createdAt: now,
      parentCommentId: parentCommentId,
    );
    final posts = _updatedPosts(
      postId,
      (post) => post.copyWith(comments: [...post.comments, comment]),
    );
    final notifications = [
      if (actorType == FeedActorType.consumer && post.authorId != authorId)
        FeedNotification(
          id: 'notification-${now.microsecondsSinceEpoch}',
          farmerId: post.authorId,
          postId: post.id,
          commentId: comment.id,
          actorName: authorName,
          postTitle: post.title,
          text: comment.text,
          createdAt: now,
        ),
      ...state.notifications,
    ];
    state = state.copyWith(posts: posts, notifications: notifications);
  }

  int unreadCountForFarmer(String farmerId) {
    return state.notifications
        .where((item) => item.farmerId == farmerId && !item.seen)
        .length;
  }

  List<FeedNotification> notificationsForFarmer(String farmerId) {
    return state.notifications
        .where((item) => item.farmerId == farmerId)
        .toList();
  }

  void markNotificationSeen(String notificationId) {
    state = state.copyWith(
      notifications: state.notifications
          .map(
            (item) =>
                item.id == notificationId ? item.copyWith(seen: true) : item,
          )
          .toList(),
    );
  }

  void markAllNotificationsSeen(String farmerId) {
    state = state.copyWith(
      notifications: state.notifications
          .map(
            (item) =>
                item.farmerId == farmerId ? item.copyWith(seen: true) : item,
          )
          .toList(),
    );
  }

  void markPostNotificationsSeen({
    required String farmerId,
    required String postId,
  }) {
    state = state.copyWith(
      notifications: state.notifications
          .map(
            (item) => item.farmerId == farmerId && item.postId == postId
                ? item.copyWith(seen: true)
                : item,
          )
          .toList(),
    );
  }

  void makeOffer({
    required String postId,
    required String authorId,
    required String authorName,
    required FeedActorType actorType,
    required String title,
    required String quantity,
    required double price,
    required String dateLabel,
    required String note,
    String? sourceCommentId,
    String? sourceCommentText,
    String? targetCustomerId,
    String? targetCustomerName,
  }) {
    final post = state.posts.firstWhere((post) => post.id == postId);
    if (post.isOffersFinished) return;
    final offer = FeedOffer(
      id: 'offer-${DateTime.now().microsecondsSinceEpoch}',
      authorName: authorName,
      authorId: authorId,
      actorType: actorType,
      title: title.trim(),
      quantity: quantity.trim(),
      price: price,
      dateLabel: dateLabel.trim(),
      note: note.trim(),
      status: FeedOfferStatus.pending,
      createdAt: DateTime.now(),
      sourceCommentId: sourceCommentId,
      sourceCommentText: sourceCommentText,
      targetCustomerId: targetCustomerId,
      targetCustomerName: targetCustomerName,
    );
    _updatePost(
      postId,
      (post) => post.copyWith(offers: [...post.offers, offer]),
    );
  }

  void counterOffer({
    required String postId,
    required String offerId,
    required String authorId,
    required String authorName,
    required FeedActorType actorType,
    required String title,
    required String quantity,
    required double price,
    required String dateLabel,
    required String note,
  }) {
    final post = state.posts.firstWhere((post) => post.id == postId);
    final countered = post.offers.firstWhere((offer) => offer.id == offerId);
    _setOfferStatus(postId, offerId, FeedOfferStatus.countered);
    makeOffer(
      postId: postId,
      authorId: authorId,
      authorName: authorName,
      actorType: actorType,
      title: title,
      quantity: quantity,
      price: price,
      dateLabel: dateLabel,
      note: note,
      sourceCommentId: countered.sourceCommentId,
      sourceCommentText: countered.sourceCommentText,
      targetCustomerId: countered.actorType == FeedActorType.consumer
          ? countered.authorId
          : countered.targetCustomerId,
      targetCustomerName: countered.actorType == FeedActorType.consumer
          ? countered.authorName
          : countered.targetCustomerName,
    );
  }

  void declineOffer(String postId, String offerId) {
    _setOfferStatus(postId, offerId, FeedOfferStatus.declined);
  }

  void cancelOffer(String postId, String offerId) {
    _setOfferStatus(postId, offerId, FeedOfferStatus.cancelled);
  }

  void setOffersFinished(String postId, bool value) {
    _updatePost(
      postId,
      (post) => post.copyWith(
        offersFinished: value,
        commentsEnabled: value ? false : post.areCommentsEnabled,
        bumpedAt: value ? post.bumpedAt : DateTime.now(),
      ),
    );
  }

  void setCommentsEnabled(String postId, bool value) {
    _updatePost(postId, (post) => post.copyWith(commentsEnabled: value));
  }

  void deletePost(String postId) {
    state = state.copyWith(
      posts: state.posts.where((post) => post.id != postId).toList(),
    );
  }

  void reportComment({
    required String postId,
    required String commentId,
    required String reporterId,
  }) {
    // TODO(backend): Send moderation report to API.
  }

  FeedOrder acceptOffer(String postId, String offerId) {
    final post = state.posts.firstWhere((post) => post.id == postId);
    final offer = post.offers.firstWhere((offer) => offer.id == offerId);
    final farmerName = offer.actorType == FeedActorType.farmer
        ? offer.authorName
        : post.authorName;
    final consumerName = offer.targetCustomerName ?? 'Customer';

    _setOfferStatus(postId, offerId, FeedOfferStatus.accepted);
    final order = FeedOrder(
      id: 'feed-order-${DateTime.now().microsecondsSinceEpoch}',
      postId: postId,
      offerId: offerId,
      title: offer.title,
      farmerName: farmerName,
      consumerName: consumerName,
      quantity: offer.quantity,
      price: offer.price,
      dateLabel: offer.dateLabel,
      createdAt: DateTime.now(),
    );
    state = state.copyWith(orders: [order, ...state.orders]);
    return order;
  }

  void _setOfferStatus(String postId, String offerId, FeedOfferStatus status) {
    _updatePost(postId, (post) {
      return post.copyWith(
        offers: post.offers
            .map(
              (offer) =>
                  offer.id == offerId ? offer.copyWith(status: status) : offer,
            )
            .toList(),
      );
    });
  }

  void _updatePost(String postId, FeedPost Function(FeedPost post) update) {
    state = state.copyWith(posts: _updatedPosts(postId, update));
  }

  List<FeedPost> _updatedPosts(
    String postId,
    FeedPost Function(FeedPost post) update,
  ) {
    return state.posts
        .map((post) => post.id == postId ? update(post) : post)
        .toList()
      ..sort(
        (left, right) => (right.bumpedAt ?? right.createdAt).compareTo(
          left.bumpedAt ?? left.createdAt,
        ),
      );
  }
}

final _seedPosts = [
  FeedPost(
    id: 'seed-sell-1',
    authorId: 'farmer-1',
    type: FeedPostType.sellNow,
    authorName: 'North Field Farm',
    actorType: FeedActorType.farmer,
    title: 'Fresh strawberries today',
    description:
        'Picked this morning. Sell now for today, and I can also take pre-orders for the weekend.',
    location: 'Vaasa market pickup',
    dateLabel: 'Today 17:00-19:00',
    priceLabel: '€5 / kg',
    quantityLabel: '18 kg available',
    acceptsPreOrders: true,
    photoEmoji: '🍓',
    photos: const [],
    createdAt: DateTime(2026, 6, 17, 8, 30),
    comments: [
      FeedComment(
        id: 'seed-comment-1',
        authorName: 'Mira',
        authorId: 'user-customer-1',
        actorType: FeedActorType.consumer,
        text: 'Can I get 2 kg if I pick up after work?',
        createdAt: DateTime(2026, 6, 17, 9, 5),
      ),
      FeedComment(
        id: 'seed-comment-1-reply',
        authorName: 'North Field Farm',
        authorId: 'farmer-1',
        actorType: FeedActorType.farmer,
        text: 'Yes, I can keep it aside.',
        createdAt: DateTime(2026, 6, 17, 9, 10),
        parentCommentId: 'seed-comment-1',
      ),
    ],
    offers: [
      FeedOffer(
        id: 'seed-offer-1',
        authorName: 'North Field Farm',
        authorId: 'farmer-1',
        actorType: FeedActorType.farmer,
        title: '2 kg strawberries',
        quantity: '2 kg',
        price: 10,
        dateLabel: 'Today after 17:30',
        note: 'I will keep two boxes aside for you.',
        status: FeedOfferStatus.pending,
        createdAt: DateTime(2026, 6, 17, 9, 15),
        sourceCommentId: 'seed-comment-1',
        sourceCommentText: 'Can I get 2 kg if I pick up after work?',
        targetCustomerId: 'user-customer-1',
        targetCustomerName: 'Mira',
      ),
    ],
  ),
  FeedPost(
    id: 'seed-request-1',
    authorId: 'farmer-1',
    type: FeedPostType.sellNow,
    authorName: 'North Bakery Farm',
    actorType: FeedActorType.farmer,
    title: 'Custom celebration cakes this weekend',
    description:
        'Taking cake pre-orders. Tell me the size, date, message, flavor, and decoration in comments.',
    location: 'Near Palosaari',
    dateLabel: 'Fri-Sun pickup',
    priceLabel: 'From €38',
    quantityLabel: 'Custom sizes',
    acceptsPreOrders: true,
    photoEmoji: '🎂',
    createdAt: DateTime(2026, 6, 16, 16, 20),
    comments: [
      FeedComment(
        id: 'seed-comment-2',
        authorName: 'Aarav',
        authorId: 'user-customer-1',
        actorType: FeedActorType.consumer,
        text:
            'I need a chocolate graduation cake for 20 people. Cherry topping, message: Congrats Rohan, pickup Saturday morning.',
        createdAt: DateTime(2026, 6, 16, 17),
      ),
    ],
    offers: [
      FeedOffer(
        id: 'seed-offer-2',
        authorName: 'North Bakery Farm',
        authorId: 'farmer-1',
        actorType: FeedActorType.farmer,
        title: 'Custom graduation cake',
        quantity: '20 servings',
        price: 58,
        dateLabel: 'Saturday 10:00 pickup',
        note: 'Chocolate sponge, cherries, and custom message included.',
        status: FeedOfferStatus.pending,
        createdAt: DateTime(2026, 6, 16, 17, 10),
        sourceCommentId: 'seed-comment-2',
        sourceCommentText:
            'I need a chocolate graduation cake for 20 people. Cherry topping, message: Congrats Rohan, pickup Saturday morning.',
        targetCustomerId: 'user-customer-1',
        targetCustomerName: 'Aarav',
      ),
    ],
  ),
];
