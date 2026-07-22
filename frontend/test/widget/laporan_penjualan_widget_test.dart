import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/penjual/laporan_penjualan.dart';

void main() {
  group('Laporan Penjualan Widget Tests', () {
    
    // Test: Halaman laporan memiliki title
    testWidgets('Halaman laporan harus menampilkan "Laporan Penjualan"', 
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LaporanPenjualan(
            userName: 'Admin',
            userEmail: 'admin@butik.com',
          ),
        ),
      );
      
      // TUNGGU 2 DETIK
      await tester.pump(const Duration(seconds: 2));
      
      // Cari teks yang pasti ada (judul header)
      expect(find.text('Laporan Penjualan'), findsOneWidget);
    });

    // Test: Halaman laporan memiliki tombol menu
    testWidgets('Halaman laporan memiliki ikon menu', 
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LaporanPenjualan(
            userName: 'Admin',
            userEmail: 'admin@butik.com',
          ),
        ),
      );
      
      await tester.pump(const Duration(seconds: 1));
      
      expect(find.byIcon(Icons.menu), findsOneWidget);
    });
  });
}