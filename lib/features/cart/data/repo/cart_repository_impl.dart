import 'dart:convert';
import 'dart:developer' as dev;

import 'package:hostations_commerce/core/error/exceptions.dart';
import 'package:hostations_commerce/core/network/network_info.dart';
import 'package:hostations_commerce/core/services/cache/cache_service.dart';
import 'package:hostations_commerce/features/address/data/model/address.dart';
import 'package:hostations_commerce/features/cart/data/remote/cart_remote_data_source.dart';
import 'package:hostations_commerce/features/cart/domain/models/cart.dart';
import 'package:hostations_commerce/features/cart/domain/repository/cart_repository.dart';
import 'package:hostations_commerce/features/cart/domain/models/address.dart';

class CartRepositoryImpl implements CartRepository {
  final CartRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  final CacheService cacheService;

  // Cache keys
  static const String _cartCacheKey = 'cart_data';

  CartRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
    required this.cacheService,
  });

  @override
  Future<Cart> getCart() async {
    if (await networkInfo.isConnected) {
      try {
        final remoteCart = await remoteDataSource.getCart();
        dev.log('Retrieved cart from remote source');

        // Cache the result
        _cacheCart(remoteCart);

        return remoteCart;
      } on ServerException catch (e) {
        dev.log('Server exception when getting cart: ${e.message}');
        // Fallback to cached data
        dev.log('Falling back to cached cart data');
        return _getCachedCart();
      } catch (e) {
        dev.log('Error getting cart: $e');
        // Fallback to cached data
        dev.log('Falling back to cached cart data');
        return _getCachedCart();
      }
    } else {
      // No internet connection, use cached data
      dev.log('No internet connection, using cached cart');
      return _getCachedCart();
    }
  }

  @override
  Future<Cart> addToCart(String variantId, {int quantity = 1}) async {
    if (await networkInfo.isConnected) {
      try {
        final updatedCart = await remoteDataSource.addToCart(variantId, quantity: quantity);
        dev.log('Added item to cart from remote source');

        // Cache the updated cart
        _cacheCart(updatedCart);

        return updatedCart;
      } catch (e) {
        dev.log('Error adding to cart: $e');

        // Return the current cart in case of error
        return await getCart();
      }
    } else {
      // No internet connection
      dev.log('No internet connection, cannot add to cart');
      return await getCart();
    }
  }

  @override
  Future<Cart> updateCartItem(String lineId, int quantity) async {
    if (await networkInfo.isConnected) {
      try {
        final updatedCart = await remoteDataSource.updateCartItem(lineId, quantity);
        dev.log('Updated cart item from remote source');

        // Cache the updated cart
        _cacheCart(updatedCart);

        return updatedCart;
      } catch (e) {
        dev.log('Error updating cart item: $e');

        // Return the current cart in case of error
        return await getCart();
      }
    } else {
      // No internet connection
      dev.log('No internet connection, cannot update cart item');
      return await getCart();
    }
  }

  @override
  Future<Cart> removeFromCart(String lineId) async {
    if (await networkInfo.isConnected) {
      try {
        final updatedCart = await remoteDataSource.removeFromCart(lineId);
        dev.log('Removed item from cart from remote source');

        // Cache the updated cart
        _cacheCart(updatedCart);

        return updatedCart;
      } catch (e) {
        dev.log('Error removing from cart: $e');

        // Return the current cart in case of error
        return await getCart();
      }
    } else {
      // No internet connection
      dev.log('No internet connection, cannot remove from cart');
      return await getCart();
    }
  }

  @override
  Future<bool> clearCart() async {
    if (await networkInfo.isConnected) {
      try {
        final success = await remoteDataSource.clearCart();

        if (success) {
          dev.log('Cleared cart from remote source');
          // Clear the cached cart
          await cacheService.remove(_cartCacheKey);
        }

        return success;
      } catch (e) {
        dev.log('Error clearing cart: $e');
        return false;
      }
    } else {
      // No internet connection
      dev.log('No internet connection, cannot clear cart');
      return false;
    }
  }

  @override
  Future<String> createCheckout() async {
    if (await networkInfo.isConnected) {
      try {
        final checkoutUrl = await remoteDataSource.createCheckout();
        dev.log('Created checkout from remote source');
        return checkoutUrl;
      } catch (e) {
        dev.log('Error creating checkout: $e');
        return '';
      }
    } else {
      // No internet connection
      dev.log('No internet connection, cannot create checkout');
      return '';
    }
  }

  Future<Cart> _getCachedCart() async {
    final cachedCart = await cacheService.getString(_cartCacheKey);
    if (cachedCart == null) {
      dev.log('No cached cart found, returning empty cart');
      return Cart.empty();
    }

    try {
      final Map<String, dynamic> cartJson = jsonDecode(cachedCart);
      dev.log('Successfully retrieved cart from cache');
      return Cart.fromJson(cartJson);
    } catch (e) {
      dev.log('Error parsing cached cart: $e');
      return Cart.empty();
    }
  }

  Future<void> _cacheCart(Cart cart) async {
    try {
      final String cartJson = jsonEncode(cart.toJson());
      await cacheService.setString(_cartCacheKey, cartJson);
      dev.log('Successfully cached cart data');
    } catch (e) {
      dev.log('Error caching cart: $e');
    }
  }

  @override
  Future<Cart> addDeliveryAddressToCart({required String cartId, required Address address}) async {
    if (await networkInfo.isConnected) {
      try {
        final updatedCart = await remoteDataSource.addAddressToCart(cartId: cartId, address: address);
        dev.log('Added delivery address to cart from remote source');
        _cacheCart(updatedCart);
        return updatedCart;
      } catch (e) {
        dev.log('Error adding delivery address to cart: $e');
        return await getCart();
      }
    } else {
      dev.log('No internet connection, cannot add delivery address to cart');
      return await getCart();
    }
  }
}
