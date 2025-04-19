import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hostations_commerce/core/di/dependency_injection.dart';
import 'package:hostations_commerce/features/cart/domain/repository/cart_repository.dart';
import 'package:hostations_commerce/features/cart/presentation/cubits/cart_state.dart';

class CartCubit extends Cubit<CartState> {
  final CartRepository _cartRepository;

  CartCubit({
    required CartRepository cartRepository,
  })  : _cartRepository = cartRepository,
        super(CartState());

  // Initialize cart data
  Future<void> loadCart() async {
    emit(state.copyWith(status: CartStatus.loading));

    try {
      final cart = await _cartRepository.getCart();
      emit(state.copyWith(
        status: CartStatus.success,
        cart: cart,
        clearErrorMessage: true,
      ));
    } catch (e) {
      log('Error loading cart: $e');
      emit(state.copyWith(
        status: CartStatus.failure,
        errorMessage: 'Failed to load cart: $e',
      ));
    }
  }

  // Add product to cart
  Future<void> addToCart(String variantId, {int quantity = 1}) async {
    // Set processing state
    emit(state.copyWith(
      isAddingToCart: true,
      processingItemId: variantId,
    ));

    try {
      final updatedCart = await _cartRepository.addToCart(variantId, quantity: quantity);

      emit(state.copyWith(
        status: CartStatus.success,
        cart: updatedCart,
        isAddingToCart: false,
        clearProcessingItemId: true,
        clearErrorMessage: true,
      ));

      DependencyInjector().snackBarService.showSuccess('Added to cart');
    } catch (e) {
      log('Error adding to cart: $e');
      emit(state.copyWith(
        isAddingToCart: false,
        clearProcessingItemId: true,
        errorMessage: 'Failed to add to cart: $e',
      ));

      DependencyInjector().snackBarService.showError('Failed to add to cart');
    }
  }

  // Update cart item quantity
  Future<void> updateCartItem(String lineId, int quantity) async {
    if (quantity < 1) {
      return removeFromCart(lineId);
    }

    // Set processing state
    emit(state.copyWith(
      isUpdatingCart: true,
      processingItemId: lineId,
    ));

    try {
      final updatedCart = await _cartRepository.updateCartItem(lineId, quantity);

      emit(state.copyWith(
        status: CartStatus.success,
        cart: updatedCart,
        isUpdatingCart: false,
        clearProcessingItemId: true,
        clearErrorMessage: true,
      ));
    } catch (e) {
      log('Error updating cart item: $e');
      emit(state.copyWith(
        isUpdatingCart: false,
        clearProcessingItemId: true,
        errorMessage: 'Failed to update cart item: $e',
      ));

      DependencyInjector().snackBarService.showError('Failed to update cart');
    }
  }

  // Increment cart item quantity
  Future<void> incrementCartItem(String lineId) async {
    final item = state.findItemById(lineId);
    if (item == null) return;

    await updateCartItem(lineId, item.quantity + 1);
  }

  // Decrement cart item quantity
  Future<void> decrementCartItem(String lineId) async {
    final item = state.findItemById(lineId);
    if (item == null) return;

    if (item.quantity <= 1) {
      await removeFromCart(lineId);
    } else {
      await updateCartItem(lineId, item.quantity - 1);
    }
  }

  // Remove item from cart
  Future<void> removeFromCart(String lineId) async {
    // Set processing state
    emit(state.copyWith(
      isRemovingFromCart: true,
      processingItemId: lineId,
    ));

    try {
      final updatedCart = await _cartRepository.removeFromCart(lineId);

      emit(state.copyWith(
        status: CartStatus.success,
        cart: updatedCart,
        isRemovingFromCart: false,
        clearProcessingItemId: true,
        clearErrorMessage: true,
      ));

      DependencyInjector().snackBarService.showSuccess('Removed from cart');
    } catch (e) {
      log('Error removing from cart: $e');
      emit(state.copyWith(
        isRemovingFromCart: false,
        clearProcessingItemId: true,
        errorMessage: 'Failed to remove from cart: $e',
      ));

      DependencyInjector().snackBarService.showError('Failed to remove from cart');
    }
  }

  // Clear the entire cart
  Future<void> clearCart() async {
    emit(state.copyWith(
      isUpdatingCart: true,
    ));

    try {
      final success = await _cartRepository.clearCart();

      if (success) {
        await loadCart();
        DependencyInjector().snackBarService.showSuccess('Cart cleared');
      } else {
        emit(state.copyWith(
          isUpdatingCart: false,
          errorMessage: 'Failed to clear cart',
        ));
        DependencyInjector().snackBarService.showError('Failed to clear cart');
      }
    } catch (e) {
      log('Error clearing cart: $e');
      emit(state.copyWith(
        isUpdatingCart: false,
        errorMessage: 'Failed to clear cart: $e',
      ));
      DependencyInjector().snackBarService.showError('Failed to clear cart');
    }
  }

  // Create checkout from cart
  Future<void> createCheckout() async {
    log('Creating checkout with ${state.cart.items.length} items');
    if (state.cart.items.isEmpty) {
      log('Checkout creation aborted: cart is empty');
      DependencyInjector().snackBarService.showWarning('Your cart is empty');
      return;
    }

    emit(state.copyWith(
      isCreatingCheckout: true,
      clearCheckoutUrl: true,
    ));
    log('Set state to isCreatingCheckout=true');

    try {
      log('Calling repository.createCheckout()');
      final checkoutUrl = await _cartRepository.createCheckout();
      log('Received checkout URL: ${checkoutUrl.isNotEmpty ? 'valid URL' : 'empty'}');

      if (checkoutUrl.isNotEmpty) {
        log('Checkout created successfully');
        emit(state.copyWith(
          isCreatingCheckout: false,
          checkoutUrl: checkoutUrl,
          clearErrorMessage: true,
        ));
      } else {
        log('Failed to create checkout: empty URL returned');
        emit(state.copyWith(
          isCreatingCheckout: false,
          errorMessage: 'Failed to create checkout',
        ));
        DependencyInjector().snackBarService.showError('Failed to create checkout');
      }
    } catch (e) {
      log('Error creating checkout: $e');
      emit(state.copyWith(
        isCreatingCheckout: false,
        errorMessage: 'Failed to create checkout: $e',
      ));
      DependencyInjector().snackBarService.showError('Failed to create checkout');
    }
  }
}
