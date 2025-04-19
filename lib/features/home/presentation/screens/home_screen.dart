import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'package:hostations_commerce/features/home/categories/data/model/category.dart';
import 'package:hostations_commerce/features/home/presentation/cubits/home_cubit.dart';
import 'package:hostations_commerce/features/home/presentation/cubits/home_state.dart';
import 'package:hostations_commerce/features/home/presentation/screens/categories_screen.dart';
import 'package:hostations_commerce/features/home/presentation/screens/product_details_screen.dart';
import 'package:hostations_commerce/features/home/presentation/screens/products_by_category_screen.dart';
import 'package:hostations_commerce/features/home/products/data/model/product.dart';
import 'package:hostations_commerce/features/home/products/presentation/cubits/product_selection_cubit.dart';
import 'package:hostations_commerce/widgets/app_widgets.dart';
import 'package:hostations_commerce/theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> bannerImages = [
    'assets/images/banner1.png',
    'assets/images/banner2.png',
    'assets/images/banner3.png',
  ];

  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
    context.read<HomeCubit>().loadHomeData();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      setState(() {
        _currentIndex = (_currentIndex + 1) % bannerImages.length;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        if (state.status == HomeStatus.initial) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () => context.read<HomeCubit>().loadHomeData(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Banner Carousel
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: SizedBox(
                    height: 170,
                    child: PageView.builder(
                      itemCount: bannerImages.length,
                      controller: PageController(viewportFraction: 0.9),
                      onPageChanged: (i) => setState(() => _currentIndex = i),
                      itemBuilder: (context, index) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          margin: EdgeInsets.symmetric(horizontal: index == _currentIndex ? 0 : 8, vertical: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.10),
                                blurRadius: 18,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Image.asset(
                              bannerImages[index],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: Colors.grey[200],
                                child: const Icon(Icons.image, size: 60, color: AppColors.primary),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                // Dots indicator for banners
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      bannerImages.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: _currentIndex == i ? 28 : 8,
                        decoration: BoxDecoration(
                          color: _currentIndex == i ? AppColors.primary : AppColors.border,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Categories
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppText('Categories', style: Theme.of(context).textTheme.titleMedium),
                      AppButton(
                        label: 'View All',
                        outlined: true,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const CategoriesScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 110,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: state.categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 16),
                    itemBuilder: (context, i) {
                      final category = state.categories[i];
                      return GestureDetector(
                        onTap: () {
                          context.read<HomeCubit>().selectCategory(category);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProductsByCategoryScreen(category: category),
                            ),
                          );
                        },
                        child: AppCard(
                          margin: EdgeInsets.zero,
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                backgroundColor: AppColors.primary.withOpacity(0.08),
                                radius: 22,
                                child: category.imageUrl != null
                                    ? Image.network(
                                        category.imageUrl!,
                                        height: 30,
                                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.category, color: AppColors.primary),
                                      )
                                    : const Icon(Icons.category, color: AppColors.primary),
                              ),
                              const SizedBox(height: 8),
                              AppText(category.title, style: Theme.of(context).textTheme.bodyMedium),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 28),
                // Top Products
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: AppText('Top Products', style: Theme.of(context).textTheme.titleMedium),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 260,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: state.saleProducts.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 16),
                    itemBuilder: (context, i) {
                      final product = state.saleProducts[i];
                      return GestureDetector(
                        onTap: () {
                          context.read<HomeCubit>().loadProductDetails(product.id);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProductDetailsScreen(productId: product.id),
                            ),
                          );
                        },
                        child: AppCard(
                          margin: EdgeInsets.zero,
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: product.images.isNotEmpty
                                    ? Image.asset(
                                        product.images.first,
                                        height: 110,
                                        width: 110,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.image, color: AppColors.primary),
                                      )
                                    : const Icon(Icons.image, color: AppColors.primary, size: 60),
                              ),
                              const SizedBox(height: 12),
                              AppText(product.title, style: Theme.of(context).textTheme.bodyLarge, maxLines: 2, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 4),
                              AppText('\$${product.price.toStringAsFixed(2)}', style: Theme.of(context).textTheme.labelLarge),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 28),
                // Sale Products
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: AppText('Sale', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.accent)),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 200,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: state.saleProducts.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 16),
                    itemBuilder: (context, i) {
                      final product = state.saleProducts[i];
                      return GestureDetector(
                        onTap: () {
                          context.read<HomeCubit>().loadProductDetails(product.id);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProductDetailsScreen(productId: product.id),
                            ),
                          );
                        },
                        child: AppCard(
                          margin: EdgeInsets.zero,
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: product.images.isNotEmpty
                                    ? Image.asset(
                                        product.images.first,
                                        height: 80,
                                        width: 80,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.image, color: AppColors.primary),
                                      )
                                    : const Icon(Icons.image, color: AppColors.primary, size: 40),
                              ),
                              const SizedBox(height: 12),
                              AppText(product.title, style: Theme.of(context).textTheme.bodyLarge, maxLines: 2, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  AppText('\$${product.price.toStringAsFixed(2)}', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.accent)),
                                  if (product.compareAtPrice != null)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8),
                                      child: AppText(
                                        '\$${product.price.toStringAsFixed(2)}',
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                              decoration: TextDecoration.lineThrough,
                                              color: AppColors.textSecondary,
                                            ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }
}
