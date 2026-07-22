import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/penjual/notifikasi_penjual.dart';

void main() {
  group('Notifikasi Penjual Widget Tests', () {
    
    // Test: Halaman notifikasi memiliki title
    testWidgets('Halaman notifikasi harus menampilkan "Notifikasi"', 
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: NotifikasiPenjual(
            userName: 'Admin',
            userEmail: 'admin@butik.com',
          ),
        ),
      );
      
      // TUNGGU 2 DETIK
      await tester.pump(const Duration(seconds: 2));
      
      expect(find.text('Notifikasi'), findsOneWidget);
    });

    // Test: Halaman notifikasi memiliki ikon refresh
    testWidgets('Halaman notifikasi memiliki ikon refresh', 
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: NotifikasiPenjual(
            userName: 'Admin',
            userEmail: 'admin@butik.com',
          ),
        ),
      );
      
      await tester.pump(const Duration(seconds: 1));
      
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });
  });
}