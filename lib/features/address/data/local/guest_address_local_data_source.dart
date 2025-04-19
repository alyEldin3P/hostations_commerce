import 'address_local_data_source.dart';
import '../model/address.dart';

class GuestAddressLocalDataSource implements AddressLocalDataSource {
  final List<Address> _addresses = [];

  @override
  Future<List<Address>> fetchAllAddresses() async {
    // Simulate delay
    await Future.delayed(const Duration(milliseconds: 200));
    return List<Address>.from(_addresses);
  }

  @override
  Future<Address> createAddress(Address address) async {
    _addresses.add(address);
    return address;
  }

  @override
  Future<Address> editAddress(Address address) async {
    final index = _addresses.indexWhere((a) => a.id == address.id);
    if (index != -1) {
      _addresses[index] = address;
      return address;
    }
    throw Exception('Address not found');
  }

  @override
  Future<void> deleteAddress(String id) async {
    _addresses.removeWhere((a) => a.id == id);
  }
}
