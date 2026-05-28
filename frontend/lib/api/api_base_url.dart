import 'package:flutter/foundation.dart';

class ApiConfig {
  static String get baseUrl {
    if (kIsWeb) {
      // Untuk Chrome web
      return "http://127.0.0.1:8000";
    } else {
      // Untuk HP - ganti dengan IP komputer lo
      return "http://192.168.149.88:8000";
    }
  }
}

class ApiBaseUrl {
  static String get baseUrl => '${ApiConfig.baseUrl}/api';

  // Endpoints
  static String get login => '$baseUrl/login';
  static String get logout => '$baseUrl/logout';
  static String get me => '$baseUrl/me';
}
