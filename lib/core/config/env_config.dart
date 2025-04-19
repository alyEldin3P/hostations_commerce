import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment configuration for the app.
/// This class provides access to environment variables defined in .env files.
/// It's used for storing sensitive information like API keys and configuration
/// that might change between environments (dev, staging, prod).
class EnvConfig {
  static final EnvConfig _instance = EnvConfig._internal();

  factory EnvConfig() => _instance;

  EnvConfig._internal();

  /// Initialize the environment configuration.
  /// This should be called before accessing any environment variables.
  Future<void> initialize() async {
    await dotenv.load(fileName: '.env');
  }

  /// Get a string value from the environment.
  String getString(String key, {String defaultValue = ''}) {
    return dotenv.env[key] ?? defaultValue;
  }

  /// Get an integer value from the environment.
  int getInt(String key, {int defaultValue = 0}) {
    final value = dotenv.env[key];
    if (value == null) return defaultValue;
    return int.tryParse(value) ?? defaultValue;
  }

  /// Get a double value from the environment.
  double getDouble(String key, {double defaultValue = 0.0}) {
    final value = dotenv.env[key];
    if (value == null) return defaultValue;
    return double.tryParse(value) ?? defaultValue;
  }

  /// Get a boolean value from the environment.
  bool getBool(String key, {bool defaultValue = false}) {
    final value = dotenv.env[key];
    if (value == null) return defaultValue;
    return value.toLowerCase() == 'true';
  }

  /// Get the privacy policy URL.
  String get privacyPolicyUrl => getString('PRIVACY_POLICY_URL');

  /// Get the terms of service URL.
  String get termsOfServiceUrl => getString('TERMS_OF_SERVICE_URL');

  /// Get the about us URL.
  String get aboutUsUrl => getString('ABOUT_US_URL');

  // E-commerce platform specific getters

  /// Get the Shopify store URL.
  String get shopifyStoreUrl => getString('SHOPIFY_STORE_URL');

  /// Get the Shopify API key.
  String get shopifyApiKey => getString('SHOPIFY_API_KEY');

  /// Get the Shopify API secret.
  String get shopifyApiSecret => getString('SHOPIFY_API_SECRET');

  /// Get the Shopify access token.
  String get shopifyAccessToken => getString('SHOPIFY_ACCESS_TOKEN');

  /// Get the Shopify storefront access token.
  String get shopifyStorefrontAccessToken => getString('SHOPIFY_STOREFRONT_ACCESS_TOKEN');

  /// Get the app name.
  String get appName => getString('APP_NAME', defaultValue: 'Hostations Commerce');

  /// Get the app theme color.
  String get appThemeColor => getString('APP_THEME_COLOR', defaultValue: '#2196F3');

  /// Get the app environment (dev, staging, prod).
  String get environment => getString('ENVIRONMENT', defaultValue: 'dev');

  /// Check if the app is in development mode.
  bool get isDevelopment => environment == 'dev';

  /// Check if the app is in production mode.
  bool get isProduction => environment == 'prod';

  /// Get the API base URL.
  String get apiBaseUrl => getString('API_BASE_URL');

  /// Get the default language.
  String get defaultLanguage => getString('DEFAULT_LANGUAGE', defaultValue: 'en');

  /// Get the supported languages.
  List<String> get supportedLanguages {
    final languages = getString('SUPPORTED_LANGUAGES', defaultValue: 'en,ar');
    return languages.split(',');
  }
}
