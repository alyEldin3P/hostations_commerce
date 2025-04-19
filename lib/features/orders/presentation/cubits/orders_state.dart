enum OrdersStatus { initial, loading, loaded, failure }

class OrdersState {
  final OrdersStatus status;
  final String? error;

  OrdersState({this.status = OrdersStatus.initial, this.error});

  OrdersState copyWith({OrdersStatus? status, String? error}) {
    return OrdersState(
      status: status ?? this.status,
      error: error,
    );
  }
}
