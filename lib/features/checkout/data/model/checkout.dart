class Checkout {
  final String id;
  final String webUrl;
  final List<dynamic> lineItems;

  Checkout({required this.id, required this.webUrl, required this.lineItems});

  factory Checkout.fromJson(Map<String, dynamic> json) => Checkout(
        id: json['id'] as String,
        webUrl: json['webUrl'] as String,
        lineItems: json['lineItems'] as List<dynamic>,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'webUrl': webUrl,
        'lineItems': lineItems,
      };

  // TODO: Add fromJsonDummy, sample, and more fields as needed
}
