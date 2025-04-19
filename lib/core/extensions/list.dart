/// Extension on List to provide additional utility methods
extension ListExtension<T> on List<T> {
  /// Returns the first element of the list, or a default value if the list is empty
  T firstOr(T defaultValue) {
    return isNotEmpty ? first : defaultValue;
  }

  /// Returns the element at the specified index, or a default value if the index is out of bounds
  T elementAtOr(int index, T defaultValue) {
    return (index >= 0 && index < length) ? this[index] : defaultValue;
  }

  /// Returns a new list with the specified item added if it's not already in the list
  List<T> addIfNotExists(T item) {
    if (!contains(item)) {
      return [...this, item];
    }
    return this;
  }

  /// Returns a new list with the specified item removed if it exists
  List<T> removeIfExists(T item) {
    if (contains(item)) {
      return where((element) => element != item).toList();
    }
    return this;
  }
}
