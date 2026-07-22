import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/pembeli/produk_pembeli.dart';

void main() {
  group('Produk Pembeli Widget Tests', () {
    // Test: Widget ProdukPembeli ditampilkan
    testWidgets('Halaman produk pembeli harus ditampilkan', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ProdukPembeli(),
        ),
      );
      
      // Cek apakah ada text "Ani Butik Syar'i"
      expect(find.text('Ani Butik Syar\'i'), findsOneWidget);
      
      // Cek apakah ada text "Busana Muslim Pilihan"
      expect(find.text('Busana Muslim Pilihan'), findsOneWidget);
      
      // Cek apakah ada field pencarian
      expect(find.byType(TextField), findsOneWidget);
    });

    // Test: Filter kategori muncul
    testWidgets('Filter kategori harus muncul', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ProdukPembeli(),
        ),
      );
      
      // Cek apakah ada tombol filter (icon)
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    // Test: Bottom navigation produk
    testWidgets('Bottom navigation harus ada', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ProdukPembeli(),
        ),
      );
      
      // Cek apakah ada text "Produk" di bottom nav
      expect(find.text('Produk'), findsOneWidget);
      
      // Cek apakah ada text "Rekomendasi" di bottom nav
      expect(find.text('Rekomendasi'), findsOneWidget);
    });
  });
}