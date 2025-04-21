class Order {
  final String id;
  final String name;
  final DateTime processedAt;
  final double total;
  final String currencyCode;
  final String fulfillmentStatus;
  final String financialStatus;
  final List<LineItem> lineItems;

  Order({
    required this.id,
    required this.name,
    required this.processedAt,
    required this.total,
    required this.currencyCode,
    required this.fulfillmentStatus,
    required this.financialStatus,
    required this.lineItems,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      name: json['name'] as String,
      processedAt: DateTime.parse(json['processedAt'] as String),
      total: double.tryParse(json['totalPriceV2']?['amount']?.toString() ?? '0') ?? 0,
      currencyCode: json['totalPriceV2']?['currencyCode'] ?? '',
      fulfillmentStatus: json['fulfillmentStatus'] ?? '',
      financialStatus: json['financialStatus'] ?? '',
      lineItems: ((json['lineItems']?['edges'] ?? []) as List)
          .map((e) => LineItem.fromJson(e['node']))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'processedAt': processedAt.toIso8601String(),
        'totalPriceV2': {
          'amount': total.toString(),
          'currencyCode': currencyCode,
        },
        'fulfillmentStatus': fulfillmentStatus,
        'financialStatus': financialStatus,
        'lineItems': {
          'edges': lineItems.map((li) => {'node': li.toJson()}).toList(),
        },
      };

  static Order fromJsonDummy() {
    return Order(
      id: 'gid://shopify/Order/1',
      name: '#1001',
      processedAt: DateTime.now(),
      total: 100.0,
      currencyCode: 'USD',
      fulfillmentStatus: 'FULFILLED',
      financialStatus: 'PAID',
      lineItems: [LineItem.fromJsonDummy()],
    );
  }

  static Order sample() => fromJsonDummy();
}

class LineItem {
  final String title;
  final int quantity;
  final double price;
  final String currencyCode;

  LineItem({
    required this.title,
    required this.quantity,
    required this.price,
    required this.currencyCode,
  });

  factory LineItem.fromJson(Map<String, dynamic> json) {
    return LineItem(
      title: json['title'] ?? '',
      quantity: json['quantity'] ?? 0,
      price: double.tryParse(json['variant']?['priceV2']?['amount']?.toString() ?? '0') ?? 0,
      currencyCode: json['variant']?['priceV2']?['currencyCode'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'quantity': quantity,
        'variant': {
          'priceV2': {
            'amount': price.toString(),
            'currencyCode': currencyCode,
          },
        },
      };

  static LineItem fromJsonDummy() {
    return LineItem(
      title: 'Sample Product',
      quantity: 1,
      price: 50.0,
      currencyCode: 'USD',
    );
  }
}
