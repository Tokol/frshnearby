import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fi.dart';
import 'app_localizations_sv.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fi'),
    Locale('sv'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Fresh Farm'**
  String get appName;

  /// No description provided for @splashLoading.
  ///
  /// In en, this message translates to:
  /// **'Preparing fresh produce...'**
  String get splashLoading;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to shop fresh local food.'**
  String get loginSubtitle;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameLabel;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginButton;

  /// No description provided for @registerButton.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get registerButton;

  /// No description provided for @createAccountPrompt.
  ///
  /// In en, this message translates to:
  /// **'New to Fresh Farm?'**
  String get createAccountPrompt;

  /// No description provided for @alreadyHaveAccountPrompt.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccountPrompt;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get registerTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start buying from nearby farms and producers.'**
  String get registerSubtitle;

  /// No description provided for @customerHomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Marketplace'**
  String get customerHomeTitle;

  /// No description provided for @customerHomeGreeting.
  ///
  /// In en, this message translates to:
  /// **'Fresh picks near you'**
  String get customerHomeGreeting;

  /// No description provided for @customerHomeEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No products yet'**
  String get customerHomeEmptyTitle;

  /// No description provided for @customerHomeEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Local produce will appear here once the marketplace is connected.'**
  String get customerHomeEmptyMessage;

  /// No description provided for @nearbyListingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Nearby fresh listings'**
  String get nearbyListingsTitle;

  /// No description provided for @homeLocationLine.
  ///
  /// In en, this message translates to:
  /// **'Vaasa, Ostrobothnia'**
  String get homeLocationLine;

  /// No description provided for @currentLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'Your current location'**
  String get currentLocationLabel;

  /// No description provided for @confirmLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm your location'**
  String get confirmLocationTitle;

  /// No description provided for @confirmLocationMessage.
  ///
  /// In en, this message translates to:
  /// **'Based on your phone location, it looks like you\'re near {location}.'**
  String confirmLocationMessage(Object location);

  /// No description provided for @useThisLocationButton.
  ///
  /// In en, this message translates to:
  /// **'Use this location'**
  String get useThisLocationButton;

  /// No description provided for @enterAnotherLocationButton.
  ///
  /// In en, this message translates to:
  /// **'Enter another location'**
  String get enterAnotherLocationButton;

  /// No description provided for @locationSearchTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose location'**
  String get locationSearchTitle;

  /// No description provided for @locationSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search city or region'**
  String get locationSearchHint;

  /// No description provided for @noLocationResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'No locations found'**
  String get noLocationResultsTitle;

  /// No description provided for @homeSearchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search potatoes, honey, tomatoes...'**
  String get homeSearchPlaceholder;

  /// No description provided for @homeHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'Fresh from local farms'**
  String get homeHeroTitle;

  /// No description provided for @homeHeroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Seasonal produce, eggs, and honey ready near you.'**
  String get homeHeroSubtitle;

  /// No description provided for @browseTodayPicks.
  ///
  /// In en, this message translates to:
  /// **'Browse today’s picks'**
  String get browseTodayPicks;

  /// No description provided for @seeAllButton.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAllButton;

  /// No description provided for @homeJustHarvestedTitle.
  ///
  /// In en, this message translates to:
  /// **'Just harvested'**
  String get homeJustHarvestedTitle;

  /// No description provided for @homeDealsTodayTitle.
  ///
  /// In en, this message translates to:
  /// **'Good deals today'**
  String get homeDealsTodayTitle;

  /// No description provided for @categoryVegetables.
  ///
  /// In en, this message translates to:
  /// **'Vegetables'**
  String get categoryVegetables;

  /// No description provided for @categoryFruits.
  ///
  /// In en, this message translates to:
  /// **'Fruits'**
  String get categoryFruits;

  /// No description provided for @categoryMeat.
  ///
  /// In en, this message translates to:
  /// **'Meat'**
  String get categoryMeat;

  /// No description provided for @categoryFish.
  ///
  /// In en, this message translates to:
  /// **'Fish'**
  String get categoryFish;

  /// No description provided for @categoryBakery.
  ///
  /// In en, this message translates to:
  /// **'Bakery'**
  String get categoryBakery;

  /// No description provided for @categoryDairy.
  ///
  /// In en, this message translates to:
  /// **'Dairy'**
  String get categoryDairy;

  /// No description provided for @categoryEggs.
  ///
  /// In en, this message translates to:
  /// **'Eggs'**
  String get categoryEggs;

  /// No description provided for @categoryHoney.
  ///
  /// In en, this message translates to:
  /// **'Honey'**
  String get categoryHoney;

  /// No description provided for @categoryCheese.
  ///
  /// In en, this message translates to:
  /// **'Cheese'**
  String get categoryCheese;

  /// No description provided for @categoryMilk.
  ///
  /// In en, this message translates to:
  /// **'Milk'**
  String get categoryMilk;

  /// No description provided for @categoryHerbs.
  ///
  /// In en, this message translates to:
  /// **'Herbs'**
  String get categoryHerbs;

  /// No description provided for @categoryMushrooms.
  ///
  /// In en, this message translates to:
  /// **'Mushrooms'**
  String get categoryMushrooms;

  /// No description provided for @categoryBerries.
  ///
  /// In en, this message translates to:
  /// **'Berries'**
  String get categoryBerries;

  /// No description provided for @categoryFlowers.
  ///
  /// In en, this message translates to:
  /// **'Flowers'**
  String get categoryFlowers;

  /// No description provided for @categoryJuice.
  ///
  /// In en, this message translates to:
  /// **'Juice'**
  String get categoryJuice;

  /// No description provided for @categoryPreserves.
  ///
  /// In en, this message translates to:
  /// **'Preserves'**
  String get categoryPreserves;

  /// No description provided for @categoryGrains.
  ///
  /// In en, this message translates to:
  /// **'Grains'**
  String get categoryGrains;

  /// No description provided for @categoryReadyMeals.
  ///
  /// In en, this message translates to:
  /// **'Ready meals'**
  String get categoryReadyMeals;

  /// No description provided for @categoryOrganic.
  ///
  /// In en, this message translates to:
  /// **'Organic'**
  String get categoryOrganic;

  /// No description provided for @notificationsLabel.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsLabel;

  /// No description provided for @cartLabel.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get cartLabel;

  /// No description provided for @customerHomeTab.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get customerHomeTab;

  /// No description provided for @customerSearchTab.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get customerSearchTab;

  /// No description provided for @messagesTab.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messagesTab;

  /// No description provided for @dealsTab.
  ///
  /// In en, this message translates to:
  /// **'Deals'**
  String get dealsTab;

  /// No description provided for @profileTab.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTab;

  /// No description provided for @farmerDashboardTab.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get farmerDashboardTab;

  /// No description provided for @farmerListingsTab.
  ///
  /// In en, this message translates to:
  /// **'Listings'**
  String get farmerListingsTab;

  /// No description provided for @farmerReviewsTab.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get farmerReviewsTab;

  /// No description provided for @customerSearchTitle.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get customerSearchTitle;

  /// No description provided for @customerSearchEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Product search will appear here.'**
  String get customerSearchEmptyMessage;

  /// No description provided for @searchListingsHint.
  ///
  /// In en, this message translates to:
  /// **'Search products, categories, or variants'**
  String get searchListingsHint;

  /// No description provided for @noListingsFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'No listings found'**
  String get noListingsFoundTitle;

  /// No description provided for @noListingsFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'Try another product, category, or variant.'**
  String get noListingsFoundMessage;

  /// No description provided for @listingDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Listing details'**
  String get listingDetailTitle;

  /// No description provided for @farmerPublicProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Farmer profile'**
  String get farmerPublicProfileTitle;

  /// No description provided for @kilometersAwayLabel.
  ///
  /// In en, this message translates to:
  /// **'km away'**
  String get kilometersAwayLabel;

  /// No description provided for @distanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get distanceLabel;

  /// No description provided for @ratingLabel.
  ///
  /// In en, this message translates to:
  /// **'rating'**
  String get ratingLabel;

  /// No description provided for @farmerRatingLabel.
  ///
  /// In en, this message translates to:
  /// **'Farmer rating'**
  String get farmerRatingLabel;

  /// No description provided for @farmRatingLabel.
  ///
  /// In en, this message translates to:
  /// **'Farm rating'**
  String get farmRatingLabel;

  /// No description provided for @farmReviewsLabel.
  ///
  /// In en, this message translates to:
  /// **'farm reviews'**
  String get farmReviewsLabel;

  /// No description provided for @newFarmLabel.
  ///
  /// In en, this message translates to:
  /// **'New farm'**
  String get newFarmLabel;

  /// No description provided for @viewFarmProfileButton.
  ///
  /// In en, this message translates to:
  /// **'View farm profile'**
  String get viewFarmProfileButton;

  /// No description provided for @verifiedBadgeLabel.
  ///
  /// In en, this message translates to:
  /// **'Verified farmer'**
  String get verifiedBadgeLabel;

  /// No description provided for @approximateLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'Approximate location'**
  String get approximateLocationLabel;

  /// No description provided for @chatButton.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chatButton;

  /// No description provided for @exactLocationAfterDealMessage.
  ///
  /// In en, this message translates to:
  /// **'Exact pickup location is shared only after a deal is confirmed.'**
  String get exactLocationAfterDealMessage;

  /// No description provided for @farmerNotFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'This farmer profile is not available.'**
  String get farmerNotFoundMessage;

  /// No description provided for @messagesTitle.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messagesTitle;

  /// No description provided for @messagesEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Conversations will appear here.'**
  String get messagesEmptyMessage;

  /// No description provided for @dealsTitle.
  ///
  /// In en, this message translates to:
  /// **'Deals'**
  String get dealsTitle;

  /// No description provided for @dealsEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Fresh offers will appear here.'**
  String get dealsEmptyMessage;

  /// No description provided for @dealsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No deals yet'**
  String get dealsEmptyTitle;

  /// No description provided for @dealStatusNegotiating.
  ///
  /// In en, this message translates to:
  /// **'Negotiating'**
  String get dealStatusNegotiating;

  /// No description provided for @dealStatusConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get dealStatusConfirmed;

  /// No description provided for @dealStatusReadyForPickup.
  ///
  /// In en, this message translates to:
  /// **'Ready for pickup'**
  String get dealStatusReadyForPickup;

  /// No description provided for @dealStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get dealStatusCompleted;

  /// No description provided for @dealStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get dealStatusCancelled;

  /// No description provided for @confirmDealButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm deal'**
  String get confirmDealButton;

  /// No description provided for @markCompletedButton.
  ///
  /// In en, this message translates to:
  /// **'Mark completed'**
  String get markCompletedButton;

  /// No description provided for @buyAgainButton.
  ///
  /// In en, this message translates to:
  /// **'Buy again'**
  String get buyAgainButton;

  /// No description provided for @rateDealButton.
  ///
  /// In en, this message translates to:
  /// **'Rate this deal'**
  String get rateDealButton;

  /// No description provided for @ratingSoftPromptMessage.
  ///
  /// In en, this message translates to:
  /// **'How was your experience? A quick rating helps other customers.'**
  String get ratingSoftPromptMessage;

  /// No description provided for @chatTitle.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chatTitle;

  /// No description provided for @messageLabel.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get messageLabel;

  /// No description provided for @sendButton.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get sendButton;

  /// No description provided for @rateDealTitle.
  ///
  /// In en, this message translates to:
  /// **'Rate your deal'**
  String get rateDealTitle;

  /// No description provided for @ratingTagFresh.
  ///
  /// In en, this message translates to:
  /// **'Fresh'**
  String get ratingTagFresh;

  /// No description provided for @ratingTagFriendly.
  ///
  /// In en, this message translates to:
  /// **'Friendly'**
  String get ratingTagFriendly;

  /// No description provided for @ratingTagOnTime.
  ///
  /// In en, this message translates to:
  /// **'On time'**
  String get ratingTagOnTime;

  /// No description provided for @ratingTextLabel.
  ///
  /// In en, this message translates to:
  /// **'Optional feedback'**
  String get ratingTextLabel;

  /// No description provided for @submitRatingButton.
  ///
  /// In en, this message translates to:
  /// **'Submit rating'**
  String get submitRatingButton;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileGuestName.
  ///
  /// In en, this message translates to:
  /// **'Guest customer'**
  String get profileGuestName;

  /// No description provided for @profileGuestEmail.
  ///
  /// In en, this message translates to:
  /// **'No email available'**
  String get profileGuestEmail;

  /// No description provided for @switchToFarmerButton.
  ///
  /// In en, this message translates to:
  /// **'Switch to Farmer'**
  String get switchToFarmerButton;

  /// No description provided for @switchToCustomerButton.
  ///
  /// In en, this message translates to:
  /// **'Switch to Customer'**
  String get switchToCustomerButton;

  /// No description provided for @applyAsFarmerButton.
  ///
  /// In en, this message translates to:
  /// **'Apply as Farmer'**
  String get applyAsFarmerButton;

  /// No description provided for @applyAsFarmerTitle.
  ///
  /// In en, this message translates to:
  /// **'Apply as Farmer'**
  String get applyAsFarmerTitle;

  /// No description provided for @applyAsFarmerIntro.
  ///
  /// In en, this message translates to:
  /// **'Tell us about your farm profile before submitting it for review.'**
  String get applyAsFarmerIntro;

  /// No description provided for @profileTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Profile type'**
  String get profileTypeLabel;

  /// No description provided for @profileTypeIndividual.
  ///
  /// In en, this message translates to:
  /// **'Individual'**
  String get profileTypeIndividual;

  /// No description provided for @profileTypeFarm.
  ///
  /// In en, this message translates to:
  /// **'Farm'**
  String get profileTypeFarm;

  /// No description provided for @profileTypeCooperative.
  ///
  /// In en, this message translates to:
  /// **'Cooperative'**
  String get profileTypeCooperative;

  /// No description provided for @displayNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Display name'**
  String get displayNameLabel;

  /// No description provided for @farmNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Farm name'**
  String get farmNameLabel;

  /// No description provided for @phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phoneLabel;

  /// No description provided for @shortDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Short description'**
  String get shortDescriptionLabel;

  /// No description provided for @profilePhotoPlaceholderLabel.
  ///
  /// In en, this message translates to:
  /// **'Profile photo placeholder'**
  String get profilePhotoPlaceholderLabel;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @farmerLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Farm location'**
  String get farmerLocationTitle;

  /// No description provided for @locationPermissionMessage.
  ///
  /// In en, this message translates to:
  /// **'Allow location access to fill your farm coordinates, or enter them manually.'**
  String get locationPermissionMessage;

  /// No description provided for @useCurrentLocationButton.
  ///
  /// In en, this message translates to:
  /// **'Use current location'**
  String get useCurrentLocationButton;

  /// No description provided for @locationPermissionDeniedMessage.
  ///
  /// In en, this message translates to:
  /// **'Location permission was denied. You can enter the location manually.'**
  String get locationPermissionDeniedMessage;

  /// No description provided for @mapPlaceholderTitle.
  ///
  /// In en, this message translates to:
  /// **'Map preview'**
  String get mapPlaceholderTitle;

  /// No description provided for @mapPlaceholderMessage.
  ///
  /// In en, this message translates to:
  /// **'A real map will appear here later. For now, confirm the coordinates below.'**
  String get mapPlaceholderMessage;

  /// No description provided for @latitudeLabel.
  ///
  /// In en, this message translates to:
  /// **'Latitude'**
  String get latitudeLabel;

  /// No description provided for @longitudeLabel.
  ///
  /// In en, this message translates to:
  /// **'Longitude'**
  String get longitudeLabel;

  /// No description provided for @cityLabel.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get cityLabel;

  /// No description provided for @countryLabel.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get countryLabel;

  /// No description provided for @confirmLocationButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm location'**
  String get confirmLocationButton;

  /// No description provided for @farmerApplicationReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Review application'**
  String get farmerApplicationReviewTitle;

  /// No description provided for @farmerApplicationReviewIntro.
  ///
  /// In en, this message translates to:
  /// **'Review your details before submitting. Admin review is required before farmer mode is available.'**
  String get farmerApplicationReviewIntro;

  /// No description provided for @submitApplicationButton.
  ///
  /// In en, this message translates to:
  /// **'Submit application'**
  String get submitApplicationButton;

  /// No description provided for @editLocationButton.
  ///
  /// In en, this message translates to:
  /// **'Edit location'**
  String get editLocationButton;

  /// No description provided for @backToCustomerModeButton.
  ///
  /// In en, this message translates to:
  /// **'Back to Customer mode'**
  String get backToCustomerModeButton;

  /// No description provided for @farmerPendingTitle.
  ///
  /// In en, this message translates to:
  /// **'Farmer application pending'**
  String get farmerPendingTitle;

  /// No description provided for @farmerPendingMessage.
  ///
  /// In en, this message translates to:
  /// **'Your farmer application is under review.'**
  String get farmerPendingMessage;

  /// No description provided for @farmerRejectedTitle.
  ///
  /// In en, this message translates to:
  /// **'Farmer application rejected'**
  String get farmerRejectedTitle;

  /// No description provided for @farmerRejectedMessage.
  ///
  /// In en, this message translates to:
  /// **'Farmer mode is not available for this account.'**
  String get farmerRejectedMessage;

  /// No description provided for @farmerSuspendedTitle.
  ///
  /// In en, this message translates to:
  /// **'Farmer access suspended'**
  String get farmerSuspendedTitle;

  /// No description provided for @farmerSuspendedMessage.
  ///
  /// In en, this message translates to:
  /// **'Farmer mode is not available for this account.'**
  String get farmerSuspendedMessage;

  /// No description provided for @farmerDashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Farmer dashboard'**
  String get farmerDashboardTitle;

  /// No description provided for @farmerDashboardEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Sales, orders, and farm activity will appear here.'**
  String get farmerDashboardEmptyMessage;

  /// No description provided for @farmerListingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Listings'**
  String get farmerListingsTitle;

  /// No description provided for @farmerListingsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No listings yet'**
  String get farmerListingsEmptyTitle;

  /// No description provided for @farmerListingsEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Your farm listings will appear here.'**
  String get farmerListingsEmptyMessage;

  /// No description provided for @createListingTitle.
  ///
  /// In en, this message translates to:
  /// **'Create listing'**
  String get createListingTitle;

  /// No description provided for @editListingTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit listing'**
  String get editListingTitle;

  /// No description provided for @listingPreviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Listing preview'**
  String get listingPreviewTitle;

  /// No description provided for @whatAreYouSelling.
  ///
  /// In en, this message translates to:
  /// **'What are you selling?'**
  String get whatAreYouSelling;

  /// No description provided for @quantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantityLabel;

  /// No description provided for @unitLabel.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get unitLabel;

  /// No description provided for @priceLabel.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get priceLabel;

  /// No description provided for @listingDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get listingDescriptionLabel;

  /// No description provided for @harvestDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Harvest date'**
  String get harvestDateLabel;

  /// No description provided for @farmingMethodLabel.
  ///
  /// In en, this message translates to:
  /// **'Farming method'**
  String get farmingMethodLabel;

  /// No description provided for @pickupNotesLabel.
  ///
  /// In en, this message translates to:
  /// **'Pickup notes'**
  String get pickupNotesLabel;

  /// No description provided for @deliveryEnabledLabel.
  ///
  /// In en, this message translates to:
  /// **'Delivery enabled'**
  String get deliveryEnabledLabel;

  /// No description provided for @listingPhotoPlaceholderLabel.
  ///
  /// In en, this message translates to:
  /// **'Photo placeholder'**
  String get listingPhotoPlaceholderLabel;

  /// No description provided for @previewListingButton.
  ///
  /// In en, this message translates to:
  /// **'Preview listing'**
  String get previewListingButton;

  /// No description provided for @editListingButton.
  ///
  /// In en, this message translates to:
  /// **'Edit listing'**
  String get editListingButton;

  /// No description provided for @saveChangesButton.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChangesButton;

  /// No description provided for @archiveListingButton.
  ///
  /// In en, this message translates to:
  /// **'Delete/archive listing'**
  String get archiveListingButton;

  /// No description provided for @listingNotFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'This listing could not be found.'**
  String get listingNotFoundMessage;

  /// No description provided for @yesLabel.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yesLabel;

  /// No description provided for @noLabel.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get noLabel;

  /// No description provided for @farmerReviewsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get farmerReviewsTitle;

  /// No description provided for @farmerReviewsEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Customer reviews will appear here.'**
  String get farmerReviewsEmptyMessage;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @languageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageLabel;

  /// No description provided for @englishLanguage.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get englishLanguage;

  /// No description provided for @finnishLanguage.
  ///
  /// In en, this message translates to:
  /// **'Finnish'**
  String get finnishLanguage;

  /// No description provided for @swedishLanguage.
  ///
  /// In en, this message translates to:
  /// **'Swedish'**
  String get swedishLanguage;

  /// No description provided for @signOutButton.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOutButton;

  /// No description provided for @genericErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get genericErrorTitle;

  /// No description provided for @genericErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Please try again in a moment.'**
  String get genericErrorMessage;

  /// No description provided for @retryButton.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryButton;

  /// No description provided for @loadingMessage.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loadingMessage;

  /// No description provided for @validationRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required.'**
  String get validationRequired;

  /// No description provided for @validationEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get validationEmail;

  /// No description provided for @validationPositiveNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a number greater than zero.'**
  String get validationPositiveNumber;

  /// No description provided for @validationNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number.'**
  String get validationNumber;

  /// No description provided for @confirmButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirmButton;

  /// No description provided for @cancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// No description provided for @confirmArchiveListingTitle.
  ///
  /// In en, this message translates to:
  /// **'Archive listing?'**
  String get confirmArchiveListingTitle;

  /// No description provided for @confirmArchiveListingMessage.
  ///
  /// In en, this message translates to:
  /// **'This listing will be removed from your active listings.'**
  String get confirmArchiveListingMessage;

  /// No description provided for @confirmDealTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm deal?'**
  String get confirmDealTitle;

  /// No description provided for @confirmDealMessage.
  ///
  /// In en, this message translates to:
  /// **'This marks the negotiation as confirmed.'**
  String get confirmDealMessage;

  /// No description provided for @confirmCompletedTitle.
  ///
  /// In en, this message translates to:
  /// **'Mark deal completed?'**
  String get confirmCompletedTitle;

  /// No description provided for @confirmCompletedMessage.
  ///
  /// In en, this message translates to:
  /// **'Completed deals move to bought history and can be rated.'**
  String get confirmCompletedMessage;

  /// No description provided for @unauthorizedTitle.
  ///
  /// In en, this message translates to:
  /// **'Not available'**
  String get unauthorizedTitle;

  /// No description provided for @verifiedFarmerRequiredMessage.
  ///
  /// In en, this message translates to:
  /// **'Only verified farmers can open this screen.'**
  String get verifiedFarmerRequiredMessage;

  /// No description provided for @productSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get productSectionTitle;

  /// No description provided for @productSectionDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose what customers will see on your farm page.'**
  String get productSectionDescription;

  /// No description provided for @stockAndPriceTitle.
  ///
  /// In en, this message translates to:
  /// **'Stock and price'**
  String get stockAndPriceTitle;

  /// No description provided for @stockAndPriceDescription.
  ///
  /// In en, this message translates to:
  /// **'Tell us how much is available and how you sell it.'**
  String get stockAndPriceDescription;

  /// No description provided for @availableNowLabel.
  ///
  /// In en, this message translates to:
  /// **'Available now'**
  String get availableNowLabel;

  /// No description provided for @productDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Product details'**
  String get productDetailsTitle;

  /// No description provided for @productDetailsDescription.
  ///
  /// In en, this message translates to:
  /// **'Optional information that can help customers decide.'**
  String get productDetailsDescription;

  /// No description provided for @producedDateOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'Produced date (optional)'**
  String get producedDateOptionalLabel;

  /// No description provided for @productionDetailsLabel.
  ///
  /// In en, this message translates to:
  /// **'Production details (optional)'**
  String get productionDetailsLabel;

  /// No description provided for @bestBeforeOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'Best before (optional)'**
  String get bestBeforeOptionalLabel;

  /// No description provided for @storageInstructionsOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'Storage instructions (optional)'**
  String get storageInstructionsOptionalLabel;

  /// No description provided for @addProductButton.
  ///
  /// In en, this message translates to:
  /// **'Add product'**
  String get addProductButton;

  /// No description provided for @productAddedMessage.
  ///
  /// In en, this message translates to:
  /// **'Product added.'**
  String get productAddedMessage;

  /// No description provided for @productUpdatedMessage.
  ///
  /// In en, this message translates to:
  /// **'Product updated.'**
  String get productUpdatedMessage;

  /// No description provided for @updateChangedFieldsHint.
  ///
  /// In en, this message translates to:
  /// **'Update only what has changed.'**
  String get updateChangedFieldsHint;

  /// No description provided for @addProductPhotoLabel.
  ///
  /// In en, this message translates to:
  /// **'Add product photo'**
  String get addProductPhotoLabel;

  /// No description provided for @sellingUnitLabel.
  ///
  /// In en, this message translates to:
  /// **'How do you sell it?'**
  String get sellingUnitLabel;

  /// No description provided for @kilogramUnit.
  ///
  /// In en, this message translates to:
  /// **'Kilogram (kg)'**
  String get kilogramUnit;

  /// No description provided for @pieceUnit.
  ///
  /// In en, this message translates to:
  /// **'Piece'**
  String get pieceUnit;

  /// No description provided for @bunchUnit.
  ///
  /// In en, this message translates to:
  /// **'Bunch'**
  String get bunchUnit;

  /// No description provided for @bagUnit.
  ///
  /// In en, this message translates to:
  /// **'Bag'**
  String get bagUnit;

  /// No description provided for @boxUnit.
  ///
  /// In en, this message translates to:
  /// **'Box'**
  String get boxUnit;

  /// No description provided for @jarUnit.
  ///
  /// In en, this message translates to:
  /// **'Jar'**
  String get jarUnit;

  /// No description provided for @customerPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Customer price'**
  String get customerPriceLabel;

  /// No description provided for @pricePerUnitHelp.
  ///
  /// In en, this message translates to:
  /// **'The customer sees this as the price per {unit}.'**
  String pricePerUnitHelp(Object unit);

  /// No description provided for @perUnitLabel.
  ///
  /// In en, this message translates to:
  /// **'per {unit}'**
  String perUnitLabel(Object unit);

  /// No description provided for @selectDateHint.
  ///
  /// In en, this message translates to:
  /// **'Select a date'**
  String get selectDateHint;

  /// No description provided for @clearDateTooltip.
  ///
  /// In en, this message translates to:
  /// **'Clear date'**
  String get clearDateTooltip;

  /// No description provided for @ordersTitle.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get ordersTitle;

  /// No description provided for @myOrdersLabel.
  ///
  /// In en, this message translates to:
  /// **'My orders'**
  String get myOrdersLabel;

  /// No description provided for @totalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get totalLabel;

  /// No description provided for @productsLabel.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get productsLabel;

  /// No description provided for @billTitle.
  ///
  /// In en, this message translates to:
  /// **'Bill'**
  String get billTitle;

  /// No description provided for @farmPickupLabel.
  ///
  /// In en, this message translates to:
  /// **'Farm pickup'**
  String get farmPickupLabel;

  /// No description provided for @courierLabel.
  ///
  /// In en, this message translates to:
  /// **'Courier'**
  String get courierLabel;

  /// No description provided for @freeLabel.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get freeLabel;

  /// No description provided for @payAndRequestLabel.
  ///
  /// In en, this message translates to:
  /// **'Pay & Request'**
  String get payAndRequestLabel;

  /// No description provided for @cartEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your cart is empty'**
  String get cartEmptyTitle;

  /// No description provided for @cartEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Add products from a farm page.'**
  String get cartEmptyMessage;

  /// No description provided for @ordersEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No orders yet'**
  String get ordersEmptyTitle;

  /// No description provided for @ordersEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Your requests and delivery progress will appear here.'**
  String get ordersEmptyMessage;

  /// No description provided for @followLabel.
  ///
  /// In en, this message translates to:
  /// **'Follow'**
  String get followLabel;

  /// No description provided for @followingLabel.
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get followingLabel;

  /// No description provided for @addToCartLabel.
  ///
  /// In en, this message translates to:
  /// **'Add to cart'**
  String get addToCartLabel;

  /// No description provided for @availableCountLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} available'**
  String availableCountLabel(Object count);

  /// No description provided for @dashboardGreeting.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get dashboardGreeting;

  /// No description provided for @dashboardIntro.
  ///
  /// In en, this message translates to:
  /// **'Manage your products, fulfil orders, and share your farm page.'**
  String get dashboardIntro;

  /// No description provided for @activeOrdersLabel.
  ///
  /// In en, this message translates to:
  /// **'Active orders'**
  String get activeOrdersLabel;

  /// No description provided for @salesThisMonthLabel.
  ///
  /// In en, this message translates to:
  /// **'Sales this month'**
  String get salesThisMonthLabel;

  /// No description provided for @allTimeSalesLabel.
  ///
  /// In en, this message translates to:
  /// **'All time €{amount}'**
  String allTimeSalesLabel(Object amount);

  /// No description provided for @noProductsMessage.
  ///
  /// In en, this message translates to:
  /// **'No product listings yet.'**
  String get noProductsMessage;

  /// No description provided for @yourFarmPageLabel.
  ///
  /// In en, this message translates to:
  /// **'Your farm page'**
  String get yourFarmPageLabel;

  /// No description provided for @previewLabel.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get previewLabel;

  /// No description provided for @copyLinkTooltip.
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get copyLinkTooltip;

  /// No description provided for @shareLinkTooltip.
  ///
  /// In en, this message translates to:
  /// **'Share link'**
  String get shareLinkTooltip;

  /// No description provided for @farmLinkCopiedMessage.
  ///
  /// In en, this message translates to:
  /// **'Farm link copied'**
  String get farmLinkCopiedMessage;

  /// No description provided for @manageLabel.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get manageLabel;

  /// No description provided for @nearbyMapTooltip.
  ///
  /// In en, this message translates to:
  /// **'Nearby map'**
  String get nearbyMapTooltip;

  /// No description provided for @homeTabLabel.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTabLabel;

  /// No description provided for @insightsTabLabel.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get insightsTabLabel;

  /// No description provided for @prototypeViewLabel.
  ///
  /// In en, this message translates to:
  /// **'Prototype view'**
  String get prototypeViewLabel;

  /// No description provided for @farmerModeLabel.
  ///
  /// In en, this message translates to:
  /// **'Farmer'**
  String get farmerModeLabel;

  /// No description provided for @consumerModeLabel.
  ///
  /// In en, this message translates to:
  /// **'Consumer'**
  String get consumerModeLabel;

  /// No description provided for @orderBookTitle.
  ///
  /// In en, this message translates to:
  /// **'Order book'**
  String get orderBookTitle;

  /// No description provided for @orderBookSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Requests, fulfilment and history'**
  String get orderBookSubtitle;

  /// No description provided for @ordersLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load orders.'**
  String get ordersLoadError;

  /// No description provided for @activeLabel.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get activeLabel;

  /// No description provided for @requestsLabel.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get requestsLabel;

  /// No description provided for @historyLabel.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyLabel;

  /// No description provided for @orderNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Order #{number}'**
  String orderNumberLabel(Object number);

  /// No description provided for @productCountLabel.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 product} other{{count} products}}'**
  String productCountLabel(num count);

  /// No description provided for @courierCollectionLabel.
  ///
  /// In en, this message translates to:
  /// **'Courier collection'**
  String get courierCollectionLabel;

  /// No description provided for @viewOrderLabel.
  ///
  /// In en, this message translates to:
  /// **'View order'**
  String get viewOrderLabel;

  /// No description provided for @newRequestStatus.
  ///
  /// In en, this message translates to:
  /// **'New request'**
  String get newRequestStatus;

  /// No description provided for @requestedStatus.
  ///
  /// In en, this message translates to:
  /// **'Requested'**
  String get requestedStatus;

  /// No description provided for @acceptedStatus.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get acceptedStatus;

  /// No description provided for @preparingStatus.
  ///
  /// In en, this message translates to:
  /// **'Preparing'**
  String get preparingStatus;

  /// No description provided for @readyStatus.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get readyStatus;

  /// No description provided for @deliveredStatus.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get deliveredStatus;

  /// No description provided for @declinedStatus.
  ///
  /// In en, this message translates to:
  /// **'Declined'**
  String get declinedStatus;

  /// No description provided for @noOrdersSectionMessage.
  ///
  /// In en, this message translates to:
  /// **'No orders in this section.'**
  String get noOrdersSectionMessage;

  /// No description provided for @completedOrdersLabel.
  ///
  /// In en, this message translates to:
  /// **'Completed orders'**
  String get completedOrdersLabel;

  /// No description provided for @averageOrderLabel.
  ///
  /// In en, this message translates to:
  /// **'Average order'**
  String get averageOrderLabel;

  /// No description provided for @quantitySoldLabel.
  ///
  /// In en, this message translates to:
  /// **'Quantity sold'**
  String get quantitySoldLabel;

  /// No description provided for @salesTrendTitle.
  ///
  /// In en, this message translates to:
  /// **'Sales trend'**
  String get salesTrendTitle;

  /// No description provided for @topProductsTitle.
  ///
  /// In en, this message translates to:
  /// **'Top products'**
  String get topProductsTitle;

  /// No description provided for @fulfilmentTitle.
  ///
  /// In en, this message translates to:
  /// **'Fulfilment'**
  String get fulfilmentTitle;

  /// No description provided for @viewSalesStatementLabel.
  ///
  /// In en, this message translates to:
  /// **'View sales statement'**
  String get viewSalesStatementLabel;

  /// No description provided for @salesStatementLabel.
  ///
  /// In en, this message translates to:
  /// **'Sales statement'**
  String get salesStatementLabel;

  /// No description provided for @previousMonthTooltip.
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get previousMonthTooltip;

  /// No description provided for @nextMonthTooltip.
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get nextMonthTooltip;

  /// No description provided for @customRangeHint.
  ///
  /// In en, this message translates to:
  /// **'Tap for custom range'**
  String get customRangeHint;

  /// No description provided for @salesPeriodLabel.
  ///
  /// In en, this message translates to:
  /// **'Sales period'**
  String get salesPeriodLabel;

  /// No description provided for @showReportLabel.
  ///
  /// In en, this message translates to:
  /// **'Show report'**
  String get showReportLabel;

  /// No description provided for @totalSalesLabel.
  ///
  /// In en, this message translates to:
  /// **'TOTAL SALES'**
  String get totalSalesLabel;

  /// No description provided for @completedOrderCountLabel.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 completed order} other{{count} completed orders}}'**
  String completedOrderCountLabel(num count);

  /// No description provided for @noCompletedSalesMessage.
  ///
  /// In en, this message translates to:
  /// **'No completed sales in this period'**
  String get noCompletedSalesMessage;

  /// No description provided for @noProductSalesMessage.
  ///
  /// In en, this message translates to:
  /// **'No product sales in this period.'**
  String get noProductSalesMessage;

  /// No description provided for @soldQuantityLabel.
  ///
  /// In en, this message translates to:
  /// **'{quantity} {unit} sold'**
  String soldQuantityLabel(Object quantity, Object unit);

  /// No description provided for @noCompletedOrdersMessage.
  ///
  /// In en, this message translates to:
  /// **'No completed orders in this period.'**
  String get noCompletedOrdersMessage;

  /// No description provided for @insightEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Complete an order to start seeing useful sales patterns.'**
  String get insightEmptyMessage;

  /// No description provided for @topEarningProductMessage.
  ///
  /// In en, this message translates to:
  /// **'{product} earned the most in this period.'**
  String topEarningProductMessage(Object product);

  /// No description provided for @shareReportTooltip.
  ///
  /// In en, this message translates to:
  /// **'Share report'**
  String get shareReportTooltip;

  /// No description provided for @paymentAuthorizedLabel.
  ///
  /// In en, this message translates to:
  /// **'{method} authorized · not charged yet'**
  String paymentAuthorizedLabel(Object method);

  /// No description provided for @paymentChargedLabel.
  ///
  /// In en, this message translates to:
  /// **'{method} charged after acceptance'**
  String paymentChargedLabel(Object method);

  /// No description provided for @declinedByFarmerLabel.
  ///
  /// In en, this message translates to:
  /// **'Declined by farmer'**
  String get declinedByFarmerLabel;

  /// No description provided for @declinedPaymentReleasedLabel.
  ///
  /// In en, this message translates to:
  /// **'Declined · payment authorization released'**
  String get declinedPaymentReleasedLabel;

  /// No description provided for @courierDeliveryLabel.
  ///
  /// In en, this message translates to:
  /// **'Courier delivery'**
  String get courierDeliveryLabel;

  /// No description provided for @removeTooltip.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removeTooltip;

  /// No description provided for @onlyQuantityAvailableMessage.
  ///
  /// In en, this message translates to:
  /// **'Only {quantity} {unit} available.'**
  String onlyQuantityAvailableMessage(Object quantity, Object unit);

  /// No description provided for @fulfilmentQuestion.
  ///
  /// In en, this message translates to:
  /// **'How would you like it?'**
  String get fulfilmentQuestion;

  /// No description provided for @pickupAtFarmLabel.
  ///
  /// In en, this message translates to:
  /// **'Pick up at farm'**
  String get pickupAtFarmLabel;

  /// No description provided for @pickupLocationAfterAcceptance.
  ///
  /// In en, this message translates to:
  /// **'Free · exact location after acceptance'**
  String get pickupLocationAfterAcceptance;

  /// No description provided for @farmsYouFollowTitle.
  ///
  /// In en, this message translates to:
  /// **'Farms you follow'**
  String get farmsYouFollowTitle;

  /// No description provided for @orderNotFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'Order not found.'**
  String get orderNotFoundMessage;

  /// No description provided for @orderDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Order details'**
  String get orderDetailsTitle;

  /// No description provided for @callLabel.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get callLabel;

  /// No description provided for @textLabel.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get textLabel;

  /// No description provided for @orderLabel.
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get orderLabel;

  /// No description provided for @statusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get statusLabel;

  /// No description provided for @customerHistoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Customer history'**
  String get customerHistoryLabel;

  /// No description provided for @declineLabel.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get declineLabel;

  /// No description provided for @acceptOrderLabel.
  ///
  /// In en, this message translates to:
  /// **'Accept order'**
  String get acceptOrderLabel;

  /// No description provided for @acceptLabel.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get acceptLabel;

  /// No description provided for @acceptRequestLabel.
  ///
  /// In en, this message translates to:
  /// **'Accept request'**
  String get acceptRequestLabel;

  /// No description provided for @addOptionalNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Add a note (optional)'**
  String get addOptionalNoteLabel;

  /// No description provided for @customerPickupLabel.
  ///
  /// In en, this message translates to:
  /// **'Customer pickup'**
  String get customerPickupLabel;

  /// No description provided for @customerWillCollectLabel.
  ///
  /// In en, this message translates to:
  /// **'Customer will collect this order'**
  String get customerWillCollectLabel;

  /// No description provided for @courierWillCollectLabel.
  ///
  /// In en, this message translates to:
  /// **'Courier will collect this order'**
  String get courierWillCollectLabel;

  /// No description provided for @preparePickupMessage.
  ///
  /// In en, this message translates to:
  /// **'Prepare it for the selected pickup point.'**
  String get preparePickupMessage;

  /// No description provided for @prepareCourierMessage.
  ///
  /// In en, this message translates to:
  /// **'Prepare it for courier collection. Delivery is handled by FreshFarm.'**
  String get prepareCourierMessage;

  /// No description provided for @customerOrderCountLabel.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 order} other{{count} orders}}'**
  String customerOrderCountLabel(num count);

  /// No description provided for @paymentAuthorizationInfo.
  ///
  /// In en, this message translates to:
  /// **'Your payment is authorized now and charged only when the farmer accepts.'**
  String get paymentAuthorizationInfo;

  /// No description provided for @authorizeWithLabel.
  ///
  /// In en, this message translates to:
  /// **'Authorize with {method}'**
  String authorizeWithLabel(Object method);

  /// No description provided for @cardLabel.
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get cardLabel;

  /// No description provided for @authorizeCardLabel.
  ///
  /// In en, this message translates to:
  /// **'Authorize your card'**
  String get authorizeCardLabel;

  /// No description provided for @requestSentLabel.
  ///
  /// In en, this message translates to:
  /// **'Request sent'**
  String get requestSentLabel;

  /// No description provided for @requestSentPaymentMessage.
  ///
  /// In en, this message translates to:
  /// **'{method} authorized. You will be charged only after the farmer accepts.'**
  String requestSentPaymentMessage(Object method);

  /// No description provided for @doneLabel.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get doneLabel;

  /// No description provided for @loadingFarmMessage.
  ///
  /// In en, this message translates to:
  /// **'Loading farm...'**
  String get loadingFarmMessage;

  /// No description provided for @farmOpenErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Could not open this farm'**
  String get farmOpenErrorTitle;

  /// No description provided for @farmNotFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Farm not found'**
  String get farmNotFoundTitle;

  /// No description provided for @shareFarmTooltip.
  ///
  /// In en, this message translates to:
  /// **'Share farm'**
  String get shareFarmTooltip;

  /// No description provided for @addedToCartMessage.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 product added to cart.} other{{count} products added to cart.}}'**
  String addedToCartMessage(num count);

  /// No description provided for @viewCartLabel.
  ///
  /// In en, this message translates to:
  /// **'View cart'**
  String get viewCartLabel;

  /// No description provided for @nextHarvestMessage.
  ///
  /// In en, this message translates to:
  /// **'This farm is preparing its next harvest.'**
  String get nextHarvestMessage;

  /// No description provided for @openFarmLabel.
  ///
  /// In en, this message translates to:
  /// **'Open farm'**
  String get openFarmLabel;

  /// No description provided for @freshPicksLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} fresh picks'**
  String freshPicksLabel(Object count);

  /// No description provided for @bestBeforeLabel.
  ///
  /// In en, this message translates to:
  /// **'Best before'**
  String get bestBeforeLabel;

  /// No description provided for @storageLabel.
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get storageLabel;

  /// No description provided for @farmPickupLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'Farm pickup location'**
  String get farmPickupLocationLabel;

  /// No description provided for @allLabel.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allLabel;

  /// No description provided for @editLabel.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editLabel;

  /// No description provided for @availableRatioLabel.
  ///
  /// In en, this message translates to:
  /// **'{active} of {total} available'**
  String availableRatioLabel(Object active, Object total);

  /// No description provided for @undoLabel.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undoLabel;

  /// No description provided for @quantityToAddLabel.
  ///
  /// In en, this message translates to:
  /// **'Quantity to add'**
  String get quantityToAddLabel;

  /// No description provided for @addToStockLabel.
  ///
  /// In en, this message translates to:
  /// **'Add to stock'**
  String get addToStockLabel;

  /// No description provided for @farmProfileNotFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'Farm profile not found.'**
  String get farmProfileNotFoundMessage;

  /// No description provided for @editFarmProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit farm profile'**
  String get editFarmProfileTitle;

  /// No description provided for @changeProfilePhotoLabel.
  ///
  /// In en, this message translates to:
  /// **'Change profile photo'**
  String get changeProfilePhotoLabel;

  /// No description provided for @changeCoverPhotoLabel.
  ///
  /// In en, this message translates to:
  /// **'Change cover photo'**
  String get changeCoverPhotoLabel;

  /// No description provided for @shortIntroductionLabel.
  ///
  /// In en, this message translates to:
  /// **'Short introduction'**
  String get shortIntroductionLabel;

  /// No description provided for @farmIntroductionHint.
  ///
  /// In en, this message translates to:
  /// **'What makes your farm and produce special?'**
  String get farmIntroductionHint;

  /// No description provided for @customerContactNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Customer contact number'**
  String get customerContactNumberLabel;

  /// No description provided for @farmPickupDescription.
  ///
  /// In en, this message translates to:
  /// **'Customers can collect accepted orders from your farm.'**
  String get farmPickupDescription;

  /// No description provided for @pickupAtFarmLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'Pickup at farm location'**
  String get pickupAtFarmLocationLabel;

  /// No description provided for @pickupAtFarmLocationDescription.
  ///
  /// In en, this message translates to:
  /// **'Use your confirmed farm location as the pickup point.'**
  String get pickupAtFarmLocationDescription;

  /// No description provided for @exactLocationAfterAcceptance.
  ///
  /// In en, this message translates to:
  /// **'Exact farm location after acceptance'**
  String get exactLocationAfterAcceptance;

  /// No description provided for @pickupAddressRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter the pickup point address.'**
  String get pickupAddressRequired;

  /// No description provided for @setPickupLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'Set pickup location'**
  String get setPickupLocationLabel;

  /// No description provided for @pickupLocationHint.
  ///
  /// In en, this message translates to:
  /// **'Street, city or recognizable place'**
  String get pickupLocationHint;

  /// No description provided for @pickupNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Pickup note'**
  String get pickupNoteLabel;

  /// No description provided for @pickupNoteHint.
  ///
  /// In en, this message translates to:
  /// **'For example: Collect from the farm gate'**
  String get pickupNoteHint;

  /// No description provided for @farmLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'Farm location'**
  String get farmLocationLabel;

  /// No description provided for @confirmedGpsLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'Based on your confirmed GPS location'**
  String get confirmedGpsLocationLabel;

  /// No description provided for @savePublicProfileLabel.
  ///
  /// In en, this message translates to:
  /// **'Save public profile'**
  String get savePublicProfileLabel;

  /// No description provided for @customerReviewLabel.
  ///
  /// In en, this message translates to:
  /// **'Customer review'**
  String get customerReviewLabel;

  /// No description provided for @writeReviewLabel.
  ///
  /// In en, this message translates to:
  /// **'Rate and review'**
  String get writeReviewLabel;

  /// No description provided for @noReviewYetLabel.
  ///
  /// In en, this message translates to:
  /// **'No review yet'**
  String get noReviewYetLabel;

  /// No description provided for @reviewOptionalHint.
  ///
  /// In en, this message translates to:
  /// **'Rating and written feedback are optional.'**
  String get reviewOptionalHint;

  /// No description provided for @notNowLabel.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get notNowLabel;

  /// No description provided for @reviewSubmittedLabel.
  ///
  /// In en, this message translates to:
  /// **'Review submitted'**
  String get reviewSubmittedLabel;

  /// No description provided for @verifiedCustomerLabel.
  ///
  /// In en, this message translates to:
  /// **'Verified customer'**
  String get verifiedCustomerLabel;

  /// No description provided for @landingNavAbout.
  ///
  /// In en, this message translates to:
  /// **'About us'**
  String get landingNavAbout;

  /// No description provided for @landingNavInterested.
  ///
  /// In en, this message translates to:
  /// **'Interested?'**
  String get landingNavInterested;

  /// No description provided for @landingNavPrototype.
  ///
  /// In en, this message translates to:
  /// **'Open prototype'**
  String get landingNavPrototype;

  /// No description provided for @landingHeroKicker.
  ///
  /// In en, this message translates to:
  /// **'From local soil to your table'**
  String get landingHeroKicker;

  /// No description provided for @landingHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'Making local food consumption easy.'**
  String get landingHeroTitle;

  /// No description provided for @landingHeroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'FRSH Nearby connects you directly to local food producers near you — cutting out middle parties, reducing costs and increasing freshness.'**
  String get landingHeroSubtitle;

  /// No description provided for @landingHeroPrimaryCta.
  ///
  /// In en, this message translates to:
  /// **'Get early access'**
  String get landingHeroPrimaryCta;

  /// No description provided for @landingHeroSecondaryCta.
  ///
  /// In en, this message translates to:
  /// **'Open the prototype'**
  String get landingHeroSecondaryCta;

  /// No description provided for @landingMapBadge.
  ///
  /// In en, this message translates to:
  /// **'Launching first in Vaasa, Finland'**
  String get landingMapBadge;

  /// No description provided for @landingMapCaption.
  ///
  /// In en, this message translates to:
  /// **'Built for local food across Europe'**
  String get landingMapCaption;

  /// No description provided for @landingAboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About us'**
  String get landingAboutTitle;

  /// No description provided for @landingAboutBody.
  ///
  /// In en, this message translates to:
  /// **'FRSH Nearby started with a simple idea: the best food is grown next door. We are building a platform that makes it effortless for consumers to access locally produced food — making it easier for food producers to sell directly to the consumer, cutting out middle parties. The platform is built by three newly graduated university students, together with local food producers. Fresh, easy and fair.'**
  String get landingAboutBody;

  /// No description provided for @landingValue1Title.
  ///
  /// In en, this message translates to:
  /// **'Local'**
  String get landingValue1Title;

  /// No description provided for @landingValue1Body.
  ///
  /// In en, this message translates to:
  /// **'Find fresh food produced near you, always in season.'**
  String get landingValue1Body;

  /// No description provided for @landingValue2Title.
  ///
  /// In en, this message translates to:
  /// **'Fair for food producers'**
  String get landingValue2Title;

  /// No description provided for @landingValue2Body.
  ///
  /// In en, this message translates to:
  /// **'Producers sell directly to end customers in the most convenient way agreed upon, increasing profits for producers and reducing costs for consumers.'**
  String get landingValue2Body;

  /// No description provided for @landingValue3Title.
  ///
  /// In en, this message translates to:
  /// **'Stronger communities'**
  String get landingValue3Title;

  /// No description provided for @landingValue3Body.
  ///
  /// In en, this message translates to:
  /// **'Every order keeps value in your region and strengthens local food networks.'**
  String get landingValue3Body;

  /// No description provided for @landingProducersTitle.
  ///
  /// In en, this message translates to:
  /// **'For producers'**
  String get landingProducersTitle;

  /// No description provided for @landingProducer1Title.
  ///
  /// In en, this message translates to:
  /// **'Promote and sell on social media!'**
  String get landingProducer1Title;

  /// No description provided for @landingProducer1Body.
  ///
  /// In en, this message translates to:
  /// **'Copy and paste the link to your personal order page into your social media posts and profiles to direct customers straight to your product catalog.'**
  String get landingProducer1Body;

  /// No description provided for @landingProducer2Title.
  ///
  /// In en, this message translates to:
  /// **'Manage all social media orders in one place!'**
  String get landingProducer2Title;

  /// No description provided for @landingProducer2Body.
  ///
  /// In en, this message translates to:
  /// **'With your order page, you can view and approve incoming orders. Once an order is approved, the customer receives a payment request. The order page also provides summaries of all approved orders by product and by customer, making order management and delivery planning simple.'**
  String get landingProducer2Body;

  /// No description provided for @landingProducer3Title.
  ///
  /// In en, this message translates to:
  /// **'Be visible to everyone!'**
  String get landingProducer3Title;

  /// No description provided for @landingProducer3Body.
  ///
  /// In en, this message translates to:
  /// **'Our interactive map brings all producers together in one place, making it easy for consumers to discover local food producers nearby.'**
  String get landingProducer3Body;

  /// No description provided for @landingProducer4Title.
  ///
  /// In en, this message translates to:
  /// **'Reports and bookkeeping'**
  String get landingProducer4Title;

  /// No description provided for @landingProducer4Body.
  ///
  /// In en, this message translates to:
  /// **'Download sales reports and receipts with ease and send them directly to your accountant.'**
  String get landingProducer4Body;

  /// No description provided for @landingConsumersTitle.
  ///
  /// In en, this message translates to:
  /// **'For consumers'**
  String get landingConsumersTitle;

  /// No description provided for @landingConsumer1Title.
  ///
  /// In en, this message translates to:
  /// **'Order local food effortlessly'**
  String get landingConsumer1Title;

  /// No description provided for @landingConsumer1Body.
  ///
  /// In en, this message translates to:
  /// **'Find nearby food producers on the app\'s map, or browse the product catalog for exactly what you\'re looking for.'**
  String get landingConsumer1Body;

  /// No description provided for @landingConsumer2Title.
  ///
  /// In en, this message translates to:
  /// **'Fresh, healthy, and traceable'**
  String get landingConsumer2Title;

  /// No description provided for @landingConsumer2Body.
  ///
  /// In en, this message translates to:
  /// **'By choosing a local producer, you know exactly what you\'re buying, where it comes from, and how the crops and animals have been cared for.'**
  String get landingConsumer2Body;

  /// No description provided for @landingConsumer3Title.
  ///
  /// In en, this message translates to:
  /// **'Support sustainable local food production'**
  String get landingConsumer3Title;

  /// No description provided for @landingConsumer3Body.
  ///
  /// In en, this message translates to:
  /// **'Buying directly from local producers supports your local economy and reduces the need for food to travel around the world.'**
  String get landingConsumer3Body;

  /// No description provided for @landingInterestedTitle.
  ///
  /// In en, this message translates to:
  /// **'Interested?'**
  String get landingInterestedTitle;

  /// No description provided for @landingInterestedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Join the waiting list and get notified when FRSH Nearby launches.'**
  String get landingInterestedSubtitle;

  /// No description provided for @landingFormRoleLabel.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get landingFormRoleLabel;

  /// No description provided for @landingFormMessageLabel.
  ///
  /// In en, this message translates to:
  /// **'Optional message'**
  String get landingFormMessageLabel;

  /// No description provided for @landingRoleConsumer.
  ///
  /// In en, this message translates to:
  /// **'Consumer'**
  String get landingRoleConsumer;

  /// No description provided for @landingRoleFarmer.
  ///
  /// In en, this message translates to:
  /// **'Food producer'**
  String get landingRoleFarmer;

  /// No description provided for @landingRoleRestaurant.
  ///
  /// In en, this message translates to:
  /// **'Restaurant / Shop'**
  String get landingRoleRestaurant;

  /// No description provided for @landingRoleSupporter.
  ///
  /// In en, this message translates to:
  /// **'Local food supporter'**
  String get landingRoleSupporter;

  /// No description provided for @landingFormSubmit.
  ///
  /// In en, this message translates to:
  /// **'Join the waiting list'**
  String get landingFormSubmit;

  /// No description provided for @landingFormConsentLabel.
  ///
  /// In en, this message translates to:
  /// **'I agree that FRSH nearby may collect, store, and process the personal data submitted through this form for the purpose of managing the waiting list, contacting me about the launch of FRSH nearby, and providing related updates, in accordance with the Privacy Policy.'**
  String get landingFormConsentLabel;

  /// No description provided for @landingFormThanks.
  ///
  /// In en, this message translates to:
  /// **'Thank you. You\'re on the early access list.'**
  String get landingFormThanks;

  /// No description provided for @landingFooterTagline.
  ///
  /// In en, this message translates to:
  /// **'Find food produced near you.'**
  String get landingFooterTagline;

  /// No description provided for @landingFooterCopyright.
  ///
  /// In en, this message translates to:
  /// **'© 2026 FRSH nearby'**
  String get landingFooterCopyright;

  /// No description provided for @prototypeChooserTitle.
  ///
  /// In en, this message translates to:
  /// **'Open the FRSH Nearby prototype'**
  String get prototypeChooserTitle;

  /// No description provided for @prototypeChooserSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick the side you want to test first.'**
  String get prototypeChooserSubtitle;

  /// No description provided for @prototypeFarmerHint.
  ///
  /// In en, this message translates to:
  /// **'Dashboard, orders, listings, insights'**
  String get prototypeFarmerHint;

  /// No description provided for @prototypeConsumerHint.
  ///
  /// In en, this message translates to:
  /// **'Nearby food, farm profiles, deals, chat'**
  String get prototypeConsumerHint;

  /// No description provided for @landingFormPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone (optional)'**
  String get landingFormPhoneLabel;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fi', 'sv'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fi':
      return AppLocalizationsFi();
    case 'sv':
      return AppLocalizationsSv();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
