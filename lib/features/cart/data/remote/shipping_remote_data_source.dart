import 'package:graphql/client.dart';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import '../model/shipping_method.dart';

abstract class ShippingRemoteDataSource {
  Future<List<ShippingMethod>> fetchShippingMethods({required String cartId});
  Future<void> setShippingMethod({required String cartId, required String deliveryGroupId, required String shippingHandle});
  Future<void> updateCartBuyerIdentity({required String cartId, required Map<String, dynamic> address});
  Future<void> addCartDeliveryAddress({required String cartId, required Map<String, dynamic> address});
}

class ShopifyShippingRemoteDataSource implements ShippingRemoteDataSource {
  final GraphQLClient client;

  ShopifyShippingRemoteDataSource({required this.client});

  @override
  Future<List<ShippingMethod>> fetchShippingMethods({required String cartId}) async {
    log('[ShippingRemoteDataSource] fetchShippingMethods called with cartId: $cartId');
    const query = r'''
      query GetCartShippingMethods($cartId: ID!) {
        cart(id: $cartId) {
          deliveryGroups(first: 10) {
            edges {
              node {
                id
                deliveryOptions {
                  handle
                  title
                  description
                  estimatedCost {
                    amount
                    currencyCode
                  }
                }
              }
            }
          }
        }
      }
    ''';
    final result = await client.query(
      QueryOptions(
        document: gql(query),
        variables: {'cartId': cartId},
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );
    if (result.hasException) {
      log('[ShippingRemoteDataSource] fetchShippingMethods error: ${result.exception}');
      throw Exception(result.exception.toString());
    }
    final deliveryGroups = result.data?['cart']?['deliveryGroups']?['edges'] as List?;
    log('[ShippingRemoteDataSource] fetchShippingMethods deliveryGroups: ${deliveryGroups?.length}');
    if (deliveryGroups == null || deliveryGroups.isEmpty) return [];
    final firstGroup = deliveryGroups.first['node'];
    log('[ShippingRemoteDataSource] fetchShippingMethods firstGroup: ${firstGroup != null ? firstGroup['id'] : 'null'}');
    final options = firstGroup?['deliveryOptions'] as List?;
    log('[ShippingRemoteDataSource] fetchShippingMethods options: ${options?.length}');
    if (options == null) return [];
    return options.map((option) => ShippingMethod.fromJson(option)).toList();
  }

  @override
  Future<void> setShippingMethod({required String cartId, required String deliveryGroupId, required String shippingHandle}) async {
    log('[ShippingRemoteDataSource] setShippingMethod called with cartId: $cartId, deliveryGroupId: $deliveryGroupId, shippingHandle: $shippingHandle');
    const mutation = r'''
      mutation SetShippingMethod($cartId: ID!, $deliveryGroupId: ID!, $handle: String!) {
        cartDeliveryGroupUpdate(
          cartId: $cartId,
          deliveryGroupId: $deliveryGroupId,
          selectedDeliveryOptionHandle: $handle
        ) {
          cart {
            id
            deliveryGroups {
              id
              selectedDeliveryOption {
                handle
                title
              }
            }
          }
          userErrors {
            field
            message
          }
        }
      }
    ''';
    final result = await client.mutate(
      MutationOptions(
        document: gql(mutation),
        variables: {
          'cartId': cartId,
          'deliveryGroupId': deliveryGroupId,
          'handle': shippingHandle,
        },
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );
    if (result.hasException) {
      log('[ShippingRemoteDataSource] setShippingMethod error: ${result.exception}');
      throw Exception(result.exception.toString());
    }
    final userErrors = result.data?['cartDeliveryGroupUpdate']?['userErrors'] as List?;
    if (userErrors != null && userErrors.isNotEmpty) {
      log('[ShippingRemoteDataSource] setShippingMethod userErrors: ${userErrors.map((e) => e['message']).join(', ')}');
      throw Exception(userErrors.map((e) => e['message']).join(', '));
    }
    log('[ShippingRemoteDataSource] setShippingMethod success');
  }

  @override
  Future<void> updateCartBuyerIdentity({required String cartId, required Map<String, dynamic> address}) async {
    log('[ShippingRemoteDataSource] updateCartBuyerIdentity called with cartId: $cartId, address: $address');
    const mutation = r'''
      mutation cartBuyerIdentityUpdate(
        $cartId: ID!,
        $buyerIdentity: CartBuyerIdentityInput!
      ) {
        cartBuyerIdentityUpdate(cartId: $cartId, buyerIdentity: $buyerIdentity) {
          cart {
            id
          }
          userErrors {
            field
            message
          }
        }
      }
    ''';
    final result = await client.mutate(
      MutationOptions(
        document: gql(mutation),
        variables: {'cartId': cartId, 'buyerIdentity': address},
      ),
    );
    if (result.hasException) {
      log('[ShippingRemoteDataSource] updateCartBuyerIdentity error: ${result.exception}');
      throw Exception(result.exception.toString());
    }
    final userErrors = result.data?['cartBuyerIdentityUpdate']?['userErrors'] as List?;
    if (userErrors != null && userErrors.isNotEmpty) {
      log('[ShippingRemoteDataSource] updateCartBuyerIdentity userErrors: ${userErrors.map((e) => e['message']).join(', ')}');
      throw Exception(userErrors.map((e) => e['message']).join(', '));
    }
    log('[ShippingRemoteDataSource] updateCartBuyerIdentity success');
  }

  @override
  Future<void> addCartDeliveryAddress({required String cartId, required Map<String, dynamic> address}) async {
    log('[ShippingRemoteDataSource] addCartDeliveryAddress called with cartId: $cartId, address: $address');
    const mutation = r'''
      mutation cartDeliveryAddressesAdd(
        $addresses: [CartSelectableAddressInput!]!,
        $cartId: ID!
      ) {
        cartDeliveryAddressesAdd(addresses: $addresses, cartId: $cartId) {
          cart {
            id
            deliveryGroups(first: 10) {
              edges {
                node {
                  id
                  deliveryOptions {
                    handle
                    title
                    description
                    estimatedCost {
                      amount
                      currencyCode
                    }
                  }
                }
              }
            }
          }
          userErrors {
            field
            message
          }
          warnings {
            code
            message
          }
        }
      }
    ''';
    final variables = {
      'cartId': cartId,
      'addresses': [address],
    };
    final result = await client.mutate(
      MutationOptions(
        document: gql(mutation),
        variables: variables,
      ),
    );
    if (result.hasException) {
      log('[ShippingRemoteDataSource] addCartDeliveryAddress error: ${result.exception}');
      throw Exception(result.exception.toString());
    }
    final userErrors = result.data?['cartDeliveryAddressesAdd']?['userErrors'] as List?;
    if (userErrors != null && userErrors.isNotEmpty) {
      log('[ShippingRemoteDataSource] addCartDeliveryAddress userErrors: ${userErrors.map((e) => e['message']).join(', ')}');
      throw Exception(userErrors.map((e) => e['message']).join(', '));
    }
    log('[ShippingRemoteDataSource] addCartDeliveryAddress success');
  }
}
