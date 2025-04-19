import '../model/address.dart';

abstract class AddressRepository {
  Future<List<Address>> fetchAllAddresses(bool isGuest);
  Future<Address> createAddress(Address address, bool isGuest);
  Future<Address> editAddress(Address address, bool isGuest);
  Future<void> deleteAddress(String id, bool isGuest);
}
