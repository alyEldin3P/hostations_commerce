import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hostations_commerce/core/di/dependency_injection.dart';
import 'package:hostations_commerce/features/cart/presentation/cubits/cart_cubit.dart';
import 'package:hostations_commerce/features/cart/presentation/cubits/cart_state.dart';
import 'package:hostations_commerce/features/cart/presentation/screens/cart_screen.dart';
import 'package:hostations_commerce/features/cart/presentation/widgets/cart_badge.dart';
import 'package:hostations_commerce/features/home/presentation/cubits/home_cubit.dart';
import 'package:hostations_commerce/features/home/presentation/cubits/home_state.dart';
import 'package:hostations_commerce/features/home/products/data/model/product.dart';
import 'package:hostations_commerce/features/home/products/presentation/widgets/variant_selector.dart';
import 'package:hostations_commerce/features/wishlist/presentation/cubits/wishlist_cubit.dart';
import 'package:hostations_commerce/features/wishlist/presentation/cubits/wishlist_state.dart';
import '../../products/presentation/cubits/product_selection_cubit.dart';

class ProductDetailsScreen extends StatefulWidget {
  static const String routeName = '/product-details';
  final String productId;

  const ProductDetailsScreen({
    Key? key,
    required this.productId,
  }) : super(key: key);

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    // ProductSelectionCubit will be provided in build
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProductSelectionCubit>(
      create: (_) {
        final product = context.read<HomeCubit>().state.selectedProduct;
        return ProductSelectionCubit(
          initialVariant: product?.variants.isNotEmpty == true ? product!.variants.first : null,
        );
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Product Details'),
          actions: [
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () {
                // TODO: Implement share functionality
              },
            ),
            CartBadge(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CartScreen(),
                  ),
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            if (state.isProductDetailsLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final product = state.selectedProduct;
            if (product == null) {
              return const Center(
                child: Text('Product not found'),
              );
            }

            return BlocBuilder<ProductSelectionCubit, ProductSelectionState>(
              builder: (context, selectionState) {
                return Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Product images
                            _buildProductImages(product),

                            // Product info
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Title and price
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        product.title,
                                        style: Theme.of(context).textTheme.titleLarge,
                                      ),
                                      BlocProvider.value(
                                        value: DependencyInjector().wishlistCubit,
                                        child: BlocBuilder<WishlistCubit, WishlistState>(
                                          builder: (context, wishlistState) {
                                            final isFavorite = wishlistState.isFavorite(product.id);
                                            final isProcessing = wishlistState.isProcessing(product.id);

                                            return IconButton(
                                              icon: isProcessing
                                                  ? const SizedBox(
                                                      width: 20,
                                                      height: 20,
                                                      child: CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                      ),
                                                    )
                                                  : Icon(
                                                      isFavorite ? Icons.favorite : Icons.favorite_border,
                                                      color: isFavorite ? Colors.red : null,
                                                    ),
                                              onPressed: isProcessing
                                                  ? null
                                                  : () {
                                                      if (isFavorite) {
                                                        context.read<WishlistCubit>().removeFromWishlist(product.id);
                                                      } else {
                                                        context.read<WishlistCubit>().addToWishlist(product.id);
                                                      }
                                                    },
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Text(
                                        '\$${selectionState.selectedVariant?.price.toStringAsFixed(2) ?? product.price.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                      if (product.compareAtPrice != null && product.compareAtPrice! > 0) ...[
                                        const SizedBox(width: 8),
                                        Text(
                                          '\$${product.compareAtPrice!.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            decoration: TextDecoration.lineThrough,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            '${(((product.compareAtPrice! - product.price) / product.compareAtPrice!) * 100).toInt()}% OFF',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),

                                  // Rating
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 4),
                                      const Text(
                                        '4.5',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '(123 reviews)',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),

                                  // Variants
                                  if (product.variants.length > 1) ...[
                                    const SizedBox(height: 16),
                                    const Text(
                                      'Variants',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    VariantSelector(
                                      product: product,
                                      selectedVariant: selectionState.selectedVariant,
                                      onVariantSelected: (variant) {
                                        context.read<ProductSelectionCubit>().selectVariant(variant);
                                      },
                                    ),
                                  ],

                                  // Quantity selector
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Quantity',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  _buildQuantitySelector(context, selectionState),

                                  // Description
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Description',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    product.description,
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Bottom action bar
                    _buildBottomActionBar(product, selectionState),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildProductImages(Product product) {
    return Stack(
      children: [
        // Image slider
        SizedBox(
          height: 300,
          child: PageView.builder(
            itemCount: product.images.length,
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return Image.network(
                product.images[index],
                fit: BoxFit.cover,
              );
            },
          ),
        ),

        // Image indicator
        if (product.images.length > 1)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                product.images.length,
                (index) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentImageIndex == index ? Theme.of(context).primaryColor : Colors.grey[300],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildQuantitySelector(BuildContext context, ProductSelectionState selectionState) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: selectionState.quantity > 1
                    ? () {
                        context.read<ProductSelectionCubit>().setQuantity(selectionState.quantity - 1);
                      }
                    : null,
              ),
              Text(
                '${selectionState.quantity}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  context.read<ProductSelectionCubit>().setQuantity(selectionState.quantity + 1);
                },
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Text(
          'Available: ${selectionState.selectedVariant?.available ?? true ? 'In Stock' : 'Out of Stock'}',
          style: TextStyle(
            color: (selectionState.selectedVariant?.available ?? true) ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActionBar(Product product, ProductSelectionState selectionState) {
    final isAvailable = selectionState.selectedVariant?.available ?? product.available;
    final variantId = selectionState.selectedVariant?.id ?? (product.variants.isNotEmpty ? product.variants.first.id : product.id);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BlocConsumer<CartCubit, CartState>(
        listener: (context, state) {
          if (state.status == CartStatus.success && !state.isAddingToCart && state.processingItemId == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Added to cart!')),
            );
          }
        },
        builder: (context, state) {
          final isProcessing = state.isProcessing(variantId);

          return Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: isAvailable && !isProcessing
                      ? () {
                          context.read<CartCubit>().addToCart(variantId, quantity: selectionState.quantity);
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                  ),
                  child: isProcessing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Buy Now',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
