import 'dart:convert';

import 'package:http/http.dart' as http;
import '../core/config/api_config.dart';

class SupportApiService {
  static String get baseUrl => ApiConfig.baseUrl;

  static const String chatKey = 'guest_support_chat';

  // ------------------------------------------------------------
  // GET CHAT MESSAGES
  // ------------------------------------------------------------
  static Future<List<Map<String, dynamic>>> getMessages() async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/api/support/chat/${Uri.encodeComponent(chatKey)}',
      ),
      headers: const {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load support messages. '
            'Status: ${response.statusCode}',
      );
    }

    final dynamic data = jsonDecode(response.body);

    if (data is! List) {
      return [];
    }

    return data
        .whereType<Map>()
        .map<Map<String, dynamic>>(
          (item) => Map<String, dynamic>.from(item),
    )
        .toList();
  }

  // ------------------------------------------------------------
  // SEND CHAT MESSAGE
  // ------------------------------------------------------------
  static Future<Map<String, dynamic>> sendMessage(
      String message,
      ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/support/chat'),
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'customerKey': chatKey,
        'message': message.trim(),
        'sender': 'CUSTOMER',
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to send support message. '
            'Status: ${response.statusCode}',
      );
    }

    final dynamic data = jsonDecode(response.body);

    if (data is! Map) {
      throw Exception(
        'Invalid support message response.',
      );
    }

    return Map<String, dynamic>.from(data);
  }
}
