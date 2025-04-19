import 'package:hostations_commerce/features/cart/domain/models/cart.dart';

abstract class CartRepository {
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
}
