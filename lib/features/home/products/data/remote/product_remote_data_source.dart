import 'package:graphql/client.dart';
import 'package:hostations_commerce/features/home/products/data/model/product.dart';

abstract class ProductRemoteDataSource {
  /// Fetches all products from the remote API
  Future<List<Product>> getProducts();

  /// Fetches products by category ID from the remote API
  Future<List<Product>> getProductsByCategory(String categoryId);

  /// Fetches a specific product by ID from the remote API
  Future<Product> getProductById(String id);

  /// Fetches most selling products from the remote API
  Future<List<Product>> getMostSellingProducts();

  /// Fetches products on sale from the remote API
  Future<List<Product>> getSaleProducts();
}

class ShopifyProductRemoteDataSource implements ProductRemoteDataSource {
  final String shopifyDomain;
  final String accessToken;
  late final GraphQLClient _client;

  ShopifyProductRemoteDataSource({
    required this.shopifyDomain,
    required this.accessToken,
  }) {
    final HttpLink httpLink = HttpLink(
      'https://$shopifyDomain/api/2023-04/graphql.json',
    );

    final AuthLink authLink = AuthLink(
      headerKey: 'X-Shopify-Storefront-Access-Token',
      getToken: () => accessToken,
    );

    _client = GraphQLClient(
      link: authLink.concat(httpLink),
      cache: GraphQLCache(),
    );
  }

  @override
  Future<List<Product>> getProducts() async {
    final QueryOptions options = QueryOptions(
      document: gql('''
        query GetProducts {
          products(first: 20) {
            edges {
              node {
                id
                title
                description
                handle
                availableForSale
                priceRange {
                  minVariantPrice {
                    amount
                    currencyCode
                  }
                }
                compareAtPriceRange {
                  minVariantPrice {
                    amount
                    currencyCode
                  }
                }
                images(first: 1) {
                  edges {
                    node {
                      url
                    }
                  }
                }
                variants(first: 5) {
                  edges {
                    node {
                      id
                      title
                      availableForSale
                      price {
                        amount
                        currencyCode
                      }
                    }
                  }
                }
              }
            }
          }
        }
      '''),
      fetchPolicy: FetchPolicy.networkOnly, // Ensure we always hit the network
    );

    final result = await _client.query(options);
    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    return _parseProductsResponse(result.data!);
  }

  @override
  Future<List<Product>> getProductsByCategory(String categoryId) async {
    final QueryOptions options = QueryOptions(
      fetchPolicy: FetchPolicy.networkOnly, // Ensure we always hit the network

      document: gql('''
        query GetProductsByCategory(\$categoryId: ID!) {
          collection(id: \$categoryId) {
            products(first: 20) {
              edges {
                node {
                  id
                  title
                  description
                  handle
                  availableForSale
                  priceRange {
                    minVariantPrice {
                      amount
                      currencyCode
                    }
                  }
                  compareAtPriceRange {
                    minVariantPrice {
                      amount
                      currencyCode
                    }
                  }
                  images(first: 1) {
                    edges {
                      node {
                        url
                      }
                    }
                  }
                  variants(first: 5) {
                    edges {
                      node {
                        id
                        title
                        availableForSale
                        price {
                          amount
                          currencyCode
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      '''),
      variables: {'categoryId': categoryId},
    );

    final result = await _client.query(options);
    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    return _parseProductsFromCollection(result.data!);
  }

  @override
  Future<Product> getProductById(String id) async {
    final QueryOptions options = QueryOptions(
      fetchPolicy: FetchPolicy.networkOnly, // Ensure we always hit the network

      document: gql('''
        query GetProduct(\$id: ID!) {
          product(id: \$id) {
            id
            title
            description
            handle
            availableForSale
            priceRange {
              minVariantPrice {
                amount
                currencyCode
              }
            }
            compareAtPriceRange {
              minVariantPrice {
                amount
                currencyCode
              }
            }
            images(first: 5) {
              edges {
                node {
                  url
                }
              }
            }
            variants(first: 10) {
              edges {
                node {
                  id
                  title
                  availableForSale
                  price {
                    amount
                    currencyCode
                  }
                }
              }
            }
          }
        }
      '''),
      variables: {'id': id},
    );

    final result = await _client.query(options);
    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    return _parseProductResponse(result.data!['product']);
  }

  @override
  Future<List<Product>> getMostSellingProducts() async {
    final QueryOptions options = QueryOptions(
      fetchPolicy: FetchPolicy.networkOnly, // Ensure we always hit the network

      document: gql('''
        query GetMostSellingProducts {
          collections(first: 1, query: "title:Featured") {
            edges {
              node {
                products(first: 10) {
                  edges {
                    node {
                      id
                      title
                      description
                      handle
                      availableForSale
                      priceRange {
                        minVariantPrice {
                          amount
                          currencyCode
                        }
                      }
                      compareAtPriceRange {
                        minVariantPrice {
                          amount
                          currencyCode
                        }
                      }
                      images(first: 1) {
                        edges {
                          node {
                            url
                          }
                        }
                      }
                      variants(first: 5) {
                        edges {
                          node {
                            id
                            title
                            availableForSale
                            price {
                              amount
                              currencyCode
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      '''),
    );

    final result = await _client.query(options);
    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    return _parseProductsFromFeaturedCollection(result.data!);
  }

  @override
  Future<List<Product>> getSaleProducts() async {
    final QueryOptions options = QueryOptions(
      fetchPolicy: FetchPolicy.networkOnly, // Ensure we always hit the network

      document: gql('''
        query GetSaleProducts {
          products(first: 20, query: "tag:sale") {
            edges {
              node {
                id
                title
                description
                handle
                availableForSale
                priceRange {
                  minVariantPrice {
                    amount
                    currencyCode
                  }
                }
                compareAtPriceRange {
                  minVariantPrice {
                    amount
                    currencyCode
                  }
                }
                images(first: 1) {
                  edges {
                    node {
                      url
                    }
                  }
                }
                variants(first: 5) {
                  edges {
                    node {
                      id
                      title
                      availableForSale
                      price {
                        amount
                        currencyCode
                      }
                      compareAtPrice {
                        amount
                        currencyCode
                      }
                    }
                  }
                }
              }
            }
          }
        }
      '''),
    );

    final result = await _client.query(options);
    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    return _parseProductsResponse(result.data!);
  }

  List<Product> _parseProductsResponse(Map<String, dynamic> data) {
    final products = <Product>[];
    final productEdges = data['products']['edges'] as List;

    for (var edge in productEdges) {
      final node = edge['node'];
      products.add(_parseProductResponse(node));
    }

    return products;
  }

  List<Product> _parseProductsFromCollection(Map<String, dynamic> data) {
    final products = <Product>[];
    final productEdges = data['collection']['products']['edges'] as List;

    for (var edge in productEdges) {
      final node = edge['node'];
      products.add(_parseProductResponse(node));
    }

    return products;
  }

  List<Product> _parseProductsFromFeaturedCollection(Map<String, dynamic> data) {
    if (data['collections']['edges'].isEmpty) {
      return [];
    }

    final products = <Product>[];
    final productEdges = data['collections']['edges'][0]['node']['products']['edges'] as List;

    for (var edge in productEdges) {
      final node = edge['node'];
      products.add(_parseProductResponse(node));
    }

    return products;
  }

  Product _parseProductResponse(Map<String, dynamic> node) {
    final images = <String>[];
    final imageEdges = node['images']['edges'] as List;
    for (var edge in imageEdges) {
      images.add(edge['node']['url']);
    }

    final variants = <ProductVariant>[];
    final variantEdges = node['variants']['edges'] as List;
    for (var edge in variantEdges) {
      final variantNode = edge['node'];
      variants.add(
        ProductVariant(
          id: variantNode['id'],
          title: variantNode['title'],
          price: double.parse(variantNode['price']['amount']),
          available: variantNode['availableForSale'],
        ),
      );
    }

    double? compareAtPrice;
    if (node['compareAtPriceRange'] != null && node['compareAtPriceRange']['minVariantPrice'] != null) {
      compareAtPrice = double.parse(
        node['compareAtPriceRange']['minVariantPrice']['amount'],
      );
    }

    return Product(
      id: node['id'],
      title: node['title'],
      description: node['description'],
      price: double.parse(node['priceRange']['minVariantPrice']['amount']),
      compareAtPrice: compareAtPrice,
      images: images,
      available: node['availableForSale'],
      variants: variants,
    );
  }
}
