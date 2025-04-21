import 'address.dart';

// Maps for country and province/state codes
const countryNameToCode = <String, String>{
  "Egypt": "EG",
  "United States": "US",
  // Add more countries as needed
};

const provinceNameToCode = <String, Map<String, String>>{
  "Egypt": {
    "Cairo": "C",
    "Giza": "GZ",
    // Add more Egyptian governorates as needed
  },
  "United States": {
    "California": "CA",
    "New York": "NY",
    // Add more US states as needed
  },
  // Add more countries and their provinces/states as needed
};

/// Converts an Address (with country/state names) to the structure required by Shopify's CartDeliveryAddressInput.
Map<String, dynamic> toCartDeliveryAddressInput(Address address) {
  final countryCode = countryNameToCode[address.country];
  final provinceCode = provinceNameToCode[address.country]?[address.state];

  return {
    'firstName': address.name, // You may want to split name if needed
    'address1': address.address1,
    'address2': address.address2,
    'city': address.city,
    'countryCode': countryCode,
    'provinceCode': provinceCode,
    'zip': address.zip,
    'phone': address.phone,
  };
}
