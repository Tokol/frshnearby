import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../location/marketplace_location_controller.dart';
import '../../features/auth/presentation/auth_controller.dart';
import '../../features/auth/domain/farmer_profile.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/customer/presentation/customer_deals_screen.dart';
import '../../features/customer/presentation/customer_home_screen.dart';
import '../../features/customer/presentation/customer_map_screen.dart';
import '../../features/customer/presentation/customer_messages_screen.dart';
import '../../features/customer/presentation/customer_profile_screen.dart';
import '../../features/customer/presentation/customer_search_screen.dart';
import '../../features/customer_marketplace/presentation/farmer_public_profile_screen.dart';
import '../../features/customer_marketplace/presentation/listing_detail_screen.dart';
import '../../features/deals/presentation/chat_thread_screen.dart';
import '../../features/deals/presentation/rating_screen.dart';
import '../../features/farmer/presentation/farmer_dashboard_screen.dart';
import '../../features/farmer/presentation/edit_farm_profile_screen.dart';
import '../../features/farmer/presentation/farmer_deals_screen.dart';
import '../../features/farmer/presentation/farmer_insights_screen.dart';
import '../../features/farmer/presentation/farmer_order_detail_screen.dart';
import '../../features/farmer_application/presentation/apply_as_farmer_screen.dart';
import '../../features/farmer_application/presentation/farmer_application_review_screen.dart';
import '../../features/farmer_application/presentation/farmer_location_screen.dart';
import '../../features/farmer_application/presentation/farmer_pending_review_screen.dart';
import '../../features/farmer_application/presentation/farmer_rejected_screen.dart';
import '../../features/listings/presentation/create_listing_screen.dart';
import '../../features/listings/presentation/edit_listing_screen.dart';
import '../../features/listings/presentation/listing_preview_screen.dart';
import '../../features/marketing/presentation/marketing_home_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/shared/presentation/app_shell.dart';
import '../../features/social_feed/domain/feed_post.dart';
import '../../features/social_feed/presentation/social_feed_screen.dart';
import '../../features/splash/presentation/splash_screen.dart';
import 'app_routes.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);
  final locationState = ref.watch(marketplaceLocationControllerProvider);

  return GoRouter(
    initialLocation: _browserInitialLocation(),
    redirect: (context, state) {
      final location = state.matchedLocation;
      final isAuthRoute =
          location == AppRoutes.login || location == AppRoutes.register;
      final isPublicRoute = location == AppRoutes.home;
      final isFarmerRoute = location.startsWith('/farmer/');
      final isApplicationRoute = location.startsWith('/farmer-application');
      final farmerStatus = authState.user?.farmerProfile?.status;

      if (isPublicRoute) {
        return null;
      }

      if (authState.isRestoring || locationState.isInitializing) {
        // Preserve explicit deep links while session and location state load.
        return null;
      }

      if (!authState.isSignedIn) {
        return isAuthRoute ? AppRoutes.customerHome : null;
      }

      if (isAuthRoute || location == AppRoutes.splash) {
        return authState.canAccessFarmerMode
            ? AppRoutes.farmerDashboard
            : AppRoutes.customerHome;
      }

      if (isApplicationRoute &&
          farmerStatus == FarmerVerificationStatus.verified) {
        return AppRoutes.customerProfile;
      }

      if (isFarmerRoute && !authState.canAccessFarmerMode) {
        if (farmerStatus == FarmerVerificationStatus.pendingReview) {
          return AppRoutes.farmerPendingReview;
        }
        if (farmerStatus == FarmerVerificationStatus.rejected) {
          return AppRoutes.farmerRejected;
        }
        return AppRoutes.customerProfile;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const MarketingHomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.prototype,
        redirect: (context, state) => AppRoutes.farmerDashboard,
      ),
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.applyAsFarmer,
        builder: (context, state) => const ApplyAsFarmerScreen(),
      ),
      GoRoute(
        path: AppRoutes.farmerLocation,
        builder: (context, state) => const FarmerLocationScreen(),
      ),
      GoRoute(
        path: AppRoutes.farmerApplicationReview,
        builder: (context, state) => const FarmerApplicationReviewScreen(),
      ),
      GoRoute(
        path: AppRoutes.farmerPendingReview,
        builder: (context, state) => const FarmerPendingReviewScreen(),
      ),
      GoRoute(
        path: AppRoutes.farmerRejected,
        builder: (context, state) => const FarmerRejectedScreen(),
      ),
      GoRoute(
        path: '/customer/listings/:listingId',
        builder: (context, state) {
          return ListingDetailScreen(
            listingId: state.pathParameters['listingId']!,
          );
        },
      ),
      GoRoute(
        path: '/customer/farmers/:farmerId',
        builder: (context, state) {
          return FarmerPublicProfileScreen(
            farmerId: state.pathParameters['farmerId']!,
            preview: state.uri.queryParameters['preview'] == 'true',
          );
        },
      ),
      GoRoute(
        path: '/customer/chat/:threadId',
        builder: (context, state) {
          return ChatThreadScreen(threadId: state.pathParameters['threadId']!);
        },
      ),
      GoRoute(
        path: '/customer/deals/:dealId/rate',
        builder: (context, state) {
          return RatingScreen(dealId: state.pathParameters['dealId']!);
        },
      ),
      GoRoute(
        path: AppRoutes.customerSearch,
        builder: (context, state) => const CustomerSearchScreen(),
      ),
      GoRoute(
        path: AppRoutes.customerMessages,
        builder: (context, state) => const CustomerMessagesScreen(),
      ),
      GoRoute(
        path: AppRoutes.customerMap,
        builder: (context, state) => const CustomerMapScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(
            navigationShell: navigationShell,
            mode: AppShellMode.customer,
          );
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.customerHome,
                pageBuilder: _pageBuilder(const CustomerHomeScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.customerCommunity,
                pageBuilder: _pageBuilder(
                  const SocialFeedScreen(viewerType: FeedActorType.consumer),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.customerDeals,
                pageBuilder: _pageBuilder(const CustomerDealsScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.customerProfile,
                pageBuilder: _pageBuilder(const CustomerProfileScreen()),
                routes: [
                  GoRoute(
                    path: 'settings',
                    builder: (context, state) => const SettingsScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => AppShell(
          navigationShell: navigationShell,
          mode: AppShellMode.farmer,
        ),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.farmerDashboard,
                pageBuilder: _pageBuilder(const FarmerDashboardScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.farmerDeals,
                pageBuilder: _pageBuilder(const FarmerDealsScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.farmerInsights,
                pageBuilder: _pageBuilder(const FarmerInsightsScreen()),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.farmerCommunity,
        builder: (context, state) => SocialFeedScreen(
          viewerType: FeedActorType.farmer,
          openComposer: state.uri.queryParameters['create'] == 'true',
        ),
      ),
      GoRoute(
        path: AppRoutes.createListing,
        builder: (context, state) => const CreateListingScreen(),
      ),
      GoRoute(
        path: AppRoutes.editFarmProfile,
        builder: (context, state) => const EditFarmProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.farmerSettings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.farmerListings,
        redirect: (context, state) => AppRoutes.farmerDashboard,
      ),
      GoRoute(
        path: '/farmer/listings/:listingId/edit',
        builder: (context, state) =>
            EditListingScreen(listingId: state.pathParameters['listingId']!),
      ),
      GoRoute(
        path: '/farmer/listings/:listingId/preview',
        builder: (context, state) =>
            ListingPreviewScreen(listingId: state.pathParameters['listingId']!),
      ),
      GoRoute(
        path: '/farmer/orders/:orderId',
        builder: (context, state) =>
            FarmerOrderDetailScreen(orderId: state.pathParameters['orderId']!),
      ),
      GoRoute(
        path: AppRoutes.farmerMessages,
        redirect: (context, state) => AppRoutes.farmerDashboard,
      ),
      GoRoute(
        path: AppRoutes.farmerReviews,
        redirect: (context, state) => AppRoutes.farmerDashboard,
      ),
    ],
  );
});

String _browserInitialLocation() {
  final fragment = Uri.base.fragment;
  if (fragment.startsWith('/')) return fragment;
  return AppRoutes.home;
}

Page<dynamic> Function(BuildContext, GoRouterState) _pageBuilder(Widget child) {
  return (context, state) => NoTransitionPage(child: child);
}
