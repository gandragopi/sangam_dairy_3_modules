
import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import '../core/config/api_config.dart';

class AuthApiService {
// Local backend URL.
static String get baseUrl => ApiConfig.baseUrl;

static const Duration _timeout = Duration(seconds: 60);

// Request email OTP
static Future<void> requestEmailOtp(String email) async {
final normalizedEmail = email.trim().toLowerCase();

if (normalizedEmail.isEmpty ||
!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
    .hasMatch(normalizedEmail)) {
throw Exception('Please enter a valid email address.');
}

final uri = Uri.parse('$baseUrl/api/auth/send-otp');

try {
final response = await http
    .post(
uri,
headers: const {
'Content-Type': 'application/json',
'Accept': 'application/json',
},
body: jsonEncode({
'email': normalizedEmail,
}),
)
    .timeout(_timeout);

if (response.statusCode == 200) {
return;
}

throw Exception(_message(response));
} on TimeoutException {
throw Exception(
'OTP request timed out. Please check your internet connection '
'and backend logs.',
);
} on http.ClientException catch (e) {
throw Exception(
'Cannot connect to backend. Check your internet connection. '
'Details: ${e.message}',
);
}
}

// Verify email OTP
static Future<Map<String, dynamic>> verifyEmailOtp({
required String email,
required String otp,
}) async {
final normalizedEmail = email.trim().toLowerCase();
final normalizedOtp = otp.trim();

if (normalizedEmail.isEmpty || normalizedOtp.isEmpty) {
throw Exception('Enter your email address and OTP.');
}

final uri = Uri.parse('$baseUrl/api/auth/verify-otp');

try {
final response = await http
    .post(
uri,
headers: const {
'Content-Type': 'application/json',
'Accept': 'application/json',
},
body: jsonEncode({
'email': normalizedEmail,
'otp': normalizedOtp,
}),
)
    .timeout(_timeout);

if (response.statusCode == 200) {
final dynamic decoded = jsonDecode(response.body);

if (decoded is Map<String, dynamic> &&
decoded['verified'] == true) {
return decoded;
}

throw Exception(
'Server did not confirm email verification. '
'Response: ${response.body}',
);
}

throw Exception(_message(response));
} on TimeoutException {
throw Exception(
'OTP verification timed out. Please try again.',
);
} on http.ClientException catch (e) {
throw Exception(
'Cannot connect to backend. Check your internet connection. '
'Details: ${e.message}',
);
}
}

// Extract a readable error message from the backend response.
static String _message(http.Response response) {
try {
final dynamic decoded = jsonDecode(response.body);

if (decoded is Map) {
final dynamic message =
decoded['message'] ??
decoded['detail'] ??
decoded['error'];

if (message != null) {
return message.toString();
}
}
} catch (_) {
// Response body is not JSON.
}

return 'Request failed (${response.statusCode}). '
'Server response: ${response.body}';
}
}
