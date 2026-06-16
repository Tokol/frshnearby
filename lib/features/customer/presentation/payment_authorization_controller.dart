import 'package:flutter_riverpod/flutter_riverpod.dart';

enum CustomerPaymentMethod { mobilePay, revolut, card }

class PaymentAuthorization {
  const PaymentAuthorization({required this.dealId, required this.method});

  final String dealId;
  final CustomerPaymentMethod method;
}

final paymentAuthorizationProvider = StateNotifierProvider<
    PaymentAuthorizationController, Map<String, PaymentAuthorization>>(
  (ref) => PaymentAuthorizationController(),
);

class PaymentAuthorizationController
    extends StateNotifier<Map<String, PaymentAuthorization>> {
  PaymentAuthorizationController() : super(const {});

  void authorize(String dealId, CustomerPaymentMethod method) {
    state = {
      ...state,
      dealId: PaymentAuthorization(dealId: dealId, method: method),
    };
  }
}

String paymentMethodLabel(CustomerPaymentMethod method) => switch (method) {
      CustomerPaymentMethod.mobilePay => 'MobilePay',
      CustomerPaymentMethod.revolut => 'Revolut',
      CustomerPaymentMethod.card => 'Card',
    };
