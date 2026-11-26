import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConfig {
  // PC Local Network IP for physical Android device connectivity: 10.193.124.131:8080
  // Windows / Web: localhost:8080
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8080';
    }
    if (Platform.isAndroid) {
      return 'http://10.193.124.131:8080';
    }
    return 'http://localhost:8080';
  }
}
