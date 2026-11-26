import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/config/api_config.dart';

class NotificationApiService {
  static String get baseUrl => ApiConfig.baseUrl;

  static Future<List<Map<String, dynamic>>> getNotifications(String userKey) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/notifications/$userKey'),
        headers: {'Accept': 'application/json'},
      );
      if (response.statusCode == 200) {
        final List decoded = jsonDecode(response.body);
        return decoded.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
      }
    } catch (_) {}
    return [];
  }
}
