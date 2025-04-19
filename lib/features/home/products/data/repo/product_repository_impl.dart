import 'package:hostations_commerce/features/home/products/data/model/product.dart';
import 'package:hostations_commerce/features/home/products/data/remote/product_remote_data_source.dart';
import 'package:hostations_commerce/features/home/products/domain/repository/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;

  ProductRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Product>> getProducts() async {
    return await remoteDataSource.getProducts();
  }

  @override
  Future<List<Product>> getProductsByCategory(String categoryId) async {
    return await remoteDataSource.getProductsByCategory(categoryId);
  }

  @override
  Future<Product> getProductById(String id) async {
    return await remoteDataSource.getProductById(id);
  }

  @override
  Future<List<Product>> getMostSellingProducts() async {
    return await remoteDataSource.getMostSellingProducts();
  }

  @override
  Future<List<Product>> getSaleProducts() async {
    return await remoteDataSource.getSaleProducts();
  }
}
