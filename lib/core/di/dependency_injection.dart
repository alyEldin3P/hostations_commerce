import 'package:core_dependencies_global/services/network_service.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hostations_commerce/core/config/env_config.dart';
import 'package:hostations_commerce/core/presentation/cubits/app/app_cubit.dart';
import 'package:hostations_commerce/features/address/data/local/address_local_data_source.dart';
import 'package:hostations_commerce/features/address/data/local/guest_address_local_data_source.dart';
import 'package:hostations_commerce/features/address/data/remote/address_remote_data_source.dart';
import 'package:hostations_commerce/features/address/data/remote/shopify_address_remote_data_source.dart';
import 'package:hostations_commerce/features/address/data/repo/address_repository.dart';
import 'package:hostations_commerce/features/address/data/repo/address_repository_impl.dart';
import 'package:hostations_commerce/features/address/presentation/cubits/address_cubit.dart';
import 'package:hostations_commerce/features/auth/data/remote/auth_remote_data_source.dart';
import 'package:hostations_commerce/features/auth/data/remote/shopify_auth_remote_data_source.dart';
import 'package:hostations_commerce/features/auth/data/repo/auth_repository_impl.dart';
import 'package:hostations_commerce/features/auth/domain/repository/auth_repository.dart';
import 'package:hostations_commerce/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:hostations_commerce/features/auth/data/local/auth_cache_service.dart';
import 'package:hostations_commerce/features/cart/data/remote/shipping_remote_data_source.dart';
import 'package:hostations_commerce/features/cart/data/repo/shipping_repository_impl.dart';
import 'package:hostations_commerce/features/cart/domain/repository/shipping_repository.dart';
import 'package:hostations_commerce/features/cart/presentation/cubits/shipping_method_cubit.dart';
import 'package:hostations_commerce/features/home/presentation/cubits/home_cubit.dart';
import 'package:hostations_commerce/core/services/cache/cache_service.dart';
import 'package:hostations_commerce/core/services/cache/shared_preferences_cache_service.dart';
import 'package:hostations_commerce/core/services/navigation/navigation_service.dart';
import 'package:hostations_commerce/core/services/navigation/navigation_service_impl.dart';
import 'package:hostations_commerce/core/services/network/network_service_impl.dart';
import 'package:hostations_commerce/core/services/snackbar/snackbar_service.dart';
import 'package:hostations_commerce/core/services/snackbar/snackbar_service_impl.dart';
import 'package:hostations_commerce/features/home/categories/data/remote/category_remote_data_source.dart';
import 'package:hostations_commerce/features/home/categories/data/repo/category_repository_impl.dart';
import 'package:hostations_commerce/features/home/categories/domain/repository/category_repository.dart';
import 'package:hostations_commerce/features/home/products/data/remote/product_remote_data_source.dart';
import 'package:hostations_commerce/features/home/products/data/repo/product_repository_impl.dart';
import 'package:hostations_commerce/features/home/products/domain/repository/product_repository.dart';
import 'package:hostations_commerce/features/wishlist/data/remote/wishlist_remote_data_source.dart';
import 'package:hostations_commerce/features/wishlist/data/repo/wishlist_repository_impl.dart';
import 'package:hostations_commerce/features/wishlist/domain/repository/wishlist_repository.dart';
import 'package:hostations_commerce/features/wishlist/presentation/cubits/wishlist_cubit.dart';
import 'package:hostations_commerce/features/cart/data/remote/cart_remote_data_source.dart';
import 'package:hostations_commerce/features/cart/data/repo/cart_repository_impl.dart';
import 'package:hostations_commerce/features/cart/domain/repository/cart_repository.dart';
import 'package:hostations_commerce/features/cart/presentation/cubits/cart_cubit.dart';
import 'package:hostations_commerce/core/network/network_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DependencyInjector {
  static final DependencyInjector _singleton = DependencyInjector._internal();
  factory DependencyInjector() => _singleton;
  DependencyInjector._internal();

  static final Map<Type, dynamic> _dependencies = {};
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  GlobalKey<ScaffoldMessengerState> get scaffoldMessengerKey => _scaffoldMessengerKey;

  Future<void> initialize() async {
    // Initialize Environment Configuration
    await EnvConfig().initialize();

    // Initialize SharedPreferences
    final sharedPreferences = await SharedPreferences.getInstance();
    _dependencies[SharedPreferences] = sharedPreferences;

    // Initialize GraphQL Client for Shopify
    final HttpLink httpLink = HttpLink(
      'https://fabrictaleseg.myshopify.com/api/2023-07/graphql.json',
      defaultHeaders: {
        'X-Shopify-Storefront-Access-Token': 'f17fa5ccf6e78f0807aacf37875f2b4f',
      },
    );

    final GraphQLClient graphQLClient = GraphQLClient(
      link: httpLink,
      cache: GraphQLCache(),
    );
    _dependencies[GraphQLClient] = graphQLClient;

    // Register services
    _dependencies[CacheService] = SharedPreferencesCacheService(sharedPreferences);
    _dependencies[NavigationService] = NavigationServiceImpl(navigatorKey);
    _dependencies[SnackBarService] = SnackBarServiceImpl(scaffoldMessengerKey);
    _dependencies[NetworkService] = NetworkServiceImpl();
    _dependencies[NetworkInfo] = NetworkInfoImpl();

    // Register auth services
    _dependencies[AuthCacheService] = AuthCacheService(cacheService: cacheService);
    _dependencies[AuthRemoteDataSource] = ShopifyAuthRemoteDataSource(
      client: graphQLClient,
      cacheService: cacheService,
    );

    _dependencies[AuthRepository] = AuthRepositoryImpl(
      remoteDataSource: authRemoteDataSource,
      cacheService: _dependencies[AuthCacheService],
    );

    // Register remote data sources
    _dependencies[CategoryRemoteDataSource] = ShopifyCategoryRemoteDataSource(
      shopifyDomain: 'fabrictaleseg.myshopify.com',
      accessToken: 'f17fa5ccf6e78f0807aacf37875f2b4f',
    );

    _dependencies[ProductRemoteDataSource] = ShopifyProductRemoteDataSource(
      shopifyDomain: 'fabrictaleseg.myshopify.com',
      accessToken: 'f17fa5ccf6e78f0807aacf37875f2b4f',
    );

    _dependencies[WishlistRemoteDataSource] = LocalWishlistDataSource(
      cacheService: cacheService,
      graphQLClient: graphQLClient,
    );

    _dependencies[CartRemoteDataSource] = ShopifyCartRemoteDataSource(
      cacheService: cacheService,
      graphQLClient: graphQLClient,
    );

    // Register repositories
    _dependencies[CategoryRepository] = CategoryRepositoryImpl(
      remoteDataSource: categoryRemoteDataSource,
    );

    _dependencies[ProductRepository] = ProductRepositoryImpl(
      remoteDataSource: productRemoteDataSource,
    );

    _dependencies[WishlistRepository] = WishlistRepositoryImpl(
      remoteDataSource: wishlistRemoteDataSource,
      networkInfo: networkInfo,
      cacheService: cacheService,
    );

    _dependencies[CartRepository] = CartRepositoryImpl(
      remoteDataSource: cartRemoteDataSource,
      networkInfo: networkInfo,
      cacheService: cacheService,
    );
  }

  // Core Services
  SharedPreferences get sharedPreferences => _dependencies[SharedPreferences]!;
  CacheService get cacheService => _dependencies[CacheService] ??= SharedPreferencesCacheService(sharedPreferences);
  NavigationService get navigationService => _dependencies[NavigationService] ??= NavigationServiceImpl(navigatorKey);
  SnackBarService get snackBarService => _dependencies[SnackBarService] ??= SnackBarServiceImpl(scaffoldMessengerKey);
  NetworkService get networkService => _dependencies[NetworkService] ??= NetworkServiceImpl();
  NetworkInfo get networkInfo => _dependencies[NetworkInfo] ??= NetworkInfoImpl();
  EnvConfig get envConfig => _dependencies[EnvConfig] ??= EnvConfig();

  // GraphQL Client
  GraphQLClient get graphQLClient => _dependencies[GraphQLClient]!;

  // Remote Data Sources
  CategoryRemoteDataSource get categoryRemoteDataSource => _dependencies[CategoryRemoteDataSource];
  ProductRemoteDataSource get productRemoteDataSource => _dependencies[ProductRemoteDataSource];
  WishlistRemoteDataSource get wishlistRemoteDataSource => _dependencies[WishlistRemoteDataSource] ??= LocalWishlistDataSource(
        cacheService: cacheService,
        graphQLClient: graphQLClient,
      );

  CartRemoteDataSource get cartRemoteDataSource => _dependencies[CartRemoteDataSource] ??= ShopifyCartRemoteDataSource(
        cacheService: cacheService,
        graphQLClient: graphQLClient,
      );

  // Auth Services
  AuthCacheService get authCacheService => _dependencies[AuthCacheService] ??= AuthCacheService(cacheService: cacheService);
  AuthRemoteDataSource get authRemoteDataSource => _dependencies[AuthRemoteDataSource];
  AuthRepository get authRepository => _dependencies[AuthRepository] ??= AuthRepositoryImpl(
        remoteDataSource: authRemoteDataSource,
        cacheService: authCacheService,
      );

  // Repositories
  CategoryRepository get categoryRepository => _dependencies[CategoryRepository] ??= CategoryRepositoryImpl(
        remoteDataSource: categoryRemoteDataSource,
      );

  ProductRepository get productRepository => _dependencies[ProductRepository] ??= ProductRepositoryImpl(
        remoteDataSource: productRemoteDataSource,
      );

  WishlistRepository get wishlistRepository => _dependencies[WishlistRepository] ??= WishlistRepositoryImpl(
        remoteDataSource: wishlistRemoteDataSource,
        networkInfo: networkInfo,
        cacheService: cacheService,
      );

  CartRepository get cartRepository => _dependencies[CartRepository] ??= CartRepositoryImpl(
        remoteDataSource: cartRemoteDataSource,
        networkInfo: networkInfo,
        cacheService: cacheService,
      );

  // Cubits
  AppCubit get appCubit => _dependencies[AppCubit] ??= AppCubit(cacheService: cacheService);
  HomeCubit get homeCubit => _dependencies[HomeCubit] ??= HomeCubit(
        categoryRepository: categoryRepository,
        productRepository: productRepository,
      );
  AuthCubit get authCubit => _dependencies[AuthCubit] ??= AuthCubit(authRepository: authRepository);
  WishlistCubit get wishlistCubit => _dependencies[WishlistCubit] ??= WishlistCubit(
        wishlistRepository: wishlistRepository,
      );

  CartCubit get cartCubit => _dependencies[CartCubit] ??= CartCubit(
        cartRepository: cartRepository,
      );

  // Address
  AddressRemoteDataSource get addressRemoteDataSource => _dependencies[AddressRemoteDataSource] ??= ShopifyAddressRemoteDataSource(
        client: graphQLClient,
        authCacheService: _dependencies[AuthCacheService],
      );
  AddressLocalDataSource get addressLocalDataSource => _dependencies[AddressLocalDataSource] ??= GuestAddressLocalDataSource();
  AddressRepository get addressRepository => _dependencies[AddressRepository] ??= AddressRepositoryImpl(
        remoteDataSource: addressRemoteDataSource,
        localDataSource: addressLocalDataSource,
        cacheService: cacheService,
      );
  AddressCubit get addressCubit => _dependencies[AddressCubit] ??= AddressCubit(
        repository: addressRepository,
      );
  ShippingMethodCubit get shippingMethodCubit => _dependencies[ShippingMethodCubit] ??= ShippingMethodCubit(
        repository: shippingRepository,
      );
  ShippingRepository get shippingRepository => _dependencies[ShippingRepository] ??= ShippingRepositoryImpl(
        remoteDataSource: shippingRemoteDataSource,
      );
  ShippingRemoteDataSource get shippingRemoteDataSource => _dependencies[ShippingRemoteDataSource] ??= ShopifyShippingRemoteDataSource(
        client: graphQLClient,
      );
}
