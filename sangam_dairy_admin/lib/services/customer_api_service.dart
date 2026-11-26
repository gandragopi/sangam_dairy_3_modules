import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/customer.dart';

class CustomerApiService {
  static final CustomerApiService _instance = CustomerApiService._internal();
  factory CustomerApiService() => _instance;
  CustomerApiService._internal();

  String baseUrl = 'http://localhost:8080/api/customers';
  bool isLiveServerConnected = false;

  final List<Customer> _mockCustomers = [
    Customer(id: 'CUST-101', name: 'Ramesh Kumar', email: 'ramesh.k@gmail.com', phone: '+91 98765 43210', city: 'Guntur', totalOrders: 18, totalSpent: 4250.0, joinedDate: DateTime(2025, 4, 12)),
    Customer(id: 'CUST-102', name: 'Sita Lakshmi', email: 'sita.lakshmi@yahoo.com', phone: '+91 91234 56789', city: 'Vijayawada', totalOrders: 24, totalSpent: 6800.0, joinedDate: DateTime(2025, 2, 20)),
    Customer(id: 'CUST-103', name: 'Venkateswarlu P.', email: 'venkat.p@outlook.com', phone: '+91 94401 22334', city: 'Tenali', totalOrders: 9, totalSpent: 2100.0, joinedDate: DateTime(2025, 6, 5)),
    Customer(id: 'CUST-104', name: 'Anitha Reddy', email: 'anitha.reddy@gmail.com', phone: '+91 97000 11223', city: 'Vadlamudi', totalOrders: 31, totalSpent: 8900.0, joinedDate: DateTime(2024, 11, 15)),
    Customer(id: 'CUST-105', name: 'Koteswara Rao', email: 'koteswara.rao@gmail.com', phone: '+91 98888 77766', city: 'Ongole', totalOrders: 14, totalSpent: 3500.0, joinedDate: DateTime(2025, 3, 10)),
  ];

  Future<List<Customer>> getCustomers() async {
    try {
      final response = await http.get(Uri.parse(baseUrl)).timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);
        List rawList = decoded is List ? decoded : (decoded['content'] ?? []);
        isLiveServerConnected = true;
        final apiCustomers = rawList.map((c) => Customer.fromJson(Map<String, dynamic>.from(c))).toList();
        if (apiCustomers.isNotEmpty) {
          _mockCustomers.clear();
          _mockCustomers.addAll(apiCustomers);
        }
        return apiCustomers;
      }
    } catch (e) {
      if (kDebugMode) print('Customer API offline ($e). Using mock customers.');
      isLiveServerConnected = false;
    }
    return List.from(_mockCustomers);
  }
}
