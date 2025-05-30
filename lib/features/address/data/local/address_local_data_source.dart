import '../model/address.dart';

abstract class AddressLocalDataSource {
  Future<List<Address>> fetchAllAddresses();
  Future<Address> createAddress(Address address);
  Future<Address> editAddress(Address address);
  Future<void> deleteAddress(String id);
}
