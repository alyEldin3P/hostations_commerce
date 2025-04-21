import 'dart:developer' as developer;
import 'package:hostations_commerce/features/orders/data/model/order.dart';

import 'checkout_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/model/checkout.dart';
import '../../data/model/shipping_address.dart';
import '../../data/model/shipping_method.dart';
import '../../data/model/payment_method.dart';
import '../../data/model/order.dart';
import '../../data/repo/checkout_repository.dart';

class CheckoutCubit extends Cubit<CheckoutState> {
  final CheckoutRepository repository;
  CheckoutCubit(this.repository) : super(CheckoutState());

  Checkout? _checkout;
  ShippingAddress? _shippingAddress;
  ShippingMethod? _shippingMethod;
  // PaymentMethod? _paymentMethod;
  Order? _order;

  void startCheckout(List<dynamic> lineItems, String? email) async {
    developer.log('CheckoutCubit: startCheckout called with lineItems: ${lineItems.length}, email: $email');
    emit(state.copyWith(status: CheckoutStatus.loading));
    try {
      _checkout = await repository.createCheckoutSession(lineItems: lineItems, email: email);
      developer.log('CheckoutCubit: Checkout session created: ${_checkout?.id}');
      emit(state.copyWith(status: CheckoutStatus.address));
    } catch (e, stack) {
      developer.log('CheckoutCubit: Error in startCheckout', error: e, stackTrace: stack);
      emit(state.copyWith(status: CheckoutStatus.failure, error: e.toString()));
    }
  }
}
