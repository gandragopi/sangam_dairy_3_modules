import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/config/api_config.dart';

class SubscriptionApiService {
  static String get baseUrl => ApiConfig.baseUrl;

  static Future<Map<String, dynamic>?> getSubscription(String userKey) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/subscriptions/$userKey'),
        headers: {'Accept': 'application/json'},
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>?;
      }
    } catch (_) {}
    return null;
  }

  static Future<bool> saveSubscription(Map<String, dynamic> subscriptionData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/subscriptions'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode(subscriptionData),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (_) {}
    return false;
  }
}
