import 'package:hostations_commerce/features/checkout/data/model/checkout.dart';

import '../remote/checkout_remote_data_source.dart';
import 'checkout_repository.dart';

class CheckoutRepositoryImpl implements CheckoutRepository {
  final CheckoutRemoteDataSource remoteDataSource;

  CheckoutRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Checkout> createCheckoutSession({
    required List<dynamic> lineItems,
    required String? email,
  }) =>
      remoteDataSource.createCheckoutSession(lineItems: lineItems, email: email);
}
