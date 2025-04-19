import 'package:hostations_commerce/features/home/categories/data/model/category.dart';
import 'package:hostations_commerce/features/home/products/data/model/product.dart';

enum HomeStatus {
  initial,
  loading,
  loaded,
  error,
}

class HomeState {
  final HomeStatus status;
  final List<Category> categories;
  final List<Product> mostSellingProducts;
  final List<Product> saleProducts;
  final String? errorMessage;
  final bool isCategoriesLoading;
  final bool isMostSellingProductsLoading;
  final bool isSaleProductsLoading;
  final Category? selectedCategory;
  final List<Product>? categoryProducts;
  final Product? selectedProduct;
  final bool isProductDetailsLoading;

  HomeState({
    this.status = HomeStatus.initial,
    this.categories = const [],
    this.mostSellingProducts = const [],
    this.saleProducts = const [],
    this.errorMessage,
    this.isCategoriesLoading = false,
    this.isMostSellingProductsLoading = false,
    this.isSaleProductsLoading = false,
    this.selectedCategory,
    this.categoryProducts,
    this.selectedProduct,
    this.isProductDetailsLoading = false,
  });

  HomeState copyWith({
    HomeStatus? status,
    List<Category>? categories,
    List<Product>? mostSellingProducts,
    List<Product>? saleProducts,
    String? errorMessage,
    bool? isCategoriesLoading,
    bool? isMostSellingProductsLoading,
    bool? isSaleProductsLoading,
    Category? selectedCategory,
    List<Product>? categoryProducts,
    Product? selectedProduct,
    bool? isProductDetailsLoading,
  }) {
    return HomeState(
      status: status ?? this.status,
      categories: categories ?? this.categories,
      mostSellingProducts: mostSellingProducts ?? this.mostSellingProducts,
      saleProducts: saleProducts ?? this.saleProducts,
      errorMessage: errorMessage ?? this.errorMessage,
      isCategoriesLoading: isCategoriesLoading ?? this.isCategoriesLoading,
      isMostSellingProductsLoading: isMostSellingProductsLoading ?? this.isMostSellingProductsLoading,
      isSaleProductsLoading: isSaleProductsLoading ?? this.isSaleProductsLoading,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      categoryProducts: categoryProducts ?? this.categoryProducts,
      selectedProduct: selectedProduct ?? this.selectedProduct,
      isProductDetailsLoading: isProductDetailsLoading ?? this.isProductDetailsLoading,
    );
  }
}
