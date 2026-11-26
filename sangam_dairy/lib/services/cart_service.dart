
import 'dart:convert';

import 'package:http/http.dart' as http;
import '../core/config/api_config.dart';

class CartService {
  // ============================================================
  // BACKEND CONFIGURATION
  // ============================================================

  static String get baseUrl => ApiConfig.baseUrl;

  // Temporary guest cart. Replace with an authenticated user ID later.
  static const String _cartKey = 'guest_cart';

  // ============================================================
  // GET CART
  // ============================================================

  static Future<List<Map<String, dynamic>>> getCart() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/cart/$_cartKey'),
      headers: const {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load cart. Status: ${response.statusCode}',
      );
    }

    final dynamic data = jsonDecode(response.body);

    if (data is! List) {
      return [];
    }

    return data.map<Map<String, dynamic>>((dynamic item) {
      final cartItem = Map<String, dynamic>.from(item as Map);

      cartItem['id'] = cartItem['id'];
      cartItem['productId'] = cartItem['productId'];
      cartItem['name'] = cartItem['productName'];
      cartItem['image'] = cartItem['image']?.toString() ?? '';
      cartItem['packSize'] = cartItem['packSize']?.toString() ?? '';
      cartItem['price'] = _toNum(cartItem['price']);
      cartItem['quantity'] = _toInt(cartItem['quantity']);

      return cartItem;
    }).toList();
  }

  // ============================================================
  // ADD TO CART
  // ============================================================

  static Future<void> addToCart(
      Map<String, dynamic> product, {
        int quantity = 1,
      }) async {
    final dynamic rawProductId = product['id'];

    if (rawProductId == null) {
      throw Exception(
        'Product ID is missing. Please reload the product from backend.',
      );
    }

    final int? productId = int.tryParse(rawProductId.toString());

    if (productId == null) {
      throw Exception('Invalid product ID: $rawProductId');
    }

    if (quantity < 1) {
      throw Exception('Quantity must be at least 1.');
    }

    final Map<String, dynamic> body = {
      'cartKey': _cartKey,
      'productId': productId,
      'productName': product['name']?.toString() ?? '',
      'image': product['image']?.toString() ?? '',
      'packSize': product['packSize']?.toString() ?? '',
      'price': _toNum(product['price']),
      'quantity': quantity,
    };

    final response = await http.post(
      Uri.parse('$baseUrl/api/cart'),
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 200 &&
        response.statusCode != 201) {
      throw Exception(
        'Failed to add product to cart. '
            'Status: ${response.statusCode}. '
            'Response: ${response.body}',
      );
    }
  }

  // ============================================================
  // INCREASE QUANTITY BY CART ITEM ID
  // ============================================================

  static Future<void> increaseQuantity(dynamic cartItemId) async {
    final item = await _findCartItem(cartItemId);

    if (item == null) {
      throw Exception('Cart item not found.');
    }

    final int currentQuantity = _toInt(item['quantity']);

    await _updateQuantity(
      item['id'],
      currentQuantity + 1,
    );
  }

  // ============================================================
  // DECREASE QUANTITY BY CART ITEM ID
  // ============================================================

  static Future<void> decreaseQuantity(dynamic cartItemId) async {
    final item = await _findCartItem(cartItemId);

    if (item == null) {
      throw Exception('Cart item not found.');
    }

    final int currentQuantity = _toInt(item['quantity']);

    if (currentQuantity <= 1) {
      await removeFromCart(item['id']);
      return;
    }

    await _updateQuantity(
      item['id'],
      currentQuantity - 1,
    );
  }

  // ============================================================
  // FIND ONE CART ITEM BY ID
  // ============================================================

  static Future<Map<String, dynamic>?> _findCartItem(
      dynamic cartItemId,
      ) async {
    if (cartItemId == null) {
      throw Exception('Cart item ID is missing.');
    }

    final cart = await getCart();

    for (final item in cart) {
      if (item['id'].toString() == cartItemId.toString()) {
        return item;
      }
    }

    return null;
  }

  // ============================================================
  // UPDATE QUANTITY
  // ============================================================

  static Future<void> _updateQuantity(
      dynamic cartItemId,
      int quantity,
      ) async {
    final int? id = int.tryParse(cartItemId.toString());

    if (id == null) {
      throw Exception('Invalid cart item ID.');
    }

    if (quantity < 1) {
      throw Exception('Quantity must be at least 1.');
    }

    final response = await http.put(
      Uri.parse('$baseUrl/api/cart/$id'),
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'quantity': quantity,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to update cart quantity. '
            'Status: ${response.statusCode}. '
            'Response: ${response.body}',
      );
    }
  }

  // ============================================================
  // REMOVE CART ITEM BY ID
  // ============================================================

  static Future<void> removeFromCart(dynamic cartItemId) async {
    if (cartItemId == null) {
      throw Exception('Cart item ID is missing.');
    }

    final int? id = int.tryParse(cartItemId.toString());

    if (id == null) {
      throw Exception('Invalid cart item ID.');
    }

    final response = await http.delete(
      Uri.parse('$baseUrl/api/cart/$id'),
      headers: const {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200 &&
        response.statusCode != 204) {
      throw Exception(
        'Failed to remove cart item. '
            'Status: ${response.statusCode}. '
            'Response: ${response.body}',
      );
    }
  }

  // ============================================================
  // CLEAR CART
  // ============================================================

  static Future<void> clearCart() async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/cart/clear/$_cartKey'),
      headers: const {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200 &&
        response.statusCode != 204) {
      throw Exception(
        'Failed to clear cart. '
            'Status: ${response.statusCode}. '
            'Response: ${response.body}',
      );
    }
  }

  // ============================================================
  // CART ITEM COUNT
  // ============================================================

  static Future<int> getCartItemCount() async {
    final cart = await getCart();

    int count = 0;

    for (final item in cart) {
      count += _toInt(item['quantity']);
    }

    return count;
  }

  // ============================================================
  // CART TOTAL
  // ============================================================

  static Future<double> getCartTotal() async {
    final cart = await getCart();

    double total = 0;

    for (final item in cart) {
      final double price = _toNum(item['price']).toDouble();
      final int quantity = _toInt(item['quantity']);

      total += price * quantity;
    }

    return total;
  }

  // ============================================================
  // NUMBER HELPERS
  // ============================================================

  static num _toNum(dynamic value) {
    if (value is num) {
      return value;
    }

    return num.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
