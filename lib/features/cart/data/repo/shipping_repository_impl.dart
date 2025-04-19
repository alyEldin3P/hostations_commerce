import 'dart:developer';

import 'package:flutter/foundation.dart';
import '../../domain/repository/shipping_repository.dart';
import '../remote/shipping_remote_data_source.dart';
import '../model/shipping_method.dart';

class ShippingRepositoryImpl implements ShippingRepository {
  final ShippingRemoteDataSource remoteDataSource;

  ShippingRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<ShippingMethod>> fetchShippingMethods({required String cartId}) {
    return remoteDataSource.fetchShippingMethods(cartId: cartId);
  }

  @override
  Future<void> setShippingMethod({required String cartId, required String deliveryGroupId, required String shippingHandle}) {
    log('[ShippingRepositoryImpl] setShippingMethod: cartId=$cartId, deliveryGroupId=$deliveryGroupId, shippingHandle=$shippingHandle');
    return remoteDataSource.setShippingMethod(cartId: cartId, deliveryGroupId: deliveryGroupId, shippingHandle: shippingHandle);
  }

  @override
  Future<void> updateCartBuyerIdentity({required String cartId, required Map<String, dynamic> address}) {
    log('[ShippingRepositoryImpl] updateCartBuyerIdentity: cartId=$cartId, address=$address');
    return remoteDataSource.updateCartBuyerIdentity(cartId: cartId, address: address);
  }

  @override
  Future<void> addCartDeliveryAddress({required String cartId, required Map<String, dynamic> address}) {
    log('[ShippingRepositoryImpl] addCartDeliveryAddress: cartId=$cartId, address=$address');
    return remoteDataSource.addCartDeliveryAddress(cartId: cartId, address: address);
  }
}
