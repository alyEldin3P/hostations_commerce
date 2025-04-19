enum CheckoutStatus { initial, address, shipping, preview, payment, status, loading, success, failure }

class CheckoutState {
  final CheckoutStatus status;
  final String? error;

  CheckoutState({this.status = CheckoutStatus.initial, this.error});

  CheckoutState copyWith({CheckoutStatus? status, String? error}) {
    return CheckoutState(
      status: status ?? this.status,
      error: error,
    );
  }
}
