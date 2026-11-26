import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AdminUser {
  final String id;
  final String name;
  final String email;
  final String role;
  final String token;
  final String avatarUrl;

  AdminUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.token = '',
    this.avatarUrl = '',
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    final userData = json['user'] is Map ? json['user'] as Map<String, dynamic> : json;

    return AdminUser(
      id: userData['id']?.toString() ?? userData['adminId']?.toString() ?? 'ADM001',
      name: userData['name']?.toString() ??
          userData['username']?.toString() ??
          userData['fullName']?.toString() ??
          'Gandra Gopi',
      email: userData['email']?.toString() ?? 'gandragopigandra123@gmail.com',
      role: userData['role']?.toString() ?? 'Super Admin',
      token: json['token']?.toString() ?? json['accessToken']?.toString() ?? '',
      avatarUrl: userData['avatarUrl']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'token': token,
      'avatarUrl': avatarUrl,
    };
  }
}

class AuthResult {
  final bool success;
  final String message;
  final AdminUser? user;

  AuthResult({
    required this.success,
    this.message = '',
    this.user,
  });
}

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  AdminUser? _currentUser;
  String authApiUrl = 'http://localhost:8080/api/auth/login';

  // Configured permanent Admin credentials
  String savedAdminEmail = 'gandragopigandra123@gmail.com';
  String savedAdminPassword = 'Gandra@2003';

  bool get isAuthenticated => _currentUser != null;
  AdminUser? get currentUser => _currentUser;

  /// Update permanent admin credentials
  void updateAdminCredentials(String email, String password) {
    if (email.isNotEmpty && password.isNotEmpty) {
      savedAdminEmail = email.trim().toLowerCase();
      savedAdminPassword = password;
      notifyListeners();
    }
  }

  Future<AuthResult> login({
    required String email,
    required String password,
    bool tryBackendServerFirst = true,
  }) async {
    final cleanEmail = email.trim().toLowerCase();

    // 1. Try Live Spring Boot Backend Server first if enabled
    if (tryBackendServerFirst) {
      try {
        final response = await http.post(
          Uri.parse(authApiUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email': cleanEmail,
            'username': cleanEmail,
            'password': password,
          }),
        ).timeout(const Duration(seconds: 4));

        if (response.statusCode == 200 || response.statusCode == 201) {
          final dynamic decoded = jsonDecode(response.body);
          Map<String, dynamic> jsonMap = {};

          if (decoded is Map<String, dynamic>) {
            jsonMap = decoded;
          } else {
            jsonMap = {'email': cleanEmail, 'name': 'Gandra Gopi'};
          }

          final user = AdminUser.fromJson(jsonMap);
          _currentUser = user;
          savedAdminEmail = cleanEmail;
          savedAdminPassword = password;
          notifyListeners();
          return AuthResult(success: true, user: user);
        } else if (response.statusCode == 401 || response.statusCode == 403) {
          return AuthResult(
            success: false,
            message: 'Invalid email or password. Please check your credentials.',
          );
        }
      } catch (e) {
        if (kDebugMode) {
          print('Backend Server unreachable at $authApiUrl. Verifying via registered admin credentials.');
        }
      }
    }

    // 2. Direct Permanent Credential Verification
    if (cleanEmail == savedAdminEmail.toLowerCase() && password == savedAdminPassword) {
      final user = AdminUser(
        id: 'ADM001',
        name: 'Gandra Gopi',
        email: cleanEmail,
        role: 'Super Admin',
      );
      _currentUser = user;
      notifyListeners();
      return AuthResult(success: true, user: user);
    } else if (cleanEmail.isNotEmpty && password.isNotEmpty) {
      // Wrong email or password entered
      return AuthResult(
        success: false,
        message: 'Invalid email or password. Please check your credentials.',
      );
    }

    return AuthResult(
      success: false,
      message: 'Please enter both email address and password.',
    );
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}
