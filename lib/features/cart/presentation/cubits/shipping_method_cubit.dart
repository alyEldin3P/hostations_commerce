import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repository/shipping_repository.dart';
import '../../data/model/shipping_method.dart';
import 'dart:developer';

enum ShippingMethodStatus { initial, loading, success, failure }

class ShippingMethodState {
  final ShippingMethodStatus status;
  final List<ShippingMethod> methods;
  final ShippingMethod? selectedMethod;
  final String? error;

  ShippingMethodState({
    this.status = ShippingMethodStatus.initial,
    this.methods = const [],
    this.selectedMethod,
    this.error,
  });

  ShippingMethodState copyWith({
    ShippingMethodStatus? status,
    List<ShippingMethod>? methods,
    ShippingMethod? selectedMethod,
    String? error,
  }) {
    return ShippingMethodState(
      status: status ?? this.status,
      methods: methods ?? this.methods,
      selectedMethod: selectedMethod ?? this.selectedMethod,
      error: error ?? this.error,
    );
  }
}

class ShippingMethodCubit extends Cubit<ShippingMethodState> {
  final ShippingRepository repository;

  ShippingMethodCubit({required this.repository}) : super(ShippingMethodState());

  Future<void> fetchMethods(String cartId) async {
    log('[ShippingMethodCubit] fetchMethods called with cartId: $cartId');
    emit(state.copyWith(status: ShippingMethodStatus.loading));
    try {
      final methods = await repository.fetchShippingMethods(cartId: cartId);
      log('[ShippingMethodCubit] fetchMethods success: methods.length = ${methods.length}');
      emit(state.copyWith(status: ShippingMethodStatus.success, methods: methods));
    } catch (e, st) {
      log('[ShippingMethodCubit] fetchMethods error: ${e}\n${st}');
      emit(state.copyWith(status: ShippingMethodStatus.failure, error: e.toString()));
    }
  }

  void selectMethod(ShippingMethod method) {
    emit(state.copyWith(selectedMethod: method));
  }

  Future<void> updateCartBuyerIdentity({required String cartId, required Map<String, dynamic> address}) async {
    log('[ShippingMethodCubit] updateCartBuyerIdentity called with cartId: $cartId, address: $address');
    emit(state.copyWith(status: ShippingMethodStatus.loading));
    try {
      await repository.updateCartBuyerIdentity(cartId: cartId, address: address);
      log('[ShippingMethodCubit] updateCartBuyerIdentity success');
      emit(state.copyWith(status: ShippingMethodStatus.success));
    } catch (e, st) {
      log('[ShippingMethodCubit] updateCartBuyerIdentity error: ${e}\n${st}');
      emit(state.copyWith(status: ShippingMethodStatus.failure, error: e.toString()));
    }
  }

  Future<void> addCartDeliveryAddress({required String cartId, required Map<String, dynamic> address}) async {
    log('[ShippingMethodCubit] addCartDeliveryAddress called with cartId: $cartId, address: $address');
    emit(state.copyWith(status: ShippingMethodStatus.loading));
    try {
      await repository.addCartDeliveryAddress(cartId: cartId, address: address);
      log('[ShippingMethodCubit] addCartDeliveryAddress success');
      emit(state.copyWith(status: ShippingMethodStatus.success));
    } catch (e, st) {
      log('[ShippingMethodCubit] addCartDeliveryAddress error: ${e}\n${st}');
      emit(state.copyWith(status: ShippingMethodStatus.failure, error: e.toString()));
    }
  }
}
