import 'dart:convert';

import 'package:http/http.dart' as http;
import '../core/config/api_config.dart';

class OrderApiService {
  static String get baseUrl => ApiConfig.baseUrl;
  static const String orderKey = 'guest_cart';

  // ============================================================
  // CREATE ORDER
  // ============================================================

  static Future<Map<String, dynamic>> createOrder({
    required String customerName,
    required String mobile,
    required String address,
    required String city,
    required String pincode,
    required String paymentMethod,
  }) async {
    final fullAddress = [
      address.trim(),
      city.trim(),
      pincode.trim(),
    ].where((value) => value.isNotEmpty).join(', ');

    final response = await http.post(
      Uri.parse('$baseUrl/api/orders'),
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'orderKey': orderKey,
        'customerName': customerName,
        'phone': mobile,
        'address': fullAddress,
        'paymentMethod': paymentMethod,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to create order. '
            'Status: ${response.statusCode}',
      );
    }

    final dynamic data = jsonDecode(response.body);

    if (data is! Map) {
      throw Exception('Invalid order response.');
    }

    return Map<String, dynamic>.from(data);
  }

  // ============================================================
  // GET ALL ORDERS
  // ============================================================

  static Future<List<Map<String, dynamic>>> getOrders() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/orders/$orderKey'),
      headers: const {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load orders. '
            'Status: ${response.statusCode}',
      );
    }

    final dynamic data = jsonDecode(response.body);

    if (data is! List) {
      return [];
    }

    final List<Map<String, dynamic>> orders = [];

    for (final item in data) {
      if (item is! Map) {
        continue;
      }

      final order = Map<String, dynamic>.from(item);

      final dynamic rawOrderId = order['id'];

      if (rawOrderId == null) {
        continue;
      }

      final int? orderId = int.tryParse(
        rawOrderId.toString(),
      );

      if (orderId == null) {
        continue;
      }

      // Get products/items belonging to this order.
      final items = await getOrderItems(orderId);

      order['items'] = items;

      orders.add(order);
    }

    return orders;
  }

  // ============================================================
  // GET ORDER ITEMS
  // ============================================================

  static Future<List<Map<String, dynamic>>> getOrderItems(
      int orderId,
      ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/orders/$orderId/items'),
      headers: const {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load order items. '
            'Status: ${response.statusCode}',
      );
    }

    final dynamic data = jsonDecode(response.body);

    if (data is! List) {
      return [];
    }

    return data
        .whereType<Map>()
        .map<Map<String, dynamic>>((item) {
      final raw = Map<String, dynamic>.from(item);

      return {
        'id': raw['id'],
        'productId': raw['productId'],
        'name': raw['productName'] ??
            raw['name'] ??
            'Product',
        'productName': raw['productName'] ??
            raw['name'] ??
            'Product',
        'image': raw['image'] ?? '',
        'packSize': raw['packSize'] ?? '',
        'price': _toDouble(raw['price']),
        'quantity': _toInt(raw['quantity']),
      };
    }).toList();
  }

  // ============================================================
  // NUMBER HELPERS
  // ============================================================

  static double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
      value?.toString() ?? '',
    ) ??
        0;
  }

  static int _toInt(dynamic value) {
    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
      value?.toString() ?? '',
    ) ??
        1;
  }
}
