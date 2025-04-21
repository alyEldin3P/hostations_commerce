import '../model/order.dart';
import '../remote/orders_remote_data_source.dart';
import 'orders_repository.dart';

class OrdersRepositoryImpl implements OrdersRepository {
  final OrdersRemoteDataSource remoteDataSource;

  OrdersRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<List<Order>> fetchOrders() async {
    return await remoteDataSource.fetchOrders();
  }

  @override
  Future<Order> fetchOrderDetails(String orderId) async {
    return await remoteDataSource.fetchOrderDetails(orderId);
  }
}
