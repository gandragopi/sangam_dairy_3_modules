import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/order.dart';

class OrderApiService {
  static final OrderApiService _instance = OrderApiService._internal();
  factory OrderApiService() => _instance;
  OrderApiService._internal() {
    _initMockOrders();
  }

  String baseUrl = 'http://localhost:8080/api/orders';
  bool isLiveServerConnected = false;

  final List<Order> _mockOrders = [];

  void _initMockOrders() {
    if (_mockOrders.isNotEmpty) return;

    final now = DateTime.now();
    final names = [
      'Ramesh Kumar', 'Sita Lakshmi', 'Venkateswarlu P.', 'Anitha Reddy',
      'Koteswara Rao', 'Suresh Babu', 'Lakshmi Narayan', 'Chaitanya V.',
      'Bhavani Prasad', 'Radha Krishna', 'Gopi Nath', 'Nageswara Rao',
      'Padma Kumari', 'Srinivasa Reddy', 'Ramakrishna M.', 'Koteswari V.',
      'Subba Rao', 'Durga Prasad', 'Venkata Ramana', 'Anjaneya Raju',
      'Sivaramakrishna', 'Mallikarjuna Rao', 'Satyanarayana', 'Subrahmanyam',
      'Veera Venkata', 'Prabhakar Rao', 'Suryanarayana', 'Anand Kumar',
      'Rajesh Babu', 'Maheshwari D.', 'Bala Krishna', 'Narsimha Rao'
    ];

    final addresses = [
      'Flat 402, Green Meadows, Guntur',
      'Door 12-4, Collectorate Road, Vijayawada',
      'Plot 88, Auto Nagar, Tenali',
      '1-89 Main Road, Vadlamudi',
      'Shop 5, Market Yard, Ongole',
      'Brindavan Gardens, Guntur',
      'M.G. Road, Vijayawada',
      'Kothapet, Tenali',
      'Main Road, Chilakaluripet',
      'Narasaraopet Central',
      'Bapatla Beach Road',
      'Labbipet, Vijayawada',
      'Brodipet, Guntur',
      'Arundelpet, Guntur',
      'Mangalagiri',
      'Gannavaram',
      'Pamarru',
      'Repalle',
      'Vinukonda'
    ];

    final productOptions = [
      {'id': 1, 'name': 'Badam Milk', 'price': 60.0},
      {'id': 4, 'name': 'Double Toned Milk', 'price': 30.0},
      {'id': 6, 'name': 'Sangam Pure Cow Ghee', 'price': 380.0},
      {'id': 7, 'name': 'Sangam Special Buffalo Ghee', 'price': 720.0},
      {'id': 8, 'name': 'Sangam Fresh Paneer', 'price': 110.0},
      {'id': 9, 'name': 'Sangam Creamy Curd', 'price': 38.0},
      {'id': 10, 'name': 'Sangam Sweet Lassi', 'price': 25.0},
      {'id': 12, 'name': 'Sangam Table Butter', 'price': 58.0},
      {'id': 13, 'name': 'Gulab Jamun Sweet Box', 'price': 190.0},
      {'id': 14, 'name': 'Sangam Malai Peda', 'price': 140.0},
      {'id': 15, 'name': 'Full Cream Milk', 'price': 36.0},
    ];

    int orderIdCounter = 8950;

    for (int day = 0; day <= 30; day++) {
      int ordersToday = (day == 0) ? 5 : 5 + (day % 2);

      for (int i = 0; i < ordersToday; i++) {
        orderIdCounter--;
        final nameIndex = (day * 3 + i) % names.length;
        final addrIndex = (day + i) % addresses.length;

        final hoursAgo = day * 24 + (i * 3) + 1;
        final createdAt = now.subtract(Duration(hours: hoursAgo));

        final itemsCount = 1 + ((day + i) % 3);
        List<OrderItem> items = [];
        double total = 0;

        for (int j = 0; j < itemsCount; j++) {
          final pIndex = (day + i + j) % productOptions.length;
          final p = productOptions[pIndex];
          final qty = 1 + ((i + j) % 3);
          final price = p['price'] as double;
          items.add(OrderItem(
            productId: p['id'] as int,
            productName: p['name'] as String,
            quantity: qty,
            unitPrice: price,
          ));
          total += price * qty;
        }

        final paymentMethods = ['UPI', 'Card', 'COD'];
        final pm = paymentMethods[(day + i) % paymentMethods.length];

        _mockOrders.add(Order(
          id: 'ORD-$orderIdCounter',
          customerName: names[nameIndex],
          customerPhone: '+91 98${(10000000 + orderIdCounter).toString().substring(1)}',
          deliveryAddress: addresses[addrIndex],
          items: items,
          totalAmount: total,
          status: day == 0 && i < 2 ? 'Processing' : 'Delivered',
          paymentStatus: 'Paid',
          paymentMethod: pm,
          transactionId: 'TXN-$pm-$orderIdCounter',
          createdAt: createdAt,
        ));
      }
    }
  }

  Future<List<Order>> getOrders() async {
    try {
      final response = await http
          .get(Uri.parse(baseUrl))
          .timeout(const Duration(seconds: 4));

      if (kDebugMode) {
        print('GET $baseUrl -> Status ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);
        List rawList = [];

        if (decoded is List) {
          rawList = decoded;
        } else if (decoded is Map<String, dynamic>) {
          if (decoded['content'] is List) {
            rawList = decoded['content'];
          } else if (decoded['data'] is List) {
            rawList = decoded['data'];
          } else if (decoded['orders'] is List) {
            rawList = decoded['orders'];
          }
        }

        isLiveServerConnected = true;
        final apiOrders = rawList
            .map<Order>((item) => Order.fromJson(Map<String, dynamic>.from(item)))
            .toList();

        if (apiOrders.isNotEmpty) {
          _mockOrders.clear();
          _mockOrders.addAll(apiOrders);
        }
        return apiOrders;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Backend API getOrders offline at $baseUrl ($e). Using mock orders.');
      }
      isLiveServerConnected = false;
    }

    return List.from(_mockOrders);
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$orderId/status'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'status': newStatus}),
      ).timeout(const Duration(seconds: 4));

      if (kDebugMode) {
        print('PUT $baseUrl/$orderId/status -> Status ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) print('updateOrderStatus API Exception: $e');
    }

    final index = _mockOrders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      final old = _mockOrders[index];
      _mockOrders[index] = Order(
        id: old.id,
        customerName: old.customerName,
        customerPhone: old.customerPhone,
        deliveryAddress: old.deliveryAddress,
        items: old.items,
        totalAmount: old.totalAmount,
        status: newStatus,
        paymentStatus: old.paymentStatus,
        paymentMethod: old.paymentMethod,
        transactionId: old.transactionId,
        createdAt: old.createdAt,
      );
    }
  }
}
