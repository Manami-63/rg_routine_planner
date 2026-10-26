/// Element-wise list equality, for `==` on immutable models.
///
/// Flutter's `listEquals` lives in `package:flutter/foundation.dart`, which
/// pure-Dart domain code should not import.
bool listEqual<T>(List<T> a, List<T> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
