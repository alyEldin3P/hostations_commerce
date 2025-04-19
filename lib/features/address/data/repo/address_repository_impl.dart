import 'package:hostations_commerce/core/di/dependency_injection.dart';
import 'package:hostations_commerce/core/services/cache/cache_service.dart';

import '../model/address.dart';
import 'address_repository.dart';
import '../remote/address_remote_data_source.dart';
import '../local/address_local_data_source.dart';
import 'dart:developer' as developer;

class AddressRepositoryImpl implements AddressRepository {
  final AddressRemoteDataSource remoteDataSource;
  final AddressLocalDataSource localDataSource;
  final CacheService cacheService;

  AddressRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.cacheService,
  });

  @override
  Future<List<Address>> fetchAllAddresses(bool isGuest) async {
    developer.log('AddressRepositoryImpl: fetchAllAddresses - isGuest: $isGuest');
    if (isGuest) {
      developer.log('AddressRepositoryImpl: Fetching addresses from LOCAL data source (guest mode)');
      return await localDataSource.fetchAllAddresses();
    } else {
      developer.log('AddressRepositoryImpl: Fetching addresses from REMOTE data source (authenticated)');
      return await remoteDataSource.fetchAllAddresses();
    }
  }

  @override
  Future<Address> createAddress(Address address, bool isGuest) async {
    developer.log('AddressRepositoryImpl: createAddress - isGuest: $isGuest');
    if (isGuest) {
      return await localDataSource.createAddress(address);
    } else {
      return await remoteDataSource.createAddress(address);
    }
  }

  @override
  Future<Address> editAddress(Address address, bool isGuest) async {
    developer.log('AddressRepositoryImpl: editAddress - isGuest: $isGuest');
    if (isGuest) {
      return await localDataSource.editAddress(address);
    } else {
      return await remoteDataSource.editAddress(address);
    }
  }

  @override
  Future<void> deleteAddress(String id, bool isGuest) async {
    developer.log('AddressRepositoryImpl: deleteAddress - isGuest: $isGuest');
    if (isGuest) {
      await localDataSource.deleteAddress(id);
    } else {
      await remoteDataSource.deleteAddress(id);
    }
  }
}
