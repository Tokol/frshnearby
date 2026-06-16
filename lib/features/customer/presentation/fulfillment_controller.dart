import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../deals/domain/deal.dart';

const courierBaseFee = 3.0;
const courierRatePerKm = 0.70;

class FulfillmentState {
  const FulfillmentState({
    this.method = FulfillmentMethod.courierDelivery,
  });

  final FulfillmentMethod method;

  FulfillmentState copyWith({FulfillmentMethod? method}) {
    return FulfillmentState(method: method ?? this.method);
  }
}

final fulfillmentControllerProvider =
    StateNotifierProvider<FulfillmentController, FulfillmentState>(
  (ref) => FulfillmentController(),
);

class FulfillmentController extends StateNotifier<FulfillmentState> {
  FulfillmentController() : super(const FulfillmentState());

  void select(FulfillmentMethod method) {
    state = state.copyWith(method: method);
  }

  void reset() => state = const FulfillmentState();
}

double courierWeightSurcharge(double weightKg) {
  if (weightKg <= 5) return 0;
  final additionalBlocks = ((weightKg - 5) / 10).ceil();
  return additionalBlocks * 3;
}

double courierDeliveryFee({
  required double distanceKm,
  required double weightKg,
}) {
  return courierBaseFee +
      (distanceKm * courierRatePerKm) +
      courierWeightSurcharge(weightKg);
}
