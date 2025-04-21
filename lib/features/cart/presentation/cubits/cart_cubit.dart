import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hostations_commerce/core/di/dependency_injection.dart';
import 'package:hostations_commerce/features/address/data/model/address.dart';
import 'package:hostations_commerce/features/cart/domain/repository/cart_repository.dart';
import 'package:hostations_commerce/features/cart/presentation/cubits/cart_state.dart';
import 'dart:developer' as logger;

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
      logger.log('Error loading cart: $e');
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
      logger.log('Error adding to cart: $e');
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
      logger.log('Error updating cart item: $e');
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
      logger.log('Error removing from cart: $e');
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
      logger.log('Error clearing cart: $e');
      emit(state.copyWith(
        isUpdatingCart: false,
        errorMessage: 'Failed to clear cart: $e',
      ));
      DependencyInjector().snackBarService.showError('Failed to clear cart');
    }
  }

  // Create checkout from cart
  Future<void> createCheckout() async {
    logger.log('Creating checkout with ${state.cart.items.length} items');
    if (state.cart.items.isEmpty) {
      logger.log('Checkout creation aborted: cart is empty');
      DependencyInjector().snackBarService.showWarning('Your cart is empty');
      return;
    }

    emit(state.copyWith(
      isCreatingCheckout: true,
      clearCheckoutUrl: true,
    ));
    logger.log('Set state to isCreatingCheckout=true');

    try {
      logger.log('Calling repository.createCheckout()');
      final checkoutUrl = await _cartRepository.createCheckout();
      logger.log('Received checkout URL: ${checkoutUrl.isNotEmpty ? 'valid URL' : 'empty'}');

      if (checkoutUrl.isNotEmpty) {
        logger.log('Checkout created successfully');
        emit(state.copyWith(
          isCreatingCheckout: false,
          checkoutUrl: checkoutUrl,
          clearErrorMessage: true,
        ));
      } else {
        logger.log('Failed to create checkout: empty URL returned');
        emit(state.copyWith(
          isCreatingCheckout: false,
          errorMessage: 'Failed to create checkout',
        ));
        DependencyInjector().snackBarService.showError('Failed to create checkout');
      }
    } catch (e) {
      logger.log('Error creating checkout: $e');
      emit(state.copyWith(
        isCreatingCheckout: false,
        errorMessage: 'Failed to create checkout: $e',
      ));
      DependencyInjector().snackBarService.showError('Failed to create checkout');
    }
  }

  Future<void> addDeliveryAddressToCart({required String cartId, required Address address}) async {
    logger.log('[CartCubit] addDeliveryAddressToCart called with cartId: $cartId, address: ${address.toJson()}');
    logger.log('[CartCubit] Cart BEFORE adding address: \n${state.cart.toJson().toString()}');
    emit(state.copyWith(
      isAddingDeliveryAddress: true,
      processingItemId: null,
      addressAddSuccess: false, // reset flag
    ));

    try {
      final updatedCart = await _cartRepository.addDeliveryAddressToCart(cartId: cartId, address: address);
      logger.log('[CartCubit] Cart AFTER adding address: \n${updatedCart.toJson().toString()}');

      emit(state.copyWith(
        status: CartStatus.addressAddSuccess, // signal success for navigation
        cart: updatedCart,
        isAddingDeliveryAddress: false,
        addressAddSuccess: true,
        clearErrorMessage: true,
      ));

      DependencyInjector().snackBarService.showSuccess('Delivery address added to cart');
    } catch (e) {
      logger.log('Error adding delivery address to cart: $e');
      emit(state.copyWith(
        isAddingDeliveryAddress: false,
        addressAddSuccess: false,
        errorMessage: 'Failed to add delivery address to cart: $e',
      ));

      DependencyInjector().snackBarService.showError('Failed to add delivery address to cart');
    }
  }

  // Hardcoded payment methods
  static const List<String> paymentMethods = [
    'Credit Card',
    'PayPal',
    'Cash on Delivery',
  ];

  void selectPaymentMethod(String method) {
    emit(state.copyWith(selectedPaymentMethod: method));
  }
}
