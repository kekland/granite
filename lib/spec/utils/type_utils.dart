/// Checks if all elements in the list are of the same type [T].
bool isListWithElementType<T>(List<dynamic> list) {
  for (final element in list) {
    if (element is! T) return false;
  }

  return true;
}
