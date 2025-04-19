import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hostations_commerce/features/home/categories/data/model/category.dart';
import 'package:hostations_commerce/features/home/categories/domain/repository/category_repository.dart';
import 'package:hostations_commerce/features/home/presentation/cubits/home_state.dart';
import 'package:hostations_commerce/features/home/products/data/model/product.dart';
import 'package:hostations_commerce/features/home/products/domain/repository/product_repository.dart';

class HomeCubit extends Cubit<HomeState> {
  final CategoryRepository categoryRepository;
  final ProductRepository productRepository;

  HomeCubit({
    required this.categoryRepository,
    required this.productRepository,
  }) : super(HomeState());

  Future<void> loadHomeData() async {
    emit(state.copyWith(
      status: HomeStatus.loading,
      isCategoriesLoading: true,
      isMostSellingProductsLoading: true,
      isSaleProductsLoading: true,
    ));

    try {
      // Load categories, featured products, and sale products in parallel
      await Future.wait([
        _loadCategories(),
        _loadMostSellingProducts(),
        _loadSaleProducts(),
      ]);

      emit(state.copyWith(
        status: HomeStatus.loaded,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: HomeStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await categoryRepository.getCategories();
      emit(state.copyWith(
        categories: categories,
        isCategoriesLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isCategoriesLoading: false,
        errorMessage: 'Failed to load categories: ${e.toString()}',
      ));
    }
  }

  Future<void> _loadMostSellingProducts() async {
    try {
      final mostSellingProducts = await productRepository.getMostSellingProducts();
      emit(state.copyWith(
        mostSellingProducts: mostSellingProducts,
        isMostSellingProductsLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isMostSellingProductsLoading: false,
        errorMessage: 'Failed to load featured products: ${e.toString()}',
      ));
    }
  }

  Future<void> _loadSaleProducts() async {
    try {
      final saleProducts = await productRepository.getSaleProducts();
      emit(state.copyWith(
        saleProducts: saleProducts,
        isSaleProductsLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isSaleProductsLoading: false,
        errorMessage: 'Failed to load sale products: ${e.toString()}',
      ));
    }
  }

  Future<void> selectCategory(Category category) async {
    emit(state.copyWith(
      selectedCategory: category,
      categoryProducts: null, // Clear previous products
      status: HomeStatus.loading,
    ));

    try {
      final products = await productRepository.getProductsByCategory(category.id);
      emit(state.copyWith(
        categoryProducts: products,
        status: HomeStatus.loaded,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: HomeStatus.error,
        errorMessage: 'Failed to load products for category: ${e.toString()}',
      ));
    }
  }

  Future<void> loadProductDetails(String productId) async {
    emit(state.copyWith(
      isProductDetailsLoading: true,
    ));

    try {
      final product = await productRepository.getProductById(productId);
      emit(state.copyWith(
        selectedProduct: product,
        isProductDetailsLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isProductDetailsLoading: false,
        errorMessage: 'Failed to load product details: ${e.toString()}',
      ));
    }
  }

  void clearSelectedCategory() {
    emit(state.copyWith(
      selectedCategory: null,
      categoryProducts: null,
    ));
  }

  void clearSelectedProduct() {
    emit(state.copyWith(
      selectedProduct: null,
    ));
  }
}
