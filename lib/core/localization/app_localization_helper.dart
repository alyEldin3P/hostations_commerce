import 'package:flutter/material.dart';
import 'package:hostations_commerce/core/localization/app_localizations.dart';

/// Extension on BuildContext to easily access translations
extension AppLocalizationsExtension on BuildContext {
  /// Get the AppLocalizations instance for the current context
  AppLocalizations get tr => AppLocalizations.of(this);
  
  /// Check if the current locale is right-to-left
  bool get isRtl => Localizations.localeOf(this).languageCode == 'ar';
}

/// Helper class for localization
class AppLocalizationHelper {
  /// Get the text direction based on the locale
  static TextDirection getTextDirection(Locale locale) {
    return locale.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr;
  }
  
  /// Get the supported locales for the app
  static List<Locale> get supportedLocales => const [
    Locale('en', ''), // English
    Locale('ar', ''), // Arabic
  ];
  
  /// Get the localization delegates for the app
  static Iterable<LocalizationsDelegate<dynamic>> get localizationDelegates => [
    AppLocalizations.delegate,
    // Add other delegates as needed
  ];
}
