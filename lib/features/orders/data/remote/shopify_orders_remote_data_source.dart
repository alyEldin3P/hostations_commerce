import 'package:graphql/client.dart';
import 'package:hostations_commerce/features/orders/data/model/order.dart';
import 'package:hostations_commerce/features/auth/data/local/auth_cache_service.dart';
import 'orders_remote_data_source.dart';

class ShopifyOrdersRemoteDataSource implements OrdersRemoteDataSource {
  final GraphQLClient client;
  final AuthCacheService authCacheService;

  ShopifyOrdersRemoteDataSource({
    required this.client,
    required this.authCacheService,
  });

  @override
  Future<List<Order>> fetchOrders() async {
    final customerAccessToken = await authCacheService.getAccessToken();
    if (customerAccessToken == null) {
      throw Exception('No customer access token found. User must be logged in.');
    }
    const query = r'''
      query GetOrders($customerAccessToken: String!) {
        customer(customerAccessToken: $customerAccessToken) {
          orders(first: 20) {
            edges {
              node {
                id
                name
                processedAt
                totalPriceV2 {
                  amount
                  currencyCode
                }
                fulfillmentStatus
                financialStatus
                lineItems(first: 20) {
                  edges {
                    node {
                      title
                      quantity
                      variant {
                        priceV2 {
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
    ''';
    final result = await client.query(
      QueryOptions(
        document: gql(query),
        variables: {'customerAccessToken': customerAccessToken},
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );
    if (result.hasException) {
      throw Exception(result.exception.toString());
    }
    final ordersJson = result.data?['customer']?['orders']?['edges'] as List?;
    if (ordersJson == null) return [];
    return ordersJson.map((edge) => Order.fromJson(edge['node'])).toList();
  }

  @override
  Future<Order> fetchOrderDetails(String orderId) async {
    final customerAccessToken = await authCacheService.getAccessToken();
    if (customerAccessToken == null) {
      throw Exception('No customer access token found. User must be logged in.');
    }
    const query = r'''
      query GetOrder($customerAccessToken: String!, $orderId: ID!) {
        customer(customerAccessToken: $customerAccessToken) {
          order(id: $orderId) {
            id
            name
            processedAt
            totalPriceV2 {
              amount
              currencyCode
            }
            fulfillmentStatus
            financialStatus
            lineItems(first: 10) {
              edges {
                node {
                  title
                  quantity
                  originalUnitPriceSet {
                    shopMoney {
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
    ''';
    final result = await client.query(
      QueryOptions(
        document: gql(query),
        variables: {
          'customerAccessToken': customerAccessToken,
          'orderId': orderId,
        },
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );
    if (result.hasException) {
      throw Exception(result.exception.toString());
    }
    final orderJson = result.data?['customer']?['order'];
    if (orderJson == null) {
      throw Exception('Order not found');
    }
    return Order.fromJson(orderJson);
  }
}
