import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hostations_commerce/core/di/dependency_injection.dart';
import 'package:hostations_commerce/features/cart/presentation/cubits/cart_cubit.dart';
import 'package:hostations_commerce/features/cart/presentation/cubits/cart_state.dart';
import 'package:hostations_commerce/features/home/products/data/model/product.dart';
import 'package:hostations_commerce/features/home/products/presentation/cubits/product_selection_cubit.dart';
import 'package:hostations_commerce/features/home/products/presentation/widgets/variant_selector.dart';

class QuickAddButton extends StatefulWidget {
  final Product product;
  final bool showVariantSelector;

  const QuickAddButton({
    super.key,
    required this.product,
    this.showVariantSelector = false,
  });

  @override
  State<QuickAddButton> createState() => _QuickAddButtonState();
}

class _QuickAddButtonState extends State<QuickAddButton> {
  bool _showOptions = false;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProductSelectionCubit>(
      create: (_) => ProductSelectionCubit(
        initialVariant: widget.product.variants.isNotEmpty ? widget.product.variants.first : null,
      ),
      child: BlocConsumer<CartCubit, CartState>(
        listener: (context, state) {
          if (state.status == CartStatus.success && !state.isAddingToCart && state.processingItemId == null) {
            DependencyInjector().snackBarService.showSuccess('${widget.product.title} added to cart');
            if (_showOptions) {
              setState(() {
                _showOptions = false;
              });
            }
          }
        },
        builder: (context, state) {
          return BlocBuilder<ProductSelectionCubit, ProductSelectionState>(
            builder: (context, selectionState) {
              final variantId = selectionState.selectedVariant?.id ?? (widget.product.variants.isNotEmpty ? widget.product.variants.first.id : widget.product.id);
              final isProcessing = state.isProcessing(variantId);
              final hasVariants = widget.product.variants.length > 1;
              if (_showOptions) {
                return _buildExpandedOptions(isProcessing, context, selectionState);
              }
              return _buildButton(isProcessing, hasVariants, context, variantId);
            },
          );
        },
      ),
    );
  }

  Widget _buildButton(bool isProcessing, bool hasVariants, BuildContext context, String variantId) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isProcessing
            ? null
            : () {
                if (hasVariants && widget.showVariantSelector) {
                  setState(() {
                    _showOptions = true;
                  });
                } else {
                  final selectionCubit = context.read<ProductSelectionCubit>();
                  _addToCart(context, variantId, selectionCubit.state.quantity);
                }
              },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 8),
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
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shopping_cart_outlined, size: 16),
                  const SizedBox(width: 8),
                  Text(hasVariants && widget.showVariantSelector ? 'Select Options' : 'Add to Cart'),
                ],
              ),
      ),
    );
  }

  Widget _buildExpandedOptions(bool isProcessing, BuildContext context, ProductSelectionState selectionState) {
    final variantId = selectionState.selectedVariant?.id ?? (widget.product.variants.isNotEmpty ? widget.product.variants.first.id : widget.product.id);
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Quick Add',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  constraints: const BoxConstraints(
                    minWidth: 24,
                    minHeight: 24,
                  ),
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    setState(() {
                      _showOptions = false;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            VariantSelector(
              product: widget.product,
              selectedVariant: selectionState.selectedVariant,
              onVariantSelected: (variant) {
                context.read<ProductSelectionCubit>().selectVariant(variant);
              },
              compact: true,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Quantity: '),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: selectionState.quantity > 1
                            ? () {
                                context.read<ProductSelectionCubit>().setQuantity(selectionState.quantity - 1);
                              }
                            : null,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            Icons.remove,
                            size: 16,
                            color: selectionState.quantity > 1 ? null : Colors.grey.shade400,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          '${selectionState.quantity}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          context.read<ProductSelectionCubit>().setQuantity(selectionState.quantity + 1);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          child: const Icon(Icons.add, size: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isProcessing ? null : () => _addToCart(context, variantId, selectionState.quantity),
                child: isProcessing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Add to Cart'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addToCart(BuildContext context, String variantId, int quantity) {
    context.read<CartCubit>().addToCart(variantId, quantity: quantity);
  }
}
