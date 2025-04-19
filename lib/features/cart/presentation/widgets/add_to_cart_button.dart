import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hostations_commerce/core/di/dependency_injection.dart';
import 'package:hostations_commerce/features/cart/presentation/cubits/cart_cubit.dart';
import 'package:hostations_commerce/features/cart/presentation/cubits/cart_state.dart';

class AddToCartButton extends StatelessWidget {
  final String variantId;
  final bool isOutlined;
  final bool showIcon;
  final bool isFullWidth;
  final bool isSmall;
  final VoidCallback? onAdded;

  const AddToCartButton({
    super.key,
    required this.variantId,
    this.isOutlined = false,
    this.showIcon = true,
    this.isFullWidth = false,
    this.isSmall = false,
    this.onAdded,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        final isProcessing = state.isProcessing(variantId);

        if (isOutlined) {
          return _buildOutlinedButton(context, isProcessing);
        }

        return _buildElevatedButton(context, isProcessing);
      },
    );
  }

  Widget _buildElevatedButton(BuildContext context, bool isProcessing) {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: isSmall ? 36 : null,
      child: ElevatedButton(
        onPressed: isProcessing ? null : () => _addToCart(context),
        style: ElevatedButton.styleFrom(
          padding: isSmall ? const EdgeInsets.symmetric(horizontal: 12, vertical: 0) : null,
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
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (showIcon) ...[
                    const Icon(Icons.shopping_cart_outlined, size: 18),
                    const SizedBox(width: 8),
                  ],
                  Text(isSmall ? 'Add' : 'Add to Cart'),
                ],
              ),
      ),
    );
  }

  Widget _buildOutlinedButton(BuildContext context, bool isProcessing) {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: isSmall ? 36 : null,
      child: OutlinedButton(
        onPressed: isProcessing ? null : () => _addToCart(context),
        style: OutlinedButton.styleFrom(
          padding: isSmall ? const EdgeInsets.symmetric(horizontal: 12, vertical: 0) : null,
        ),
        child: isProcessing
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor,
                  ),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (showIcon) ...[
                    const Icon(Icons.shopping_cart_outlined, size: 18),
                    const SizedBox(width: 8),
                  ],
                  Text(isSmall ? 'Add' : 'Add to Cart'),
                ],
              ),
      ),
    );
  }

  void _addToCart(BuildContext context) {
    context.read<CartCubit>().addToCart(variantId);
    if (onAdded != null) {
      onAdded!();
    }
  }
}
