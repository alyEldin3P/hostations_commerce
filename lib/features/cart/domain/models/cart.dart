import 'package:hostations_commerce/features/address/data/model/address.dart';
import 'package:hostations_commerce/features/cart/domain/models/cart_item.dart';
import 'package:hostations_commerce/features/cart/domain/models/address.dart';

class DeliveryGroup {
  final String id;
  final String? selectedDeliveryOptionHandle;

  DeliveryGroup({required this.id, this.selectedDeliveryOptionHandle});

  factory DeliveryGroup.fromJson(Map<String, dynamic> json) {
    return DeliveryGroup(
      id: json['id'],
      selectedDeliveryOptionHandle: json['selectedDeliveryOption']?['handle'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'selectedDeliveryOptionHandle': selectedDeliveryOptionHandle,
      };
}

class Cart {
  final String id;
  final List<CartItem> items;
  final String subtotal;
  final String total;
  final String currency;
  final int itemCount;
  final double? tax;
  final double? discount;
  final List<DeliveryGroup>? deliveryGroups;
  final Address? shippingAddress;

  const Cart({
    required this.id,
    required this.items,
    required this.subtotal,
    required this.total,
    required this.currency,
    required this.itemCount,
    this.tax,
    this.discount,
    this.deliveryGroups,
    this.shippingAddress,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      id: json['id'],
      items: (json['items'] as List<dynamic>?)?.map((e) => CartItem.fromJson(e)).toList() ?? [],
      subtotal: json['subtotal'] ?? '0.00',
      total: json['total'] ?? '0.00',
      currency: json['currency'] ?? '',
      itemCount: json['itemCount'] ?? 0,
      tax: (json['tax'] as num?)?.toDouble(),
      discount: (json['discount'] as num?)?.toDouble(),
      deliveryGroups: (json['deliveryGroups'] as List<dynamic>?)?.map((e) => DeliveryGroup.fromJson(e)).toList(),
      shippingAddress: json['shippingAddress'] != null ? Address.fromJson(json['shippingAddress']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'total': total,
      'currency': currency,
      'itemCount': itemCount,
      'tax': tax,
      'discount': discount,
      'deliveryGroups': deliveryGroups?.map((g) => g.toJson()).toList(),
      'shippingAddress': shippingAddress?.toJson(),
    };
  }

  Cart copyWith({
    String? id,
    List<CartItem>? items,
    String? subtotal,
    String? total,
    String? currency,
    int? itemCount,
    double? tax,
    double? discount,
    List<DeliveryGroup>? deliveryGroups,
    Address? shippingAddress,
  }) {
    return Cart(
      id: id ?? this.id,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      total: total ?? this.total,
      currency: currency ?? this.currency,
      itemCount: itemCount ?? this.itemCount,
      tax: tax ?? this.tax,
      discount: discount ?? this.discount,
      deliveryGroups: deliveryGroups ?? this.deliveryGroups,
      shippingAddress: shippingAddress ?? this.shippingAddress,
    );
  }

  static Cart empty() {
    return Cart(
      id: '',
      items: [],
      subtotal: '0.00',
      total: '0.00',
      currency: 'USD',
      itemCount: 0,
      deliveryGroups: [],
      shippingAddress: null,
    );
  }

  static Cart sample() {
    return Cart(
      id: 'cart1',
      items: [CartItem.sample(), CartItem.sample().copyWith(id: '2', title: 'Another Product')],
      subtotal: '39.98',
      total: '43.98',
      currency: 'USD',
      itemCount: 2,
      tax: 4.00,
      discount: 0.00,
      deliveryGroups: [DeliveryGroup(id: 'group1', selectedDeliveryOptionHandle: 'standard')],
      shippingAddress: Address.sample(),
    );
  }

  static Map<String, dynamic> fromJsonDummy() {
    return {
      'id': 'cart1',
      'items': [CartItem.fromJsonDummy(), CartItem.fromJsonDummy()],
      'subtotal': '39.98',
      'total': '43.98',
      'currency': 'USD',
      'itemCount': 2,
      'tax': 4.00,
      'discount': 0.00,
      'deliveryGroups': [
        {'id': 'group1', 'selectedDeliveryOptionHandle': 'standard'},
      ],
      'shippingAddress': Address.fromJsonDummy(),
    };
  }
}
