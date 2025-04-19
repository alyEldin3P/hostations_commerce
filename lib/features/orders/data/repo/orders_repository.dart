import '../model/order.dart';

abstract class OrdersRepository {
  Future<List<Order>> fetchOrders();
  Future<Order> fetchOrderDetails(String orderId);
}
