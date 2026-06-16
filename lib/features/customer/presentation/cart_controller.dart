import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../customer_marketplace/domain/customer_listing.dart';

final cartControllerProvider =
    StateNotifierProvider<CartController, List<CartItem>>(
      (ref) => CartController(),
    );

class CartItem {
  const CartItem({required this.listing, required this.quantity});

  final CustomerListing listing;
  final double quantity;

  double get total => listing.listing.price * quantity;

  CartItem copyWith({double? quantity}) {
    return CartItem(listing: listing, quantity: quantity ?? this.quantity);
  }
}

class CartController extends StateNotifier<List<CartItem>> {
  CartController() : super(const []);

  void add(CustomerListing listing, double quantity) {
    final index = state.indexWhere(
      (item) => item.listing.listing.id == listing.listing.id,
    );
    if (index == -1) {
      state = [...state, CartItem(listing: listing, quantity: quantity)];
      return;
    }
    final existing = state[index];
    final available = listing.listing.quantity;
    final updatedQuantity = (existing.quantity + quantity)
        .clamp(1, available)
        .toDouble();
    final updated = [...state];
    updated[index] = existing.copyWith(quantity: updatedQuantity);
    state = updated;
  }

  void set(CustomerListing listing, double quantity) {
    final index = state.indexWhere(
      (item) => item.listing.listing.id == listing.listing.id,
    );
    final safeQuantity = quantity
        .clamp(1, listing.listing.quantity)
        .toDouble();
    if (index == -1) {
      state = [...state, CartItem(listing: listing, quantity: safeQuantity)];
      return;
    }
    final updated = [...state];
    updated[index] = CartItem(listing: listing, quantity: safeQuantity);
    state = updated;
  }

  void updateQuantity(String listingId, double quantity) {
    final index = state.indexWhere(
      (item) => item.listing.listing.id == listingId,
    );
    if (index == -1) return;
    final item = state[index];
    final safeQuantity = quantity
        .clamp(1, item.listing.listing.quantity)
        .toDouble();
    final updated = [...state];
    updated[index] = item.copyWith(quantity: safeQuantity);
    state = updated;
  }

  void remove(String listingId) {
    state = state
        .where((item) => item.listing.listing.id != listingId)
        .toList();
  }

  void clear() => state = const [];
}
