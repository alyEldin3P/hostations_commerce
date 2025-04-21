import 'package:hostations_commerce/core/di/dependency_injection.dart';
import 'package:hostations_commerce/core/services/cache/cache_service.dart';
import 'package:hostations_commerce/features/address/data/model/address.dart';
import 'package:hostations_commerce/features/address/data/model/address_mapper.dart';
import 'package:hostations_commerce/features/cart/domain/models/cart.dart';
import 'package:hostations_commerce/features/cart/domain/models/cart_item.dart';
import 'package:graphql_flutter/graphql_flutter.dart' as graphql;
import 'dart:developer';

abstract class CartRemoteDataSource {
  /// Get the current cart
  Future<Cart> getCart();

  /// Add a product to cart
  /// Returns the updated cart if successful
  Future<Cart> addToCart(String variantId, {int quantity = 1});

  /// Update the quantity of a cart item
  /// Returns the updated cart if successful
  Future<Cart> updateCartItem(String lineId, int quantity);

  /// Remove an item from cart
  /// Returns the updated cart if successful
  Future<Cart> removeFromCart(String lineId);

  /// Clear the entire cart
  /// Returns true if successful
  Future<bool> clearCart();

  /// Create a checkout from the cart
  /// Returns the checkout URL if successful
  Future<String> createCheckout();

  Future<Cart> addAddressToCart({required String cartId, required Address address});
}

class ShopifyCartRemoteDataSource implements CartRemoteDataSource {
  final CacheService _cacheService;
  final graphql.GraphQLClient _graphQLClient;

  // Cache key prefix for cart
  static const String _cartKeyPrefix = 'cart_';
  static const String _cartIdKey = 'cart_id';

  ShopifyCartRemoteDataSource({
    required CacheService cacheService,
    required graphql.GraphQLClient graphQLClient,
  })  : _cacheService = cacheService,
        _graphQLClient = graphQLClient;

  // Get the current user ID or a default for guest users
  Future<String> _getCurrentUserId() async {
    final authCache = DependencyInjector().authCacheService;
    final user = await authCache.getCachedUser();
    return user?.id ?? 'guest_user';
  }

  // Get the cart cache key for the current user
  Future<String> _getCartKey() async {
    final userId = await _getCurrentUserId();
    return '$_cartKeyPrefix$userId';
  }

  // Get the cart ID from cache or create a new one
  Future<String?> _getCartId() async {
    final key = await _getCartKey();
    final cartIdKey = '${key}_$_cartIdKey';
    return _cacheService.getString(cartIdKey);
  }

  // Save the cart ID to cache
  Future<void> _saveCartId(String cartId) async {
    final key = await _getCartKey();
    final cartIdKey = '${key}_$_cartIdKey';
    await _cacheService.setString(cartIdKey, cartId);
  }

  @override
  Future<Cart> getCart() async {
    try {
      // Try to get existing cart ID
      final cartId = await _getCartId();

      if (cartId == null || cartId.isEmpty) {
        // No cart exists yet, create a new one
        return await _createCart();
      }

      // Fetch the cart from Shopify
      final query = '''
        query GetCart(\$cartId: ID!) {
          cart(id: \$cartId) {
            id
            lines(first: 100) {
              edges {
                node {
                  id
                  quantity
                  merchandise {
                    ... on ProductVariant {
                      id
                      title
                      product {
                        id
                        title
                        images(first: 1) {
                          edges {
                            node {
                              url
                            }
                          }
                        }
                      }
                      price {
                        amount
                        currencyCode
                      }
                    }
                  }
                }
              }
            }
            cost {
              subtotalAmount {
                amount
                currencyCode
              }
              totalAmount {
                amount
                currencyCode
              }
              totalTaxAmount {
                amount
                currencyCode
              }
            }
            totalQuantity
            deliveryGroups(first: 10) {
              edges {
                node {
                  id
                  selectedDeliveryOption { handle title }
                }
              }
            }
            delivery {
              addresses {
                id
                oneTimeUse
                selected
                address {
                  ... on CartDeliveryAddress {
                    address1
                    address2
                    city
                    company
                    countryCode
                    firstName
                    lastName
                    phone
                    provinceCode
                    zip
                    name
                    formatted
                    formattedArea
                  }
                }
              }
            }
          }
        }
      ''';

      final result = await _graphQLClient.query(
        graphql.QueryOptions(
          document: graphql.gql(query),
          variables: {
            'cartId': cartId,
          },
          fetchPolicy: graphql.FetchPolicy.networkOnly, // Ensure we always hit the network
        ),
      );
      // Log the raw Shopify response for debugging
      log('Shopify getCart response: \u001b[36m${result.data}\u001b[0m');
      if (result.hasException) {
        log('GraphQL error: ${result.exception.toString()}');
        // If there's an error (like cart not found), create a new cart
        return await _createCart();
      }

      final cartData = result.data?['cart'];
      if (cartData == null) {
        return await _createCart();
      }

      // Parse the cart data
      final items = <CartItem>[];
      final lines = cartData['lines']['edges'];

      for (final line in lines) {
        final node = line['node'];
        final merchandise = node['merchandise'];
        final product = merchandise['product'];
        String? image;

        if (product['images'] != null && product['images']['edges'] != null) {
          final edges = product['images']['edges'];
          if (edges is List && edges.isNotEmpty) {
            image = edges[0]['node']?['url'];
          } else if (edges is Map && edges.containsKey('node')) {
            image = edges['node']?['url'];
          }
        }

        items.add(CartItem(
          id: node['id'],
          variantId: merchandise['id'],
          title: product['title'],
          image: image,
          price: merchandise['price']['amount'],
          currency: merchandise['price']['currencyCode'],
          quantity: node['quantity'],
          variantTitle: merchandise['title'],
        ));
      }

      final cost = cartData['cost'];
      // Parse delivery groups if present
      final deliveryGroupsEdges = cartData['deliveryGroups']?['edges'] as List?;
      List<DeliveryGroup>? deliveryGroups;
      if (deliveryGroupsEdges != null) {
        deliveryGroups = deliveryGroupsEdges.map((e) => DeliveryGroup.fromJson(e['node'])).toList();
      }
      return Cart(
        id: cartData['id'],
        items: items,
        subtotal: cost['subtotalAmount']['amount'],
        total: cost['totalAmount']['amount'],
        currency: cost['subtotalAmount']['currencyCode'],
        itemCount: cartData['totalQuantity'],
        tax: double.tryParse(cost['totalTaxAmount']?['amount'] ?? '0'),
        deliveryGroups: deliveryGroups,
      );
    } catch (e) {
      log('Error getting cart: ${e.toString()}');
      // Return an empty cart in case of error
      return Cart.empty();
    }
  }

  Future<Cart> _createCart() async {
    try {
      final mutation = '''
        mutation CreateCart {
          cartCreate {
            cart {
              id
              totalQuantity
              cost {
                subtotalAmount {
                  amount
                  currencyCode
                }
                totalAmount {
                  amount
                  currencyCode
                }
              }
              deliveryGroups(first: 10) {
                edges {
                  node {
                    id
                    selectedDeliveryOption { handle title }
                  }
                }
              }
            }
          }
        }
      ''';

      final result = await _graphQLClient.mutate(
        graphql.MutationOptions(
          document: graphql.gql(mutation),
        ),
      );

      if (result.hasException) {
        log('GraphQL error creating cart: ${result.exception.toString()}');
        return Cart.empty();
      }

      final cartData = result.data?['cartCreate']?['cart'];
      if (cartData == null) {
        return Cart.empty();
      }

      // Save the cart ID for future use
      await _saveCartId(cartData['id']);

      final cost = cartData['cost'];
      // Parse delivery groups if present
      final deliveryGroupsEdges = cartData['deliveryGroups']?['edges'] as List?;
      List<DeliveryGroup>? deliveryGroups;
      if (deliveryGroupsEdges != null) {
        deliveryGroups = deliveryGroupsEdges.map((e) => DeliveryGroup.fromJson(e['node'])).toList();
      }
      return Cart(
        id: cartData['id'],
        items: [],
        subtotal: cost['subtotalAmount']['amount'],
        total: cost['totalAmount']['amount'],
        currency: cost['subtotalAmount']['currencyCode'],
        itemCount: cartData['totalQuantity'],
        deliveryGroups: deliveryGroups,
      );
    } catch (e) {
      log('Error creating cart: ${e.toString()}');
      return Cart.empty();
    }
  }

  @override
  Future<Cart> addToCart(String variantId, {int quantity = 1}) async {
    try {
      // Get or create cart ID
      String? cartId = await _getCartId();
      if (cartId == null || cartId.isEmpty) {
        final newCart = await _createCart();
        cartId = newCart.id;
      }

      // Add the item to cart
      final mutation = '''
        mutation AddToCart(\$cartId: ID!, \$lines: [CartLineInput!]!) {
          cartLinesAdd(cartId: \$cartId, lines: \$lines) {
            cart {
              id
              lines(first: 100) {
                edges {
                  node {
                    id
                    quantity
                    merchandise {
                      ... on ProductVariant {
                        id
                        title
                        product {
                          id
                          title
                          images(first: 1) {
                            edges {
                              node {
                                url
                              }
                            }
                          }
                        }
                        price {
                          amount
                          currencyCode
                        }
                      }
                    }
                  }
                }
              }
              cost {
                subtotalAmount {
                  amount
                  currencyCode
                }
                totalAmount {
                  amount
                  currencyCode
                }
                totalTaxAmount {
                  amount
                  currencyCode
                }
              }
              totalQuantity
              deliveryGroups(first: 10) {
                edges {
                  node {
                    id
                    selectedDeliveryOption { handle title }
                  }
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

      final result = await _graphQLClient.mutate(
        graphql.MutationOptions(
          document: graphql.gql(mutation),
          variables: {
            'cartId': cartId,
            'lines': [
              {
                'merchandiseId': variantId,
                'quantity': quantity,
              }
            ],
          },
        ),
      );

      if (result.hasException) {
        log('GraphQL error adding to cart: ${result.exception.toString()}');
        return await getCart();
      }

      final userErrors = result.data?['cartLinesAdd']?['userErrors'];
      if (userErrors != null && (userErrors as List).isNotEmpty) {
        log('User errors adding to cart: ${userErrors.toString()}');
        return await getCart();
      }

      final cartData = result.data?['cartLinesAdd']?['cart'];
      if (cartData == null) {
        return await getCart();
      }

      // Parse the cart data
      final items = <CartItem>[];
      final lines = cartData['lines']['edges'];

      for (final line in lines) {
        final node = line['node'];
        final merchandise = node['merchandise'];
        final product = merchandise['product'];
        String? image;
        if (product['images'] != null && product['images']['edges'] != null) {
          final edges = product['images']['edges'];
          if (edges is List && edges.isNotEmpty) {
            image = edges[0]['node']?['url'];
          } else if (edges is Map && edges.containsKey('node')) {
            image = edges['node']?['url'];
          }
        }

        items.add(CartItem(
          id: node['id'],
          variantId: merchandise['id'],
          title: product['title'],
          image: image,
          price: merchandise['price']['amount'],
          currency: merchandise['price']['currencyCode'],
          quantity: node['quantity'],
          variantTitle: merchandise['title'],
        ));
      }

      final cost = cartData['cost'];
      // Parse delivery groups if present
      final deliveryGroupsEdges = cartData['deliveryGroups']?['edges'] as List?;
      List<DeliveryGroup>? deliveryGroups;
      if (deliveryGroupsEdges != null) {
        deliveryGroups = deliveryGroupsEdges.map((e) => DeliveryGroup.fromJson(e['node'])).toList();
      }
      return Cart(
        id: cartData['id'],
        items: items,
        subtotal: cost['subtotalAmount']['amount'],
        total: cost['totalAmount']['amount'],
        currency: cost['subtotalAmount']['currencyCode'],
        itemCount: cartData['totalQuantity'],
        tax: double.tryParse(cost['totalTaxAmount']?['amount'] ?? '0'),
        deliveryGroups: deliveryGroups,
      );
    } catch (e) {
      log('Error adding to cart: ${e.toString()}');
      return await getCart();
    }
  }

  @override
  Future<Cart> updateCartItem(String lineId, int quantity) async {
    try {
      // Get cart ID
      final cartId = await _getCartId();
      if (cartId == null || cartId.isEmpty) {
        return Cart.empty();
      }

      // Update the item quantity
      final mutation = '''
        mutation UpdateCartItem(\$cartId: ID!, \$lines: [CartLineUpdateInput!]!) {
          cartLinesUpdate(cartId: \$cartId, lines: \$lines) {
            cart {
              id
              lines(first: 100) {
                edges {
                  node {
                    id
                    quantity
                    merchandise {
                      ... on ProductVariant {
                        id
                        title
                        product {
                          id
                          title
                          images(first: 1) {
                            edges {
                              node {
                                url
                              }
                            }
                          }
                        }
                        price {
                          amount
                          currencyCode
                        }
                      }
                    }
                  }
                }
              }
              cost {
                subtotalAmount {
                  amount
                  currencyCode
                }
                totalAmount {
                  amount
                  currencyCode
                }
                totalTaxAmount {
                  amount
                  currencyCode
                }
              }
              totalQuantity
              deliveryGroups(first: 10) {
                edges {
                  node {
                    id
                    selectedDeliveryOption { handle title }
                  }
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

      final result = await _graphQLClient.mutate(
        graphql.MutationOptions(
          document: graphql.gql(mutation),
          variables: {
            'cartId': cartId,
            'lines': [
              {
                'id': lineId,
                'quantity': quantity,
              }
            ],
          },
        ),
      );

      if (result.hasException) {
        log('GraphQL error updating cart item: ${result.exception.toString()}');
        return await getCart();
      }

      final userErrors = result.data?['cartLinesUpdate']?['userErrors'];
      if (userErrors != null && (userErrors as List).isNotEmpty) {
        log('User errors updating cart item: ${userErrors.toString()}');
        return await getCart();
      }

      final cartData = result.data?['cartLinesUpdate']?['cart'];
      if (cartData == null) {
        return await getCart();
      }

      // Parse the cart data
      final items = <CartItem>[];
      final lines = cartData['lines']['edges'];

      for (final line in lines) {
        final node = line['node'];
        final merchandise = node['merchandise'];
        final product = merchandise['product'];
        String? image;
        if (product['images'] != null && product['images']['edges'] != null) {
          final edges = product['images']['edges'];
          if (edges is List && edges.isNotEmpty) {
            image = edges[0]['node']?['url'];
          } else if (edges is Map && edges.containsKey('node')) {
            image = edges['node']?['url'];
          }
        }

        items.add(CartItem(
          id: node['id'],
          variantId: merchandise['id'],
          title: product['title'],
          image: image,
          price: merchandise['price']['amount'],
          currency: merchandise['price']['currencyCode'],
          quantity: node['quantity'],
          variantTitle: merchandise['title'],
        ));
      }

      final cost = cartData['cost'];
      // Parse delivery groups if present
      final deliveryGroupsEdges = cartData['deliveryGroups']?['edges'] as List?;
      List<DeliveryGroup>? deliveryGroups;
      if (deliveryGroupsEdges != null) {
        deliveryGroups = deliveryGroupsEdges.map((e) => DeliveryGroup.fromJson(e['node'])).toList();
      }
      return Cart(
        id: cartData['id'],
        items: items,
        subtotal: cost['subtotalAmount']['amount'],
        total: cost['totalAmount']['amount'],
        currency: cost['subtotalAmount']['currencyCode'],
        itemCount: cartData['totalQuantity'],
        tax: double.tryParse(cost['totalTaxAmount']?['amount'] ?? '0'),
        deliveryGroups: deliveryGroups,
      );
    } catch (e) {
      log('Error updating cart item: ${e.toString()}');
      return await getCart();
    }
  }

  @override
  Future<Cart> removeFromCart(String lineId) async {
    try {
      // Get cart ID
      final cartId = await _getCartId();
      if (cartId == null || cartId.isEmpty) {
        return Cart.empty();
      }

      // Remove the item from cart
      final mutation = '''
        mutation RemoveFromCart(\$cartId: ID!, \$lineIds: [ID!]!) {
          cartLinesRemove(cartId: \$cartId, lineIds: \$lineIds) {
            cart {
              id
              lines(first: 100) {
                edges {
                  node {
                    id
                    quantity
                    merchandise {
                      ... on ProductVariant {
                        id
                        title
                        product {
                          id
                          title
                          images(first: 1) {
                            edges {
                              node {
                                url
                              }
                            }
                          }
                        }
                        price {
                          amount
                          currencyCode
                        }
                      }
                    }
                  }
                }
              }
              cost {
                subtotalAmount {
                  amount
                  currencyCode
                }
                totalAmount {
                  amount
                  currencyCode
                }
                totalTaxAmount {
                  amount
                  currencyCode
                }
              }
              totalQuantity
              deliveryGroups(first: 10) {
                edges {
                  node {
                    id
                    selectedDeliveryOption { handle title }
                  }
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

      final result = await _graphQLClient.mutate(
        graphql.MutationOptions(
          document: graphql.gql(mutation),
          variables: {
            'cartId': cartId,
            'lineIds': [lineId],
          },
        ),
      );

      if (result.hasException) {
        log('GraphQL error removing from cart: ${result.exception.toString()}');
        return await getCart();
      }

      final userErrors = result.data?['cartLinesRemove']?['userErrors'];
      if (userErrors != null && (userErrors as List).isNotEmpty) {
        log('User errors removing from cart: ${userErrors.toString()}');
        return await getCart();
      }

      final cartData = result.data?['cartLinesRemove']?['cart'];
      if (cartData == null) {
        return await getCart();
      }

      // Parse the cart data
      final items = <CartItem>[];
      final lines = cartData['lines']['edges'];

      for (final line in lines) {
        final node = line['node'];
        final merchandise = node['merchandise'];
        final product = merchandise['product'];
        String? image;
        if (product['images'] != null && product['images']['edges'] != null) {
          final edges = product['images']['edges'];
          if (edges is List && edges.isNotEmpty) {
            image = edges[0]['node']?['url'];
          } else if (edges is Map && edges.containsKey('node')) {
            image = edges['node']?['url'];
          }
        }

        items.add(CartItem(
          id: node['id'],
          variantId: merchandise['id'],
          title: product['title'],
          image: image,
          price: merchandise['price']['amount'],
          currency: merchandise['price']['currencyCode'],
          quantity: node['quantity'],
          variantTitle: merchandise['title'],
        ));
      }

      final cost = cartData['cost'];
      // Parse delivery groups if present
      final deliveryGroupsEdges = cartData['deliveryGroups']?['edges'] as List?;
      List<DeliveryGroup>? deliveryGroups;
      if (deliveryGroupsEdges != null) {
        deliveryGroups = deliveryGroupsEdges.map((e) => DeliveryGroup.fromJson(e['node'])).toList();
      }
      return Cart(
        id: cartData['id'],
        items: items,
        subtotal: cost['subtotalAmount']['amount'],
        total: cost['totalAmount']['amount'],
        currency: cost['subtotalAmount']['currencyCode'],
        itemCount: cartData['totalQuantity'],
        tax: double.tryParse(cost['totalTaxAmount']?['amount'] ?? '0'),
        deliveryGroups: deliveryGroups,
      );
    } catch (e) {
      log('Error removing from cart: ${e.toString()}');
      return await getCart();
    }
  }

  @override
  Future<bool> clearCart() async {
    try {
      // Create a new cart to replace the old one
      final newCart = await _createCart();
      return newCart.id.isNotEmpty;
    } catch (e) {
      log('Error clearing cart: ${e.toString()}');
      return false;
    }
  }

  @override
  Future<String> createCheckout() async {
    try {
      // Get cart ID
      final cartId = await _getCartId();
      if (cartId == null || cartId.isEmpty) {
        return '';
      }

      // Create a checkout from the cart
      final mutation = '''
        mutation CreateCheckout(\$cartId: ID!) {
          checkoutCreateFromCart(cartId: \$cartId) {
            checkout {
              id
              webUrl
            }
            checkoutUserErrors {
              field
              message
            }
          }
        }
      ''';

      final result = await _graphQLClient.mutate(
        graphql.MutationOptions(
          document: graphql.gql(mutation),
          variables: {
            'cartId': cartId,
          },
        ),
      );

      if (result.hasException) {
        log('GraphQL error creating checkout: ${result.exception.toString()}');
        return '';
      }

      final userErrors = result.data?['checkoutCreateFromCart']?['checkoutUserErrors'];
      if (userErrors != null && (userErrors as List).isNotEmpty) {
        log('User errors creating checkout: ${userErrors.toString()}');
        return '';
      }

      final checkout = result.data?['checkoutCreateFromCart']?['checkout'];
      if (checkout == null) {
        return '';
      }

      return checkout['webUrl'];
    } catch (e) {
      log('Error creating checkout: ${e.toString()}');
      return '';
    }
  }

  @override
  Future<Cart> addAddressToCart({required String cartId, required Address address}) async {
    // Build CartDeliveryAddressInput for Shopify 2025 API

    final addressInput = toCartDeliveryAddressInput(address);
    const mutation = r'''
      mutation cartDeliveryAddressesAdd(
        $cartId: ID!,
        $addresses: [CartSelectableAddressInput!]!
      ) {
        cartDeliveryAddressesAdd(cartId: $cartId, addresses: $addresses) {
          cart {
            id
            delivery {
              addresses {
                id
                oneTimeUse
                selected
                address {
                  ... on CartDeliveryAddress {
                    address1
                    address2
                    city
                    countryCode
                    firstName
                    lastName
                    phone
                    provinceCode
                    zip
                    name
                  }
                }
        
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

    final result = await _graphQLClient.mutate(
      graphql.MutationOptions(
        document: graphql.gql(mutation),
        variables: {
          'cartId': cartId,
          'addresses': [
            {
              'address': {
                "deliveryAddress": addressInput,
              },
              'selected': true,
            }
          ],
        },
      ),
    );

    final userErrors = result.data?['cartDeliveryAddressesAdd']?['userErrors'] as List?;
    if (userErrors != null && userErrors.isNotEmpty) {
      log('[CartRemoteDataSource] cartDeliveryAddressesAdd userErrors: \\${userErrors.map((e) => e['message']).join(', ')}');
      throw Exception(userErrors.map((e) => e['message']).join(', '));
    }

    log('[CartRemoteDataSource] cartDeliveryAddressesAdd success with data: ${result}');
    final cartData = result.data?['cartDeliveryAddressesAdd']?['cart'];

    if (cartData == null) {
      throw Exception('No cart returned from cartDeliveryAddressesAdd');
    }
    log('[CartRemoteDataSource] cartDeliveryAddressesAdd success with cart: ${cartData}');
    return Cart.fromJson(cartData);
  }
}
