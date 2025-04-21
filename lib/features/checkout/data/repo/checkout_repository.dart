import '../model/order.dart';
import '../model/shipping_method.dart';
import '../model/payment_method.dart';
import '../model/checkout.dart';
import '../model/shipping_address.dart';

abstract class CheckoutRepository {
  Future<Checkout> createCheckoutSession({
    required List<dynamic> lineItems,
    required String? email,
  });
}
