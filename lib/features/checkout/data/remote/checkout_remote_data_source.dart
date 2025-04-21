import '../model/checkout.dart';

abstract class CheckoutRemoteDataSource {
  Future<Checkout> createCheckoutSession({
    required List<dynamic> lineItems,
    required String? email,
  });
}
