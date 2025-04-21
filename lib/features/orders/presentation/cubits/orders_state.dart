import 'package:hostations_commerce/features/checkout/data/model/order.dart';
import 'package:hostations_commerce/features/orders/data/model/order.dart';

enum OrdersStatus { initial, loading, loaded, failure }

class OrdersState {
  final OrdersStatus status;
  final List<Order> orders;
  final String? error;

  OrdersState({
    this.status = OrdersStatus.initial,
    this.orders = const [],
    this.error,
  });

  OrdersState copyWith({OrdersStatus? status, List<Order>? orders, String? error}) {
    return OrdersState(
      status: status ?? this.status,
      orders: orders ?? this.orders,
      error: error,
    );
  }
}
