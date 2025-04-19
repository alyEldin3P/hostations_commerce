import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hostations_commerce/core/presentation/cubits/app/app_state.dart';
import 'package:hostations_commerce/core/services/cache/cache_service.dart';

class AppCubit extends Cubit<AppState> {
  final CacheService _cacheService;
  static const String _hasOpenedAppBeforeKey = 'has_opened_app_before';
  static const String _selectedLanguageKey = 'selected_language';
  static const String _themeDarkModeKey = 'theme_dark_mode';
  static const String _isLoggedInKey = 'is_logged_in';
  static const int _totalOnboardingScreens = 3; // Total number of onboarding screens

  AppCubit({required CacheService cacheService})
      : _cacheService = cacheService,
        super(const AppState());

  Future<void> init() async {
    emit(state.copyWith(status: AppStateStatus.loading));
    try {
      final hasOpenedAppBefore = _cacheService.getBool(_hasOpenedAppBeforeKey) ?? false;
      final selectedLanguageCode = _cacheService.getString(_selectedLanguageKey) ?? 'en';
      final isRightToLeft = selectedLanguageCode == 'ar';
      final isDark = _cacheService.getBool(_themeDarkModeKey) ?? false;
      final isLoggedIn = _cacheService.getBool(_isLoggedInKey) ?? false;
      log("isLoggedIN $isLoggedIn");
      emit(state.copyWith(
        status: AppStateStatus.success,
        hasOpenedAppBefore: hasOpenedAppBefore,
        selectedLanguageCode: selectedLanguageCode,
        isRightToLeft: isRightToLeft,
        isGuest: !isLoggedIn,
        themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AppStateStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> setHasOpenedAppBefore() async {
    emit(state.copyWith(status: AppStateStatus.loading));
    try {
      await _cacheService.setBool(_hasOpenedAppBeforeKey, true);
      emit(state.copyWith(
        status: AppStateStatus.success,
        hasOpenedAppBefore: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AppStateStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> setLanguage(String languageCode) async {
    emit(state.copyWith(status: AppStateStatus.loading));
    try {
      await _cacheService.setString(_selectedLanguageKey, languageCode);
      final isRightToLeft = languageCode == 'ar';

      emit(state.copyWith(
        status: AppStateStatus.success,
        selectedLanguageCode: languageCode,
        isRightToLeft: isRightToLeft,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AppStateStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  // Onboarding navigation methods
  void nextOnboardingScreen() {
    if (state.currentOnboardingIndex < _totalOnboardingScreens - 1) {
      emit(state.copyWith(
        currentOnboardingIndex: state.currentOnboardingIndex + 1,
      ));
    }
  }

  void previousOnboardingScreen() {
    if (state.currentOnboardingIndex > 0) {
      emit(state.copyWith(
        currentOnboardingIndex: state.currentOnboardingIndex - 1,
      ));
    }
  }

  void goToOnboardingScreen(int index) {
    if (index >= 0 && index < _totalOnboardingScreens) {
      emit(state.copyWith(
        currentOnboardingIndex: index,
      ));
    }
  }

  bool isLastOnboardingScreen() {
    return state.currentOnboardingIndex == _totalOnboardingScreens - 1;
  }

  // Getters for supported languages
  List<Map<String, dynamic>> getSupportedLanguages() {
    return [
      {
        'code': 'en',
        'name': 'English',
        'flagImagePath': 'assets/images/flags/en.png',
        'isRightToLeft': false,
      },
      {
        'code': 'ar',
        'name': 'العربية',
        'flagImagePath': 'assets/images/flags/ar.png',
        'isRightToLeft': true,
      },
    ];
  }

  void toggleTheme(bool isDark) {
    emit(state.copyWith(themeMode: isDark ? ThemeMode.dark : ThemeMode.light));
    _cacheService.setBool(_themeDarkModeKey, isDark);
  }

  Future<void> setIsGuest(bool isGuest) async {
    emit(state.copyWith(status: AppStateStatus.loading));
    try {
      await _cacheService.setBool(_isLoggedInKey, !isGuest);
      emit(state.copyWith(isGuest: isGuest));
    } catch (e) {
      emit(state.copyWith(
        status: AppStateStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}
