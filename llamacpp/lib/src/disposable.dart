import 'package:meta/meta.dart';

/// A resource that can be disposed, or "cleaned up".
mixin Disposable {
  bool _wasDisposed = false;

  /// Frees any resources and marks as disposed.
  @mustCallSuper
  void dispose() => _wasDisposed = true;

  /// Throws a [StateError] if this was marked as disposed.
  @protected
  void checkDisposed() {
    if (_wasDisposed) {
      throw StateError('Tried to access $this, but was already disposed');
    }
  }
}
