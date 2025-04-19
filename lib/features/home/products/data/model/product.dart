class Product {
  final String id;
  final String title;
  final String description;
  final double price;
  final double? compareAtPrice;
  final List<String> images;
  final bool available;
  final List<ProductVariant> variants;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    this.compareAtPrice,
    required this.images,
    required this.available,
    required this.variants,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      price: double.parse(json['price'].toString()),
      compareAtPrice: json['compareAtPrice'] != null ? double.parse(json['compareAtPrice'].toString()) : null,
      images: (json['images'] as List<dynamic>).map((e) => e['src'] as String).toList(),
      available: json['available'] as bool,
      variants: (json['variants'] as List<dynamic>).map((e) => ProductVariant.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  factory Product.fromShopify(Map<String, dynamic> json) {
    final node = json['node'] ?? json;
    final priceV2 = node['priceRange']['minVariantPrice'];
    final compareAtPriceV2 = node['compareAtPriceRange']?['maxVariantPrice'];

    return Product(
      id: node['id'] as String,
      title: node['title'] as String,
      description: node['description'] as String,
      price: double.parse(priceV2['amount'].toString()),
      compareAtPrice: compareAtPriceV2 != null && compareAtPriceV2['amount'] != null ? double.parse(compareAtPriceV2['amount'].toString()) : null,
      images: (node['images']['edges'] as List<dynamic>).map((edge) => edge['node']['originalSrc'] as String).toList(),
      available: node['availableForSale'] as bool,
      variants: (node['variants']['edges'] as List<dynamic>).map((edge) => ProductVariant.fromShopify(edge['node'] as Map<String, dynamic>)).toList(),
    );
  }

  // Sample data for testing
  static List<Product> get sample {
    return List.generate(
      10,
      (index) => Product(
        id: 'product-${index + 1}',
        title: 'Product ${index + 1}',
        description: 'This is a detailed description for Product ${index + 1}. It includes all the features and specifications that a customer might want to know before making a purchase.',
        price: (index + 1) * 10.99,
        compareAtPrice: index % 2 == 0 ? (index + 1) * 15.99 : null,
        images: [
          'https://via.placeholder.com/500',
          'https://via.placeholder.com/500?text=Image2',
          'https://via.placeholder.com/500?text=Image3',
        ],
        available: true,
        variants: [
          ProductVariant(
            id: 'variant-${index + 1}-1',
            title: 'Small',
            price: (index + 1) * 10.99,
            available: true,
          ),
          ProductVariant(
            id: 'variant-${index + 1}-2',
            title: 'Medium',
            price: (index + 1) * 12.99,
            available: true,
          ),
          ProductVariant(
            id: 'variant-${index + 1}-3',
            title: 'Large',
            price: (index + 1) * 14.99,
            available: index % 3 != 0,
          ),
        ],
      ),
    );
  }

  // Create a dummy from JSON
  static Product fromJsonDummy(Map<String, dynamic> json) {
    return Product.fromJson(json);
  }
}

class ProductVariant {
  final String id;
  final String title;
  final double price;
  final bool available;

  ProductVariant({
    required this.id,
    required this.title,
    required this.price,
    required this.available,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      id: json['id'] as String,
      title: json['title'] as String,
      price: double.parse(json['price'].toString()),
      available: json['available'] as bool,
    );
  }

  factory ProductVariant.fromShopify(Map<String, dynamic> json) {
    return ProductVariant(
      id: json['id'] as String,
      title: json['title'] as String,
      price: double.parse(json['priceV2']['amount'].toString()),
      available: json['availableForSale'] as bool,
    );
  }
}
