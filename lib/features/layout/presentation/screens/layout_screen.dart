import 'dart:ui';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hostations_commerce/core/di/dependency_injection.dart';
import 'package:hostations_commerce/features/cart/presentation/cubits/cart_cubit.dart';
import 'package:hostations_commerce/features/cart/presentation/cubits/cart_state.dart';
import 'package:hostations_commerce/features/cart/presentation/screens/cart_screen.dart';
import 'package:hostations_commerce/features/home/presentation/screens/home_screen.dart';
import 'package:hostations_commerce/features/profile/presentation/screens/profile_screen.dart';
import 'package:hostations_commerce/widgets/app_widgets.dart';
import 'package:hostations_commerce/theme/app_theme.dart';

class LayoutScreen extends StatelessWidget {
  static const String routeName = '/home';

  const LayoutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const _HomeScreenContent();
  }
}

class _HomeScreenContent extends StatefulWidget {
  const _HomeScreenContent();

  @override
  State<_HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<_HomeScreenContent> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const CartScreen(),
    const ProfileScreen(),
  ];

  final List<IconData> _activeIcons = [
    Icons.home,
    Icons.shopping_cart,
    Icons.person,
  ];

  // TODO: Replace with actual user name from profile state
  final String userName = 'Taimoor Sikander';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      AppText(
                        'Hello,',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white70),
                      ),
                      AppText(
                        userName,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  BlocProvider.value(
                    value: DependencyInjector().cartCubit..loadCart(),
                    child: BlocBuilder<CartCubit, CartState>(
                      builder: (context, cartState) {
                        return Stack(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.shopping_cart, color: Colors.white, size: 32),
                              onPressed: () => setState(() => _currentIndex = 1),
                            ),
                            if (cartState.cart.itemCount > 0)
                              Positioned(
                                right: 6,
                                top: 10,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: AppColors.accent,
                                    shape: BoxShape.circle,
                                  ),
                                  constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                                  child: Center(
                                    child: Text(
                                      '${cartState.cart.itemCount}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: SimpleNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        cartItemCountProvider: DependencyInjector().cartCubit,
        icons: _activeIcons,
      ),
    );
  }
}

class SimpleNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final CartCubit cartItemCountProvider;
  final List<IconData> icons;

  const SimpleNavBar({
    required this.currentIndex,
    required this.onTap,
    required this.cartItemCountProvider,
    required this.icons,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: cartItemCountProvider..loadCart(),
      child: BlocBuilder<CartCubit, CartState>(
        builder: (context, cartState) {
          return Container(
            margin: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.07),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(icons.length, (index) {
                final bool isActive = currentIndex == index;
                final Color iconColor = isActive ? AppColors.primary : AppColors.textSecondary;
                return Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => onTap(index),
                    child: SizedBox(
                      height: 60,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            icons[index],
                            color: iconColor,
                            size: 28,
                          ),
                          if (index == 1 && cartState.cart.itemCount > 0)
                            Positioned(
                              right: 18,
                              top: 14,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: AppColors.accent,
                                  shape: BoxShape.circle,
                                ),
                                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                                child: Center(
                                  child: Text(
                                    '${cartState.cart.itemCount}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          );
        },
      ),
    );
  }
}
