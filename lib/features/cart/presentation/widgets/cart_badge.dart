import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hostations_commerce/core/di/dependency_injection.dart';
import 'package:hostations_commerce/features/cart/presentation/cubits/cart_cubit.dart';
import 'package:hostations_commerce/features/cart/presentation/cubits/cart_state.dart';
import 'package:hostations_commerce/features/cart/presentation/screens/cart_screen.dart';

class CartBadge extends StatelessWidget {
  final Color? badgeColor;
  final Color? iconColor;
  final double iconSize;
  final VoidCallback? onTap;

  const CartBadge({
    super.key,
    this.badgeColor,
    this.iconColor,
    this.iconSize = 24.0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        return Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: Icon(
                Icons.shopping_cart_outlined,
                color: iconColor,
                size: iconSize,
              ),
              onPressed: onTap ??
                  () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const CartScreen(),
                      ),
                    );
                  },
            ),
            if (state.cart.itemCount > 0)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: badgeColor ?? Theme.of(context).colorScheme.error,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    state.cart.itemCount > 9 ? '9+' : '${state.cart.itemCount}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
