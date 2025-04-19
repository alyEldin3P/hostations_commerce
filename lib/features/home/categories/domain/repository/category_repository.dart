import 'package:hostations_commerce/features/home/categories/data/model/category.dart';

abstract class CategoryRepository {
  /// Fetches all categories from the store
  Future<List<Category>> getCategories();
  
  /// Fetches a specific category by ID
  Future<Category> getCategoryById(String id);
}
