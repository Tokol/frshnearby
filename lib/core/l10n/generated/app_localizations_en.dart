// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Fresh Farm';

  @override
  String get splashLoading => 'Preparing fresh produce...';

  @override
  String get loginTitle => 'Welcome back';

  @override
  String get loginSubtitle => 'Sign in to shop fresh local food.';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get nameLabel => 'Name';

  @override
  String get loginButton => 'Sign in';

  @override
  String get registerButton => 'Create account';

  @override
  String get createAccountPrompt => 'New to Fresh Farm?';

  @override
  String get alreadyHaveAccountPrompt => 'Already have an account?';

  @override
  String get registerTitle => 'Create your account';

  @override
  String get registerSubtitle =>
      'Start buying from nearby farms and producers.';

  @override
  String get customerHomeTitle => 'Marketplace';

  @override
  String get customerHomeGreeting => 'Fresh picks near you';

  @override
  String get customerHomeEmptyTitle => 'No products yet';

  @override
  String get customerHomeEmptyMessage =>
      'Local produce will appear here once the marketplace is connected.';

  @override
  String get nearbyListingsTitle => 'Nearby fresh listings';

  @override
  String get homeLocationLine => 'Vaasa, Ostrobothnia';

  @override
  String get currentLocationLabel => 'Your current location';

  @override
  String get confirmLocationTitle => 'Confirm your location';

  @override
  String confirmLocationMessage(Object location) {
    return 'Based on your phone location, it looks like you\'re near $location.';
  }

  @override
  String get useThisLocationButton => 'Use this location';

  @override
  String get enterAnotherLocationButton => 'Enter another location';

  @override
  String get locationSearchTitle => 'Choose location';

  @override
  String get locationSearchHint => 'Search city or region';

  @override
  String get noLocationResultsTitle => 'No locations found';

  @override
  String get homeSearchPlaceholder => 'Search potatoes, honey, tomatoes...';

  @override
  String get homeHeroTitle => 'Fresh from local farms';

  @override
  String get homeHeroSubtitle =>
      'Seasonal produce, eggs, and honey ready near you.';

  @override
  String get browseTodayPicks => 'Browse today’s picks';

  @override
  String get seeAllButton => 'See all';

  @override
  String get homeJustHarvestedTitle => 'Just harvested';

  @override
  String get homeDealsTodayTitle => 'Good deals today';

  @override
  String get categoryVegetables => 'Vegetables';

  @override
  String get categoryFruits => 'Fruits';

  @override
  String get categoryMeat => 'Meat';

  @override
  String get categoryFish => 'Fish';

  @override
  String get categoryBakery => 'Bakery';

  @override
  String get categoryDairy => 'Dairy';

  @override
  String get categoryEggs => 'Eggs';

  @override
  String get categoryHoney => 'Honey';

  @override
  String get categoryCheese => 'Cheese';

  @override
  String get categoryMilk => 'Milk';

  @override
  String get categoryHerbs => 'Herbs';

  @override
  String get categoryMushrooms => 'Mushrooms';

  @override
  String get categoryBerries => 'Berries';

  @override
  String get categoryFlowers => 'Flowers';

  @override
  String get categoryJuice => 'Juice';

  @override
  String get categoryPreserves => 'Preserves';

  @override
  String get categoryGrains => 'Grains';

  @override
  String get categoryReadyMeals => 'Ready meals';

  @override
  String get categoryOrganic => 'Organic';

  @override
  String get notificationsLabel => 'Notifications';

  @override
  String get cartLabel => 'Cart';

  @override
  String get customerHomeTab => 'Home';

  @override
  String get customerSearchTab => 'Search';

  @override
  String get messagesTab => 'Messages';

  @override
  String get dealsTab => 'Deals';

  @override
  String get profileTab => 'Profile';

  @override
  String get farmerDashboardTab => 'Dashboard';

  @override
  String get farmerListingsTab => 'Listings';

  @override
  String get farmerReviewsTab => 'Reviews';

  @override
  String get customerSearchTitle => 'Search';

  @override
  String get customerSearchEmptyMessage => 'Product search will appear here.';

  @override
  String get searchListingsHint => 'Search products, categories, or variants';

  @override
  String get noListingsFoundTitle => 'No listings found';

  @override
  String get noListingsFoundMessage =>
      'Try another product, category, or variant.';

  @override
  String get listingDetailTitle => 'Listing details';

  @override
  String get farmerPublicProfileTitle => 'Farmer profile';

  @override
  String get kilometersAwayLabel => 'km away';

  @override
  String get distanceLabel => 'Distance';

  @override
  String get ratingLabel => 'rating';

  @override
  String get farmerRatingLabel => 'Farmer rating';

  @override
  String get farmRatingLabel => 'Farm rating';

  @override
  String get farmReviewsLabel => 'farm reviews';

  @override
  String get newFarmLabel => 'New farm';

  @override
  String get viewFarmProfileButton => 'View farm profile';

  @override
  String get verifiedBadgeLabel => 'Verified farmer';

  @override
  String get approximateLocationLabel => 'Approximate location';

  @override
  String get chatButton => 'Chat';

  @override
  String get exactLocationAfterDealMessage =>
      'Exact pickup location is shared only after a deal is confirmed.';

  @override
  String get farmerNotFoundMessage => 'This farmer profile is not available.';

  @override
  String get messagesTitle => 'Messages';

  @override
  String get messagesEmptyMessage => 'Conversations will appear here.';

  @override
  String get dealsTitle => 'Deals';

  @override
  String get dealsEmptyMessage => 'Fresh offers will appear here.';

  @override
  String get dealsEmptyTitle => 'No deals yet';

  @override
  String get dealStatusNegotiating => 'Negotiating';

  @override
  String get dealStatusConfirmed => 'Confirmed';

  @override
  String get dealStatusReadyForPickup => 'Ready for pickup';

  @override
  String get dealStatusCompleted => 'Completed';

  @override
  String get dealStatusCancelled => 'Cancelled';

  @override
  String get confirmDealButton => 'Confirm deal';

  @override
  String get markCompletedButton => 'Mark completed';

  @override
  String get buyAgainButton => 'Buy again';

  @override
  String get rateDealButton => 'Rate this deal';

  @override
  String get ratingSoftPromptMessage =>
      'How was your experience? A quick rating helps other customers.';

  @override
  String get chatTitle => 'Chat';

  @override
  String get messageLabel => 'Message';

  @override
  String get sendButton => 'Send';

  @override
  String get rateDealTitle => 'Rate your deal';

  @override
  String get ratingTagFresh => 'Fresh';

  @override
  String get ratingTagFriendly => 'Friendly';

  @override
  String get ratingTagOnTime => 'On time';

  @override
  String get ratingTextLabel => 'Optional feedback';

  @override
  String get submitRatingButton => 'Submit rating';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileGuestName => 'Guest customer';

  @override
  String get profileGuestEmail => 'No email available';

  @override
  String get switchToFarmerButton => 'Switch to Farmer';

  @override
  String get switchToCustomerButton => 'Switch to Customer';

  @override
  String get applyAsFarmerButton => 'Apply as Farmer';

  @override
  String get applyAsFarmerTitle => 'Apply as Farmer';

  @override
  String get applyAsFarmerIntro =>
      'Tell us about your farm profile before submitting it for review.';

  @override
  String get profileTypeLabel => 'Profile type';

  @override
  String get profileTypeIndividual => 'Individual';

  @override
  String get profileTypeFarm => 'Farm';

  @override
  String get profileTypeCooperative => 'Cooperative';

  @override
  String get displayNameLabel => 'Display name';

  @override
  String get farmNameLabel => 'Farm name';

  @override
  String get phoneLabel => 'Phone';

  @override
  String get shortDescriptionLabel => 'Short description';

  @override
  String get profilePhotoPlaceholderLabel => 'Profile photo placeholder';

  @override
  String get continueButton => 'Continue';

  @override
  String get farmerLocationTitle => 'Farm location';

  @override
  String get locationPermissionMessage =>
      'Allow location access to fill your farm coordinates, or enter them manually.';

  @override
  String get useCurrentLocationButton => 'Use current location';

  @override
  String get locationPermissionDeniedMessage =>
      'Location permission was denied. You can enter the location manually.';

  @override
  String get mapPlaceholderTitle => 'Map preview';

  @override
  String get mapPlaceholderMessage =>
      'A real map will appear here later. For now, confirm the coordinates below.';

  @override
  String get latitudeLabel => 'Latitude';

  @override
  String get longitudeLabel => 'Longitude';

  @override
  String get cityLabel => 'City';

  @override
  String get countryLabel => 'Country';

  @override
  String get confirmLocationButton => 'Confirm location';

  @override
  String get farmerApplicationReviewTitle => 'Review application';

  @override
  String get farmerApplicationReviewIntro =>
      'Review your details before submitting. Admin review is required before farmer mode is available.';

  @override
  String get submitApplicationButton => 'Submit application';

  @override
  String get editLocationButton => 'Edit location';

  @override
  String get backToCustomerModeButton => 'Back to Customer mode';

  @override
  String get farmerPendingTitle => 'Farmer application pending';

  @override
  String get farmerPendingMessage => 'Your farmer application is under review.';

  @override
  String get farmerRejectedTitle => 'Farmer application rejected';

  @override
  String get farmerRejectedMessage =>
      'Farmer mode is not available for this account.';

  @override
  String get farmerSuspendedTitle => 'Farmer access suspended';

  @override
  String get farmerSuspendedMessage =>
      'Farmer mode is not available for this account.';

  @override
  String get farmerDashboardTitle => 'Farmer dashboard';

  @override
  String get farmerDashboardEmptyMessage =>
      'Sales, orders, and farm activity will appear here.';

  @override
  String get farmerListingsTitle => 'Listings';

  @override
  String get farmerListingsEmptyTitle => 'No listings yet';

  @override
  String get farmerListingsEmptyMessage =>
      'Your farm listings will appear here.';

  @override
  String get createListingTitle => 'Create listing';

  @override
  String get editListingTitle => 'Edit listing';

  @override
  String get listingPreviewTitle => 'Listing preview';

  @override
  String get whatAreYouSelling => 'What are you selling?';

  @override
  String get quantityLabel => 'Quantity';

  @override
  String get unitLabel => 'Unit';

  @override
  String get priceLabel => 'Price';

  @override
  String get listingDescriptionLabel => 'Description';

  @override
  String get harvestDateLabel => 'Harvest date';

  @override
  String get farmingMethodLabel => 'Farming method';

  @override
  String get pickupNotesLabel => 'Pickup notes';

  @override
  String get deliveryEnabledLabel => 'Delivery enabled';

  @override
  String get listingPhotoPlaceholderLabel => 'Photo placeholder';

  @override
  String get previewListingButton => 'Preview listing';

  @override
  String get editListingButton => 'Edit listing';

  @override
  String get saveChangesButton => 'Save changes';

  @override
  String get archiveListingButton => 'Delete/archive listing';

  @override
  String get listingNotFoundMessage => 'This listing could not be found.';

  @override
  String get yesLabel => 'Yes';

  @override
  String get noLabel => 'No';

  @override
  String get farmerReviewsTitle => 'Reviews';

  @override
  String get farmerReviewsEmptyMessage => 'Customer reviews will appear here.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get languageLabel => 'Language';

  @override
  String get englishLanguage => 'English';

  @override
  String get finnishLanguage => 'Finnish';

  @override
  String get swedishLanguage => 'Swedish';

  @override
  String get signOutButton => 'Sign out';

  @override
  String get genericErrorTitle => 'Something went wrong';

  @override
  String get genericErrorMessage => 'Please try again in a moment.';

  @override
  String get retryButton => 'Retry';

  @override
  String get loadingMessage => 'Loading...';

  @override
  String get validationRequired => 'This field is required.';

  @override
  String get validationEmail => 'Enter a valid email address.';

  @override
  String get validationPositiveNumber => 'Enter a number greater than zero.';

  @override
  String get validationNumber => 'Enter a valid number.';

  @override
  String get confirmButton => 'Confirm';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get confirmArchiveListingTitle => 'Archive listing?';

  @override
  String get confirmArchiveListingMessage =>
      'This listing will be removed from your active listings.';

  @override
  String get confirmDealTitle => 'Confirm deal?';

  @override
  String get confirmDealMessage => 'This marks the negotiation as confirmed.';

  @override
  String get confirmCompletedTitle => 'Mark deal completed?';

  @override
  String get confirmCompletedMessage =>
      'Completed deals move to bought history and can be rated.';

  @override
  String get unauthorizedTitle => 'Not available';

  @override
  String get verifiedFarmerRequiredMessage =>
      'Only verified farmers can open this screen.';

  @override
  String get productSectionTitle => 'Product';

  @override
  String get productSectionDescription =>
      'Choose what customers will see on your farm page.';

  @override
  String get stockAndPriceTitle => 'Stock and price';

  @override
  String get stockAndPriceDescription =>
      'Tell us how much is available and how you sell it.';

  @override
  String get availableNowLabel => 'Available now';

  @override
  String get productDetailsTitle => 'Product details';

  @override
  String get productDetailsDescription =>
      'Optional information that can help customers decide.';

  @override
  String get producedDateOptionalLabel => 'Produced date (optional)';

  @override
  String get productionDetailsLabel => 'Production details (optional)';

  @override
  String get bestBeforeOptionalLabel => 'Best before (optional)';

  @override
  String get storageInstructionsOptionalLabel =>
      'Storage instructions (optional)';

  @override
  String get addProductButton => 'Add product';

  @override
  String get productAddedMessage => 'Product added.';

  @override
  String get productUpdatedMessage => 'Product updated.';

  @override
  String get updateChangedFieldsHint => 'Update only what has changed.';

  @override
  String get addProductPhotoLabel => 'Add product photo';

  @override
  String get sellingUnitLabel => 'How do you sell it?';

  @override
  String get kilogramUnit => 'Kilogram (kg)';

  @override
  String get pieceUnit => 'Piece';

  @override
  String get bunchUnit => 'Bunch';

  @override
  String get bagUnit => 'Bag';

  @override
  String get boxUnit => 'Box';

  @override
  String get jarUnit => 'Jar';

  @override
  String get customerPriceLabel => 'Customer price';

  @override
  String pricePerUnitHelp(Object unit) {
    return 'The customer sees this as the price per $unit.';
  }

  @override
  String perUnitLabel(Object unit) {
    return 'per $unit';
  }

  @override
  String get selectDateHint => 'Select a date';

  @override
  String get clearDateTooltip => 'Clear date';

  @override
  String get ordersTitle => 'Orders';

  @override
  String get myOrdersLabel => 'My orders';

  @override
  String get totalLabel => 'Total';

  @override
  String get productsLabel => 'Products';

  @override
  String get billTitle => 'Bill';

  @override
  String get farmPickupLabel => 'Farm pickup';

  @override
  String get courierLabel => 'Courier';

  @override
  String get freeLabel => 'Free';

  @override
  String get payAndRequestLabel => 'Pay & Request';

  @override
  String get cartEmptyTitle => 'Your cart is empty';

  @override
  String get cartEmptyMessage => 'Add products from a farm page.';

  @override
  String get ordersEmptyTitle => 'No orders yet';

  @override
  String get ordersEmptyMessage =>
      'Your requests and delivery progress will appear here.';

  @override
  String get followLabel => 'Follow';

  @override
  String get followingLabel => 'Following';

  @override
  String get addToCartLabel => 'Add to cart';

  @override
  String availableCountLabel(Object count) {
    return '$count available';
  }

  @override
  String get dashboardGreeting => 'Good morning';

  @override
  String get dashboardIntro =>
      'Manage your products, fulfil orders, and share your farm page.';

  @override
  String get activeOrdersLabel => 'Active orders';

  @override
  String get salesThisMonthLabel => 'Sales this month';

  @override
  String allTimeSalesLabel(Object amount) {
    return 'All time €$amount';
  }

  @override
  String get noProductsMessage => 'No product listings yet.';

  @override
  String get yourFarmPageLabel => 'Your farm page';

  @override
  String get previewLabel => 'Preview';

  @override
  String get copyLinkTooltip => 'Copy link';

  @override
  String get shareLinkTooltip => 'Share link';

  @override
  String get farmLinkCopiedMessage => 'Farm link copied';

  @override
  String get manageLabel => 'Manage';

  @override
  String get nearbyMapTooltip => 'Nearby map';

  @override
  String get homeTabLabel => 'Home';

  @override
  String get insightsTabLabel => 'Insights';

  @override
  String get prototypeViewLabel => 'Prototype view';

  @override
  String get farmerModeLabel => 'Farmer';

  @override
  String get consumerModeLabel => 'Consumer';

  @override
  String get orderBookTitle => 'Order book';

  @override
  String get orderBookSubtitle => 'Requests, fulfilment and history';

  @override
  String get ordersLoadError => 'Could not load orders.';

  @override
  String get activeLabel => 'Active';

  @override
  String get requestsLabel => 'Requests';

  @override
  String get historyLabel => 'History';

  @override
  String orderNumberLabel(Object number) {
    return 'Order #$number';
  }

  @override
  String productCountLabel(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count products',
      one: '1 product',
    );
    return '$_temp0';
  }

  @override
  String get courierCollectionLabel => 'Courier collection';

  @override
  String get viewOrderLabel => 'View order';

  @override
  String get newRequestStatus => 'New request';

  @override
  String get requestedStatus => 'Requested';

  @override
  String get acceptedStatus => 'Accepted';

  @override
  String get preparingStatus => 'Preparing';

  @override
  String get readyStatus => 'Ready';

  @override
  String get deliveredStatus => 'Delivered';

  @override
  String get declinedStatus => 'Declined';

  @override
  String get noOrdersSectionMessage => 'No orders in this section.';

  @override
  String get completedOrdersLabel => 'Completed orders';

  @override
  String get averageOrderLabel => 'Average order';

  @override
  String get quantitySoldLabel => 'Quantity sold';

  @override
  String get salesTrendTitle => 'Sales trend';

  @override
  String get topProductsTitle => 'Top products';

  @override
  String get fulfilmentTitle => 'Fulfilment';

  @override
  String get viewSalesStatementLabel => 'View sales statement';

  @override
  String get salesStatementLabel => 'Sales statement';

  @override
  String get previousMonthTooltip => 'Previous month';

  @override
  String get nextMonthTooltip => 'Next month';

  @override
  String get customRangeHint => 'Tap for custom range';

  @override
  String get salesPeriodLabel => 'Sales period';

  @override
  String get showReportLabel => 'Show report';

  @override
  String get totalSalesLabel => 'TOTAL SALES';

  @override
  String completedOrderCountLabel(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count completed orders',
      one: '1 completed order',
    );
    return '$_temp0';
  }

  @override
  String get noCompletedSalesMessage => 'No completed sales in this period';

  @override
  String get noProductSalesMessage => 'No product sales in this period.';

  @override
  String soldQuantityLabel(Object quantity, Object unit) {
    return '$quantity $unit sold';
  }

  @override
  String get noCompletedOrdersMessage => 'No completed orders in this period.';

  @override
  String get insightEmptyMessage =>
      'Complete an order to start seeing useful sales patterns.';

  @override
  String topEarningProductMessage(Object product) {
    return '$product earned the most in this period.';
  }

  @override
  String get shareReportTooltip => 'Share report';

  @override
  String paymentAuthorizedLabel(Object method) {
    return '$method authorized · not charged yet';
  }

  @override
  String paymentChargedLabel(Object method) {
    return '$method charged after acceptance';
  }

  @override
  String get declinedByFarmerLabel => 'Declined by farmer';

  @override
  String get declinedPaymentReleasedLabel =>
      'Declined · payment authorization released';

  @override
  String get courierDeliveryLabel => 'Courier delivery';

  @override
  String get removeTooltip => 'Remove';

  @override
  String onlyQuantityAvailableMessage(Object quantity, Object unit) {
    return 'Only $quantity $unit available.';
  }

  @override
  String get fulfilmentQuestion => 'How would you like it?';

  @override
  String get pickupAtFarmLabel => 'Pick up at farm';

  @override
  String get pickupLocationAfterAcceptance =>
      'Free · exact location after acceptance';

  @override
  String get farmsYouFollowTitle => 'Farms you follow';

  @override
  String get orderNotFoundMessage => 'Order not found.';

  @override
  String get orderDetailsTitle => 'Order details';

  @override
  String get callLabel => 'Call';

  @override
  String get textLabel => 'Text';

  @override
  String get orderLabel => 'Order';

  @override
  String get statusLabel => 'Status';

  @override
  String get customerHistoryLabel => 'Customer history';

  @override
  String get declineLabel => 'Decline';

  @override
  String get acceptOrderLabel => 'Accept order';

  @override
  String get acceptLabel => 'Accept';

  @override
  String get acceptRequestLabel => 'Accept request';

  @override
  String get addOptionalNoteLabel => 'Add a note (optional)';

  @override
  String get customerPickupLabel => 'Customer pickup';

  @override
  String get customerWillCollectLabel => 'Customer will collect this order';

  @override
  String get courierWillCollectLabel => 'Courier will collect this order';

  @override
  String get preparePickupMessage =>
      'Prepare it for the selected pickup point.';

  @override
  String get prepareCourierMessage =>
      'Prepare it for courier collection. Delivery is handled by FreshFarm.';

  @override
  String customerOrderCountLabel(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count orders',
      one: '1 order',
    );
    return '$_temp0';
  }

  @override
  String get paymentAuthorizationInfo =>
      'Your payment is authorized now and charged only when the farmer accepts.';

  @override
  String authorizeWithLabel(Object method) {
    return 'Authorize with $method';
  }

  @override
  String get cardLabel => 'Card';

  @override
  String get authorizeCardLabel => 'Authorize your card';

  @override
  String get requestSentLabel => 'Request sent';

  @override
  String requestSentPaymentMessage(Object method) {
    return '$method authorized. You will be charged only after the farmer accepts.';
  }

  @override
  String get doneLabel => 'Done';

  @override
  String get loadingFarmMessage => 'Loading farm...';

  @override
  String get farmOpenErrorTitle => 'Could not open this farm';

  @override
  String get farmNotFoundTitle => 'Farm not found';

  @override
  String get shareFarmTooltip => 'Share farm';

  @override
  String addedToCartMessage(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count products added to cart.',
      one: '1 product added to cart.',
    );
    return '$_temp0';
  }

  @override
  String get viewCartLabel => 'View cart';

  @override
  String get nextHarvestMessage => 'This farm is preparing its next harvest.';

  @override
  String get openFarmLabel => 'Open farm';

  @override
  String freshPicksLabel(Object count) {
    return '$count fresh picks';
  }

  @override
  String get bestBeforeLabel => 'Best before';

  @override
  String get storageLabel => 'Storage';

  @override
  String get farmPickupLocationLabel => 'Farm pickup location';

  @override
  String get allLabel => 'All';

  @override
  String get editLabel => 'Edit';

  @override
  String availableRatioLabel(Object active, Object total) {
    return '$active of $total available';
  }

  @override
  String get undoLabel => 'Undo';

  @override
  String get quantityToAddLabel => 'Quantity to add';

  @override
  String get addToStockLabel => 'Add to stock';

  @override
  String get farmProfileNotFoundMessage => 'Farm profile not found.';

  @override
  String get editFarmProfileTitle => 'Edit farm profile';

  @override
  String get changeProfilePhotoLabel => 'Change profile photo';

  @override
  String get changeCoverPhotoLabel => 'Change cover photo';

  @override
  String get shortIntroductionLabel => 'Short introduction';

  @override
  String get farmIntroductionHint =>
      'What makes your farm and produce special?';

  @override
  String get customerContactNumberLabel => 'Customer contact number';

  @override
  String get farmPickupDescription =>
      'Customers can collect accepted orders from your farm.';

  @override
  String get pickupAtFarmLocationLabel => 'Pickup at farm location';

  @override
  String get pickupAtFarmLocationDescription =>
      'Use your confirmed farm location as the pickup point.';

  @override
  String get exactLocationAfterAcceptance =>
      'Exact farm location after acceptance';

  @override
  String get pickupAddressRequired => 'Enter the pickup point address.';

  @override
  String get setPickupLocationLabel => 'Set pickup location';

  @override
  String get pickupLocationHint => 'Street, city or recognizable place';

  @override
  String get pickupNoteLabel => 'Pickup note';

  @override
  String get pickupNoteHint => 'For example: Collect from the farm gate';

  @override
  String get farmLocationLabel => 'Farm location';

  @override
  String get confirmedGpsLocationLabel =>
      'Based on your confirmed GPS location';

  @override
  String get savePublicProfileLabel => 'Save public profile';

  @override
  String get customerReviewLabel => 'Customer review';

  @override
  String get writeReviewLabel => 'Rate and review';

  @override
  String get noReviewYetLabel => 'No review yet';

  @override
  String get reviewOptionalHint => 'Rating and written feedback are optional.';

  @override
  String get notNowLabel => 'Not now';

  @override
  String get reviewSubmittedLabel => 'Review submitted';

  @override
  String get verifiedCustomerLabel => 'Verified customer';

  @override
  String get landingNavAbout => 'About us';

  @override
  String get landingNavInterested => 'Interested?';

  @override
  String get landingNavPrototype => 'Open prototype';

  @override
  String get landingHeroKicker => 'From local soil to your table';

  @override
  String get landingHeroTitle => 'Making local food consumption easy.';

  @override
  String get landingHeroSubtitle =>
      'FRSH Nearby connects you directly to local food producers near you — cutting out middle parties, reducing costs and increasing freshness.';

  @override
  String get landingHeroPrimaryCta => 'Get early access';

  @override
  String get landingHeroSecondaryCta => 'Open the prototype';

  @override
  String get landingMapBadge => 'Launching first in Vaasa, Finland';

  @override
  String get landingMapCaption => 'Built for local food across Europe';

  @override
  String get landingAboutTitle => 'About us';

  @override
  String get landingAboutBody =>
      'FRSH Nearby started with a simple idea: the best food is grown next door. We are building a platform that makes it effortless for consumers to access locally produced food — making it easier for food producers to sell directly to the consumer, cutting out middle parties. The platform is built by three newly graduated university students, together with local food producers. Fresh, easy and fair.';

  @override
  String get landingValue1Title => 'Local';

  @override
  String get landingValue1Body =>
      'Find fresh food produced near you, always in season.';

  @override
  String get landingValue2Title => 'Fair for food producers';

  @override
  String get landingValue2Body =>
      'Producers sell directly to end customers in the most convenient way agreed upon, increasing profits for producers and reducing costs for consumers.';

  @override
  String get landingValue3Title => 'Stronger communities';

  @override
  String get landingValue3Body =>
      'Every order keeps value in your region and strengthens local food networks.';

  @override
  String get landingProducersTitle => 'For producers';

  @override
  String get landingProducer1Title => 'Promote and sell on social media!';

  @override
  String get landingProducer1Body =>
      'Copy and paste the link to your personal order page into your social media posts and profiles to direct customers straight to your product catalog.';

  @override
  String get landingProducer2Title =>
      'Manage all social media orders in one place!';

  @override
  String get landingProducer2Body =>
      'With your order page, you can view and approve incoming orders. Once an order is approved, the customer receives a payment request. The order page also provides summaries of all approved orders by product and by customer, making order management and delivery planning simple.';

  @override
  String get landingProducer3Title => 'Be visible to everyone!';

  @override
  String get landingProducer3Body =>
      'Our interactive map brings all producers together in one place, making it easy for consumers to discover local food producers nearby.';

  @override
  String get landingProducer4Title => 'Reports and bookkeeping';

  @override
  String get landingProducer4Body =>
      'Download sales reports and receipts with ease and send them directly to your accountant.';

  @override
  String get landingConsumersTitle => 'For consumers';

  @override
  String get landingConsumer1Title => 'Order local food effortlessly';

  @override
  String get landingConsumer1Body =>
      'Find nearby food producers on the app\'s map, or browse the product catalog for exactly what you\'re looking for.';

  @override
  String get landingConsumer2Title => 'Fresh, healthy, and traceable';

  @override
  String get landingConsumer2Body =>
      'By choosing a local producer, you know exactly what you\'re buying, where it comes from, and how the crops and animals have been cared for.';

  @override
  String get landingConsumer3Title =>
      'Support sustainable local food production';

  @override
  String get landingConsumer3Body =>
      'Buying directly from local producers supports your local economy and reduces the need for food to travel around the world.';

  @override
  String get landingInterestedTitle => 'Interested?';

  @override
  String get landingInterestedSubtitle =>
      'Join the waiting list and get notified when FRSH Nearby launches.';

  @override
  String get landingFormRoleLabel => 'Role';

  @override
  String get landingFormMessageLabel => 'Optional message';

  @override
  String get landingRoleConsumer => 'Consumer';

  @override
  String get landingRoleFarmer => 'Food producer';

  @override
  String get landingRoleRestaurant => 'Restaurant / Shop';

  @override
  String get landingRoleSupporter => 'Local food supporter';

  @override
  String get landingFormSubmit => 'Join the waiting list';

  @override
  String get landingFormConsentLabel =>
      'I agree that FRSH nearby may collect, store, and process the personal data submitted through this form for the purpose of managing the waiting list, contacting me about the launch of FRSH nearby, and providing related updates, in accordance with the Privacy Policy.';

  @override
  String get landingFormThanks =>
      'Thank you. You\'re on the early access list.';

  @override
  String get landingFooterTagline => 'Find food produced near you.';

  @override
  String get landingFooterCopyright => '© 2026 FRSH nearby';

  @override
  String get prototypeChooserTitle => 'Open the FRSH Nearby prototype';

  @override
  String get prototypeChooserSubtitle =>
      'Pick the side you want to test first.';

  @override
  String get prototypeFarmerHint => 'Dashboard, orders, listings, insights';

  @override
  String get prototypeConsumerHint => 'Nearby food, farm profiles, deals, chat';

  @override
  String get landingFormPhoneLabel => 'Phone (optional)';
}
