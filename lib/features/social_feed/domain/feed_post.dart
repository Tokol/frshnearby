enum FeedPostType { sellNow, preOrderRequest }

enum FeedActorType { farmer, consumer }

enum FeedOfferStatus { pending, countered, accepted, declined }

class FeedComment {
  const FeedComment({
    required this.id,
    required this.authorName,
    required this.authorId,
    required this.actorType,
    required this.text,
    required this.createdAt,
    this.parentCommentId,
  });

  final String id;
  final String authorName;
  final String authorId;
  final FeedActorType actorType;
  final String text;
  final DateTime createdAt;
  final String? parentCommentId;
}

class FeedOffer {
  const FeedOffer({
    required this.id,
    required this.authorName,
    required this.authorId,
    required this.actorType,
    required this.title,
    required this.quantity,
    required this.price,
    required this.dateLabel,
    required this.note,
    required this.status,
    required this.createdAt,
    this.sourceCommentId,
    this.sourceCommentText,
    this.targetCustomerId,
    this.targetCustomerName,
  });

  final String id;
  final String authorName;
  final String authorId;
  final FeedActorType actorType;
  final String title;
  final String quantity;
  final double price;
  final String dateLabel;
  final String note;
  final FeedOfferStatus status;
  final DateTime createdAt;
  final String? sourceCommentId;
  final String? sourceCommentText;
  final String? targetCustomerId;
  final String? targetCustomerName;

  FeedOffer copyWith({FeedOfferStatus? status}) {
    return FeedOffer(
      id: id,
      authorName: authorName,
      authorId: authorId,
      actorType: actorType,
      title: title,
      quantity: quantity,
      price: price,
      dateLabel: dateLabel,
      note: note,
      status: status ?? this.status,
      createdAt: createdAt,
      sourceCommentId: sourceCommentId,
      sourceCommentText: sourceCommentText,
      targetCustomerId: targetCustomerId,
      targetCustomerName: targetCustomerName,
    );
  }
}

class FeedOrder {
  const FeedOrder({
    required this.id,
    required this.postId,
    required this.offerId,
    required this.title,
    required this.farmerName,
    required this.consumerName,
    required this.quantity,
    required this.price,
    required this.dateLabel,
    required this.createdAt,
  });

  final String id;
  final String postId;
  final String offerId;
  final String title;
  final String farmerName;
  final String consumerName;
  final String quantity;
  final double price;
  final String dateLabel;
  final DateTime createdAt;
}

class FeedPost {
  const FeedPost({
    required this.id,
    required this.authorId,
    required this.type,
    required this.authorName,
    required this.actorType,
    required this.title,
    required this.description,
    required this.location,
    required this.dateLabel,
    required this.createdAt,
    required this.comments,
    required this.offers,
    this.bumpedAt,
    this.photos = const [],
    this.priceLabel,
    this.quantityLabel,
    this.acceptsPreOrders = false,
    bool? offersFinished,
    bool? commentsEnabled,
    this.photoEmoji = '🥕',
  }) : _offersFinished = offersFinished,
       _commentsEnabled = commentsEnabled;

  final String id;
  final String authorId;
  final FeedPostType type;
  final String authorName;
  final FeedActorType actorType;
  final String title;
  final String description;
  final String location;
  final String dateLabel;
  final DateTime createdAt;
  final DateTime? bumpedAt;
  final List<FeedComment> comments;
  final List<FeedOffer> offers;
  final List<String> photos;
  final String? priceLabel;
  final String? quantityLabel;
  final bool acceptsPreOrders;
  final bool? _offersFinished;
  final bool? _commentsEnabled;
  bool get isOffersFinished => _offersFinished ?? false;
  bool get areCommentsEnabled => _commentsEnabled ?? true;
  final String photoEmoji;

  FeedPost copyWith({
    List<FeedComment>? comments,
    List<FeedOffer>? offers,
    bool? offersFinished,
    bool? commentsEnabled,
    DateTime? bumpedAt,
  }) {
    return FeedPost(
      id: id,
      authorId: authorId,
      type: type,
      authorName: authorName,
      actorType: actorType,
      title: title,
      description: description,
      location: location,
      dateLabel: dateLabel,
      createdAt: createdAt,
      bumpedAt: bumpedAt ?? this.bumpedAt,
      comments: comments ?? this.comments,
      offers: offers ?? this.offers,
      photos: photos,
      priceLabel: priceLabel,
      quantityLabel: quantityLabel,
      acceptsPreOrders: acceptsPreOrders,
      offersFinished: offersFinished ?? isOffersFinished,
      commentsEnabled: commentsEnabled ?? areCommentsEnabled,
      photoEmoji: photoEmoji,
    );
  }
}
