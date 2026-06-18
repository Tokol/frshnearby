class AppRoutes {
  const AppRoutes._();

  static const home = '/';
  static const splash = '/splash';
  static const prototype = '/prototype';
  static const login = '/login';
  static const register = '/register';
  static const customerHome = '/customer/home';
  static const customerMap = '/customer/map';
  static const customerSearch = '/customer/search';
  static const customerMessages = '/customer/messages';
  static const customerDeals = '/customer/deals';
  static const customerProfile = '/customer/profile';
  static const customerCommunity = '/customer/community';
  static String customerListingDetail(String listingId) =>
      '/customer/listings/$listingId';

  static String farmerPublicProfile(String farmerId) =>
      '/customer/farmers/$farmerId';

  static String chatThread(String threadId) => '/customer/chat/$threadId';

  static String rateDeal(String dealId) => '/customer/deals/$dealId/rate';

  static const applyAsFarmer = '/farmer-application/apply';
  static const farmerLocation = '/farmer-application/location';
  static const farmerApplicationReview = '/farmer-application/review';
  static const farmerPendingReview = '/farmer-application/pending-review';
  static const farmerRejected = '/farmer-application/rejected';
  static const farmerDashboard = '/farmer/dashboard';
  static const editFarmProfile = '/farmer/profile/edit';
  static const farmerListings = '/farmer/listings';
  static const createListing = '/farmer/listings/create';
  static const farmerMessages = '/farmer/messages';
  static const farmerDeals = '/farmer/deals';
  static const farmerCommunity = '/farmer/community';
  static const farmerInsights = '/farmer/insights';
  static const farmerReviews = '/farmer/reviews';
  static const settings = '/customer/profile/settings';
  static const farmerSettings = '/farmer/settings';

  static String editListing(String listingId) =>
      '/farmer/listings/$listingId/edit';

  static String previewListing(String listingId) =>
      '/farmer/listings/$listingId/preview';

  static String farmerOrderDetail(String orderId) => '/farmer/orders/$orderId';
}
