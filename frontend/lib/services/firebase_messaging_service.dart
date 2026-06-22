// lib/services/firebase_messaging_service.dart

import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_base_url.dart';
import '../main.dart';
import '../penjual/produk_screen.dart';

// Handler untuk background message (harus top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

class FirebaseMessagingService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotif =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'sibu_stok_channel',
    'Notifikasi Stok',
    description: 'Notifikasi ketika stok produk menipis',
    importance: Importance.high,
    playSound: true,
  );

  /// Inisialisasi — panggil di main
  static Future<void> initialize() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      return;
    }

    await _localNotif
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('logoo');
    await _localNotif.initialize(
      const InitializationSettings(android: androidSettings),
      onDidReceiveNotificationResponse: _onNotifTapped,
    );

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    RemoteMessage? initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageOpened(initialMessage);
    }

    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpened);

    await _saveFcmToken();

    _messaging.onTokenRefresh.listen((newToken) async {
      await _sendTokenToServer(newToken);
    });
  }

  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    await _localNotif.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: 'logoo',
          color: const Color(0xFF803033),
        ),
      ),
      payload: jsonEncode(message.data),
    );
  }

  /// Saat user tap notifikasi
  static void _onNotifTapped(NotificationResponse response) async {
    if (response.payload != null) {
      final data = jsonDecode(response.payload!);
      if (data['route'] == '/rekomendasi-stok' || data['route'] == 'stok') {
        final prefs = await SharedPreferences.getInstance();
        final currentName = prefs.getString('user_name') ?? 'Admin Butik';
        final currentEmail = prefs.getString('user_email') ?? 'admin@butik.com';

        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (context) =>
                ProdukScreen(userName: currentName, userEmail: currentEmail),
          ),
        );
      }
    }
  }

  /// Saat app dibuka dari notifikasi
  static void _handleMessageOpened(RemoteMessage message) async {
    final data = message.data;
    if (data['route'] == '/rekomendasi-stok' || data['route'] == 'stok') {
      final prefs = await SharedPreferences.getInstance();
      final currentName = prefs.getString('user_name') ?? 'Admin Butik';
      final currentEmail = prefs.getString('user_email') ?? 'admin@butik.com';

      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) =>
              ProdukScreen(userName: currentName, userEmail: currentEmail),
        ),
      );
    }
  }

  /// Ambil token dan kirim ke server Laravel
  static Future<void> _saveFcmToken() async {
    final token = await _messaging.getToken();
    if (token != null) {
      print(" SIBU FCM Token kamu: $token");
      await _sendTokenToServer(token);
    }
  }

  static Future<void> _sendTokenToServer(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('token');
      if (authToken == null) return;

      await http.post(
        Uri.parse(ApiBaseUrl.fcmToken),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'fcm_token': token}),
      );
    } catch (e) {
      // Gagal kirim token — tidak perlu crash
    }
  }
}
