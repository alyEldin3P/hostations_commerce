import '../model/order.dart';
import '../model/shipping_method.dart';
import '../model/payment_method.dart';

abstract class CheckoutLocalDataSource {
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
}
