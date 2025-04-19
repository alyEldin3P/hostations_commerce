import 'package:flutter/material.dart';

abstract class SnackBarService {
  void showSuccess(String message, {Duration? duration});
  void showError(String message, {Duration? duration});
  void showInfo(String message, {Duration? duration});
  void showWarning(String message, {Duration? duration});
  void showCustom({
    required String message,
    required Color backgroundColor,
    required Color textColor,
    Duration? duration,
    Widget? icon,
    SnackBarAction? action,
  });
}
