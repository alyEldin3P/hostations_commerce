import '../model/order.dart';

abstract class OrdersRemoteDataSource {
  Future<List<Order>> fetchOrders();
  Future<Order> fetchOrderDetails(String orderId);
}
