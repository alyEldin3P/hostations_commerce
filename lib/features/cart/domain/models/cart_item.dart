class CartItem {
  final String id;
  final String variantId;
  final String title;
  final String? image;
  final String price;
  final String currency;
  final int quantity;
  final String? variantTitle;

  CartItem({
    required this.id,
    required this.variantId,
    required this.title,
    this.image,
    required this.price,
    required this.currency,
    required this.quantity,
    this.variantTitle,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      variantId: json['variantId'],
      title: json['title'],
      image: json['image'] as String?,
      price: json['price'],
      currency: json['currency'],
      quantity: json['quantity'],
      variantTitle: json['variantTitle'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'variantId': variantId,
      'title': title,
      'image': image,
      'price': price,
      'currency': currency,
      'quantity': quantity,
      'variantTitle': variantTitle,
    };
  }

  CartItem copyWith({
    String? id,
    String? variantId,
    String? title,
    String? image,
    String? price,
    String? currency,
    int? quantity,
    String? variantTitle,
  }) {
    return CartItem(
      id: id ?? this.id,
      variantId: variantId ?? this.variantId,
      title: title ?? this.title,
      image: image ?? this.image,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      quantity: quantity ?? this.quantity,
      variantTitle: variantTitle ?? this.variantTitle,
    );
  }

  static CartItem sample() {
    return CartItem(
      id: '1',
      variantId: 'variant1',
      title: 'Sample Product',
      image: 'https://example.com/image.jpg',
      price: '19.99',
      currency: 'USD',
      quantity: 1,
      variantTitle: 'Small / Red',
    );
  }

  static Map<String, dynamic> fromJsonDummy() {
    return {
      'id': '1',
      'variantId': 'variant1',
      'title': 'Sample Product',
      'image': 'https://example.com/image.jpg',
      'price': '19.99',
      'currency': 'USD',
      'quantity': 1,
      'variantTitle': 'Small / Red',
    };
  }
}
