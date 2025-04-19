class Address {
  final String id;
  final String name;
  final String phone;
  final String address1;
  final String? address2;
  final String city;
  final String country;
  final String state;
  final String zip;
  final bool isDefault;

  Address({
    required this.id,
    required this.name,
    required this.phone,
    required this.address1,
    this.address2,
    required this.city,
    required this.country,
    required this.state,
    required this.zip,
    this.isDefault = false,
  });

  factory Address.fromJson(Map<String, dynamic> json) => Address(
        id: json['id'] as String,
        name: json['name'] as String,
        phone: json['phone'] as String,
        address1: json['address1'] as String,
        address2: json['address2'] as String?,
        city: json['city'] as String,
        country: json['country'] as String,
        state: json['state'] as String,
        zip: json['zip'] as String,
        isDefault: json['isDefault'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'address1': address1,
        'address2': address2,
        'city': city,
        'country': country,
        'state': state,
        'zip': zip,
        'isDefault': isDefault,
      };

  Address copyWith({
    String? id,
    String? name,
    String? phone,
    String? address1,
    String? address2,
    String? city,
    String? country,
    String? state,
    String? zip,
    bool? isDefault,
  }) =>
      Address(
        id: id ?? this.id,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        address1: address1 ?? this.address1,
        address2: address2 ?? this.address2,
        city: city ?? this.city,
        country: country ?? this.country,
        state: state ?? this.state,
        zip: zip ?? this.zip,
        isDefault: isDefault ?? this.isDefault,
      );

  static Address sample() => Address(
        id: 'sample-id',
        name: 'John Doe',
        phone: '+1234567890',
        address1: '123 Main St',
        address2: 'Apt 4B',
        city: 'New York',
        country: 'US',
        state: 'NY',
        zip: '10001',
        isDefault: true,
      );

  static Address fromJsonDummy() => sample();
}
