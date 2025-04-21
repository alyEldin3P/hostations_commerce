import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:hostations_commerce/core/services/network/network_service_impl.dart';

import '../model/checkout.dart';
import 'checkout_remote_data_source.dart';

class CheckoutRemoteDataSourceImpl implements CheckoutRemoteDataSource {
  final NetworkService networkService;
  static const String _shopifyEndpoint = 'https://fabrictaleseg.myshopify.com/api/2023-07/graphql.json';
  static const String _storefrontToken = 'f17fa5ccf6e78f0807aacf37875f2b4f';

  CheckoutRemoteDataSourceImpl({required this.networkService});

  @override
  Future<Checkout> createCheckoutSession({
    required List<dynamic> lineItems,
    required String? email,
  }) async {
    const String mutation = r'''
      mutation cartCreate(
        $input: CartInput!
      ) {
        cartCreate(input: $input) {
          cart {
            id
            checkoutUrl
            lines(first: 10) {
              edges {
                node {
                  id
                  quantity
                  merchandise {
                    ... on ProductVariant {
                      id
                    }
                  }
                }
              }
            }
          }
          userErrors { field message }
        }
      }
    ''';

    final Map<String, dynamic> variables = {
      'input': {
        'lines': lineItems
            .map((item) => {
                  'merchandiseId': item['variantId'],
                  'quantity': item['quantity'],
                })
            .toList(),
        if (email != null) 'buyerIdentity': {'email': email},
      },
    };

    log('[Shopify] Creating cart with variables: ' + variables.toString());
    try {
      final response = await networkService.post(
        _shopifyEndpoint,
        data: {
          'query': mutation,
          'variables': variables,
        },
        options: Options(headers: {
          'X-Shopify-Storefront-Access-Token': _storefrontToken,
          'Content-Type': 'application/json',
        }),
      );
      log('[Shopify] cartCreate response: ' + response.data.toString());
      final data = response.data['data']?['cartCreate'];
      if (data == null || data['cart'] == null) {
        throw Exception('Shopify cartCreate failed: ' + (data['userErrors']?.toString() ?? 'Unknown error'));
      }
      final cart = data['cart'];
      return Checkout(
        id: cart['id'] as String,
        checkoutUrl: cart['checkoutUrl'] as String,
        lineItems: (cart['lines']['edges'] as List).map((e) => e['node']).toList(),
      );
    } catch (e) {
      log('[Shopify] Error creating cart: $e');
      rethrow;
    }
  }
}
