import 'package:hostations_commerce/features/wishlist/domain/models/wishlist_item.dart';

abstract class WishlistRepository {
  /// Get all favorites for the current user
  Future<List<WishlistItem>> getFavorites();

  /// Add a product to favorites
  /// Returns true if successful, false otherwise
  Future<bool> addToFavorites(String productId);

  /// Remove a product from favorites
  /// Returns true if successful, false otherwise
  Future<bool> removeFromFavorites(String productId);

  /// Check if a product is in favorites
  /// Returns true if it is, false otherwise
  Future<bool> isFavorite(String productId);

  /// Get all favorite product IDs
  /// This is useful for quick checks without loading full product details
  Future<List<String>> getFavoriteIds();
}
