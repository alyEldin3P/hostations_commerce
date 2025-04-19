import 'address_remote_data_source.dart';
import '../model/address.dart';

class GuestAddressRemoteDataSource implements AddressRemoteDataSource {
  @override
  Future<List<Address>> fetchAllAddresses() async => [];

  @override
  Future<Address> createAddress(Address address) async => address;

  @override
  Future<Address> editAddress(Address address) async => address;

  @override
  Future<void> deleteAddress(String id) async {}
}
