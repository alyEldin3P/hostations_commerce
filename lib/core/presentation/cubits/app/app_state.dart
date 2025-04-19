import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum AppStateStatus { initial, loading, success, failure }

class AppState extends Equatable {
  final AppStateStatus status;
  final bool hasOpenedAppBefore;
  final String selectedLanguageCode;
  final bool isGuest;
  final bool isRightToLeft;
  final int currentOnboardingIndex;
  final String errorMessage;
  final ThemeMode themeMode;

  const AppState({
    this.status = AppStateStatus.initial,
    this.hasOpenedAppBefore = false,
    this.selectedLanguageCode = 'en',
    this.isGuest = true,
    this.isRightToLeft = false,
    this.currentOnboardingIndex = 0,
    this.errorMessage = '',
    this.themeMode = ThemeMode.system,
  });

  AppState copyWith({
    AppStateStatus? status,
    bool? hasOpenedAppBefore,
    String? selectedLanguageCode,
    bool? isRightToLeft,
    int? currentOnboardingIndex,
    String? errorMessage,
    ThemeMode? themeMode,
    bool? isGuest,
  }) {
    return AppState(
      status: status ?? this.status,
      hasOpenedAppBefore: hasOpenedAppBefore ?? this.hasOpenedAppBefore,
      selectedLanguageCode: selectedLanguageCode ?? this.selectedLanguageCode,
      isRightToLeft: isRightToLeft ?? this.isRightToLeft,
      currentOnboardingIndex: currentOnboardingIndex ?? this.currentOnboardingIndex,
      errorMessage: errorMessage ?? this.errorMessage,
      themeMode: themeMode ?? this.themeMode,
      isGuest: isGuest ?? this.isGuest,
    );
  }

  @override
  List<Object?> get props => [status, hasOpenedAppBefore, selectedLanguageCode, isRightToLeft, currentOnboardingIndex, errorMessage, themeMode, isGuest];
}
