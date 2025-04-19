import '../model/order.dart';
import '../model/shipping_method.dart';
import '../model/payment_method.dart';
import '../model/checkout.dart';
import '../model/shipping_address.dart';

abstract class CheckoutRemoteDataSource {
  Future<List<ShippingMethod>> fetchShippingMethods();
  Future<Order> createOrder({
    required String addressId,
    required String shippingMethodId,
    String? coupon,
    String? notes,
    required String paymentMethodId,
  });
  Future<List<PaymentMethod>> fetchPaymentMethods();
  Future<Order> fetchOrderStatus(String orderId);

  Future<Checkout> createCheckoutSession({
    required List<dynamic> lineItems,
    required String? email,
  });

  Future<Checkout> updateShippingAddress({
    required String checkoutId,
    required ShippingAddress address,
  });

  Future<List<ShippingMethod>> fetchShippingRates({
    required String checkoutId,
  });

  Future<Checkout> selectShippingMethod({
    required String checkoutId,
    required String shippingRateHandle,
  });

  Future<Order> completeCheckout({
    required String checkoutId,
    required String paymentToken, // Or payment session id
  });
}
