import 'address_remote_data_source.dart';
import '../model/address.dart';
import 'package:graphql/client.dart';
import 'package:hostations_commerce/features/auth/data/local/auth_cache_service.dart';

class ShopifyAddressRemoteDataSource implements AddressRemoteDataSource {
  final GraphQLClient client;
  final AuthCacheService authCacheService;

  ShopifyAddressRemoteDataSource({
    required this.client,
    required this.authCacheService,
  });

  @override
  Future<List<Address>> fetchAllAddresses() async {
    final customerAccessToken = await authCacheService.getAccessToken();
    if (customerAccessToken == null) {
      throw Exception('No customer access token found. User must be logged in.');
    }
    const query = r'''
      query GetAddresses($customerAccessToken: String!) {
        customer(customerAccessToken: $customerAccessToken) {
          addresses(first: 20) {
            edges {
              node {
                id
                address1
                address2
                city
                company
                country
                firstName
                lastName
                phone
                province
                zip
              }
            }
          }
        }
      }
    ''';

    final result = await client.query(
      QueryOptions(
        document: gql(query),
        variables: {'customerAccessToken': customerAccessToken},
        fetchPolicy: FetchPolicy.networkOnly, // Ensure we always hit the network
      ),
    );

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    final edges = result.data?['customer']?['addresses']?['edges'] as List?;
    if (edges == null) return [];

    return edges.map((edge) {
      final node = edge['node'] as Map<String, dynamic>;
      return Address(
        id: node['id'],
        name: '${node['firstName'] ?? ''} ${node['lastName'] ?? ''}'.trim(),
        phone: node['phone'] ?? '',
        address1: node['address1'] ?? '',
        address2: node['address2'],
        city: node['city'] ?? '',
        country: node['country'] ?? '',
        state: node['province'] ?? '',
        zip: node['zip'] ?? '',
      );
    }).toList();
  }

  @override
  Future<Address> createAddress(Address address) async {
    final customerAccessToken = await authCacheService.getAccessToken();
    if (customerAccessToken == null) {
      throw Exception('No customer access token found. User must be logged in.');
    }
    const mutation = r'''
      mutation CreateAddress($customerAccessToken: String!, $address: MailingAddressInput!) {
        customerAddressCreate(customerAccessToken: $customerAccessToken, address: $address) {
          customerAddress {
            id
            address1
            address2
            city
            country
            firstName
            lastName
            phone
            province
            zip
          }
          userErrors {
            field
            message
          }
        }
      }
    ''';

    final variables = {
      'customerAccessToken': customerAccessToken,
      'address': {
        'address1': address.address1,
        'address2': address.address2,
        'city': address.city,
        'country': address.country,
        'firstName': address.name.split(' ').first,
        'lastName': address.name.split(' ').skip(1).join(' '),
        'phone': address.phone,
        'province': address.state,
        'zip': address.zip,
      }
    };

    final result = await client.mutate(
      MutationOptions(
        document: gql(mutation),
        variables: variables,
      ),
    );

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    final data = result.data?['customerAddressCreate']?['customerAddress'];
    if (data == null) {
      final errors = result.data?['customerAddressCreate']?['userErrors'];
      throw Exception(errors?.toString() ?? 'Unknown error');
    }

    return Address(
      id: data['id'],
      name: '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'.trim(),
      phone: data['phone'] ?? '',
      address1: data['address1'] ?? '',
      address2: data['address2'],
      city: data['city'] ?? '',
      country: data['country'] ?? '',
      state: data['province'] ?? '',
      zip: data['zip'] ?? '',
    );
  }

  @override
  Future<Address> editAddress(Address address) async {
    final customerAccessToken = await authCacheService.getAccessToken();
    if (customerAccessToken == null) {
      throw Exception('No customer access token found. User must be logged in.');
    }
    const mutation = r'''
      mutation UpdateAddress($customerAccessToken: String!, $id: ID!, $address: MailingAddressInput!) {
        customerAddressUpdate(customerAccessToken: $customerAccessToken, id: $id, address: $address) {
          customerAddress {
            id
            address1
            address2
            city
            country
            firstName
            lastName
            phone
            province
            zip
          }
          userErrors {
            field
            message
          }
        }
      }
    ''';

    final variables = {
      'customerAccessToken': customerAccessToken,
      'id': address.id,
      'address': {
        'address1': address.address1,
        'address2': address.address2,
        'city': address.city,
        'country': address.country,
        'firstName': address.name.split(' ').first,
        'lastName': address.name.split(' ').skip(1).join(' '),
        'phone': address.phone,
        'province': address.state,
        'zip': address.zip,
      }
    };

    final result = await client.mutate(
      MutationOptions(
        document: gql(mutation),
        variables: variables,
      ),
    );

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    final data = result.data?['customerAddressUpdate']?['customerAddress'];
    if (data == null) {
      final errors = result.data?['customerAddressUpdate']?['userErrors'];
      throw Exception(errors?.toString() ?? 'Unknown error');
    }

    return Address(
      id: data['id'],
      name: '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'.trim(),
      phone: data['phone'] ?? '',
      address1: data['address1'] ?? '',
      address2: data['address2'],
      city: data['city'] ?? '',
      country: data['country'] ?? '',
      state: data['province'] ?? '',
      zip: data['zip'] ?? '',
    );
  }

  @override
  Future<void> deleteAddress(String id) async {
    final customerAccessToken = await authCacheService.getAccessToken();
    if (customerAccessToken == null) {
      throw Exception('No customer access token found. User must be logged in.');
    }
    const mutation = r'''
      mutation DeleteAddress($customerAccessToken: String!, $id: ID!) {
        customerAddressDelete(customerAccessToken: $customerAccessToken, id: $id) {
          deletedCustomerAddressId
          userErrors {
            field
            message
          }
        }
      }
    ''';

    final variables = {
      'customerAccessToken': customerAccessToken,
      'id': id,
    };

    final result = await client.mutate(
      MutationOptions(
        document: gql(mutation),
        variables: variables,
      ),
    );

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    final errors = result.data?['customerAddressDelete']?['userErrors'];
    if (errors != null && (errors as List).isNotEmpty) {
      throw Exception(errors.toString());
    }
  }
}
