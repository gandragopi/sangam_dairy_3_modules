import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/config/api_config.dart';

class ReferralApiService {
  static String get baseUrl => ApiConfig.baseUrl;

  static Future<Map<String, dynamic>?> getReferralData(String userKey) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/referral/$userKey'),
        headers: {'Accept': 'application/json'},
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>?;
      }
    } catch (_) {}
    return null;
  }

  static Future<bool> saveReferralData(String userKey, Map<String, dynamic> referralData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/referral/$userKey'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode(referralData),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (_) {}
    return false;
  }
}
