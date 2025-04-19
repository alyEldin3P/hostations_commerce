import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:hostations_commerce/core/di/dependency_injection.dart';
import 'package:hostations_commerce/core/services/cache/cache_service.dart';

import 'package:hostations_commerce/features/wishlist/domain/models/wishlist_item.dart';
import 'package:graphql_flutter/graphql_flutter.dart' as graphql;

abstract class WishlistRemoteDataSource {
  /// Get all favorites for the current user
  Future<List<WishlistItem>> getFavorites();

  /// Add a product to favorites
  /// Returns true if successful, false otherwise
  Future<bool> addToFavorites(String productId);

  /// Remove a product from favorites
  /// Returns true if successful, false otherwise
  Future<bool> removeFromFavorites(String productId);

  /// Get all favorite product IDs
  /// This is useful for quick checks without loading full product details
  Future<List<String>> getFavoriteIds();

  /// Check if a product is in the wishlist
  Future<bool> isFavorite(String productId);
}

class LocalWishlistDataSource implements WishlistRemoteDataSource {
  final CacheService _cacheService;
  final graphql.GraphQLClient _graphQLClient;

  // Cache key prefix for wishlist
  static const String _wishlistKeyPrefix = 'wishlist_';

  LocalWishlistDataSource({
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

  // Get the wishlist cache key for the current user
  Future<String> _getWishlistKey() async {
    final userId = await _getCurrentUserId();
    return '$_wishlistKeyPrefix$userId';
  }

  @override
  Future<List<WishlistItem>> getFavorites() async {
    final productIds = await getFavoriteIds();
    if (productIds.isEmpty) return [];
    return _fetchProductsByIds(productIds);
  }

  @override
  Future<bool> addToFavorites(String productId) async {
    try {
      final key = await _getWishlistKey();
      final ids = await getFavoriteIds();

      // Check if product is already in wishlist
      if (ids.contains(productId)) {
        log('Product $productId already in wishlist');
        return true;
      }

      // Add product to wishlist
      ids.add(productId);

      // Save updated wishlist
      await _cacheService.setString(key, jsonEncode(ids));
      log('Added product $productId to wishlist. Total items: ${ids.length}');
      return true;
    } catch (e) {
      log('Error adding to favorites: $e');
      return false;
    }
  }

  @override
  Future<bool> removeFromFavorites(String productId) async {
    try {
      final key = await _getWishlistKey();
      final ids = await getFavoriteIds();

      // Check if product is in wishlist
      if (!ids.contains(productId)) {
        log('Product $productId not in wishlist');
        return true;
      }

      // Remove product from wishlist
      ids.remove(productId);

      // Save updated wishlist
      await _cacheService.setString(key, jsonEncode(ids));
      log('Removed product $productId from wishlist. Total items: ${ids.length}');
      return true;
    } catch (e) {
      log('Error removing from favorites: $e');
      return false;
    }
  }

  @override
  Future<List<String>> getFavoriteIds() async {
    try {
      final key = await _getWishlistKey();
      final wishlistJson = await _cacheService.getString(key);

      if (wishlistJson == null || wishlistJson.isEmpty) {
        return [];
      }

      return List<String>.from(jsonDecode(wishlistJson));
    } catch (e) {
      log('Error getting favorite IDs: $e');
      return [];
    }
  }

  @override
  Future<bool> isFavorite(String productId) async {
    final ids = await getFavoriteIds();
    return ids.contains(productId);
  }

  Future<List<WishlistItem>> _fetchProductsByIds(List<String> ids) async {
    final query = '''
      query GetProducts(\$ids: [ID!]!) {
        nodes(ids: \$ids) {
          ... on Product {
            id
            title
            description
            images(first: 1) {
              edges {
                node {
                  url
                }
              }
            }
            priceRange {
              minVariantPrice {
                amount
                currencyCode
              }
            }
          }
        }
      }
    ''';

    try {
      final result = await _graphQLClient.query(
        graphql.QueryOptions(
          fetchPolicy: graphql.FetchPolicy.networkOnly, // Ensure we always hit the network
          document: graphql.gql(query),
          variables: {
            'ids': ids.map((id) => 'gid://shopify/Product/$id').toList(),
          },
        ),
      );

      if (result.hasException) {
        log('GraphQL error: ${result.exception.toString()}');
        return [];
      }

      final nodes = result.data?['nodes'];
      if (nodes == null) return [];

      return List<WishlistItem>.from(nodes.map((node) {
        String? imageUrl;
        final images = node['images']?['edges'];
        if (images != null && images.length > 0) {
          imageUrl = images[0]['node']?['url'];
        }

        return WishlistItem(
          id: node['id'],
          title: node['title'],
          description: node['description'] ?? '',
          image: imageUrl,
          price: node['priceRange']['minVariantPrice']['amount'],
          currency: node['priceRange']['minVariantPrice']['currencyCode'],
        );
      }));
    } catch (e) {
      log('Error fetching products: $e');
      return [];
    }
  }
}
