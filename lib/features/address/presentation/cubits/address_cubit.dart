import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/model/address.dart';
import '../../data/repo/address_repository.dart';
import 'address_state.dart';

class AddressCubit extends Cubit<AddressState> {
  final AddressRepository repository;

  AddressCubit({required this.repository}) : super(AddressState());

  Future<void> fetchAllAddresses(bool isGuest) async {
    emit(state.copyWith(status: AddressStatus.loading));
    try {
      final addresses = await repository.fetchAllAddresses(isGuest);
      log('Addresses: $addresses');
      emit(state.copyWith(status: AddressStatus.success, addresses: addresses));
    } catch (e) {
      emit(state.copyWith(status: AddressStatus.failure, error: e.toString()));
    }
  }

  Future<void> createAddress(Address address, bool isGuest) async {
    emit(state.copyWith(status: AddressStatus.loading));
    try {
      await repository.createAddress(address, isGuest);
      await fetchAllAddresses(isGuest);
    } catch (e) {
      emit(state.copyWith(status: AddressStatus.failure, error: e.toString()));
    }
  }

  Future<void> editAddress(Address address, bool isGuest) async {
    emit(state.copyWith(status: AddressStatus.loading));
    try {
      await repository.editAddress(address, isGuest);
      await fetchAllAddresses(isGuest);
    } catch (e) {
      emit(state.copyWith(status: AddressStatus.failure, error: e.toString()));
    }
  }

  Future<void> deleteAddress(String id, bool isGuest) async {
    emit(state.copyWith(status: AddressStatus.loading));
    try {
      await repository.deleteAddress(id, isGuest);
      await fetchAllAddresses(isGuest);
    } catch (e) {
      emit(state.copyWith(status: AddressStatus.failure, error: e.toString()));
    }
  }

  void selectAddress(Address? address) {
    emit(state.copyWith(selectedAddress: address));
  }
}
