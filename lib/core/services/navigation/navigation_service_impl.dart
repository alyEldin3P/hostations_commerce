import 'package:flutter/material.dart';
import 'package:hostations_commerce/core/services/navigation/navigation_service.dart';

class NavigationServiceImpl implements NavigationService {
  final GlobalKey<NavigatorState> navigatorKey;

  NavigationServiceImpl(this.navigatorKey);

  @override
  Future<T?> navigateTo<T>(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushNamed<T>(routeName, arguments: arguments);
  }

  @override
  Future<T?> navigateToReplacing<T>(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushReplacementNamed<T, dynamic>(routeName, arguments: arguments);
  }

  @override
  Future<T?> navigateToRemovingAll<T>(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushNamedAndRemoveUntil<T>(routeName, (Route<dynamic> route) => false, arguments: arguments);
  }

  @override
  void pop<T>([T? result]) {
    navigatorKey.currentState!.pop<T>(result);
  }

  @override
  void popUntil(String routeName) {
    navigatorKey.currentState!.popUntil(ModalRoute.withName(routeName));
  }

  @override
  bool canPop() {
    return navigatorKey.currentState!.canPop();
  }
}
