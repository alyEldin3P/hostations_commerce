import '../model/order.dart';

abstract class OrdersLocalDataSource {
  Future<List<Order>> fetchOrders();
  Future<Order> fetchOrderDetails(String orderId);
}
