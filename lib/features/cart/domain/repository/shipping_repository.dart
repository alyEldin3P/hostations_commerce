import '../../data/model/shipping_method.dart';

abstract class ShippingRepository {
  Future<List<ShippingMethod>> fetchShippingMethods({required String cartId});
  Future<void> setShippingMethod({required String cartId, required String deliveryGroupId, required String shippingHandle});
  Future<void> updateCartBuyerIdentity({required String cartId, required Map<String, dynamic> address});
  Future<void> addCartDeliveryAddress({required String cartId, required Map<String, dynamic> address});
}
