import 'package:flutter/foundation.dart';

class AppState extends ChangeNotifier {
  // ============================================================
  // USER STATE
  // ============================================================

  String? _email;
  String? _name;

  String? get email => _email;
  String? get name => _name;

  bool get isLoggedIn => _email != null;

  // ============================================================
  // CART
  // ============================================================

  final Map<String, int> _cart = {};

  Map<String, int> get cart => Map.unmodifiable(_cart);

  // ============================================================
  // LOGIN
  // NO FIREBASE
  // NO SMTP
  // LOCAL DEMO LOGIN
  // ============================================================

  void login({
    required String email,
    String? name,
  }) {
    _email = email.trim();
    _name = name?.trim();

    notifyListeners();
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  void logout() {
    _email = null;
    _name = null;

    _cart.clear();

    notifyListeners();
  }

  // ============================================================
  // CART - ADD
  // ============================================================

  void addToCart(String productId) {
    _cart[productId] = (_cart[productId] ?? 0) + 1;
    notifyListeners();
  }

  // ============================================================
  // CART - REMOVE
  // ============================================================

  void removeFromCart(String productId) {
    if (!_cart.containsKey(productId)) {
      return;
    }

    final currentQuantity = _cart[productId] ?? 0;

    if (currentQuantity <= 1) {
      _cart.remove(productId);
    } else {
      _cart[productId] = currentQuantity - 1;
    }

    notifyListeners();
  }

  // ============================================================
  // CART - SET QUANTITY
  // ============================================================

  void setCartQuantity(
      String productId,
      int quantity,
      ) {
    if (quantity <= 0) {
      _cart.remove(productId);
    } else {
      _cart[productId] = quantity;
    }

    notifyListeners();
  }

  // ============================================================
  // CART - CLEAR
  // ============================================================

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  // ============================================================
  // CART - CHECK
  // ============================================================

  bool isInCart(String productId) {
    return _cart.containsKey(productId);
  }

  // ============================================================
  // CART - QUANTITY
  // ============================================================

  int cartQuantity(String productId) {
    return _cart[productId] ?? 0;
  }

  // ============================================================
  // TOTAL ITEMS
  // ============================================================

  int get totalCartItems {
    return _cart.values.fold(
      0,
          (total, quantity) => total + quantity,
    );
  }
}
