import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../customer_marketplace/presentation/customer_marketplace_controller.dart';
import '../data/listing_repository.dart';
import '../domain/listing.dart';
import '../domain/listing_draft.dart';

final listingControllerProvider =
    StateNotifierProvider<ListingController, ListingState>((ref) {
      // Recreate and load once session restoration reveals the farmer profile.
      ref.watch(authControllerProvider);
      return ListingController(ref.watch(listingRepositoryProvider), ref)
        ..loadListings();
    });

class ListingState {
  const ListingState({
    this.listings = const [],
    this.isLoading = false,
    this.isSaving = false,
  });

  final List<Listing> listings;
  final bool isLoading;
  final bool isSaving;

  ListingState copyWith({
    List<Listing>? listings,
    bool? isLoading,
    bool? isSaving,
  }) {
    return ListingState(
      listings: listings ?? this.listings,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

class ListingController extends StateNotifier<ListingState> {
  ListingController(this._repository, this._ref) : super(const ListingState());

  final ListingRepository _repository;
  final Ref _ref;

  Future<void> loadListings() async {
    final farmerId = _farmerId;
    if (farmerId == null) {
      state = state.copyWith(listings: []);
      return;
    }

    state = state.copyWith(isLoading: true);
    final listings = await _repository.getFarmerListings(farmerId);
    await _syncPublicListings(farmerId, listings);
    state = state.copyWith(listings: listings, isLoading: false);
  }

  Listing? listingById(String id) {
    for (final listing in state.listings) {
      if (listing.id == id) {
        return listing;
      }
    }
    return null;
  }

  ListingDraft initialDraft() {
    final farmerProfile = _ref.read(authControllerProvider).user?.farmerProfile;
    return ListingDraft(
      latitude: farmerProfile?.latitude,
      longitude: farmerProfile?.longitude,
    );
  }

  Future<Listing> createListing(ListingDraft draft) async {
    final authState = _ref.read(authControllerProvider);
    final farmerId = authState.user?.farmerProfile?.id;
    if (!authState.canAccessFarmerMode || farmerId == null) {
      throw StateError('Only verified farmers can create listings.');
    }

    state = state.copyWith(isSaving: true);
    try {
      final listing = await _repository.createListing(
        farmerId: farmerId,
        draft: draft,
      );
      await loadListings();
      state = state.copyWith(isSaving: false);
      return listing;
    } catch (_) {
      state = state.copyWith(isSaving: false);
      rethrow;
    }
  }

  Future<Listing> updateListing(Listing listing) async {
    state = state.copyWith(isSaving: true);
    try {
      final stockStatus = listing.quantity <= 0
          ? ListingStatus.soldOut
          : ListingStatus.active;
      final updatedListing = await _repository.updateListing(
        listing.copyWith(status: stockStatus),
      );
      await loadListings();
      state = state.copyWith(isSaving: false);
      return updatedListing;
    } catch (_) {
      state = state.copyWith(isSaving: false);
      rethrow;
    }
  }

  Future<Listing> updateQuantity({
    required String listingId,
    required double quantity,
    String? unit,
  }) async {
    final listing = listingById(listingId);
    if (listing == null) {
      throw StateError('Listing not found.');
    }

    final safeQuantity = quantity < 0 ? 0.0 : quantity;
    final status = safeQuantity == 0
        ? ListingStatus.soldOut
        : ListingStatus.active;
    final updated = await updateListing(
      listing.copyWith(
        quantity: safeQuantity,
        unit: unit == null || unit.trim().isEmpty ? listing.unit : unit.trim(),
        status: status,
      ),
    );

    return updated;
  }

  Future<void> archiveListing(String listingId) async {
    state = state.copyWith(isSaving: true);
    await _repository.archiveListing(listingId);
    await loadListings();
    state = state.copyWith(isSaving: false);
  }

  String? get _farmerId {
    final authState = _ref.read(authControllerProvider);
    if (!authState.canAccessFarmerMode) {
      return null;
    }
    return authState.user?.farmerProfile?.id;
  }

  Future<void> _syncPublicListings(
    String farmerId,
    List<Listing> listings,
  ) async {
    await _ref
        .read(customerMarketplaceRepositoryProvider)
        .replaceFarmerListings(farmerId: farmerId, listings: listings);
    _ref.invalidate(nearbyListingsProvider);
    _ref.invalidate(searchListingsProvider);
    _ref.invalidate(customerListingProvider);
  }
}
