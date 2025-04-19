import 'dart:convert';
import 'dart:developer' as dev;

import 'package:hostations_commerce/core/error/exceptions.dart';
import 'package:hostations_commerce/core/network/network_info.dart';
import 'package:hostations_commerce/core/services/cache/cache_service.dart';
import 'package:hostations_commerce/features/wishlist/data/remote/wishlist_remote_data_source.dart';
import 'package:hostations_commerce/features/wishlist/domain/models/wishlist_item.dart';
import 'package:hostations_commerce/features/wishlist/domain/repository/wishlist_repository.dart';

class WishlistRepositoryImpl implements WishlistRepository {
  final WishlistRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  final CacheService cacheService;

  // Cache keys
  static const String _wishlistCacheKey = 'wishlist_items';
  static const String _wishlistIdsCacheKey = 'wishlist_ids';

  WishlistRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
    required this.cacheService,
  });

  @override
  Future<List<WishlistItem>> getFavorites() async {
    if (await networkInfo.isConnected) {
      try {
        final remoteWishlist = await remoteDataSource.getFavorites();

        // Cache the result
        _cacheWishlistItems(remoteWishlist);

        return remoteWishlist;
      } on ServerException catch (e) {
        dev.log('Server exception when getting favorites: ${e.message}');
        // Fallback to cached data
        return _getCachedWishlistItems();
      } catch (e) {
        dev.log('Error getting favorites: $e');
        // Fallback to cached data
        return _getCachedWishlistItems();
      }
    } else {
      // No internet connection, use cached data
      dev.log('No internet connection, using cached wishlist');
      return _getCachedWishlistItems();
    }
  }

  @override
  Future<bool> isFavorite(String id) async {
    if (await networkInfo.isConnected) {
      try {
        final isFavorite = await remoteDataSource.isFavorite(
          id,
        );
        return isFavorite;
      } catch (e) {
        dev.log('Error checking if product is favorite: $e');
        // Fallback to local cache
        final cachedIds = await _getCachedWishlistIds();
        return cachedIds.contains(id);
      }
    } else {
      // No internet connection, check local cache
      final cachedIds = await _getCachedWishlistIds();
      return cachedIds.contains(id);
    }
  }

  @override
  Future<bool> addToFavorites(String id) async {
    if (await networkInfo.isConnected) {
      try {
        final success = await remoteDataSource.addToFavorites(id);

        if (success) {
          // Update local cache
          await _updateLocalCacheAfterAdd(id);
        }

        return success;
      } catch (e) {
        dev.log('Error adding to favorites: $e');

        // Fallback: Update local cache only
        await _updateLocalCacheAfterAdd(id);

        // Return true to indicate to the UI that the item was added (even if only locally)
        return true;
      }
    } else {
      // No internet connection, update local cache only
      dev.log('No internet connection, updating local cache only');
      await _updateLocalCacheAfterAdd(id);
      return true;
    }
  }

  @override
  Future<bool> removeFromFavorites(String id) async {
    if (await networkInfo.isConnected) {
      try {
        final success = await remoteDataSource.removeFromFavorites(id);

        if (success) {
          // Update local cache
          await _updateLocalCacheAfterRemove(id);
        }

        return success;
      } catch (e) {
        dev.log('Error removing from favorites: $e');

        // Fallback: Update local cache only
        await _updateLocalCacheAfterRemove(id);

        // Return true to indicate to the UI that the item was removed (even if only locally)
        return true;
      }
    } else {
      // No internet connection, update local cache only
      dev.log('No internet connection, updating local cache only');
      await _updateLocalCacheAfterRemove(id);
      return true;
    }
  }

  @override
  Future<List<String>> getFavoriteIds() async {
    if (await networkInfo.isConnected) {
      try {
        final remoteIds = await remoteDataSource.getFavoriteIds();
        await _cacheWishlistIds(remoteIds);
        return remoteIds;
      } catch (e) {
        dev.log('Error getting favorite IDs: $e');
        return _getCachedWishlistIds();
      }
    } else {
      return _getCachedWishlistIds();
    }
  }

  Future<void> _updateLocalCacheAfterAdd(String id) async {
    final currentIds = await _getCachedWishlistIds();
    final updatedIds = List<String>.from(currentIds)..add(id);
    await _cacheWishlistIds(updatedIds);
  }

  Future<void> _updateLocalCacheAfterRemove(String id) async {
    final currentIds = await _getCachedWishlistIds();
    final updatedIds = currentIds.where((idItem) => idItem != id).toList();
    await _cacheWishlistIds(updatedIds);
  }

  Future<List<String>> _getCachedWishlistIds() async {
    final cachedIds = await cacheService.getString(_wishlistIdsCacheKey);
    return cachedIds?.split(',') ?? [];
  }

  Future<void> _cacheWishlistIds(List<String> ids) async {
    await cacheService.setString(_wishlistIdsCacheKey, ids.join(','));
  }

  Future<List<WishlistItem>> _getCachedWishlistItems() async {
    final cachedItems = await cacheService.getString(_wishlistCacheKey);
    if (cachedItems == null) {
      return [];
    }

    try {
      final List<dynamic> items = jsonDecode(cachedItems);
      return items.map((item) => WishlistItem.fromJson(item)).toList();
    } catch (e) {
      dev.log('Error parsing cached wishlist: $e');
      return [];
    }
  }

  Future<void> _cacheWishlistItems(List<WishlistItem> items) async {
    try {
      final String itemsJson = jsonEncode(items.map((item) => item.toJson()).toList());
      await cacheService.setString(_wishlistCacheKey, itemsJson);
    } catch (e) {
      dev.log('Error caching wishlist: $e');
    }
  }
}
