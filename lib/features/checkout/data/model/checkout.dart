class Checkout {
  final String id;
  final String checkoutUrl;
  final List<dynamic> lineItems;

  Checkout({required this.id, required this.checkoutUrl, required this.lineItems});

  factory Checkout.fromJson(Map<String, dynamic> json) => Checkout(
        id: json['id'] as String,
        checkoutUrl: json['checkoutUrl'] as String,
        lineItems: json['lines'] != null && json['lines']['edges'] != null
            ? (json['lines']['edges'] as List).map((e) => e['node']).toList()
            : [],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'checkoutUrl': checkoutUrl,
        'lineItems': lineItems,
      };

  // TODO: Add fromJsonDummy, sample, and more fields as needed
}
