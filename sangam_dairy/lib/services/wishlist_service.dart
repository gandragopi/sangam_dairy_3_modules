import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class WishlistService {
  static const String _wishlistKey = 'sangam_dairy_wishlist';

  // ============================================================
  // GET SAVED WISHLIST
  // ============================================================

  static Future<List<Map<String, dynamic>>> getWishlist() async {
    final prefs = await SharedPreferences.getInstance();

    final List<String> savedList =
        prefs.getStringList(_wishlistKey) ?? [];

    return savedList.map((item) {
      final decoded = jsonDecode(item);

      return Map<String, dynamic>.from(decoded);
    }).toList();
  }

  // ============================================================
  // CHECK PRODUCT IS WISHLISTED
  // ============================================================

  static Future<bool> isWishlisted(
      Map<String, dynamic> product,
      ) async {
    final wishlist = await getWishlist();

    final String productName =
        product['name']?.toString() ?? '';

    return wishlist.any(
          (item) => item['name']?.toString() == productName,
    );
  }

  // ============================================================
  // ADD PRODUCT
  // ============================================================

  static Future<void> addToWishlist(
      Map<String, dynamic> product,
      ) async {
    final prefs = await SharedPreferences.getInstance();

    final List<String> savedList =
        prefs.getStringList(_wishlistKey) ?? [];

    final String productName =
        product['name']?.toString() ?? '';

    final bool alreadyExists = savedList.any((item) {
      try {
        final decoded = jsonDecode(item);

        return decoded['name']?.toString() == productName;
      } catch (_) {
        return false;
      }
    });

    if (alreadyExists) {
      return;
    }

    savedList.add(
      jsonEncode(product),
    );

    await prefs.setStringList(
      _wishlistKey,
      savedList,
    );
  }

  // ============================================================
  // REMOVE PRODUCT
  // ============================================================

  static Future<void> removeFromWishlist(
      Map<String, dynamic> product,
      ) async {
    final prefs = await SharedPreferences.getInstance();

    final List<String> savedList =
        prefs.getStringList(_wishlistKey) ?? [];

    final String productName =
        product['name']?.toString() ?? '';

    savedList.removeWhere((item) {
      try {
        final decoded = jsonDecode(item);

        return decoded['name']?.toString() == productName;
      } catch (_) {
        return false;
      }
    });

    await prefs.setStringList(
      _wishlistKey,
      savedList,
    );
  }

  // ============================================================
  // TOGGLE WISHLIST
  // ============================================================

  static Future<bool> toggleWishlist(
      Map<String, dynamic> product,
      ) async {
    final bool exists =
    await isWishlisted(product);

    if (exists) {
      await removeFromWishlist(product);
      return false;
    }

    await addToWishlist(product);
    return true;
  }

  // ============================================================
  // CLEAR ALL WISHLIST
  // ============================================================

  static Future<void> clearWishlist() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_wishlistKey);
  }
}
