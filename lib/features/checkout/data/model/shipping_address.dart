class ShippingAddress {
  final String firstName;
  final String lastName;
  final String address1;
  final String city;
  final String country;
  final String zip;

  ShippingAddress({
    required this.firstName,
    required this.lastName,
    required this.address1,
    required this.city,
    required this.country,
    required this.zip,
  });

  factory ShippingAddress.fromJson(Map<String, dynamic> json) => ShippingAddress(
        firstName: json['firstName'] as String,
        lastName: json['lastName'] as String,
        address1: json['address1'] as String,
        city: json['city'] as String,
        country: json['country'] as String,
        zip: json['zip'] as String,
      );

  Map<String, dynamic> toJson() => {
        'firstName': firstName,
        'lastName': lastName,
        'address1': address1,
        'city': city,
        'country': country,
        'zip': zip,
      };

  // TODO: Add fromJsonDummy, sample, and more fields as needed
}
