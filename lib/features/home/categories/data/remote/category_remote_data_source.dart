import 'dart:developer';

import 'package:hostations_commerce/features/home/categories/data/model/category.dart';
import 'package:graphql/client.dart';

abstract class CategoryRemoteDataSource {
  /// Fetches all categories from the remote API
  Future<List<Category>> getCategories();

  /// Fetches a specific category by ID from the remote API
  Future<Category> getCategoryById(String id);
}

class ShopifyCategoryRemoteDataSource implements CategoryRemoteDataSource {
  final String shopifyDomain;
  final String accessToken;
  late final GraphQLClient _client;

  ShopifyCategoryRemoteDataSource({
    required this.shopifyDomain,
    required this.accessToken,
  }) {
    final httpLink = HttpLink(
      'https://$shopifyDomain/api/2023-07/graphql.json',
      defaultHeaders: {
        'X-Shopify-Storefront-Access-Token': accessToken,
      },
    );
    _client = GraphQLClient(
      link: httpLink,
      cache: GraphQLCache(),
    );
  }

  @override
  Future<List<Category>> getCategories() async {
    const String query = r'''
    query GetCollections {
      collections(first: 20) {
        edges {
          node {
            id
            title
            description
            image {
              url
            }
          }
        }
      }
    }
    ''';

    final result = await _client.query(
      QueryOptions(
        document: gql(query),
        fetchPolicy: FetchPolicy.networkOnly, // Ensure we always hit the network
      ),
    );
    if (result.hasException) {
      throw Exception('Failed to fetch categories: ${result.exception}');
    }

    final collections = result.data?['collections']['edges'] as List<dynamic>;
    return collections.map((collection) {
      log(collection.toString());
      final node = collection['node'];
      return Category(
        id: node['id'],
        title: node['title'],
        description: node['description'] ?? '',
        imageUrl: node['image']?['url'] ?? '',
      );
    }).toList();
  }

  @override
  Future<Category> getCategoryById(String id) async {
    final String query = r'''
    query GetCollection($id: ID!) {
      collection(id: $id) {
        id
        title
        description
        image {
          url
        }
      }
    }
    ''';

    final result = await _client.query(
      QueryOptions(
        document: gql(query),
        variables: {'id': id},
        fetchPolicy: FetchPolicy.networkOnly, // Ensure we always hit the network
      ),
    );

    if (result.hasException) {
      throw Exception('Failed to fetch category: ${result.exception}');
    }

    final collection = result.data?['collection'];
    if (collection == null) {
      throw Exception('Category not found');
    }

    return Category(
      id: collection['id'],
      title: collection['title'],
      description: collection['description'] ?? '',
      imageUrl: collection['image']?['url'] ?? '',
    );
  }
}
