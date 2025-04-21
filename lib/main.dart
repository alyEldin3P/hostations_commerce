import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hostations_commerce/core/di/dependency_injection.dart';
import 'package:hostations_commerce/core/localization/app_localization_helper.dart';
import 'package:hostations_commerce/core/presentation/cubits/app/app_cubit.dart';
import 'package:hostations_commerce/core/presentation/cubits/app/app_state.dart';
import 'package:hostations_commerce/features/address/presentation/cubits/address_cubit.dart';
import 'package:hostations_commerce/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:hostations_commerce/features/auth/presentation/cubits/auth_state.dart';
import 'package:hostations_commerce/features/auth/presentation/screens/login_screen.dart';
import 'package:hostations_commerce/features/cart/presentation/cubits/cart_cubit.dart';
import 'package:hostations_commerce/features/checkout/presentation/screens/confirm_order_screen.dart';
import 'package:hostations_commerce/features/checkout/presentation/screens/payment_method_screen.dart';
import 'package:hostations_commerce/features/home/presentation/cubits/home_cubit.dart';
import 'package:hostations_commerce/features/layout/presentation/screens/layout_screen.dart';
import 'package:hostations_commerce/features/language/presentation/screens/language_selection_screen.dart';
import 'package:hostations_commerce/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:hostations_commerce/features/splash/presentation/screens/splash_screen.dart';
import 'package:hostations_commerce/features/wishlist/presentation/screens/wishlist_screen.dart';
import 'package:hostations_commerce/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:hostations_commerce/features/settings/presentation/screens/settings_screen.dart';
import 'package:hostations_commerce/features/about/presentation/screens/about_screen.dart';
import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final injector = DependencyInjector();
  await injector.initialize();
  // final shopify = ShopifyService();
  // final productResponse = await shopify.createProduct('Dummy Product', 'This is a dummy product.');
  // print('Product Response: ${productResponse.body}');
  // final productResponse = await shopify.createProductWithVariants('Dummy Product With Variants', 'This is a dummy product with variants.', ['Small', 'Medium', 'Large'], ['Red', 'Blue', 'Black']);
  // print('Product Response: ${productResponse.body}');
  // // Create a dummy collection
  // final collectionResponse = await shopify.createCollection('Dummy Collection');
  // print('Collection Response: ${collectionResponse.body}');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AppCubit>(
          create: (context) {
            final cacheService = DependencyInjector().cacheService;
            final appCubit = AppCubit(cacheService: cacheService)..init();
            return appCubit;
          },
        ),
        BlocProvider<HomeCubit>(
          create: (context) => DependencyInjector().homeCubit,
        ),
        BlocProvider<AuthCubit>(
          create: (context) => DependencyInjector().authCubit,
        ),
        BlocProvider<CartCubit>(
          create: (context) => DependencyInjector().cartCubit,
        ),
        BlocProvider<AddressCubit>(
          create: (context) => DependencyInjector().addressCubit,
        ),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<AuthCubit, AuthState>(
            listener: (context, state) async {
              final appCubit = context.read<AppCubit>();
              if (state.status == AuthStatus.unauthenticated) return appCubit.setIsGuest(true);
              if (state.status == AuthStatus.authenticated) return appCubit.setIsGuest(false);
            },
          ),
        ],
        child: BlocBuilder<AppCubit, AppState>(
          builder: (context, state) {
            final locale = Locale(state.selectedLanguageCode);
            final textDirection = state.isRightToLeft ? TextDirection.rtl : TextDirection.ltr;

            return MaterialApp(
              navigatorKey: DependencyInjector().navigatorKey,
              scaffoldMessengerKey: DependencyInjector().scaffoldMessengerKey,
              title: DependencyInjector().envConfig.appName,
              debugShowCheckedModeBanner: false,
              // Localization setup
              locale: locale,
              supportedLocales: AppLocalizationHelper.supportedLocales,
              localizationsDelegates: [
                ...AppLocalizationHelper.localizationDelegates,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              routes: {
                SplashScreen.routeName: (context) => const SplashScreen(),
                OnboardingScreen.routeName: (context) => const OnboardingScreen(),
                LanguageSelectionScreen.routeName: (context) => const LanguageSelectionScreen(),
                LayoutScreen.routeName: (context) => const LayoutScreen(),
                LoginScreen.routeName: (context) => const LoginScreen(),
                WishlistScreen.routeName: (context) => const WishlistScreen(),
                NotificationsScreen.routeName: (context) => const NotificationsScreen(),
                ThemeScreen.routeName: (context) => const ThemeScreen(),
                AboutScreen.routeName: (context) => AboutScreen(
                      type: ModalRoute.of(context)!.settings.arguments as String,
                    ),
                PaymentMethodScreen.routeName: (context) => const PaymentMethodScreen(),
                ConfirmOrderScreen.routeName: (context) => const ConfirmOrderScreen(),
                // Add more routes as we implement them
              },
              builder: (context, child) {
                return Directionality(
                  textDirection: textDirection,
                  child: child!,
                );
              },
              initialRoute: SplashScreen.routeName,
              theme: ThemeData.light(),
              darkTheme: ThemeData.dark(),
              themeMode: state.themeMode,
            );
          },
        ),
      ),
    );
  }
}

class ShopifyService {
  final String storeDomain = 'fabrictaleseg.myshopify.com';
  final String accessToken = const String.fromEnvironment('SHOPIFY_ACCESS_TOKEN');
  Future<http.Response> createProductWithVariants(String title, String bodyHtml, List<String> sizes, List<String> colors) {
    final url = Uri.https(storeDomain, '/admin/api/2023-04/graphql.json');
    final headers = {
      'Content-Type': 'application/json',
      'X-Shopify-Access-Token': accessToken,
    };

    // First create the product with the option names
    final mutation = '''
    mutation {
      productCreate(input: {
        title: "$title",
        bodyHtml: "$bodyHtml",
        options: ["Color", "Size"],
        variants: [
          ${_buildVariantInputs(colors, sizes)}
        ]
      }) {
        product {
          id
          title
          options {
            id
            name
            values
          }
          variants(first: 20) {
            edges {
              node {
                id
                title
                selectedOptions {
                  name
                  value
                }
              }
            }
          }
        }
        userErrors {
          field
          message
        }
      }
    }
  ''';

    return http.post(url, headers: headers, body: jsonEncode({'query': mutation}));
  }

  String _buildVariantInputs(List<String> colors, List<String> sizes) {
    List<String> variantInputs = [];

    for (String color in colors) {
      for (String size in sizes) {
        variantInputs.add('''
        {
          options: ["$color", "$size"]
        }
      ''');
      }
    }

    return variantInputs.join(',');
  }

  Future<http.Response> createCollection(String title) {
    final url = Uri.https(storeDomain, '/admin/api/2023-04/graphql.json');
    final headers = {
      'Content-Type': 'application/json',
      'X-Shopify-Access-Token': accessToken,
    };
    final mutation = '''
      mutation {
        collectionCreate(input: {
          title: "$title"
        }) {
          collection {
            id
          }
          userErrors {
            field
            message
          }
        }
      }
    ''';
    return http.post(url, headers: headers, body: jsonEncode({'query': mutation}));
  }
}
