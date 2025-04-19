import 'package:hostations_commerce/features/home/products/data/model/product.dart';

abstract class ProductRepository {
  /// Fetches all products
  Future<List<Product>> getProducts();

  /// Fetches products by category ID
  Future<List<Product>> getProductsByCategory(String categoryId);

  /// Fetches a specific product by ID
  Future<Product> getProductById(String id);

  /// Fetches featured products
  Future<List<Product>> getMostSellingProducts();

  /// Fetches products on sale
  Future<List<Product>> getSaleProducts();
}
