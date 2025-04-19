// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/foundation.dart';

import '../../data/model/address.dart';

enum AddressStatus { initial, loading, success, failure }

class AddressState {
  final List<Address> addresses;
  final AddressStatus status;
  final String? error;
  final Address? selectedAddress;

  AddressState({
    this.addresses = const [],
    this.status = AddressStatus.initial,
    this.error,
    this.selectedAddress,
  });

  AddressState copyWith({
    List<Address>? addresses,
    AddressStatus? status,
    String? error,
    Address? selectedAddress,
  }) {
    return AddressState(
      addresses: addresses ?? this.addresses,
      status: status ?? this.status,
      error: error,
      selectedAddress: selectedAddress ?? this.selectedAddress,
    );
  }

  @override
  bool operator ==(covariant AddressState other) {
    if (identical(this, other)) return true;

    return listEquals(other.addresses, addresses) && other.status == status && other.error == error && other.selectedAddress == selectedAddress;
  }

  @override
  int get hashCode {
    return addresses.hashCode ^ status.hashCode ^ error.hashCode ^ selectedAddress.hashCode;
  }
}
