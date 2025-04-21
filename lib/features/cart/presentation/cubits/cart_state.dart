import 'package:equatable/equatable.dart';
import 'package:hostations_commerce/features/cart/domain/models/cart.dart';
import 'package:hostations_commerce/features/cart/domain/models/cart_item.dart';

enum CartStatus { initial, loading, success, failure, addressAddSuccess }

class CartState extends Equatable {
  final CartStatus status;
  final Cart cart;
  final String? errorMessage;
  final bool isAddingToCart;
  final bool isUpdatingCart;
  final bool isRemovingFromCart;
  final bool isCreatingCheckout;
  final String? processingItemId;
  final String? checkoutUrl;
  final bool addressAddSuccess;
  final bool isAddingDeliveryAddress;
  final String? selectedPaymentMethod;

  CartState({
    this.status = CartStatus.initial,
    this.cart = const Cart(
      id: '',
      items: [],
      subtotal: '0.00',
      total: '0.00',
      currency: 'USD',
      itemCount: 0,
    ),
    this.errorMessage,
    this.isAddingToCart = false,
    this.isUpdatingCart = false,
    this.isRemovingFromCart = false,
    this.isCreatingCheckout = false,
    this.processingItemId,
    this.checkoutUrl,
    this.addressAddSuccess = false,
    this.isAddingDeliveryAddress = false,
    this.selectedPaymentMethod,
  });

  bool get isEmpty => cart.items.isEmpty;

  bool get isLoading => status == CartStatus.loading;

  bool get hasError => status == CartStatus.failure;

  bool isProcessing(String id) => processingItemId == id;

  CartItem? findItemById(String id) {
    try {
      return cart.items.firstWhere((item) => item.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  List<Object?> get props => [
        status,
        cart,
        errorMessage,
        isAddingToCart,
        isUpdatingCart,
        isRemovingFromCart,
        isCreatingCheckout,
        processingItemId,
        checkoutUrl,
        addressAddSuccess,
        isAddingDeliveryAddress,
        selectedPaymentMethod,
      ];

  CartState copyWith({
    CartStatus? status,
    Cart? cart,
    String? errorMessage,
    bool? isAddingToCart,
    bool? isUpdatingCart,
    bool? isRemovingFromCart,
    bool? isCreatingCheckout,
    String? processingItemId,
    String? checkoutUrl,
    bool? addressAddSuccess,
    bool? isAddingDeliveryAddress,
    String? selectedPaymentMethod,
    bool clearProcessingItemId = false,
    bool clearErrorMessage = false,
    bool clearCheckoutUrl = false,
  }) {
    return CartState(
      status: status ?? this.status,
      cart: cart ?? this.cart,
      errorMessage: clearErrorMessage ? null : errorMessage ?? this.errorMessage,
      isAddingToCart: isAddingToCart ?? this.isAddingToCart,
      isUpdatingCart: isUpdatingCart ?? this.isUpdatingCart,
      isRemovingFromCart: isRemovingFromCart ?? this.isRemovingFromCart,
      isCreatingCheckout: isCreatingCheckout ?? this.isCreatingCheckout,
      processingItemId: clearProcessingItemId ? null : processingItemId ?? this.processingItemId,
      checkoutUrl: clearCheckoutUrl ? null : checkoutUrl ?? this.checkoutUrl,
      addressAddSuccess: addressAddSuccess ?? this.addressAddSuccess,
      isAddingDeliveryAddress: isAddingDeliveryAddress ?? this.isAddingDeliveryAddress,
      selectedPaymentMethod: selectedPaymentMethod ?? this.selectedPaymentMethod,
    );
  }
}
