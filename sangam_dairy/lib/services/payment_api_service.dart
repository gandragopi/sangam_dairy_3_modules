import 'dart:convert';

import 'package:http/http.dart' as http;
import '../core/config/api_config.dart';

class PaymentApiService {
  static String get baseUrl => ApiConfig.baseUrl;
  /// Creates a PENDING payment in the backend.
  static Future<Map<String, dynamic>> createPayment({
    required String orderKey,
    required String paymentReference,
    required double amount,
    required String paymentMethod,
  }) async {
    final Uri url = Uri.parse('$baseUrl/api/payments');

    final Map<String, dynamic> body = {
      'orderKey': orderKey,
      'paymentReference': paymentReference,
      'amount': amount,
      'paymentMethod': paymentMethod,
    };

    final http.Response response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    throw Exception(
      'Failed to create payment: '
          '${response.statusCode} ${response.body}',
    );
  }

  /// Marks a PENDING payment as SUCCESS.
  ///
  /// This is a development/test flow.
  /// Real card payments require a payment gateway and server-side verification.
  static Future<Map<String, dynamic>> markPaymentSuccess({
    required String paymentReference,
    String? transactionId,
  }) async {
    final Uri url = Uri.parse(
      '$baseUrl/api/payments/$paymentReference/success',
    );

    final Map<String, dynamic> body = {};

    if (transactionId != null && transactionId.trim().isNotEmpty) {
      body['transactionId'] = transactionId.trim();
    }

    final http.Response response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    throw Exception(
      'Failed to mark payment as successful: '
          '${response.statusCode} ${response.body}',
    );
  }

  /// Gets a payment using its payment reference.
  static Future<Map<String, dynamic>> getPayment(
      String paymentReference,
      ) async {
    final Uri url = Uri.parse(
      '$baseUrl/api/payments/$paymentReference',
    );

    final http.Response response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    throw Exception(
      'Failed to get payment: '
          '${response.statusCode} ${response.body}',
    );
  }
}
