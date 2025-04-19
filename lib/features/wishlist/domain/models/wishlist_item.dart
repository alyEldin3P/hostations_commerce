class WishlistItem {
  final String id;
  final String title;
  final String description;
  final String? image;
  final String price;
  final String currency;

  WishlistItem({
    required this.id,
    required this.title,
    required this.description,
    this.image,
    required this.price,
    required this.currency,
  });

  factory WishlistItem.fromJson(Map<String, dynamic> json) {
    return WishlistItem(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      image: json['image'] as String?,
      price: json['price'],
      currency: json['currency'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'image': image,
      'price': price,
      'currency': currency,
    };
  }

  WishlistItem copyWith({
    String? id,
    String? title,
    String? description,
    String? image,
    String? price,
    String? currency,
  }) {
    return WishlistItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      image: image ?? this.image,
      price: price ?? this.price,
      currency: currency ?? this.currency,
    );
  }

  static WishlistItem sample() {
    return WishlistItem(
      id: '1',
      title: 'Sample Product',
      description: 'This is a sample product description',
      image: 'https://example.com/image.jpg',
      price: '19.99',
      currency: 'USD',
    );
  }

  static Map<String, dynamic> fromJsonDummy() {
    return {
      'id': '1',
      'title': 'Sample Product',
      'description': 'This is a sample product description',
      'image': 'https://example.com/image.jpg',
      'price': '19.99',
      'currency': 'USD',
    };
  }
}
