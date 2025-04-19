class ShippingMethod {
  final String id;
  final String title;
  final String description;
  final double price;
  final String currency;

  ShippingMethod({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.currency,
  });

  factory ShippingMethod.fromJson(Map<String, dynamic> json) {
    return ShippingMethod(
      id: json['handle'] ?? json['id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      price: double.tryParse(json['totalAmount']?['amount']?.toString() ?? '0') ?? 0,
      currency: json['totalAmount']?['currencyCode'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'price': price,
    'currency': currency,
  };
}
