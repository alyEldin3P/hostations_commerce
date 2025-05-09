// class Address {
//   final String firstName;
//   final String lastName;
//   final String address1;
//   final String? address2;
//   final String city;
//   final String province;
//   final String country;
//   final String zip;
//   final String phone;

//   Address({
//     required this.firstName,
//     required this.lastName,
//     required this.address1,
//     this.address2,
//     required this.city,
//     required this.province,
//     required this.country,
//     required this.zip,
//     required this.phone,
//   });

//   factory Address.fromJson(Map<String, dynamic> json) {
//     return Address(
//       firstName: json['firstName'] ?? '',
//       lastName: json['lastName'] ?? '',
//       address1: json['address1'] ?? '',
//       address2: json['address2'],
//       city: json['city'] ?? '',
//       province: json['province'] ?? '',
//       country: json['country'] ?? '',
//       zip: json['zip'] ?? '',
//       phone: json['phone'] ?? '',
//     );
//   }

//   Map<String, dynamic> toJson() => {
//     'firstName': firstName,
//     'lastName': lastName,
//     'address1': address1,
//     'address2': address2,
//     'city': city,
//     'province': province,
//     'country': country,
//     'zip': zip,
//     'phone': phone,
//   };

//   @override
//   String toString() {
//     return ' $firstName $lastName, $address1${address2 != null ? ", $address2" : ""}, $city, $province, $country, $zip, $phone';
//   }

//   static Address sample() {
//     return Address(
//       firstName: 'John',
//       lastName: 'Doe',
//       address1: '123 Main St',
//       address2: 'Apt 4B',
//       city: 'Cairo',
//       province: 'Cairo',
//       country: 'EG',
//       zip: '12345',
//       phone: '+201234567890',
//     );
//   }

//   static Map<String, dynamic> fromJsonDummy() {
//     return {
//       'firstName': 'John',
//       'lastName': 'Doe',
//       'address1': '123 Main St',
//       'address2': 'Apt 4B',
//       'city': 'Cairo',
//       'province': 'Cairo',
//       'country': 'EG',
//       'zip': '12345',
//       'phone': '+201234567890',
//     };
//   }
// }
