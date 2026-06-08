import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'dart:io' show Platform;

class ApiConfig {
  static String get baseUrl {
    // Web
    if (kIsWeb) {
      return "http://localhost:8000";
    }
    // Android emulator
    if (Platform.isAndroid) {
      return "http://10.0.2.2:8000";
    }
    // Android physical device
    return "http://192.168.88.13:8000";
  }
}

class ApiBaseUrl {
  static String get baseUrl => '${ApiConfig.baseUrl}/api';

  // Auth
  static String get login => '$baseUrl/login';
  static String get logout => '$baseUrl/logout';

  // Produk
  static String get me => '$baseUrl/me';
  static String get produk => '$baseUrl/produk';
  static String produkById(int id) => '$baseUrl/produk/$id';
  
  // Kategori
  static String get kategori => '$baseUrl/kategori';

  // Gambar produk
  static String getImageUrl(dynamic path) {
    if (path == null) return '';
    if (path is String && path.isNotEmpty) {
      String fileName = path.split('/').last;
      return '${ApiConfig.baseUrl}/gambar/$fileName';
    }
    return '';
  }

  // Gambar size chart
static String getSizeChartUrl(dynamic path) {
  if (path == null) return '';
  if (path is String && path.isNotEmpty) {
    String fileName = path.split('/').last;
    return '${ApiConfig.baseUrl}/size-chart/$fileName';
  }
  return '';
}

  static String safeString(dynamic value, {String defaultValue = ''}) {
    if (value == null) return defaultValue;
    return value.toString();
  }

  static int safeInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  static List safeList(dynamic value) {
    if (value == null) return [];
    if (value is List) return value;
    if (value is String) {
      try {
        final decoded = jsonDecode(value);
        if (decoded is List) return decoded;
      } catch (e) {
        return [];
      }
    }
    return [];
  }
}
