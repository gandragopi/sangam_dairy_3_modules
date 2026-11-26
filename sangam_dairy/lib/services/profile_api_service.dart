import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/config/api_config.dart';

class ProfileApiService {
  static String get baseUrl => ApiConfig.baseUrl;

  static Future<Map<String, dynamic>?> getProfile(String mobile) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/profile/$mobile'),
        headers: {'Accept': 'application/json'},
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>?;
      }
    } catch (_) {}
    return null;
  }

  static Future<bool> saveProfile(Map<String, dynamic> profileData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/profile'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode(profileData),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (_) {}
    return false;
  }
}
