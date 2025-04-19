import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hostations_commerce/core/di/dependency_injection.dart';
import 'package:hostations_commerce/features/cart/presentation/widgets/add_to_cart_button.dart';
import 'package:hostations_commerce/features/wishlist/presentation/cubits/wishlist_cubit.dart';
import 'package:hostations_commerce/features/wishlist/presentation/cubits/wishlist_state.dart';

class ProductDetailActions extends StatelessWidget {
  final String productId;
  final String variantId;
  final VoidCallback? onAddedToCart;

  const ProductDetailActions({
    super.key,
    required this.productId,
    required this.variantId,
    this.onAddedToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          // Wishlist button
          BlocProvider<WishlistCubit>.value(
            value: DependencyInjector().wishlistCubit,
            child: BlocBuilder<WishlistCubit, WishlistState>(
              builder: (context, state) {
                final isFavorite = state.isFavorite(productId);
                final isProcessing = state.isProcessing(productId);
                
                return IconButton(
                  icon: isProcessing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(
                          isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: isFavorite ? Colors.red : null,
                        ),
                  onPressed: isProcessing
                      ? null
                      : () {
                          if (isFavorite) {
                            context.read<WishlistCubit>().removeFromWishlist(productId);
                          } else {
                            context.read<WishlistCubit>().addToWishlist(productId);
                          }
                        },
                );
              },
            ),
          ),
          
          // Share button
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Share product functionality
              DependencyInjector().snackBarService.showInfo('Sharing functionality will be implemented soon');
            },
          ),
          
          const SizedBox(width: 8),
          
          // Add to cart button
          Expanded(
            child: AddToCartButton(
              variantId: variantId,
              isFullWidth: true,
              onAdded: onAddedToCart,
            ),
          ),
        ],
      ),
    );
  }
}
