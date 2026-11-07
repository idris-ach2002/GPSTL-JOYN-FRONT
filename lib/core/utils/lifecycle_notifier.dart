import 'package:flutter/foundation.dart';

/// Une réponse réseau peut arriver après la fermeture de son écran.
class LifecycleNotifier extends ChangeNotifier {
  bool _disposed = false;
  bool get isDisposed => _disposed;
  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
