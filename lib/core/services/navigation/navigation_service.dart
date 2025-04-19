abstract class NavigationService {
  Future<T?> navigateTo<T>(String routeName, {Object? arguments});
  Future<T?> navigateToReplacing<T>(String routeName, {Object? arguments});
  Future<T?> navigateToRemovingAll<T>(String routeName, {Object? arguments});
  void pop<T>([T? result]);
  void popUntil(String routeName);
  bool canPop();
}
