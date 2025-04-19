import 'dart:developer' as developer;
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
  PaymentMethod? _paymentMethod;
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

  void submitShippingAddress(ShippingAddress address) async {
    developer.log('CheckoutCubit: submitShippingAddress called with address: ${address.toJson()}');
    emit(state.copyWith(status: CheckoutStatus.loading));
    try {
      _shippingAddress = address;
      _checkout = await repository.updateShippingAddress(checkoutId: _checkout!.id, address: address);
      developer.log('CheckoutCubit: Shipping address updated for checkoutId: ${_checkout?.id}');
      emit(state.copyWith(status: CheckoutStatus.shipping));
    } catch (e, stack) {
      developer.log('CheckoutCubit: Error in submitShippingAddress', error: e, stackTrace: stack);
      emit(state.copyWith(status: CheckoutStatus.failure, error: e.toString()));
    }
  }

  void selectShippingMethod(ShippingMethod method) async {
    developer.log('CheckoutCubit: selectShippingMethod called with method: ${method.id}');
    emit(state.copyWith(status: CheckoutStatus.loading));
    try {
      _shippingMethod = method;
      _checkout = await repository.selectShippingMethod(
        checkoutId: _checkout!.id,
        shippingRateHandle: method.id,
      );
      developer.log('CheckoutCubit: Shipping method selected: ${method.id}');
      emit(state.copyWith(status: CheckoutStatus.payment));
    } catch (e, stack) {
      developer.log('CheckoutCubit: Error in selectShippingMethod', error: e, stackTrace: stack);
      emit(state.copyWith(status: CheckoutStatus.failure, error: e.toString()));
    }
  }

  void submitPayment(String paymentToken) async {
    developer.log('CheckoutCubit: submitPayment called with paymentToken: $paymentToken');
    emit(state.copyWith(status: CheckoutStatus.loading));
    try {
      _order = await repository.completeCheckout(
        checkoutId: _checkout!.id,
        paymentToken: paymentToken,
      );
      developer.log('CheckoutCubit: Payment submitted, orderId: ${_order?.id}');
      emit(state.copyWith(status: CheckoutStatus.success));
    } catch (e, stack) {
      developer.log('CheckoutCubit: Error in submitPayment', error: e, stackTrace: stack);
      emit(state.copyWith(status: CheckoutStatus.failure, error: e.toString()));
    }
  }

  void goToAddress() {
    developer.log('CheckoutCubit: goToAddress called');
    emit(state.copyWith(status: CheckoutStatus.address));
  }
  void goToShipping() {
    developer.log('CheckoutCubit: goToShipping called');
    emit(state.copyWith(status: CheckoutStatus.shipping));
  }
  void goToPreview() {
    developer.log('CheckoutCubit: goToPreview called');
    emit(state.copyWith(status: CheckoutStatus.preview));
  }
  void goToPayment() {
    developer.log('CheckoutCubit: goToPayment called');
    emit(state.copyWith(status: CheckoutStatus.payment));
  }
  void goToStatus({bool success = true, String? error}) {
    developer.log('CheckoutCubit: goToStatus called, success: $success, error: $error');
    emit(state.copyWith(
      status: success ? CheckoutStatus.success : CheckoutStatus.failure,
      error: error,
    ));
  }
}
