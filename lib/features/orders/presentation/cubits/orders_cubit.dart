import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hostations_commerce/features/orders/data/model/order.dart';
import 'package:hostations_commerce/features/orders/data/repo/orders_repository.dart';

import 'orders_state.dart';

class OrdersCubit extends Cubit<OrdersState> {
  final OrdersRepository ordersRepository;
  OrdersCubit({required this.ordersRepository}) : super(OrdersState());

  Future<void> fetchOrders() async {
    emit(state.copyWith(status: OrdersStatus.loading, error: null));
    try {
      List<Order>? orders = await ordersRepository.fetchOrders();
      emit(state.copyWith(status: OrdersStatus.loaded, orders: orders));
    } catch (e) {
      emit(state.copyWith(status: OrdersStatus.failure, error: e.toString()));
    }
  }
}
