import 'dart:developer';

import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hostations_commerce/core/services/cache/cache_service.dart';
import 'package:hostations_commerce/features/auth/data/model/user.dart';
import 'package:hostations_commerce/features/auth/data/remote/auth_remote_data_source.dart';

class ShopifyAuthRemoteDataSource implements AuthRemoteDataSource {
  final GraphQLClient _client;
  final CacheService _cacheService;
  static const String _accessTokenKey = 'user_access_token';
  static const String _userDataKey = 'user_data';

  ShopifyAuthRemoteDataSource({
    required GraphQLClient client,
    required CacheService cacheService,
  })  : _client = client,
        _cacheService = cacheService;

  @override
  Future<UserModel> signIn({required String email, required String password}) async {
    final MutationOptions options = MutationOptions(
      document: gql('''
        mutation customerAccessTokenCreate(\$input: CustomerAccessTokenCreateInput!) {
          customerAccessTokenCreate(input: \$input) {
            customerAccessToken {
              accessToken
              expiresAt
            }
            customerUserErrors {
              code
              field
              message
            }
          }
        }
      '''),
      variables: {
        'input': {
          'email': email,
          'password': password,
        },
      },
    );

    final QueryResult result = await _client.mutate(options);

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    final data = result.data!;
    final customerAccessTokenCreate = data['customerAccessTokenCreate'];
    final customerUserErrors = customerAccessTokenCreate['customerUserErrors'];

    if (customerUserErrors != null && customerUserErrors.isNotEmpty) {
      throw Exception(customerUserErrors[0]['message']);
    }

    final accessToken = customerAccessTokenCreate['customerAccessToken']['accessToken'];

    // Get customer data with the access token
    final user = await _getCustomerData(accessToken);

    // Save access token and user data to cache
    await _cacheService.setString(_accessTokenKey, accessToken);
    await _cacheService.setString(_userDataKey, user.toJson().toString());

    return user;
  }

  @override
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phone,
    bool acceptsMarketing = false,
  }) async {
    final MutationOptions options = MutationOptions(
      document: gql('''
        mutation customerCreate(\$input: CustomerCreateInput!) {
          customerCreate(input: \$input) {
            customer {
              id
              email
              firstName
              lastName
              acceptsMarketing
            }
            customerUserErrors {
              code
              field
              message
            }
          }
        }
      '''),
      variables: {
        'input': {
          'email': email,
          'password': password,
          'firstName': firstName,
          'lastName': lastName,
          // 'phone': phone,
          'acceptsMarketing': acceptsMarketing,
        },
      },
    );

    final QueryResult result = await _client.mutate(options);
    if (result.hasException) {
      log(result.exception.toString());
      throw Exception(result.exception.toString());
    }

    final data = result.data!;
    final customerCreate = data['customerCreate'];
    final customerUserErrors = customerCreate['customerUserErrors'];

    if (customerUserErrors != null && customerUserErrors.isNotEmpty) {
      throw Exception(customerUserErrors[0]['message']);
    }

    // After creating the account, sign in to get the access token
    return await signIn(email: email, password: password);
  }

  @override
  Future<void> signOut() async {
    // Clear the access token and user data from cache
    await _cacheService.remove(_accessTokenKey);
    await _cacheService.remove(_userDataKey);
  }

  @override
  Future<bool> isSignedIn() async {
    final accessToken = await _cacheService.getString(_accessTokenKey);
    return accessToken != null && accessToken.isNotEmpty;
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final accessToken = await _cacheService.getString(_accessTokenKey);

    if (accessToken == null || accessToken.isEmpty) {
      return null;
    }

    try {
      return await _getCustomerData(accessToken);
    } catch (e) {
      // If there's an error (e.g., token expired), sign out
      await signOut();
      return null;
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    final MutationOptions options = MutationOptions(
      document: gql('''
        mutation customerRecover(\$email: String!) {
          customerRecover(email: \$email) {
            customerUserErrors {
              code
              field
              message
            }
          }
        }
      '''),
      variables: {
        'email': email,
      },
    );

    final QueryResult result = await _client.mutate(options);

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    final data = result.data!;
    final customerRecover = data['customerRecover'];
    final customerUserErrors = customerRecover['customerUserErrors'];

    if (customerUserErrors != null && customerUserErrors.isNotEmpty) {
      throw Exception(customerUserErrors[0]['message']);
    }
  }

  Future<UserModel> _getCustomerData(String accessToken) async {
    final QueryOptions options = QueryOptions(
      document: gql('''
        query getCustomer(\$customerAccessToken: String!) {
          customer(customerAccessToken: \$customerAccessToken) {
            id
            email
            firstName
            lastName
            phone
            acceptsMarketing
          }
        }
      '''),
      variables: {
        'customerAccessToken': accessToken,
      },
      fetchPolicy: FetchPolicy.networkOnly, // Ensure we always hit the network
    );

    final QueryResult result = await _client.query(options);

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    final data = result.data!;
    return UserModel.fromJson(data, accessToken: accessToken);
  }
}
