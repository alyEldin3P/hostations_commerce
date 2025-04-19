import 'package:flutter/material.dart';
import 'package:hostations_commerce/core/services/snackbar/snackbar_service.dart';

class SnackBarServiceImpl implements SnackBarService {
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey;
  
  SnackBarServiceImpl(this._scaffoldMessengerKey);
  
  ScaffoldMessengerState get _scaffoldMessenger => _scaffoldMessengerKey.currentState!;
  
  bool _isShowingSnackbar = false;
  String? _currentSnackbarMessage;

  @override
  void showSuccess(String message, {Duration? duration}) {
    showCustom(
      message: message,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      duration: duration,
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );
  }
  
  @override
  void showError(String message, {Duration? duration}) {
    showCustom(
      message: message,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      duration: duration,
      icon: const Icon(Icons.error, color: Colors.white),
    );
  }
  
  @override
  void showInfo(String message, {Duration? duration}) {
    showCustom(
      message: message,
      backgroundColor: Colors.blue,
      textColor: Colors.white,
      duration: duration,
      icon: const Icon(Icons.info, color: Colors.white),
    );
  }
  
  @override
  void showWarning(String message, {Duration? duration}) {
    showCustom(
      message: message,
      backgroundColor: Colors.orange,
      textColor: Colors.white,
      duration: duration,
      icon: const Icon(Icons.warning, color: Colors.white),
    );
  }
  
  @override
  void showCustom({
    required String message,
    required Color backgroundColor,
    required Color textColor,
    Duration? duration,
    Widget? icon,
    SnackBarAction? action,
  }) {
    // Ignore if the same message is already being shown
    if (_isShowingSnackbar && _currentSnackbarMessage == message) return;

    _isShowingSnackbar = true;
    _currentSnackbarMessage = message;

    final snackBar = SnackBar(
      content: Row(
        children: [
          if (icon != null) ...[
            icon,
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: textColor),
            ),
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      duration: duration ?? const Duration(seconds: 3),
      action: action,
    );

    _scaffoldMessenger.showSnackBar(snackBar).closed.then((_) {
      _isShowingSnackbar = false;
      _currentSnackbarMessage = null;
    });
  }
}
