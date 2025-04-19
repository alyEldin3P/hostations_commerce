class Category {
  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final List<Category> subCategories;

  Category({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    this.subCategories = const [],
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      imageUrl: json['image']?['src'] as String?,
      subCategories: (json['subCategories'] as List<dynamic>?)?.map((e) => Category.fromJson(e as Map<String, dynamic>)).toList() ?? [],
    );
  }

  factory Category.fromShopify(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      imageUrl: json['image']?['url'] as String?,
      subCategories: (json['children']?['edges'] as List<dynamic>?)?.map((e) => Category.fromShopify(e['node'] as Map<String, dynamic>)).toList() ?? [],
    );
  }

  // Sample data for testing
  static List<Category> get sample {
    return [
      Category(
        id: '1',
        title: 'Electronics',
        description: 'Description for Electronics',
        imageUrl: 'https://via.placeholder.com/150',
        subCategories: [
          Category(
            id: '1-1',
            title: 'Smartphones',
            description: 'Description for Smartphones',
            imageUrl: 'https://via.placeholder.com/150',
          ),
          Category(
            id: '1-2',
            title: 'Laptops',
            description: 'Description for Laptops',
            imageUrl: 'https://via.placeholder.com/150',
          ),
        ],
      ),
      Category(
        id: '2',
        title: 'Clothing',
        description: 'Description for Clothing',
        imageUrl: 'https://via.placeholder.com/150',
        subCategories: [
          Category(
            id: '2-1',
            title: 'Men',
            description: 'Description for Men',
            imageUrl: 'https://via.placeholder.com/150',
          ),
          Category(
            id: '2-2',
            title: 'Women',
            description: 'Description for Women',
            imageUrl: 'https://via.placeholder.com/150',
          ),
        ],
      ),
      Category(
        id: '3',
        title: 'Home & Kitchen',
        description: 'Description for Home & Kitchen',
        imageUrl: 'https://via.placeholder.com/150',
      ),
      Category(
        id: '4',
        title: 'Books',
        description: 'Description for Books',
        imageUrl: 'https://via.placeholder.com/150',
      ),
      Category(
        id: '5',
        title: 'Sports',
        description: 'Description for Sports',
        imageUrl: 'https://via.placeholder.com/150',
      ),
    ];
  }

  // Create a dummy from JSON
  static Category fromJsonDummy(Map<String, dynamic> json) {
    return Category.fromJson(json);
  }
}
